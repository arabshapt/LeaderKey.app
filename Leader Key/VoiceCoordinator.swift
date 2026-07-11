import AVFoundation
import AppKit
import Defaults
import Foundation
import KeyboardShortcuts

enum VoiceKeychain {
  static let groqAPIKeyAccount = "voice.groq"
  static let geminiAPIKeyAccount = "voice.gemini"

  static func cloudAPIKeyAccount(for provider: VoiceCloudPlannerProvider) -> String {
    provider.keychainAccount
  }
}

final class VoiceCoordinator {
  private struct VoiceDispatchCurrentAppContext: Encodable {
    let bundleId: String?
    let localizedName: String?
  }

  private struct VoiceDispatchRecentCommandContext: Encodable {
    let transcript: String
    let action_ids: [String]
    let labels: [String]
    let types: [String]
    let plan_reason: String
  }

  private struct VoiceDispatchContext: Encodable {
    let currentApp: VoiceDispatchCurrentAppContext?
    let recentCommands: [VoiceDispatchRecentCommandContext]
  }

  enum State: Equatable {
    case idle
    case recordingToggle
    case recordingHold
    case transcribing
    case planning
    case ready(String)
    case error(String)

    var displayName: String {
      switch self {
      case .idle:
        return "Idle"
      case .recordingToggle:
        return "Recording"
      case .recordingHold:
        return "Hold to talk"
      case .transcribing:
        return "Transcribing"
      case .planning:
        return "Planning"
      case .ready(let message):
        return message
      case .error(let message):
        return message
      }
    }

    var statusItemStatus: StatusItem.VoiceStatus {
      switch self {
      case .idle:
        return .idle
      case .recordingToggle, .recordingHold:
        return .recording
      case .transcribing, .planning:
        return .processing
      case .ready(let message):
        return .ready(message)
      case .error(let message):
        return .error(message)
      }
    }
  }

  private enum CaptureMode {
    case command
    case dictate
  }

  private let statusItem: StatusItem
  private let config: UserConfig
  private let audioCapture: VoiceAudioCapturing
  private let dispatchBridge = VoiceDispatchBridge()
  private let transcriber: SpeechTranscribing
  private let micAuthorizationStatus: () -> AVAuthorizationStatus
  private let requestMicAccess: (@escaping (Bool) -> Void) -> Void
  private var settingsObserver: NSObjectProtocol?
  private var recentSuccessfulCommands: [VoiceDispatchRecentCommandContext] = []
  private var captureMode: CaptureMode = .command
  private var isArmingRecording = false
  private var pendingKeyUpWhileArming = false
  private var processingTask: Task<Void, Never>?
  private var processingWatchdog: DispatchWorkItem?
  // Watchdog ceilings above the worst legitimate stage duration (URLSession
  // timeout is 30s; planning can chain transcribe retries + a confirmation dialog).
  var transcribingWatchdogTimeout: TimeInterval = 35
  var planningWatchdogTimeout: TimeInterval = 90
  private(set) var state: State = .idle {
    didSet {
      statusItem.voiceStatus = state.statusItemStatus
      debugLog("[VoiceCoordinator] State: \(state.displayName)")
      updateProcessingWatchdog()
    }
  }

  init(
    statusItem: StatusItem,
    config: UserConfig,
    audioCapture: VoiceAudioCapturing = VoiceAudioCapture(),
    transcriber: SpeechTranscribing = OpenAICompatibleSpeechToTextClient(),
    micAuthorizationStatus: @escaping () -> AVAuthorizationStatus = {
      AVCaptureDevice.authorizationStatus(for: .audio)
    },
    requestMicAccess: @escaping (@escaping (Bool) -> Void) -> Void = { completion in
      AVCaptureDevice.requestAccess(for: .audio) { granted in
        DispatchQueue.main.async {
          completion(granted)
        }
      }
    }
  ) {
    self.statusItem = statusItem
    self.config = config
    self.audioCapture = audioCapture
    self.transcriber = transcriber
    self.micAuthorizationStatus = micAuthorizationStatus
    self.requestMicAccess = requestMicAccess

    audioCapture.onRecordingInterrupted = { [weak self] in
      guard let self else { return }
      switch self.state {
      case .recordingHold, .recordingToggle:
        debugLog("[VoiceCoordinator] Recording interrupted by audio device change")
        self.state = .error("Audio device changed")
      default:
        break
      }
    }
  }

  func start() {
    updateAudioWarmState()
    settingsObserver = NotificationCenter.default.addObserver(
      forName: .voiceSettingsDidChange,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.updateAudioWarmState()
    }

    KeyboardShortcuts.onKeyDown(for: .voiceToggleRecord) { [weak self] in
      DispatchQueue.main.async {
        self?.handleToggleKeyDown()
      }
    }

    KeyboardShortcuts.onKeyDown(for: .voiceHoldToTalk) { [weak self] in
      DispatchQueue.main.async {
        self?.handleHoldKeyDown()
      }
    }

    KeyboardShortcuts.onKeyUp(for: .voiceHoldToTalk) { [weak self] in
      DispatchQueue.main.async {
        self?.handleHoldKeyUp()
      }
    }

    KeyboardShortcuts.onKeyDown(for: .voiceDictateToggle) { [weak self] in
      DispatchQueue.main.async {
        self?.handleDictateToggleKeyDown()
      }
    }

    KeyboardShortcuts.onKeyDown(for: .voiceDictateHold) { [weak self] in
      DispatchQueue.main.async {
        self?.handleDictateHoldKeyDown()
      }
    }

    KeyboardShortcuts.onKeyUp(for: .voiceDictateHold) { [weak self] in
      DispatchQueue.main.async {
        self?.handleDictateHoldKeyUp()
      }
    }
  }

  func stop() {
    if let settingsObserver {
      NotificationCenter.default.removeObserver(settingsObserver)
      self.settingsObserver = nil
    }
    processingTask?.cancel()
    processingTask = nil
    audioCapture.stopCompletely()
    audioCapture.cleanupTempFiles()
    state = .idle
  }

  /// Arms a one-shot timeout whenever the coordinator enters a processing
  /// state, so a hung transcription/planning request can never wedge the
  /// state machine (new recordings are blocked while transcribing/planning).
  private func updateProcessingWatchdog() {
    processingWatchdog?.cancel()
    processingWatchdog = nil

    let timeout: TimeInterval
    switch state {
    case .transcribing:
      timeout = transcribingWatchdogTimeout
    case .planning:
      timeout = planningWatchdogTimeout
    default:
      return
    }

    let item = DispatchWorkItem { [weak self] in
      guard let self else { return }
      guard self.state == .transcribing || self.state == .planning else { return }
      debugLog(
        "[VoiceCoordinator] Watchdog fired in state \(self.state.displayName); cancelling voice processing"
      )
      self.processingTask?.cancel()
      self.processingTask = nil
      self.state = .error("Voice timed out")
    }
    processingWatchdog = item
    DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: item)
  }

  func handleToggleKeyDown() {
    guard voiceEnabled else {
      state = .idle
      return
    }

    switch state {
    case .recordingToggle:
      finishRecording(trigger: "toggle")
    case .idle, .ready, .error:
      captureMode = .command
      beginRecording(mode: .recordingToggle)
    case .recordingHold, .transcribing, .planning:
      break
    }
  }

  func handleHoldKeyDown() {
    guard voiceEnabled else {
      state = .idle
      return
    }

    switch state {
    case .idle, .ready, .error:
      captureMode = .command
      beginRecording(mode: .recordingHold)
    case .recordingToggle, .recordingHold, .transcribing, .planning:
      break
    }
  }

  func handleHoldKeyUp() {
    guard voiceEnabled else {
      state = .idle
      return
    }

    if isArmingRecording {
      pendingKeyUpWhileArming = true
      return
    }

    if state == .recordingHold {
      finishRecordingWithTrailingCapture(trigger: "hold", expectedMode: .command)
    }
  }

  func handleDictateToggleKeyDown() {
    guard voiceEnabled else {
      state = .idle
      return
    }

    switch state {
    case .recordingToggle where captureMode == .dictate:
      finishRecording(trigger: "dictate")
    case .idle, .ready, .error:
      captureMode = .dictate
      beginRecording(mode: .recordingToggle)
    case .recordingToggle, .recordingHold, .transcribing, .planning:
      break
    }
  }

  func handleDictateHoldKeyDown() {
    guard voiceEnabled else {
      state = .idle
      return
    }

    switch state {
    case .idle, .ready, .error:
      captureMode = .dictate
      beginRecording(mode: .recordingHold)
    case .recordingToggle, .recordingHold, .transcribing, .planning:
      break
    }
  }

  func handleDictateHoldKeyUp() {
    guard voiceEnabled else {
      state = .idle
      return
    }

    if isArmingRecording {
      pendingKeyUpWhileArming = true
      return
    }

    if state == .recordingHold, captureMode == .dictate {
      finishRecordingWithTrailingCapture(trigger: "dictate-hold", expectedMode: .dictate)
    }
  }

  private func finishRecordingWithTrailingCapture(trigger: String, expectedMode: CaptureMode) {
    let trailingDuration: TimeInterval = 0.3
    DispatchQueue.main.asyncAfter(deadline: .now() + trailingDuration) { [weak self] in
      guard let self else { return }
      guard self.state == .recordingHold, self.captureMode == expectedMode else { return }
      self.finishRecording(trigger: trigger)
    }
  }

  private func beginRecording(mode: State) {
    processingTask?.cancel()
    processingTask = nil
    isArmingRecording = true
    pendingKeyUpWhileArming = false

    ensureMicrophoneAccess { [weak self] granted in
      guard let self else { return }

      self.isArmingRecording = false
      let keyUpArrivedWhileArming = self.pendingKeyUpWhileArming
      self.pendingKeyUpWhileArming = false

      if granted {
        self.updateAudioWarmState()
        do {
          try self.audioCapture.startRecording()
          self.state = mode
          if keyUpArrivedWhileArming, mode == .recordingHold {
            // The hold key was released while the permission prompt was still
            // pending — finish immediately so recording can never get stuck.
            self.finishRecording(trigger: "hold-armed-late")
          }
        } catch {
          self.state = .error("Recording failed")
          debugLog("[VoiceCoordinator] Failed to start recording: \(error)")
        }
      } else {
        self.state = .error("Microphone blocked")
      }
    }
  }

  private func finishRecording(trigger: String) {
    let result = audioCapture.stopRecording()
    let mode = captureMode

    state = .transcribing

    guard let result else {
      state = .ready("No audio captured")
      returnToIdleAfterReady()
      return
    }

    let fileBytes =
      (try? FileManager.default.attributesOfItem(atPath: result.url.path)[.size] as? Int) ?? 0
    let rmsDB = VoiceAudioCapture.overallRMSDb(url: result.url)
    debugLog(
      "[VoiceCoordinator] \(trigger) recording captured \(String(format: "%.2f", result.duration))s, preRollFrames=\(result.preRollFrameCount), bytes=\(fileBytes), rms=\(String(format: "%.1f", rmsDB))dB, url=\(result.url.path)"
    )

    if mode == .command {
      VoiceAudioCapture.trimTrailingSilence(url: result.url)
    }

    let prompt = mode == .dictate ? nil : transcriptionPrompt()
    let targetBundleId = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
    let dispatchOptions = voiceDispatchOptions(bundleId: targetBundleId)

    processingTask = Task { [weak self] in
      guard let self else { return }

      do {
        var transcript = try await self.transcribe(result: result, prompt: prompt)

        await MainActor.run {
          debugLog(
            "[VoiceCoordinator] STT transcript provider=\(Defaults[.voiceSTTProvider].rawValue) model=\(transcript.model) requestID=\(transcript.requestID ?? "n/a") text=\"\(transcript.text)\""
          )
        }

        if mode == .dictate {
          await MainActor.run {
            self.handleDictationTranscript(transcript.text)
          }
          return
        }

        await MainActor.run {
          self.state = .planning
        }

        do {
          var dispatch = try await self.dispatchBridge.dispatch(
            transcript: transcript.text,
            bundleId: targetBundleId,
            options: dispatchOptions
          )

          await MainActor.run {
            debugLog("[VoiceCoordinator] Dispatch \(dispatch.debugSummary)")
          }

          if self.shouldRetryTranscription(transcript: transcript, dispatch: dispatch) {
            do {
              await MainActor.run {
                debugLog("[VoiceCoordinator] Retrying STT with \(VoiceSTTModel.whisperLargeV3.rawValue)")
              }
              let retriedTranscript = try await self.transcribe(
                result: result,
                prompt: prompt,
                modelOverride: .whisperLargeV3
              )
              let retriedDispatch = try await self.dispatchBridge.dispatch(
                transcript: retriedTranscript.text,
                bundleId: targetBundleId,
                options: dispatchOptions
              )

              await MainActor.run {
                debugLog(
                  "[VoiceCoordinator] STT retry transcript model=\(retriedTranscript.model) requestID=\(retriedTranscript.requestID ?? "n/a") text=\"\(retriedTranscript.text)\""
                )
                debugLog("[VoiceCoordinator] Retry dispatch \(retriedDispatch.debugSummary)")
              }

              if retriedDispatch.isBetterForVoiceThan(dispatch) {
                transcript = retriedTranscript
                dispatch = retriedDispatch
                await MainActor.run {
                  debugLog("[VoiceCoordinator] Using retry transcript for dispatch")
                }
              }
            } catch {
              await MainActor.run {
                debugLog("[VoiceCoordinator] STT accuracy retry failed: \(error)")
              }
            }
          }

          let shouldOfferConfirmation =
            dispatchOptions.execute
            && dispatch.execution.needsConfirmation
            && !dispatch.execution.blocked

          if shouldOfferConfirmation {
            let confirmed = await MainActor.run {
              self.confirmDestructiveDispatch(dispatch)
            }
            if confirmed {
              do {
                let confirmedDispatch = try await self.dispatchBridge.dispatch(
                  transcript: transcript.text,
                  bundleId: targetBundleId,
                  options: dispatchOptions.withAllowDestructive(true)
                )
                await MainActor.run {
                  self.rememberSuccessfulCommand(transcript: transcript.text, dispatch: confirmedDispatch)
                  self.state = .ready(confirmedDispatch.displayMessage)
                  self.returnToIdleAfterReady(multiStep: confirmedDispatch.isMultiStep)
                  debugLog(
                    "[VoiceCoordinator] Dispatch confirmed \(confirmedDispatch.debugSummary)")
                }
              } catch {
                await MainActor.run {
                  self.state = .error("Dispatch failed")
                  debugLog("[VoiceCoordinator] Confirmed dispatch failed: \(error)")
                }
              }
            } else {
              await MainActor.run {
                self.state = .ready("Voice cancelled")
                self.returnToIdleAfterReady()
                debugLog("[VoiceCoordinator] Confirmation cancelled")
              }
            }
          } else {
            await MainActor.run {
              if let plannerError = dispatch.plan.plannerError,
                Defaults[.voiceNotifyTierUnavailable]
              {
                debugLog(
                  "[VoiceCoordinator] Planner fallback: \(plannerError)")
              }
              self.rememberSuccessfulCommand(transcript: transcript.text, dispatch: dispatch)
              self.state = .ready(dispatch.displayMessage)
              self.returnToIdleAfterReady(multiStep: dispatch.isMultiStep)
            }
          }
        } catch {
          if Task.isCancelled { return }
          await MainActor.run {
            self.state = .error("Dispatch failed")
            debugLog("[VoiceCoordinator] Dispatch failed: \(error)")
          }
        }
      } catch VoiceTranscriptionError.emptyTranscript {
        await MainActor.run {
          self.state = .ready("No speech detected")
          self.returnToIdleAfterReady()
        }
      } catch VoiceTranscriptionError.missingAPIKey {
        await MainActor.run {
          self.state = .error("Groq key missing")
          debugLog("[VoiceCoordinator] STT transcription skipped: API key missing")
        }
      } catch {
        // A cancelled request (watchdog or superseding recording) already
        // handled its own state transition — don't overwrite it.
        if Task.isCancelled || error is CancellationError
          || (error as? URLError)?.code == .cancelled
        {
          debugLog("[VoiceCoordinator] Voice processing cancelled")
          return
        }
        await MainActor.run {
          self.state = .error("Transcription failed")
          debugLog("[VoiceCoordinator] STT transcription failed: \(error)")
        }
      }
    }
  }

  private func transcribe(
    result: VoiceAudioCapture.CaptureResult,
    prompt: String?,
    modelOverride: VoiceSTTModel? = nil
  ) async throws -> VoiceTranscriptionResult {
    switch Defaults[.voiceSTTProvider] {
    case .groq:
      guard let apiKey = KeychainHelper.load(account: VoiceKeychain.groqAPIKeyAccount) else {
        throw VoiceTranscriptionError.missingAPIKey
      }
      return try await transcriber.transcribe(
        audioURL: result.url,
        model: (modelOverride ?? Defaults[.voiceSTTModel]).rawValue,
        baseURL: "https://api.groq.com/openai",
        bearerToken: apiKey,
        prompt: prompt
      )
    case .parakeet:
      return try await transcriber.transcribe(
        audioURL: result.url,
        model: Defaults[.voiceParakeetModel],
        baseURL: Defaults[.voiceParakeetBaseURL],
        bearerToken: nil,
        prompt: prompt
      )
    }
  }

  private func shouldRetryTranscription(
    transcript: VoiceTranscriptionResult,
    dispatch: VoiceDispatchResult
  ) -> Bool {
    guard Defaults[.voiceSTTProvider] == .groq else {
      return false
    }
    guard transcript.model == VoiceSTTModel.whisperLargeV3Turbo.rawValue else {
      return false
    }
    return transcript.suggestsAccuracyRetry || dispatch.needsTranscriptionRetry
  }

  private func voiceDispatchOptions(bundleId: String?) -> VoiceDispatchOptions {
    let plannerMode = Defaults[.voicePlannerMode]
    let cloudProvider = Defaults[.voiceCloudPlannerProvider]
    let model: String
    switch plannerMode {
    case .tieredGroq, .groqOnly:
      model = Defaults[.voiceGroqPlannerModel]
    case .tieredGemini, .geminiOnly:
      model = Defaults[.voiceGeminiPlannerModel]
    case .tieredCloud, .cloudOnly:
      model = Defaults[.voiceCloudPlannerModel]
    case .fastOnly, .tiered, .tieredOllama:
      model = Defaults[.voiceTier2Model]
    }
    let cloudAPIKey =
      KeychainHelper.load(account: VoiceKeychain.cloudAPIKeyAccount(for: cloudProvider)) ?? ""
    let dispatchMode = Defaults[.voiceDispatchMode]
    return VoiceDispatchOptions(
      configDirectory: Defaults[.configDir],
      execute: dispatchMode.executesActions,
      allowDestructive: dispatchMode.allowsDestructiveActions,
      plannerMode: plannerMode,
      cloudPlannerProvider: cloudProvider,
      llamaURL: Defaults[.voiceLlamaServerURL],
      model: model,
      groqApiKey: KeychainHelper.load(account: VoiceKeychain.groqAPIKeyAccount) ?? "",
      geminiApiKey: KeychainHelper.load(account: VoiceKeychain.geminiAPIKeyAccount) ?? "",
      cloudPlannerApiKey: cloudAPIKey,
      cloudPlannerBaseURL: Defaults[.voiceCloudPlannerBaseURL],
      contextJSON: voiceDispatchContextJSON(bundleId: bundleId)
    )
  }

  private func voiceDispatchContextJSON(bundleId: String?) -> String? {
    let currentApp = NSWorkspace.shared.frontmostApplication
    let context = VoiceDispatchContext(
      currentApp: VoiceDispatchCurrentAppContext(
        bundleId: bundleId,
        localizedName: currentApp?.localizedName
      ),
      recentCommands: recentSuccessfulCommands
    )

    guard let data = try? JSONEncoder().encode(context) else {
      return nil
    }
    return String(data: data, encoding: .utf8)
  }

  private func rememberSuccessfulCommand(
    transcript: String,
    dispatch: VoiceDispatchResult
  ) {
    guard dispatch.validation.valid,
      !dispatch.execution.blocked,
      !dispatch.execution.steps.isEmpty
    else {
      return
    }

    recentSuccessfulCommands.append(
      VoiceDispatchRecentCommandContext(
        transcript: transcript,
        action_ids: dispatch.execution.steps.map(\.actionID),
        labels: dispatch.execution.steps.map(\.label),
        types: dispatch.execution.steps.map(\.type),
        plan_reason: dispatch.plan.reason
      )
    )

    if recentSuccessfulCommands.count > 6 {
      recentSuccessfulCommands.removeFirst(recentSuccessfulCommands.count - 6)
    }
  }

  @MainActor
  private func confirmDestructiveDispatch(_ dispatch: VoiceDispatchResult) -> Bool {
    let previousApp = NSWorkspace.shared.frontmostApplication

    NSApp.activate(ignoringOtherApps: true)
    let alert = NSAlert()
    alert.alertStyle = .warning
    alert.messageText = "Run voice command?"
    alert.informativeText = Self.confirmationBody(for: dispatch)
    alert.addButton(withTitle: "Run")
    alert.addButton(withTitle: "Cancel")
    if let cancelButton = alert.buttons.last {
      cancelButton.keyEquivalent = "\u{1b}"
    }

    let timeoutSeconds: TimeInterval = 10
    var timedOut = false
    let timer = DispatchSource.makeTimerSource(queue: .main)
    timer.schedule(deadline: .now() + timeoutSeconds)
    timer.setEventHandler {
      timedOut = true
      NSApp.abortModal()
    }
    timer.resume()

    let response = alert.runModal()
    timer.cancel()

    if let previousApp, previousApp.bundleIdentifier != Bundle.main.bundleIdentifier {
      previousApp.activate()
    }

    return !timedOut && response == .alertFirstButtonReturn
  }

  private static func confirmationBody(for dispatch: VoiceDispatchResult) -> String {
    let labels = dispatch.execution.steps.map { step -> String in
      if step.label.isEmpty {
        return step.actionID
      }
      if let reason = step.reason, !reason.isEmpty {
        return "\(step.label) (\(reason))"
      }
      return step.label
    }
    let chain =
      labels.isEmpty
      ? "(no actions)"
      : labels.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
    return "\(dispatch.validation.reason)\n\n\(chain)"
  }

  private func ensureMicrophoneAccess(_ completion: @escaping (Bool) -> Void) {
    switch micAuthorizationStatus() {
    case .authorized:
      completion(true)
    case .notDetermined:
      requestMicAccess(completion)
    case .denied, .restricted:
      completion(false)
    @unknown default:
      completion(false)
    }
  }

  private var voiceEnabled: Bool {
    Defaults[.voiceDispatcherEnabled]
  }

  private func transcriptionPrompt() -> String? {
    let bundleId = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
    let prompt = VoicePromptBuilder.build(config: config, bundleId: bundleId)
    if let prompt {
      debugLog("[VoiceCoordinator] STT prompt primed with \(prompt.utf8.count) chars")
    } else {
      debugLog("[VoiceCoordinator] STT prompt disabled")
    }
    return prompt
  }

  private func updateAudioWarmState() {
    let shouldPrewarm =
      Defaults[.voiceDispatcherEnabled]
      && Defaults[.voicePrewarmMicrophone]
      && micAuthorizationStatus() == .authorized

    audioCapture.setPrewarmingEnabled(shouldPrewarm)

    if !Defaults[.voiceDispatcherEnabled] {
      audioCapture.stopCompletely()
      state = .idle
    }
  }

  @MainActor
  private func handleDictationTranscript(_ transcript: String) {
    let trimmed = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      state = .ready("No speech detected")
      returnToIdleAfterReady()
      return
    }

    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(trimmed, forType: .string)

    Self.simulatePaste()

    debugLog("[VoiceCoordinator] Dictation transcript pasted (\(trimmed.utf8.count) bytes)")
    state = .ready(Self.readyMessage(for: trimmed))
    returnToIdleAfterReady()
  }

  private static func simulatePaste() {
    guard let source = CGEventSource(stateID: .hidSystemState) else {
      debugLog("[VoiceCoordinator] Dictation paste skipped: failed to create CGEventSource")
      return
    }
    let tap = CGEventTapLocation.cghidEventTap
    let vKey: CGKeyCode = 0x09
    if let down = CGEvent(keyboardEventSource: source, virtualKey: vKey, keyDown: true) {
      down.flags = .maskCommand
      down.post(tap: tap)
    }
    if let up = CGEvent(keyboardEventSource: source, virtualKey: vKey, keyDown: false) {
      up.flags = .maskCommand
      up.post(tap: tap)
    }
  }

  private func returnToIdleAfterReady(multiStep: Bool = false) {
    let delay: TimeInterval = multiStep ? 3.0 : 1.5
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
      guard let self, case .ready = self.state else { return }
      self.state = .idle
    }
  }

  private static func readyMessage(for transcript: String) -> String {
    let trimmed = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.count <= 28 {
      return trimmed.isEmpty ? "No speech detected" : trimmed
    }
    let endIndex = trimmed.index(trimmed.startIndex, offsetBy: 28)
    return "\(trimmed[..<endIndex])..."
  }
}

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

  private let statusItem: StatusItem
  private let config: UserConfig
  private let audioCapture = VoiceAudioCapture()
  private let dispatchBridge = VoiceDispatchBridge()
  private let transcriber = GroqSpeechToTextClient()
  private var settingsObserver: NSObjectProtocol?
  private var recentSuccessfulCommands: [VoiceDispatchRecentCommandContext] = []
  private var state: State = .idle {
    didSet {
      statusItem.voiceStatus = state.statusItemStatus
      debugLog("[VoiceCoordinator] State: \(state.displayName)")
    }
  }

  init(statusItem: StatusItem, config: UserConfig) {
    self.statusItem = statusItem
    self.config = config
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
  }

  func stop() {
    if let settingsObserver {
      NotificationCenter.default.removeObserver(settingsObserver)
      self.settingsObserver = nil
    }
    audioCapture.stopCompletely()
    audioCapture.cleanupTempFiles()
    state = .idle
  }

  private func handleToggleKeyDown() {
    guard voiceEnabled else {
      state = .idle
      return
    }

    switch state {
    case .recordingToggle:
      finishRecording(trigger: "toggle")
    case .idle, .ready, .error:
      beginRecording(mode: .recordingToggle)
    case .recordingHold, .transcribing, .planning:
      break
    }
  }

  private func handleHoldKeyDown() {
    guard voiceEnabled else {
      state = .idle
      return
    }

    switch state {
    case .idle, .ready, .error:
      beginRecording(mode: .recordingHold)
    case .recordingToggle, .recordingHold, .transcribing, .planning:
      break
    }
  }

  private func handleHoldKeyUp() {
    guard voiceEnabled else {
      state = .idle
      return
    }

    if state == .recordingHold {
      finishRecording(trigger: "hold")
    }
  }

  private func beginRecording(mode: State) {
    ensureMicrophoneAccess { [weak self] granted in
      guard let self else { return }

      if granted {
        self.updateAudioWarmState()
        do {
          try self.audioCapture.startRecording()
          self.state = mode
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

    state = .transcribing

    guard let result else {
      state = .ready("No audio captured")
      returnToIdleAfterReady()
      return
    }

    debugLog(
      "[VoiceCoordinator] \(trigger) recording captured \(String(format: "%.2f", result.duration))s, preRollFrames=\(result.preRollFrameCount), url=\(result.url.path)"
    )

    VoiceAudioCapture.trimTrailingSilence(url: result.url)

    let prompt = transcriptionPrompt()
    let targetBundleId = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
    let dispatchOptions = voiceDispatchOptions(bundleId: targetBundleId)

    Task { [weak self] in
      guard let self else { return }

      do {
        var transcript = try await self.transcribe(result: result, prompt: prompt)

        await MainActor.run {
          debugLog(
            "[VoiceCoordinator] Groq transcript model=\(transcript.model) requestID=\(transcript.requestID ?? "n/a") text=\"\(transcript.text)\""
          )
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
                debugLog("[VoiceCoordinator] Retrying Groq STT with \(VoiceSTTModel.whisperLargeV3.rawValue)")
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
                  "[VoiceCoordinator] Groq retry transcript model=\(retriedTranscript.model) requestID=\(retriedTranscript.requestID ?? "n/a") text=\"\(retriedTranscript.text)\""
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
                debugLog("[VoiceCoordinator] Groq accuracy retry failed: \(error)")
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
          debugLog("[VoiceCoordinator] Groq transcription skipped: API key missing")
        }
      } catch {
        await MainActor.run {
          self.state = .error("Transcription failed")
          debugLog("[VoiceCoordinator] Groq transcription failed: \(error)")
        }
      }
    }
  }

  private func transcribe(
    result: VoiceAudioCapture.CaptureResult,
    prompt: String?,
    modelOverride: VoiceSTTModel? = nil
  ) async throws -> VoiceTranscriptionResult {
    guard let apiKey = KeychainHelper.load(account: VoiceKeychain.groqAPIKeyAccount) else {
      throw VoiceTranscriptionError.missingAPIKey
    }

    return try await transcriber.transcribe(
      audioURL: result.url,
      model: modelOverride ?? Defaults[.voiceSTTModel],
      apiKey: apiKey,
      prompt: prompt
    )
  }

  private func shouldRetryTranscription(
    transcript: VoiceTranscriptionResult,
    dispatch: VoiceDispatchResult
  ) -> Bool {
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
    return VoiceDispatchOptions(
      configDirectory: Defaults[.configDir],
      execute: Defaults[.voiceDispatchMode] == .execute,
      allowDestructive: false,
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
    switch AVCaptureDevice.authorizationStatus(for: .audio) {
    case .authorized:
      completion(true)
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .audio) { granted in
        DispatchQueue.main.async {
          completion(granted)
        }
      }
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
      debugLog("[VoiceCoordinator] Groq prompt primed with \(prompt.utf8.count) chars")
    } else {
      debugLog("[VoiceCoordinator] Groq prompt disabled")
    }
    return prompt
  }

  private func updateAudioWarmState() {
    let shouldPrewarm =
      Defaults[.voiceDispatcherEnabled]
      && Defaults[.voicePrewarmMicrophone]
      && AVCaptureDevice.authorizationStatus(for: .audio) == .authorized

    audioCapture.setPrewarmingEnabled(shouldPrewarm)

    if !Defaults[.voiceDispatcherEnabled] {
      audioCapture.stopCompletely()
      state = .idle
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

import AVFoundation
import AppKit
import Defaults
import Foundation
import KeyboardShortcuts

enum VoiceKeychain {
  static let groqAPIKeyAccount = "voice.groq"
}

final class VoiceCoordinator {
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
  private let transcriber = GroqSpeechToTextClient()
  private var settingsObserver: NSObjectProtocol?
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

    let prompt = transcriptionPrompt()

    Task { [weak self] in
      guard let self else { return }

      do {
        let transcript = try await self.transcribe(result: result, prompt: prompt)

        await MainActor.run {
          self.state = .ready(Self.readyMessage(for: transcript.text))
          self.returnToIdleAfterReady()
          debugLog(
            "[VoiceCoordinator] Groq transcript model=\(transcript.model) requestID=\(transcript.requestID ?? "n/a") text=\"\(transcript.text)\""
          )
          debugLog("[VoiceCoordinator] Transcript-to-dispatch bridge is the next slice.")
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
    prompt: String?
  ) async throws -> VoiceTranscriptionResult {
    guard let apiKey = KeychainHelper.load(account: VoiceKeychain.groqAPIKeyAccount) else {
      throw VoiceTranscriptionError.missingAPIKey
    }

    return try await transcriber.transcribe(
      audioURL: result.url,
      model: Defaults[.voiceSTTModel],
      apiKey: apiKey,
      prompt: prompt
    )
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

  private func returnToIdleAfterReady() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
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

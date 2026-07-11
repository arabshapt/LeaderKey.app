import AVFoundation
import Defaults
import XCTest

@testable import Leader_Key

final class MockVoiceAudioCapture: VoiceAudioCapturing {
  var isRecording = false
  var onRecordingInterrupted: (() -> Void)?
  var startRecordingCallCount = 0
  var stopRecordingCallCount = 0
  var startRecordingError: Error?
  var captureResult: VoiceAudioCapture.CaptureResult?

  func setPrewarmingEnabled(_ enabled: Bool) {}

  func startRecording() throws {
    if let startRecordingError {
      throw startRecordingError
    }
    startRecordingCallCount += 1
    isRecording = true
  }

  func stopRecording() -> VoiceAudioCapture.CaptureResult? {
    stopRecordingCallCount += 1
    isRecording = false
    return captureResult
  }

  func writeSessionSnapshot() -> URL? { nil }

  func stopCompletely() {
    isRecording = false
  }

  func cleanupTempFiles() {}
}

final class MockSpeechTranscriber: SpeechTranscribing {
  var transcribeCallCount = 0
  var hangForever = false
  var resultProvider: () throws -> VoiceTranscriptionResult = {
    throw VoiceTranscriptionError.emptyTranscript
  }

  func transcribe(
    audioURL: URL,
    model: String,
    baseURL: String,
    bearerToken: String?,
    prompt: String?
  ) async throws -> VoiceTranscriptionResult {
    transcribeCallCount += 1
    if hangForever {
      // Task.sleep is cancellation-aware, mimicking a hung URLSession request
      try await Task.sleep(nanoseconds: 60_000_000_000)
    }
    return try resultProvider()
  }
}

final class VoiceCoordinatorTests: XCTestCase {
  var originalSuite: UserDefaults!
  var statusItem: StatusItem!
  var userConfig: UserConfig!
  var audioCapture: MockVoiceAudioCapture!
  var transcriber: MockSpeechTranscriber!
  var tempConfigDir: String!

  override func setUpWithError() throws {
    originalSuite = defaultsSuite
    defaultsSuite = UserDefaults(suiteName: UUID().uuidString)!

    tempConfigDir = NSTemporaryDirectory().appending("/LeaderKeyVoiceTests-\(UUID().uuidString)")
    try FileManager.default.createDirectory(atPath: tempConfigDir, withIntermediateDirectories: true)
    Defaults[.configDir] = tempConfigDir

    Defaults[.voiceDispatcherEnabled] = true
    Defaults[.voicePrewarmMicrophone] = false
    Defaults[.voiceSTTProvider] = .parakeet

    statusItem = StatusItem()
    userConfig = UserConfig()
    audioCapture = MockVoiceAudioCapture()
    transcriber = MockSpeechTranscriber()
    audioCapture.captureResult = VoiceAudioCapture.CaptureResult(
      url: FileManager.default.temporaryDirectory
        .appendingPathComponent("leaderkey-voice-test-\(UUID().uuidString).wav"),
      duration: 1.0,
      sampleRate: 16000,
      frameCount: 16000,
      preRollFrameCount: 0
    )
  }

  override func tearDownWithError() throws {
    try? FileManager.default.removeItem(atPath: tempConfigDir)
    defaultsSuite = originalSuite
  }

  private func makeCoordinator(
    authorization: @escaping () -> AVAuthorizationStatus = { .authorized },
    requestMicAccess: @escaping (@escaping (Bool) -> Void) -> Void = { $0(true) }
  ) -> VoiceCoordinator {
    VoiceCoordinator(
      statusItem: statusItem,
      config: userConfig,
      audioCapture: audioCapture,
      transcriber: transcriber,
      micAuthorizationStatus: authorization,
      requestMicAccess: requestMicAccess
    )
  }

  /// Pump the main run loop until the predicate is true or the timeout elapses.
  private func waitUntil(
    _ description: String,
    timeout: TimeInterval = 3,
    _ predicate: () -> Bool
  ) -> Bool {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
      if predicate() { return true }
      RunLoop.current.run(until: Date().addingTimeInterval(0.02))
    }
    return predicate()
  }

  func testDictateHoldHappyPathStartsAndFinishesRecording() {
    let coordinator = makeCoordinator()

    coordinator.handleDictateHoldKeyDown()
    XCTAssertEqual(coordinator.state, .recordingHold)
    XCTAssertEqual(audioCapture.startRecordingCallCount, 1)

    coordinator.handleDictateHoldKeyUp()
    // Mock transcriber throws emptyTranscript, so the pipeline ends in "No speech detected"
    XCTAssertTrue(
      waitUntil("recording finished") {
        self.audioCapture.stopRecordingCallCount == 1 && coordinator.state != .recordingHold
          && coordinator.state != .transcribing
      },
      "hold release should stop recording and settle state, got \(coordinator.state)"
    )
    XCTAssertEqual(transcriber.transcribeCallCount, 1)
  }

  func testDictateToggleStartsAndStops() {
    let coordinator = makeCoordinator()

    coordinator.handleDictateToggleKeyDown()
    XCTAssertEqual(coordinator.state, .recordingToggle)
    XCTAssertEqual(audioCapture.startRecordingCallCount, 1)

    coordinator.handleDictateToggleKeyDown()
    XCTAssertEqual(audioCapture.stopRecordingCallCount, 1)
    XCTAssertTrue(
      waitUntil("toggle finished") {
        coordinator.state != .recordingToggle && coordinator.state != .transcribing
      },
      "second toggle press should finish recording, got \(coordinator.state)"
    )
  }

  func testCommandHoldHappyPathStopsRecording() {
    let coordinator = makeCoordinator()

    coordinator.handleHoldKeyDown()
    XCTAssertEqual(coordinator.state, .recordingHold)

    coordinator.handleHoldKeyUp()
    XCTAssertTrue(
      waitUntil("command hold finished") { self.audioCapture.stopRecordingCallCount == 1 },
      "hold release should stop recording"
    )
  }

  func testDisabledVoiceIgnoresKeyDown() {
    Defaults[.voiceDispatcherEnabled] = false
    let coordinator = makeCoordinator()

    coordinator.handleDictateHoldKeyDown()
    XCTAssertEqual(coordinator.state, .idle)
    XCTAssertEqual(audioCapture.startRecordingCallCount, 0)
  }

  /// Repro for the stuck-recording race: the hold key is released while the
  /// microphone-permission completion is still pending. The key-up must not be
  /// dropped — recording has to stop once permission resolves.
  func testKeyUpDuringPermissionArmingStillStopsRecording() {
    var pendingCompletion: ((Bool) -> Void)?
    let coordinator = makeCoordinator(
      authorization: { .notDetermined },
      requestMicAccess: { completion in pendingCompletion = completion }
    )

    coordinator.handleDictateHoldKeyDown()
    // Permission prompt is "showing": recording hasn't started yet.
    XCTAssertEqual(coordinator.state, .idle)

    // Quick tap: user releases before granting permission.
    coordinator.handleDictateHoldKeyUp()

    // Permission granted after the key-up.
    pendingCompletion?(true)

    let settled = waitUntil("recording settled after late permission grant", timeout: 2) {
      coordinator.state != .recordingHold
    }
    XCTAssertTrue(
      settled,
      "recording should not stay stuck in recordingHold after key-up + late permission grant"
    )
    XCTAssertEqual(audioCapture.stopRecordingCallCount, 1, "late grant should finish immediately")
  }

  func testWatchdogRecoversFromHungTranscription() {
    transcriber.hangForever = true
    let coordinator = makeCoordinator()
    coordinator.transcribingWatchdogTimeout = 0.2

    coordinator.handleDictateHoldKeyDown()
    coordinator.handleDictateHoldKeyUp()

    XCTAssertTrue(
      waitUntil("watchdog fired", timeout: 3) {
        coordinator.state == .error("Voice timed out")
      },
      "hung transcription should be cancelled by the watchdog, got \(coordinator.state)"
    )

    // The coordinator must accept a fresh recording after the watchdog fired.
    transcriber.hangForever = false
    coordinator.handleDictateHoldKeyDown()
    XCTAssertEqual(coordinator.state, .recordingHold)
  }

  func testStrippingTrailingPeriod() {
    XCTAssertEqual(VoiceCoordinator.strippingTrailingPeriod("open new tab."), "open new tab")
    XCTAssertEqual(VoiceCoordinator.strippingTrailingPeriod("open new tab"), "open new tab")
    // Multiple sentences keep their punctuation
    XCTAssertEqual(
      VoiceCoordinator.strippingTrailingPeriod("First. Second."), "First. Second.")
    // Ellipses are preserved
    XCTAssertEqual(VoiceCoordinator.strippingTrailingPeriod("wait..."), "wait...")
    XCTAssertEqual(VoiceCoordinator.strippingTrailingPeriod("."), "")
  }

  func testConvertTo16kMonoWAVData() throws {
    // Write a 0.25s 440Hz sine at 48kHz stereo float as the conversion input
    let sourceURL = FileManager.default.temporaryDirectory
      .appendingPathComponent("leaderkey-voice-convtest-\(UUID().uuidString).wav")
    defer { try? FileManager.default.removeItem(at: sourceURL) }

    // Scope the writer so the WAV header is finalized before conversion reads it
    try autoreleasepool {
      let sourceFormat = AVAudioFormat(
        commonFormat: .pcmFormatFloat32, sampleRate: 48000, channels: 2, interleaved: false)!
      let sourceFile = try AVAudioFile(forWriting: sourceURL, settings: sourceFormat.settings)
      let frameCount = AVAudioFrameCount(48000 * 0.25)
      let buffer = AVAudioPCMBuffer(pcmFormat: sourceFormat, frameCapacity: frameCount)!
      buffer.frameLength = frameCount
      for frame in 0..<Int(frameCount) {
        let sample = Float(sin(2.0 * Double.pi * 440.0 * Double(frame) / 48000.0)) * 0.5
        buffer.floatChannelData![0][frame] = sample
        buffer.floatChannelData![1][frame] = sample
      }
      try sourceFile.write(from: buffer)
    }

    let converted = try OpenAICompatibleSpeechToTextClient.convertTo16kMonoWAVData(
      audioURL: sourceURL)
    XCTAssertFalse(converted.isEmpty)

    // Round-trip: the converted bytes must parse as a 16kHz mono WAV of ~0.25s
    let convertedURL = FileManager.default.temporaryDirectory
      .appendingPathComponent("leaderkey-voice-convtest-out-\(UUID().uuidString).wav")
    defer { try? FileManager.default.removeItem(at: convertedURL) }
    try converted.write(to: convertedURL)

    let convertedFile = try AVAudioFile(forReading: convertedURL)
    XCTAssertEqual(convertedFile.fileFormat.sampleRate, 16000)
    XCTAssertEqual(convertedFile.fileFormat.channelCount, 1)
    let expectedFrames = Double(16000) * 0.25
    XCTAssertEqual(Double(convertedFile.length), expectedFrames, accuracy: expectedFrames * 0.1)
  }

  func testDeviceChangeInterruptionSurfacesErrorAndRecovers() {
    let coordinator = makeCoordinator()

    coordinator.handleDictateHoldKeyDown()
    XCTAssertEqual(coordinator.state, .recordingHold)

    // Simulate the audio device changing mid-recording.
    audioCapture.isRecording = false
    audioCapture.onRecordingInterrupted?()

    XCTAssertEqual(coordinator.state, .error("Audio device changed"))

    // A key-up in the error state must not crash or restart anything.
    coordinator.handleDictateHoldKeyUp()
    XCTAssertEqual(coordinator.state, .error("Audio device changed"))

    // The next key-down starts a fresh recording.
    coordinator.handleDictateHoldKeyDown()
    XCTAssertEqual(coordinator.state, .recordingHold)
  }
}

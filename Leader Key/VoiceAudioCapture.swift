import AVFoundation
import Foundation

extension Notification.Name {
  static let voiceSettingsDidChange = Notification.Name("VoiceSettingsDidChange")
}

/// Seam for VoiceCoordinator so tests can substitute a mock capture backend.
protocol VoiceAudioCapturing: AnyObject {
  var isRecording: Bool { get }
  func setPrewarmingEnabled(_ enabled: Bool)
  func startRecording() throws
  func stopRecording() -> VoiceAudioCapture.CaptureResult?
  func stopCompletely()
  func cleanupTempFiles()
}

final class VoiceAudioCapture: VoiceAudioCapturing {
  struct CaptureResult {
    let url: URL
    let duration: TimeInterval
    let sampleRate: Double
    let frameCount: AVAudioFramePosition
    let preRollFrameCount: AVAudioFramePosition
  }

  private struct StoredBuffer {
    let buffer: AVAudioPCMBuffer
    let frameCount: AVAudioFramePosition
  }

  private let engine = AVAudioEngine()
  private let queue = DispatchQueue(label: "com.leaderkey.voice-audio-capture")
  private let preRollDuration: TimeInterval = 0.75
  private let tapBufferSize: AVAudioFrameCount = 2048

  private var hasInstalledTap = false
  private var installedTapFormat: AVAudioFormat?
  private var prewarmingEnabled = false
  private var preRollBuffers: [StoredBuffer] = []
  private var preRollFrameCount: AVAudioFramePosition = 0
  private var activeFile: AVAudioFile?
  private var activeURL: URL?
  private var activeFrameCount: AVAudioFramePosition = 0
  private var activePreRollFrameCount: AVAudioFramePosition = 0
  private var lastCaptureURL: URL?
  private var configChangeObserver: NSObjectProtocol?

  init() {
    configChangeObserver = NotificationCenter.default.addObserver(
      forName: .AVAudioEngineConfigurationChange,
      object: engine,
      queue: nil
    ) { [weak self] _ in
      self?.handleEngineConfigurationChange()
    }
  }

  deinit {
    if let configChangeObserver {
      NotificationCenter.default.removeObserver(configChangeObserver)
    }
  }

  var isRecording: Bool {
    queue.sync {
      activeFile != nil
    }
  }

  func setPrewarmingEnabled(_ enabled: Bool) {
    queue.sync {
      prewarmingEnabled = enabled
      if enabled {
        do {
          try ensureEngineRunning()
        } catch {
          debugLog("[VoiceAudioCapture] Failed to prewarm audio engine: \(error)")
        }
      } else if activeFile == nil {
        teardownEngineLocked()
      }
    }
  }

  func startRecording() throws {
    try queue.sync {
      try ensureEngineRunning()
      if activeFile != nil { return }

      if let lastCaptureURL {
        try? FileManager.default.removeItem(at: lastCaptureURL)
        self.lastCaptureURL = nil
      }

      guard let format = installedTapFormat else {
        throw NSError(
          domain: "VoiceAudioCapture", code: -1,
          userInfo: [NSLocalizedDescriptionKey: "Audio tap format unavailable"])
      }
      let url = Self.makeCaptureURL()
      let file = try AVAudioFile(forWriting: url, settings: format.settings)

      activeFile = file
      activeURL = url
      activeFrameCount = 0
      activePreRollFrameCount = preRollFrameCount

      for stored in preRollBuffers {
        try file.write(from: stored.buffer)
        activeFrameCount += stored.frameCount
      }
      preRollBuffers.removeAll()
      preRollFrameCount = 0
    }
  }

  func stopRecording() -> CaptureResult? {
    queue.sync {
      guard let url = activeURL else { return nil }

      let sampleRate = installedTapFormat?.sampleRate
        ?? engine.inputNode.outputFormat(forBus: 0).sampleRate
      let frameCount = activeFrameCount
      let preRollFrames = activePreRollFrameCount

      activeFile = nil
      activeURL = nil
      activeFrameCount = 0
      activePreRollFrameCount = 0
      lastCaptureURL = url

      if !prewarmingEnabled {
        teardownEngineLocked()
      }

      return CaptureResult(
        url: url,
        duration: Double(frameCount) / sampleRate,
        sampleRate: sampleRate,
        frameCount: frameCount,
        preRollFrameCount: preRollFrames
      )
    }
  }

  func stopCompletely() {
    queue.sync {
      if let url = activeURL {
        try? FileManager.default.removeItem(at: url)
      }
      if let url = lastCaptureURL {
        try? FileManager.default.removeItem(at: url)
      }
      activeFile = nil
      activeURL = nil
      activeFrameCount = 0
      activePreRollFrameCount = 0
      preRollBuffers.removeAll()
      preRollFrameCount = 0
      lastCaptureURL = nil
      teardownEngineLocked()
    }
  }

  func cleanupTempFiles() {
    let fm = FileManager.default
    let tmpDir = fm.temporaryDirectory
    guard let contents = try? fm.contentsOfDirectory(
      at: tmpDir, includingPropertiesForKeys: nil)
    else { return }
    for url in contents where url.lastPathComponent.hasPrefix("leaderkey-voice-") {
      try? fm.removeItem(at: url)
    }
  }

  private func ensureEngineRunning() throws {
    let currentFormat = engine.inputNode.outputFormat(forBus: 0)

    if hasInstalledTap, !Self.formatsMatch(installedTapFormat, currentFormat) {
      debugLog(
        "[VoiceAudioCapture] Input format changed (tap=\(Self.describeFormat(installedTapFormat)) hw=\(Self.describeFormat(currentFormat))), rebuilding tap"
      )
      teardownEngineLocked()
    }

    if !hasInstalledTap {
      try installTapLocked()
    }

    if !engine.isRunning {
      do {
        try engine.start()
      } catch {
        debugLog("[VoiceAudioCapture] engine.start failed (\(error)); rebuilding tap and retrying")
        teardownEngineLocked()
        try installTapLocked()
        try engine.start()
      }
    }
  }

  private func installTapLocked() throws {
    let input = engine.inputNode
    engine.prepare()

    do {
      try LKExceptionCatcher.perform {
        input.installTap(onBus: 0, bufferSize: self.tapBufferSize, format: nil) {
          [weak self] buffer, _ in
          guard let self,
            let copied = Self.copyBuffer(buffer)
          else {
            return
          }
          self.queue.async {
            self.handleInputBuffer(copied)
          }
        }
      }
    } catch {
      debugLog("[VoiceAudioCapture] installTap raised NSException: \(error)")
      throw error
    }

    hasInstalledTap = true
    installedTapFormat = input.outputFormat(forBus: 0)
  }

  private func handleEngineConfigurationChange() {
    queue.async { [weak self] in
      guard let self else { return }
      debugLog("[VoiceAudioCapture] AVAudioEngine configuration changed")
      let hadActiveFile = self.activeFile != nil
      self.teardownEngineLocked()
      if hadActiveFile {
        debugLog("[VoiceAudioCapture] Active recording aborted by audio device change")
      }
    }
    queue.asyncAfter(deadline: .now() + 0.15) { [weak self] in
      guard let self else { return }
      guard self.prewarmingEnabled, self.activeFile == nil else { return }
      do {
        try self.ensureEngineRunning()
      } catch {
        debugLog("[VoiceAudioCapture] Failed to restart engine after config change: \(error)")
      }
    }
  }

  private static func formatsMatch(_ a: AVAudioFormat?, _ b: AVAudioFormat?) -> Bool {
    guard let a, let b else { return false }
    return a.sampleRate == b.sampleRate
      && a.channelCount == b.channelCount
      && a.commonFormat == b.commonFormat
  }

  private static func describeFormat(_ format: AVAudioFormat?) -> String {
    guard let format else { return "nil" }
    return "\(Int(format.sampleRate))Hz/\(format.channelCount)ch"
  }

  private func handleInputBuffer(_ buffer: AVAudioPCMBuffer) {
    let frames = AVAudioFramePosition(buffer.frameLength)

    if let file = activeFile {
      do {
        try file.write(from: buffer)
        activeFrameCount += frames
      } catch {
        debugLog("[VoiceAudioCapture] Failed to write audio buffer: \(error)")
      }
      return
    }

    guard prewarmingEnabled else { return }

    preRollBuffers.append(StoredBuffer(buffer: buffer, frameCount: frames))
    preRollFrameCount += frames
    trimPreRollBuffers()
  }

  private func trimPreRollBuffers() {
    let sampleRate = engine.inputNode.outputFormat(forBus: 0).sampleRate
    let maxFrames = AVAudioFramePosition(sampleRate * preRollDuration)

    while preRollFrameCount > maxFrames, let first = preRollBuffers.first {
      preRollFrameCount -= first.frameCount
      preRollBuffers.removeFirst()
    }
  }

  private func teardownEngineLocked() {
    if hasInstalledTap {
      engine.inputNode.removeTap(onBus: 0)
      hasInstalledTap = false
      installedTapFormat = nil
    }
    if engine.isRunning {
      engine.stop()
    }
  }

  private static func copyBuffer(_ buffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
    guard let copy = AVAudioPCMBuffer(pcmFormat: buffer.format, frameCapacity: buffer.frameLength)
    else {
      return nil
    }

    copy.frameLength = buffer.frameLength
    let frameLength = Int(buffer.frameLength)
    let channelCount = Int(buffer.format.channelCount)

    if let source = buffer.floatChannelData, let destination = copy.floatChannelData {
      for channel in 0..<channelCount {
        destination[channel].update(from: source[channel], count: frameLength)
      }
      return copy
    }

    if let source = buffer.int16ChannelData, let destination = copy.int16ChannelData {
      for channel in 0..<channelCount {
        destination[channel].update(from: source[channel], count: frameLength)
      }
      return copy
    }

    if let source = buffer.int32ChannelData, let destination = copy.int32ChannelData {
      for channel in 0..<channelCount {
        destination[channel].update(from: source[channel], count: frameLength)
      }
      return copy
    }

    return nil
  }

  private static func makeCaptureURL() -> URL {
    FileManager.default.temporaryDirectory
      .appendingPathComponent("leaderkey-voice-\(UUID().uuidString)")
      .appendingPathExtension("wav")
  }

  /// Trim trailing silence from a WAV file in-place.
  /// Detects silence as RMS below the threshold in the final `tailDuration` seconds.
  static func trimTrailingSilence(
    url: URL,
    tailDuration: TimeInterval = 0.5,
    silenceThresholdDB: Float = -40
  ) {
    guard let file = try? AVAudioFile(forReading: url) else { return }
    let format = file.processingFormat
    let totalFrames = AVAudioFrameCount(file.length)
    let tailFrames = AVAudioFrameCount(format.sampleRate * tailDuration)
    guard totalFrames > tailFrames else { return }

    let checkStart = totalFrames - tailFrames
    file.framePosition = AVAudioFramePosition(checkStart)
    guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: tailFrames) else {
      return
    }
    do {
      try file.read(into: buffer)
    } catch {
      return
    }

    let rms = rmsLevel(buffer: buffer)
    let rmsDB = rms > 0 ? 20 * log10(rms) : -Float.infinity
    guard rmsDB < silenceThresholdDB else { return }

    // Find where silence begins by scanning backwards in chunks
    let chunkFrames = AVAudioFrameCount(format.sampleRate * 0.05)
    var trimPoint = totalFrames
    var scanPosition = totalFrames
    while scanPosition > chunkFrames {
      scanPosition -= chunkFrames
      file.framePosition = AVAudioFramePosition(scanPosition)
      guard let chunk = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: chunkFrames) else {
        break
      }
      do {
        try file.read(into: chunk)
      } catch {
        break
      }
      let chunkRMS = rmsLevel(buffer: chunk)
      let chunkDB = chunkRMS > 0 ? 20 * log10(chunkRMS) : -Float.infinity
      if chunkDB >= silenceThresholdDB {
        trimPoint = scanPosition + chunkFrames
        break
      }
      trimPoint = scanPosition
    }

    guard trimPoint < totalFrames else { return }

    // Rewrite the file with trimmed content
    file.framePosition = 0
    guard let readBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: trimPoint) else {
      return
    }
    do {
      try file.read(into: readBuffer)
      let trimmedFile = try AVAudioFile(
        forWriting: url, settings: format.settings)
      try trimmedFile.write(from: readBuffer)
      debugLog(
        "[VoiceAudioCapture] Trimmed \(totalFrames - trimPoint) silent frames from recording")
    } catch {
      debugLog("[VoiceAudioCapture] Failed to trim silence: \(error)")
    }
  }

  /// Compute the overall RMS dB level of a WAV file. Useful for diagnosing silent recordings.
  /// Returns -Float.infinity if the file is empty or unreadable.
  static func overallRMSDb(url: URL) -> Float {
    guard let file = try? AVAudioFile(forReading: url) else { return -.infinity }
    let format = file.processingFormat
    let totalFrames = AVAudioFrameCount(file.length)
    guard totalFrames > 0 else { return -.infinity }

    let chunkFrames = AVAudioFrameCount(min(UInt32(format.sampleRate), totalFrames))
    var sumSquares: Double = 0
    var totalSamples: Int = 0
    var position: AVAudioFrameCount = 0
    while position < totalFrames {
      let remaining = totalFrames - position
      let take = min(chunkFrames, remaining)
      guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: take) else { break }
      file.framePosition = AVAudioFramePosition(position)
      do {
        try file.read(into: buffer)
      } catch {
        break
      }
      guard let data = buffer.floatChannelData else { break }
      let frames = Int(buffer.frameLength)
      for i in 0..<frames {
        let sample = Double(data[0][i])
        sumSquares += sample * sample
      }
      totalSamples += frames
      position += take
    }

    guard totalSamples > 0 else { return -.infinity }
    let rms = sqrt(sumSquares / Double(totalSamples))
    return rms > 0 ? Float(20 * log10(rms)) : -.infinity
  }

  private static func rmsLevel(buffer: AVAudioPCMBuffer) -> Float {
    guard let data = buffer.floatChannelData, buffer.frameLength > 0 else { return 0 }
    let frames = Int(buffer.frameLength)
    var sum: Float = 0
    for i in 0..<frames {
      let sample = data[0][i]
      sum += sample * sample
    }
    return sqrt(sum / Float(frames))
  }
}

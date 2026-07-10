import AVFoundation
import Foundation

struct VoiceTranscriptionResult {
  let text: String
  let model: String
  let requestID: String?
  let quality: VoiceTranscriptionQuality

  var suggestsAccuracyRetry: Bool {
    quality.suggestsAccuracyRetry || Self.looksRepetitive(text)
  }

  private static func looksRepetitive(_ text: String) -> Bool {
    let words = text
      .lowercased()
      .split { !$0.isLetter && !$0.isNumber }
      .map(String.init)
    guard words.count >= 4 else { return false }
    return Set(words).count <= 2
  }
}

struct VoiceTranscriptionQuality {
  let averageLogProbability: Double?
  let maximumNoSpeechProbability: Double?
  let maximumCompressionRatio: Double?

  var suggestsAccuracyRetry: Bool {
    if let averageLogProbability, averageLogProbability < -0.8 {
      return true
    }
    if let maximumNoSpeechProbability, maximumNoSpeechProbability > 0.65 {
      return true
    }
    if let maximumCompressionRatio, maximumCompressionRatio > 2.6 {
      return true
    }
    return false
  }

  static let unavailable = VoiceTranscriptionQuality(
    averageLogProbability: nil,
    maximumNoSpeechProbability: nil,
    maximumCompressionRatio: nil
  )
}

enum VoiceTranscriptionError: LocalizedError {
  case missingAPIKey
  case invalidEndpoint
  case invalidResponse
  case httpFailure(statusCode: Int, body: String)
  case emptyTranscript

  var errorDescription: String? {
    switch self {
    case .missingAPIKey:
      return "Transcription API key is missing."
    case .invalidEndpoint:
      return "Transcription endpoint is invalid."
    case .invalidResponse:
      return "Transcription server returned an invalid response."
    case .httpFailure(let statusCode, let body):
      return "Transcription failed with HTTP \(statusCode): \(body)"
    case .emptyTranscript:
      return "Transcription returned an empty transcript."
    }
  }
}

final class OpenAICompatibleSpeechToTextClient {
  private static let maxPromptCharacters = 840

  private struct TranscriptionResponse: Decodable {
    struct RequestMetadata: Decodable {
      let id: String?
    }

    struct Segment: Decodable {
      let avgLogprob: Double?
      let compressionRatio: Double?
      let noSpeechProb: Double?

      enum CodingKeys: String, CodingKey {
        case avgLogprob = "avg_logprob"
        case compressionRatio = "compression_ratio"
        case noSpeechProb = "no_speech_prob"
      }
    }

    let text: String
    let xGroq: RequestMetadata?
    let segments: [Segment]?

    enum CodingKeys: String, CodingKey {
      case text
      case xGroq = "x_groq"
      case segments
    }
  }

  private let requestTimeout: TimeInterval = 30

  func transcribe(
    audioURL: URL,
    model: String,
    baseURL: String,
    bearerToken: String?,
    prompt: String?
  ) async throws -> VoiceTranscriptionResult {
    let trimmedBase = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
      .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    guard let url = URL(string: "\(trimmedBase)/v1/audio/transcriptions") else {
      throw VoiceTranscriptionError.invalidEndpoint
    }

    let trimmedKey = bearerToken?.trimmingCharacters(in: .whitespacesAndNewlines)

    let boundary = "leaderkey-\(UUID().uuidString)"
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.timeoutInterval = requestTimeout
    if let trimmedKey, !trimmedKey.isEmpty {
      request.setValue("Bearer \(trimmedKey)", forHTTPHeaderField: "Authorization")
    }
    request.setValue(
      "multipart/form-data; boundary=\(boundary)",
      forHTTPHeaderField: "Content-Type"
    )
    request.httpBody = try multipartBody(
      audioURL: audioURL,
      model: model,
      boundary: boundary,
      prompt: prompt
    )

    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw VoiceTranscriptionError.invalidResponse
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      let body = String(data: data, encoding: .utf8) ?? ""
      throw VoiceTranscriptionError.httpFailure(statusCode: httpResponse.statusCode, body: body)
    }

    let decoded = try JSONDecoder().decode(TranscriptionResponse.self, from: data)
    let transcript = decoded.text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !transcript.isEmpty else {
      throw VoiceTranscriptionError.emptyTranscript
    }

    return VoiceTranscriptionResult(
      text: transcript,
      model: model,
      requestID: decoded.xGroq?.id,
      quality: Self.quality(from: decoded.segments)
    )
  }

  private func multipartBody(
    audioURL: URL,
    model: String,
    boundary: String,
    prompt: String?
  ) throws -> Data {
    var body = Data()
    let (fileData, filename) = try Self.preparedAudioForUpload(audioURL: audioURL)

    body.appendMultipartField(name: "model", value: model, boundary: boundary)
    body.appendMultipartField(name: "response_format", value: "verbose_json", boundary: boundary)
    body.appendMultipartField(name: "language", value: "en", boundary: boundary)
    body.appendMultipartField(name: "temperature", value: "0", boundary: boundary)
    if let prompt = limitedPrompt(prompt) {
      body.appendMultipartField(name: "prompt", value: prompt, boundary: boundary)
    }
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
    body.append("Content-Type: audio/wav\r\n\r\n")
    body.append(fileData)
    body.append("\r\n")
    body.append("--\(boundary)--\r\n")

    return body
  }

  /// Re-encodes the captured WAV to 16 kHz Int16 mono before upload. Most ASR backends
  /// (Parakeet/Whisper) are trained on this format and resampling on the server side can be
  /// flaky for short clips. Uses /usr/bin/afconvert (a separate process) so any failure in the
  /// system audio converter cannot crash Leader Key. Falls back to the original file on any error.
  private static func preparedAudioForUpload(audioURL: URL) throws -> (Data, String) {
    let originalData = try Data(contentsOf: audioURL)
    let originalFilename = audioURL.lastPathComponent

    let outputURL = FileManager.default.temporaryDirectory
      .appendingPathComponent("leaderkey-voice-upload-\(UUID().uuidString)")
      .appendingPathExtension("wav")
    defer { try? FileManager.default.removeItem(at: outputURL) }

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/afconvert")
    process.arguments = [
      "-f", "WAVE",
      "-d", "LEI16@16000",
      "-c", "1",
      audioURL.path,
      outputURL.path,
    ]
    let stderrPipe = Pipe()
    process.standardOutput = Pipe()
    process.standardError = stderrPipe

    do {
      try process.run()
      process.waitUntilExit()
    } catch {
      debugLog("[VoiceTranscriber] afconvert spawn failed: \(error); sending original audio")
      return (originalData, originalFilename)
    }

    guard process.terminationStatus == 0 else {
      let errOutput =
        String(
          data: stderrPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8
        ) ?? ""
      debugLog(
        "[VoiceTranscriber] afconvert exited \(process.terminationStatus): \(errOutput); sending original audio"
      )
      return (originalData, originalFilename)
    }

    guard let convertedData = try? Data(contentsOf: outputURL), !convertedData.isEmpty else {
      debugLog("[VoiceTranscriber] afconvert produced no output; sending original audio")
      return (originalData, originalFilename)
    }

    let convertedFilename = (originalFilename as NSString).deletingPathExtension + "-16k.wav"
    return (convertedData, convertedFilename)
  }

  private static func quality(
    from segments: [TranscriptionResponse.Segment]?
  ) -> VoiceTranscriptionQuality {
    guard let segments, !segments.isEmpty else {
      return .unavailable
    }

    let logProbabilities = segments.compactMap(\.avgLogprob)
    let noSpeechProbabilities = segments.compactMap(\.noSpeechProb)
    let compressionRatios = segments.compactMap(\.compressionRatio)

    let averageLogProbability =
      logProbabilities.isEmpty
      ? nil
      : logProbabilities.reduce(0, +) / Double(logProbabilities.count)

    return VoiceTranscriptionQuality(
      averageLogProbability: averageLogProbability,
      maximumNoSpeechProbability: noSpeechProbabilities.max(),
      maximumCompressionRatio: compressionRatios.max()
    )
  }

  private func limitedPrompt(_ prompt: String?) -> String? {
    guard let prompt = prompt?.trimmingCharacters(in: .whitespacesAndNewlines), !prompt.isEmpty
    else {
      return nil
    }

    guard prompt.utf8.count > Self.maxPromptCharacters else {
      return prompt
    }

    var result = ""
    for character in prompt {
      let next = result + String(character)
      if next.utf8.count > Self.maxPromptCharacters {
        break
      }
      result = next
    }
    return result.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}

extension Data {
  fileprivate mutating func append(_ string: String) {
    append(Data(string.utf8))
  }

  fileprivate mutating func appendMultipartField(
    name: String,
    value: String,
    boundary: String
  ) {
    append("--\(boundary)\r\n")
    append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
    append("\(value)\r\n")
  }
}

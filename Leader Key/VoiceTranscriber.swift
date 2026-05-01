import Foundation

struct VoiceTranscriptionResult {
  let text: String
  let model: String
  let requestID: String?
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
      return "Groq API key is missing."
    case .invalidEndpoint:
      return "Groq transcription endpoint is invalid."
    case .invalidResponse:
      return "Groq returned an invalid response."
    case .httpFailure(let statusCode, let body):
      return "Groq transcription failed with HTTP \(statusCode): \(body)"
    case .emptyTranscript:
      return "Groq returned an empty transcript."
    }
  }
}

final class GroqSpeechToTextClient {
  private struct GroqTranscriptionResponse: Decodable {
    struct RequestMetadata: Decodable {
      let id: String?
    }

    let text: String
    let xGroq: RequestMetadata?

    enum CodingKeys: String, CodingKey {
      case text
      case xGroq = "x_groq"
    }
  }

  private let endpoint = "https://api.groq.com/openai/v1/audio/transcriptions"
  private let requestTimeout: TimeInterval = 30

  func transcribe(
    audioURL: URL,
    model: VoiceSTTModel,
    apiKey: String
  ) async throws -> VoiceTranscriptionResult {
    let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedKey.isEmpty else {
      throw VoiceTranscriptionError.missingAPIKey
    }

    guard let url = URL(string: endpoint) else {
      throw VoiceTranscriptionError.invalidEndpoint
    }

    let boundary = "leaderkey-\(UUID().uuidString)"
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.timeoutInterval = requestTimeout
    request.setValue("Bearer \(trimmedKey)", forHTTPHeaderField: "Authorization")
    request.setValue(
      "multipart/form-data; boundary=\(boundary)",
      forHTTPHeaderField: "Content-Type"
    )
    request.httpBody = try multipartBody(
      audioURL: audioURL,
      model: model.rawValue,
      boundary: boundary
    )

    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw VoiceTranscriptionError.invalidResponse
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      let body = String(data: data, encoding: .utf8) ?? ""
      throw VoiceTranscriptionError.httpFailure(statusCode: httpResponse.statusCode, body: body)
    }

    let decoded = try JSONDecoder().decode(GroqTranscriptionResponse.self, from: data)
    let transcript = decoded.text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !transcript.isEmpty else {
      throw VoiceTranscriptionError.emptyTranscript
    }

    return VoiceTranscriptionResult(
      text: transcript,
      model: model.rawValue,
      requestID: decoded.xGroq?.id
    )
  }

  private func multipartBody(audioURL: URL, model: String, boundary: String) throws -> Data {
    var body = Data()
    let fileData = try Data(contentsOf: audioURL)
    let filename = audioURL.lastPathComponent

    body.appendMultipartField(name: "model", value: model, boundary: boundary)
    body.appendMultipartField(name: "response_format", value: "json", boundary: boundary)
    body.appendMultipartField(name: "temperature", value: "0", boundary: boundary)
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
    body.append("Content-Type: audio/wav\r\n\r\n")
    body.append(fileData)
    body.append("\r\n")
    body.append("--\(boundary)--\r\n")

    return body
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

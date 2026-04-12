import Foundation

// MARK: - Protocol

protocol AIProviderClient {
    var supportsWebResearch: Bool { get }
    func generateJSON(system: String, prompt: String) async throws -> Data
}

// MARK: - Gemini

struct GeminiProvider: AIProviderClient {
    let apiKey: String
    let model: String
    let webResearchEnabled: Bool

    var supportsWebResearch: Bool { true }

    func generateJSON(system: String, prompt: String) async throws -> Data {
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")

        var body: [String: Any] = [
            "system_instruction": ["parts": [["text": system]]],
            "contents": [["parts": [["text": prompt]]]],
            "generationConfig": ["responseMimeType": "application/json"],
        ]

        if webResearchEnabled {
            body["tools"] = [["google_search": [String: String]()]]
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return try await executeRequest(request, extractPath: \.geminiContent)
    }
}

// MARK: - OpenAI (Chat Completions)

struct OpenAIProvider: AIProviderClient {
    let apiKey: String
    let model: String
    let baseURL: String

    var supportsWebResearch: Bool { false }

    func generateJSON(system: String, prompt: String) async throws -> Data {
        let endpoint = effectiveBaseURL + "/chat/completions"
        guard let url = URL(string: endpoint) else {
            throw AIProviderError.invalidURL(endpoint)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": system],
                ["role": "user", "content": prompt],
            ],
            "response_format": ["type": "json_object"],
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return try await executeRequest(request, extractPath: \.openAIContent)
    }

    private var effectiveBaseURL: String {
        let trimmed = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "https://api.openai.com/v1" : trimmed.trimmingSuffix("/")
    }
}

// MARK: - Anthropic

struct AnthropicProvider: AIProviderClient {
    let apiKey: String
    let model: String

    var supportsWebResearch: Bool { false }

    func generateJSON(system: String, prompt: String) async throws -> Data {
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": model,
            "max_tokens": 4096,
            "system": system,
            "messages": [
                ["role": "user", "content": prompt],
            ],
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return try await executeRequest(request, extractPath: \.anthropicContent)
    }
}

// MARK: - Shared Helpers

enum AIProviderError: LocalizedError {
    case invalidURL(String)
    case httpFailure(statusCode: Int, body: String)
    case noContent
    case invalidJSON(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL(let url): return "Invalid provider URL: \(url)"
        case .httpFailure(let code, let body): return "Provider HTTP \(code): \(Self.redactSecrets(body))"
        case .noContent: return "Provider returned no content"
        case .invalidJSON(let detail): return "Invalid JSON from provider: \(detail)"
        }
    }

    private static func redactSecrets(_ text: String) -> String {
        // Redact anything that looks like an API key or auth header value
        let patterns = [
            "Bearer [A-Za-z0-9_-]+",
            "key=[A-Za-z0-9_-]+",
            "x-api-key: [A-Za-z0-9_-]+",
        ]
        var result = text
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern) {
                result = regex.stringByReplacingMatches(
                    in: result,
                    range: NSRange(result.startIndex..., in: result),
                    withTemplate: "[REDACTED]"
                )
            }
        }
        return result
    }
}

private func executeRequest(_ request: URLRequest) async throws -> Data {
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
        throw AIProviderError.noContent
    }
    guard (200...299).contains(httpResponse.statusCode) else {
        let body = String(data: data, encoding: .utf8) ?? ""
        throw AIProviderError.httpFailure(statusCode: httpResponse.statusCode, body: body)
    }
    return data
}

private func executeRequest(
    _ request: URLRequest,
    extractPath: KeyPath<[String: Any], String?>
) async throws -> Data {
    let data = try await executeRequest(request)
    guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        return data
    }
    guard let text = json[keyPath: extractPath] else {
        throw AIProviderError.noContent
    }
    guard let textData = text.data(using: .utf8) else {
        throw AIProviderError.invalidJSON("Could not encode extracted text")
    }
    return textData
}

// KeyPath helpers for extracting text from provider-specific response shapes
private extension Dictionary where Key == String, Value == Any {
    var openAIContent: String? {
        guard let choices = self["choices"] as? [[String: Any]],
              let first = choices.first,
              let message = first["message"] as? [String: Any],
              let content = message["content"] as? String
        else { return nil }
        return content
    }

    var anthropicContent: String? {
        guard let content = self["content"] as? [[String: Any]],
              let first = content.first,
              let text = first["text"] as? String
        else { return nil }
        return text
    }

    var geminiContent: String? {
        guard let candidates = self["candidates"] as? [[String: Any]],
              let first = candidates.first,
              let content = first["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String
        else { return nil }
        return text
    }
}

private extension String {
    func trimmingSuffix(_ suffix: String) -> String {
        if hasSuffix(suffix) {
            return String(dropLast(suffix.count))
        }
        return self
    }
}

// MARK: - Factory

enum AIProviderFactory {
    static func makeProvider(settings: CommandScoutProviderSettings, apiKey: String) -> AIProviderClient {
        let model = settings.effectiveModelName
        switch settings.providerKind {
        case .gemini:
            return GeminiProvider(apiKey: apiKey, model: model, webResearchEnabled: settings.webResearchEnabled)
        case .openAI:
            return OpenAIProvider(apiKey: apiKey, model: model, baseURL: "")
        case .anthropic:
            return AnthropicProvider(apiKey: apiKey, model: model)
        case .openAICompatible:
            return OpenAIProvider(apiKey: apiKey, model: model, baseURL: settings.baseURL)
        }
    }
}

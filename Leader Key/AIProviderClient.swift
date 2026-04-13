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

    var supportsWebResearch: Bool {
        CommandScoutAIProviderKind.gemini.supportsWebResearch(modelName: model)
    }

    private var usesWebResearch: Bool {
        webResearchEnabled && supportsWebResearch
    }

    func generateJSON(system: String, prompt: String) async throws -> Data {
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent")!
        var request = URLRequest(url: url)
        request.timeoutInterval = requestTimeout
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")

        var body: [String: Any] = [
            "system_instruction": ["parts": [["text": system]]],
            "contents": [["parts": [["text": prompt]]]],
            "generationConfig": generationConfigPayload,
        ]

        if usesWebResearch {
            body["tools"] = [searchToolPayload]
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return try await executeRequest(
            request,
            extractPath: \.geminiContent,
            noContentDetails: ProviderResponseParser.geminiNoContentDetails(from:)
        )
    }

    var searchToolPayload: [String: Any] {
        let normalizedModel = model.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if normalizedModel.hasPrefix("gemma-") {
            return ["googleSearch": [String: String]()]
        }
        return ["google_search": [String: String]()]
    }

    var generationConfigPayload: [String: Any] {
        var payload: [String: Any] = ["maxOutputTokens": 4096]
        // Gemma/Gemini grounded search can hang when combined with forced JSON MIME mode.
        // Keep strict JSON in the prompt and let the local parser validate the response.
        if !usesWebResearch {
            payload["responseMimeType"] = "application/json"
        }
        return payload
    }

    private var requestTimeout: TimeInterval {
        usesWebResearch ? 180 : 90
    }
}

// MARK: - OpenAI (Chat Completions)

enum OpenRouterRequestMode {
    case strictStructured
    case relaxedJSON
}

struct OpenAIProvider: AIProviderClient {
    let apiKey: String
    let model: String
    let baseURL: String
    let webResearchEnabled: Bool

    var supportsWebResearch: Bool { isOpenRouterBaseURL }

    func generateJSON(system: String, prompt: String) async throws -> Data {
        let endpoint = effectiveBaseURL + "/chat/completions"
        guard let url = URL(string: endpoint) else {
            throw AIProviderError.invalidURL(endpoint)
        }

        if isOpenRouterBaseURL {
            return try await generateOpenRouterJSON(url: url, system: system, prompt: prompt)
        }

        var request = baseRequest(url: url)
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody(system: system, prompt: prompt))
        return try await executeRequest(request, extractPath: \.openAIContent)
    }

    func requestBody(system: String, prompt: String) -> [String: Any] {
        requestBody(system: system, prompt: prompt, openRouterMode: .strictStructured, includeWebPlugin: webResearchEnabled)
    }

    func requestBody(
        system: String,
        prompt: String,
        openRouterMode: OpenRouterRequestMode,
        includeWebPlugin: Bool
    ) -> [String: Any] {
        var body: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": system],
                ["role": "user", "content": prompt],
            ],
        ]

        if isOpenRouterBaseURL {
            switch openRouterMode {
            case .strictStructured:
                body["response_format"] = openRouterStrictResponseFormat
                body["provider"] = ["require_parameters": true] as [String: Any]
            case .relaxedJSON:
                body["response_format"] = ["type": "json_object"] as [String: Any]
            }
            body["temperature"] = 0.2
            body["max_tokens"] = 4096
            if includeWebPlugin {
                body["plugins"] = [["id": "web", "max_results": 3] as [String: Any]]
            }
        } else {
            body["response_format"] = ["type": "json_object"] as [String: Any]
        }

        return body
    }

    private func generateOpenRouterJSON(url: URL, system: String, prompt: String) async throws -> Data {
        let variants: [(mode: OpenRouterRequestMode, includeWebPlugin: Bool, maxAttempts: Int)] = webResearchEnabled
            ? [
                (.strictStructured, true, 1),
                (.relaxedJSON, true, 1),
                (.relaxedJSON, false, ProviderRetryPolicy.maxAttempts),
            ]
            : [
                (.strictStructured, false, 1),
                (.relaxedJSON, false, ProviderRetryPolicy.maxAttempts),
            ]

        var lastError: Error?
        for variant in variants {
            var request = baseRequest(url: url)
            request.httpBody = try JSONSerialization.data(
                withJSONObject: requestBody(
                    system: system,
                    prompt: prompt,
                    openRouterMode: variant.mode,
                    includeWebPlugin: variant.includeWebPlugin
                )
            )

            do {
                return try await executeRequest(
                    request,
                    extractPath: \.openAIContent,
                    maxAttempts: variant.maxAttempts
                )
            } catch {
                guard shouldTryNextOpenRouterVariant(after: error) else {
                    throw error
                }
                lastError = error
            }
        }

        if let lastError {
            throw lastError
        }
        throw AIProviderError.noContent(details: nil)
    }

    private func shouldTryNextOpenRouterVariant(after error: Error) -> Bool {
        guard let providerError = error as? AIProviderError else {
            return false
        }
        switch providerError {
        case .httpFailure(let statusCode, _):
            return statusCode == 400 || statusCode == 422 || (500...599).contains(statusCode)
        default:
            return false
        }
    }

    private func baseRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.timeoutInterval = requestTimeout
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        return request
    }

    private var effectiveBaseURL: String {
        let trimmed = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "https://api.openai.com/v1" : trimmed.trimmingSuffix("/")
    }

    private var requestTimeout: TimeInterval {
        webResearchEnabled ? 180 : 90
    }

    private var isOpenRouterBaseURL: Bool {
        guard let url = URL(string: effectiveBaseURL),
              let host = url.host?.lowercased()
        else {
            return false
        }
        return host == "openrouter.ai" || host.hasSuffix(".openrouter.ai")
    }

    private var openRouterStrictResponseFormat: [String: Any] {
        [
            "type": "json_schema",
            "json_schema": [
                "name": "command_scout_suggestions",
                "strict": true,
                "schema": [
                    "type": "object",
                    "additionalProperties": false,
                    "required": ["suggestions"],
                    "properties": [
                        "suggestions": [
                            "type": "array",
                            "maxItems": CommandScoutService.maxAISuggestions,
                            "items": [
                                "type": "object",
                                "additionalProperties": false,
                                "required": [
                                    "title",
                                    "category",
                                    "source",
                                    "actionType",
                                    "actionValue",
                                    "suggestedSequence",
                                    "description",
                                    "aiDescription",
                                    "confidence",
                                    "sourceNotes",
                                ],
                                "properties": [
                                    "title": ["type": "string"],
                                    "category": ["type": "string"],
                                    "source": [
                                        "type": "string",
                                        "enum": ["liveMenu", "ai", "web", "local"],
                                    ],
                                    "actionType": [
                                        "type": "string",
                                        "enum": ["menu", "shortcut", "keystroke", "url"],
                                    ],
                                    "actionValue": ["type": "string"],
                                    "suggestedSequence": [
                                        "type": "string",
                                        "minLength": 1,
                                        "maxLength": 3,
                                        "pattern": "^[a-zA-Z0-9]{1,3}$",
                                    ],
                                    "description": ["type": "string"],
                                    "aiDescription": ["type": "string"],
                                    "confidence": [
                                        "type": "number",
                                        "minimum": 0,
                                        "maximum": 1,
                                    ],
                                    "sourceNotes": ["type": "string"],
                                ],
                            ],
                        ],
                    ],
                ],
            ],
        ]
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
        request.timeoutInterval = 90
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
    case noContent(details: String?)
    case invalidJSON(String)
    case requestTimedOut(seconds: TimeInterval)

    var errorDescription: String? {
        switch self {
        case .invalidURL(let url): return "Invalid provider URL: \(url)"
        case .httpFailure(let code, let body):
            let detail = Self.providerErrorMessage(from: body) ?? Self.redactSecrets(body)
            if code == 429 || body.localizedCaseInsensitiveContains("RESOURCE_EXHAUSTED") {
                return "Provider quota or rate limit exceeded (HTTP \(code)): \(detail)"
            }
            return "Provider HTTP \(code): \(detail)"
        case .noContent(let details):
            if let details, !details.isEmpty {
                return "Provider returned no content: \(details)"
            }
            return "Provider returned no content"
        case .invalidJSON(let detail): return "Invalid JSON from provider: \(detail)"
        case .requestTimedOut(let seconds):
            return "Provider request timed out after \(Int(seconds)) seconds"
        }
    }

    func userFacingMessage(provider: CommandScoutAIProviderKind, modelName: String) -> String {
        let model = modelName.trimmingCharacters(in: .whitespacesAndNewlines)
        switch self {
        case .httpFailure(let code, let body)
            where code == 429 || body.localizedCaseInsensitiveContains("RESOURCE_EXHAUSTED"):
            let detail = Self.providerErrorMessage(from: body)
            let modelText = model.isEmpty ? "" : " for \(model)"
            switch provider {
            case .gemini:
                let detailText = detail.map { " Google says: \($0)" } ?? ""
                return """
                Gemini quota or rate limit exceeded\(modelText).\(detailText) Preview models have stricter limits and Gemini limits are applied per Google AI project, not per API key. Try again later, switch to a lower-quota-risk model like gemini-2.5-flash, disable web research, or use another provider.
                """
            case .openAI, .anthropic, .openAICompatible:
                let detailText = detail.map { ": \($0)" } ?? "."
                return "\(provider.displayName) quota or rate limit exceeded\(modelText)\(detailText)"
            }
        case .requestTimedOut(let seconds):
            let modelText = model.isEmpty ? "" : " for \(model)"
            return "\(provider.displayName) request timed out\(modelText) after \(Int(seconds)) seconds. Web research can be slower; try again, disable web research for this scan, or use a faster model."
        case .noContent(let details):
            let modelText = model.isEmpty ? "" : " for \(model)"
            let detailText = details.map { " Details: \($0)" } ?? ""
            return "\(provider.displayName) returned no text\(modelText).\(detailText) Try again, disable web research, use a faster model, or reduce the scan scope."
        default:
            return localizedDescription
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

    private static func providerErrorMessage(from body: String) -> String? {
        guard let data = body.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return nil }

        if let message = json["message"] as? String {
            return redactSecrets(message)
        }
        if let error = json["error"] as? [String: Any],
           let message = error["message"] as? String {
            return redactSecrets(message)
        }
        return nil
    }
}

enum ProviderRetryPolicy {
    static let maxAttempts = 3
    private static let baseDelayNanoseconds: UInt64 = 1_000_000_000
    private static let maxDelayNanoseconds: UInt64 = 8_000_000_000

    static func shouldRetry(statusCode: Int) -> Bool {
        statusCode == 408 || statusCode == 409 || statusCode == 425 || statusCode == 429
            || (500...599).contains(statusCode)
    }

    static func delayNanoseconds(forAttempt attempt: Int, response: HTTPURLResponse? = nil) -> UInt64 {
        if let retryAfter = retryAfterDelayNanoseconds(from: response) {
            return min(retryAfter, maxDelayNanoseconds)
        }
        let exponent = max(0, attempt - 1)
        let multiplier = UInt64(1 << min(exponent, 3))
        return min(baseDelayNanoseconds * multiplier, maxDelayNanoseconds)
    }

    private static func retryAfterDelayNanoseconds(from response: HTTPURLResponse?) -> UInt64? {
        guard let retryAfter = response?.value(forHTTPHeaderField: "Retry-After")?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !retryAfter.isEmpty
        else {
            return nil
        }
        if let seconds = Double(retryAfter), seconds >= 0 {
            return UInt64(seconds * 1_000_000_000)
        }
        return nil
    }
}

private func executeRequest(_ request: URLRequest, maxAttempts: Int = ProviderRetryPolicy.maxAttempts) async throws -> Data {
    for attempt in 1...max(1, maxAttempts) {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let error as URLError where error.code == .timedOut {
            throw AIProviderError.requestTimedOut(seconds: request.timeoutInterval)
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIProviderError.noContent(details: nil)
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            let error = AIProviderError.httpFailure(statusCode: httpResponse.statusCode, body: body)
            guard ProviderRetryPolicy.shouldRetry(statusCode: httpResponse.statusCode),
                  attempt < max(1, maxAttempts)
            else {
                throw error
            }
            try await Task.sleep(
                nanoseconds: ProviderRetryPolicy.delayNanoseconds(
                    forAttempt: attempt,
                    response: httpResponse
                )
            )
            continue
        }
        return data
    }
    throw AIProviderError.noContent(details: nil)
}

private func executeRequest(
    _ request: URLRequest,
    extractPath: KeyPath<[String: Any], String?>,
    maxAttempts: Int = ProviderRetryPolicy.maxAttempts,
    noContentDetails: (([String: Any]) -> String?)? = nil
) async throws -> Data {
    let data = try await executeRequest(request, maxAttempts: maxAttempts)
    guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        return data
    }
    guard let text = json[keyPath: extractPath] else {
        throw AIProviderError.noContent(details: noContentDetails?(json))
    }
    guard let textData = text.data(using: .utf8) else {
        throw AIProviderError.invalidJSON("Could not encode extracted text")
    }
    return textData
}

enum ProviderResponseParser {
    static func geminiContent(from json: [String: Any]) -> String? {
        guard let candidates = json["candidates"] as? [[String: Any]],
              !candidates.isEmpty
        else { return nil }

        let allParts = candidates.flatMap { candidate -> [[String: Any]] in
            guard let content = candidate["content"] as? [String: Any],
                  let parts = content["parts"] as? [[String: Any]]
            else { return [] }
            return parts
        }

        let visibleParts = textParts(from: allParts, includeThoughts: false)
        if !visibleParts.isEmpty {
            return visibleParts.joined()
        }

        let fallbackParts = textParts(from: allParts, includeThoughts: true)
        return fallbackParts.isEmpty ? nil : fallbackParts.joined()
    }

    static func geminiNoContentDetails(from json: [String: Any]) -> String? {
        var details: [String] = []

        if let promptFeedback = json["promptFeedback"] as? [String: Any],
           let blockReason = promptFeedback["blockReason"] as? String,
           !blockReason.isEmpty {
            details.append("prompt blocked: \(blockReason)")
        }

        if let candidates = json["candidates"] as? [[String: Any]], !candidates.isEmpty {
            let finishReasons = candidates.compactMap { $0["finishReason"] as? String }
            if !finishReasons.isEmpty {
                details.append("finishReason: \(finishReasons.joined(separator: ", "))")
            }

            let partCount = candidates.reduce(0) { total, candidate in
                guard let content = candidate["content"] as? [String: Any],
                      let parts = content["parts"] as? [[String: Any]]
                else { return total }
                return total + parts.count
            }
            details.append("text parts: \(partCount)")
        } else {
            details.append("no candidates")
        }

        if let usage = json["usageMetadata"] as? [String: Any] {
            let tokenFields = [
                "promptTokenCount",
                "candidatesTokenCount",
                "thoughtsTokenCount",
                "totalTokenCount",
            ]
            let tokens = tokenFields.compactMap { key -> String? in
                guard let value = usage[key] else { return nil }
                return "\(key): \(value)"
            }
            if !tokens.isEmpty {
                details.append(tokens.joined(separator: ", "))
            }
        }

        return details.isEmpty ? nil : details.joined(separator: "; ")
    }

    private static func textParts(from parts: [[String: Any]], includeThoughts: Bool) -> [String] {
        parts.compactMap { part -> String? in
            if !includeThoughts, part["thought"] as? Bool == true {
                return nil
            }
            guard let text = part["text"] as? String else {
                return nil
            }
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : text
        }
    }
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
        ProviderResponseParser.geminiContent(from: self)
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
            return OpenAIProvider(apiKey: apiKey, model: model, baseURL: "", webResearchEnabled: false)
        case .anthropic:
            return AnthropicProvider(apiKey: apiKey, model: model)
        case .openAICompatible:
            return OpenAIProvider(
                apiKey: apiKey,
                model: model,
                baseURL: settings.baseURL,
                webResearchEnabled: settings.webResearchEnabled && settings.isOpenRouterBaseURL
            )
        }
    }
}

import XCTest

@testable import Leader_Key

final class CommandScoutTests: XCTestCase {

    // MARK: - Sequence Normalizer

    func testTokensSplitBySpaces() {
        XCTAssertEqual(CommandScoutSequenceNormalizer.tokens(from: "t n"), ["t", "n"])
    }

    func testTokensSplitBySeparators() {
        XCTAssertEqual(CommandScoutSequenceNormalizer.tokens(from: "t > n"), ["t", "n"])
        XCTAssertEqual(CommandScoutSequenceNormalizer.tokens(from: "t/n"), ["t", "n"])
        XCTAssertEqual(CommandScoutSequenceNormalizer.tokens(from: "t,n"), ["t", "n"])
    }

    func testTokensCompactSequenceSplit() {
        // 2-3 char alphanumeric strings split into individual chars
        XCTAssertEqual(CommandScoutSequenceNormalizer.tokens(from: "tn"), ["t", "n"])
        XCTAssertEqual(CommandScoutSequenceNormalizer.tokens(from: "abc"), ["a", "b", "c"])
    }

    func testTokensCompactSequenceNoSplitForLong() {
        // 4+ chars should not split
        XCTAssertEqual(CommandScoutSequenceNormalizer.tokens(from: "abcd"), ["abcd"])
    }

    func testTokensEmpty() {
        XCTAssertEqual(CommandScoutSequenceNormalizer.tokens(from: ""), [])
        XCTAssertEqual(CommandScoutSequenceNormalizer.tokens(from: "   "), [])
    }

    func testTokensLowercased() {
        XCTAssertEqual(CommandScoutSequenceNormalizer.tokens(from: "T N"), ["t", "n"])
    }

    func testNormalizedSequence() {
        XCTAssertEqual(CommandScoutSequenceNormalizer.normalizedSequence("bm"), "bm")
        XCTAssertEqual(CommandScoutSequenceNormalizer.normalizedSequence("b m"), "bm")
        XCTAssertEqual(CommandScoutSequenceNormalizer.normalizedSequence("b > m"), "bm")
        XCTAssertFalse(CommandScoutSequenceNormalizer.normalizedSequence("b m").contains(" "))
    }

    // MARK: - Validation: Empty Sequence

    func testValidationRejectsEmptySequence() {
        let suggestion = makeSuggestion(sequence: "", actionType: .menu, value: "App > File > New")
        let result = CommandScoutService.validate(suggestions: [suggestion], existingRoot: emptyRoot())
        XCTAssertEqual(result[0].conflictStatus, .invalidSequence)
    }

    // MARK: - Validation: Duplicate Sequence

    func testValidationDetectsDuplicateSequenceInBatch() {
        let s1 = makeSuggestion(id: "1", sequence: "t n", actionType: .menu, value: "App > Tab > New")
        let s2 = makeSuggestion(id: "2", sequence: "t n", actionType: .menu, value: "App > Tab > Next")
        let result = CommandScoutService.validate(suggestions: [s1, s2], existingRoot: emptyRoot())
        XCTAssertEqual(result[0].conflictStatus, .clear)
        XCTAssertEqual(result[1].conflictStatus, .duplicateSequence)
    }

    func testValidationDetectsDuplicateSequenceAgainstExisting() {
        let existing = Group(key: nil, label: "Root", stickyMode: nil, actions: [
            .action(Action(key: "a", type: .application, value: "/Applications/Safari.app")),
        ])
        let suggestion = makeSuggestion(sequence: "a", actionType: .menu, value: "App > File > New")
        let result = CommandScoutService.validate(suggestions: [suggestion], existingRoot: existing)
        XCTAssertEqual(result[0].conflictStatus, .duplicateSequence)
    }

    func testValidationDetectsDuplicateNestedSequence() {
        let existing = Group(key: nil, label: "Root", stickyMode: nil, actions: [
            .group(Group(key: "t", label: "Tabs", stickyMode: nil, actions: [
                .action(Action(key: "n", type: .menu, value: "App > Tab > New")),
            ])),
        ])
        let suggestion = makeSuggestion(sequence: "t n", actionType: .menu, value: "App > Tab > Next")
        let result = CommandScoutService.validate(suggestions: [suggestion], existingRoot: existing)
        XCTAssertEqual(result[0].conflictStatus, .duplicateSequence)
    }

    // MARK: - Validation: Duplicate Action

    func testValidationDetectsDuplicateAction() {
        let s1 = makeSuggestion(id: "1", sequence: "t n", actionType: .menu, value: "App > Tab > New")
        let s2 = makeSuggestion(id: "2", sequence: "t x", actionType: .menu, value: "App > Tab > New")
        let result = CommandScoutService.validate(suggestions: [s1, s2], existingRoot: emptyRoot())
        XCTAssertEqual(result[0].conflictStatus, .clear)
        XCTAssertEqual(result[1].conflictStatus, .duplicateAction)
    }

    func testValidationDetectsDuplicateActionAgainstExistingConfig() {
        let existing = Group(key: nil, label: "Root", stickyMode: nil, actions: [
            .group(Group(key: "t", label: "Tabs", stickyMode: nil, actions: [
                .action(Action(key: "n", type: .menu, value: "App > Tab > New")),
            ])),
        ])
        let suggestion = makeSuggestion(sequence: "t x", actionType: .menu, value: "App > Tab > New")
        let result = CommandScoutService.validate(suggestions: [suggestion], existingRoot: existing)
        XCTAssertEqual(result[0].conflictStatus, .duplicateAction)
    }

    // MARK: - Validation: Unsupported Action Type

    func testValidationRejectsUnsupported() {
        let suggestion = makeSuggestion(sequence: "x", actionType: .unsupported, value: "something")
        let result = CommandScoutService.validate(suggestions: [suggestion], existingRoot: emptyRoot())
        XCTAssertEqual(result[0].conflictStatus, .unsupportedAction)
    }

    // MARK: - Validation: Invalid Menu Value

    func testValidationRejectsInvalidMenuValue() {
        let suggestion = makeSuggestion(sequence: "m n", actionType: .menu, value: "NoSeparator")
        let result = CommandScoutService.validate(suggestions: [suggestion], existingRoot: emptyRoot())
        XCTAssertEqual(result[0].conflictStatus, .invalidActionValue)
    }

    func testValidationAcceptsValidMenuValue() {
        let suggestion = makeSuggestion(sequence: "m n", actionType: .menu, value: "App > File > New")
        let result = CommandScoutService.validate(suggestions: [suggestion], existingRoot: emptyRoot())
        XCTAssertEqual(result[0].conflictStatus, .clear)
    }

    // MARK: - Validation: Clear Pass

    func testValidationPassesClear() {
        let suggestions = [
            makeSuggestion(id: "1", sequence: "t n", actionType: .menu, value: "App > Tab > New"),
            makeSuggestion(id: "2", sequence: "t c", actionType: .menu, value: "App > Tab > Close"),
            makeSuggestion(id: "3", sequence: "w n", actionType: .shortcut, value: "Cmd+N"),
        ]
        let result = CommandScoutService.validate(suggestions: suggestions, existingRoot: emptyRoot())
        XCTAssertTrue(result.allSatisfy { $0.conflictStatus == .clear })
    }

    // MARK: - Menu Suggestion Conversion

    func testMenuItemsConvertToSuggestions() {
        let items = [
            CommandScoutMenuItem(appName: "Safari", enabled: true, path: "File > New Window", title: "New Window"),
            CommandScoutMenuItem(appName: "Safari", enabled: true, path: "Edit > Copy", title: "Copy"),
        ]
        let suggestions = CommandScoutService.suggestionsFromMenuItems(items, appName: "Safari")
        XCTAssertEqual(suggestions.count, 2)
        XCTAssertEqual(suggestions[0].actionValue, "Safari > File > New Window")
        XCTAssertEqual(suggestions[0].source, .liveMenu)
        XCTAssertEqual(suggestions[0].actionType, .menu)
    }

    func testMenuItemsFilterNoise() {
        let items = [
            CommandScoutMenuItem(appName: "Safari", enabled: true, path: "Safari > About", title: "About"),
            CommandScoutMenuItem(appName: "Safari", enabled: true, path: "Safari > Quit", title: "Quit"),
            CommandScoutMenuItem(appName: "Safari", enabled: true, path: "Safari > Services", title: "Services"),
            CommandScoutMenuItem(appName: "Safari", enabled: true, path: "Safari > Hide", title: "Hide"),
            CommandScoutMenuItem(appName: "Safari", enabled: true, path: "Safari > Hide Others", title: "Hide Others"),
            CommandScoutMenuItem(appName: "Safari", enabled: true, path: "Safari > Show All", title: "Show All"),
        ]
        let suggestions = CommandScoutService.suggestionsFromMenuItems(items, appName: "Safari")
        XCTAssertTrue(suggestions.isEmpty)
    }

    func testMenuItemsSkipDisabled() {
        let items = [
            CommandScoutMenuItem(appName: "Safari", enabled: false, path: "Edit > Undo", title: "Undo"),
        ]
        let suggestions = CommandScoutService.suggestionsFromMenuItems(items, appName: "Safari")
        XCTAssertTrue(suggestions.isEmpty)
    }

    // MARK: - makeAction()

    func testMakeActionCreatesValidAction() {
        let suggestion = makeSuggestion(
            sequence: "t n",
            actionType: .menu,
            value: "Safari > File > New Window",
            title: "New Window"
        )
        let action = suggestion.makeAction()
        XCTAssertNotNil(action)
        XCTAssertEqual(action?.key, "n")  // Last token
        XCTAssertEqual(action?.type, .menu)
        XCTAssertEqual(action?.value, "Safari > File > New Window")
        XCTAssertEqual(action?.label, "New Window")
    }

    func testMakeActionReturnsNilForUnsupported() {
        let suggestion = makeSuggestion(sequence: "x", actionType: .unsupported, value: "something")
        XCTAssertNil(suggestion.makeAction())
    }

    func testMakeActionReturnsNilForEmptySequence() {
        let suggestion = makeSuggestion(sequence: "", actionType: .menu, value: "App > File > New")
        XCTAssertNil(suggestion.makeAction())
    }

    func testMakeActionReturnsNilForEmptyValue() {
        let suggestion = makeSuggestion(sequence: "m", actionType: .menu, value: "   ")
        XCTAssertNil(suggestion.makeAction())
    }

    // MARK: - Sequence Assignment

    func testAssignSequencesUsesCategory() {
        var suggestion = makeSuggestion(sequence: "", actionType: .menu, value: "App > Tab > New", title: "New Tab")
        suggestion.category = "Tabs"
        let result = CommandScoutService.assignSequences(to: [suggestion], existingRoot: emptyRoot())
        XCTAssertFalse(result[0].suggestedSequence.isEmpty)
        XCTAssertTrue(result[0].suggestedSequence.hasPrefix("t"))
        XCTAssertFalse(result[0].suggestedSequence.contains(" "))
    }

    func testAssignSequencesAvoidsExisting() {
        let existing = Group(key: nil, label: "Root", stickyMode: nil, actions: [
            .action(Action(key: "a", type: .application, value: "/Applications/App.app")),
        ])
        var s1 = makeSuggestion(id: "1", sequence: "", actionType: .menu, value: "App > File > About", title: "About App")
        s1.category = "Misc"
        let result = CommandScoutService.assignSequences(to: [s1], existingRoot: existing)
        // Should not assign sequence "a" since it's taken
        let assigned = result[0].suggestedSequence
        XCTAssertFalse(assigned.isEmpty)
        XCTAssertNotEqual(CommandScoutSequenceNormalizer.tokens(from: assigned), ["a"])
    }

    func testAssignSequencesPreservesExisting() {
        let suggestion = makeSuggestion(sequence: "t n", actionType: .menu, value: "App > Tab > New")
        let result = CommandScoutService.assignSequences(to: [suggestion], existingRoot: emptyRoot())
        XCTAssertEqual(result[0].suggestedSequence, "tn")
    }

    // MARK: - Menu Inventory JSON Parsing

    func testParseMenuInventoryJSON() {
        let json = """
            {"app":"Safari","items":[{"appName":"Safari","enabled":true,"path":"File > New","title":"New"}]}
            """
        let parsed = CommandScoutService.parseMenuInventoryJSON(json)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.app, "Safari")
        XCTAssertEqual(parsed?.items.count, 1)
        XCTAssertEqual(parsed?.items[0].title, "New")
    }

    func testParseMenuInventoryInvalidJSON() {
        XCTAssertNil(CommandScoutService.parseMenuInventoryJSON("not json"))
        XCTAssertNil(CommandScoutService.parseMenuInventoryJSON(""))
    }

    func testMenuFetchResultPreservesErrorMessage() {
        let result = CommandScoutService.menuFetchResult(appName: "Safari", rawJSON: "ERROR: App not running: Safari")
        XCTAssertTrue(result.items.isEmpty)
        XCTAssertEqual(result.errorMessage, "ERROR: App not running: Safari")
    }

    func testMenuFetchResultDoesNotReturnErrorForValidInventory() {
        let json = """
            {"app":"Safari","items":[{"appName":"Safari","enabled":true,"path":"File > New","title":"New"}]}
            """
        let result = CommandScoutService.menuFetchResult(appName: "Safari", rawJSON: json)
        XCTAssertNil(result.errorMessage)
        XCTAssertEqual(result.items.count, 1)
    }

    // MARK: - AI Parsing and Debug Bundle

    func testParseAISuggestionsSupportsFencedJSON() throws {
        let data = """
            ```json
            {"suggestions":[{"title":"New Tab","category":"Tabs","source":"web","actionType":"shortcut","actionValue":"Cn","confidence":0.8,"sourceNotes":"docs"}]}
            ```
            """.data(using: .utf8)!

        let suggestions = try XCTUnwrap(CommandScoutService.parseAISuggestions(data))
        XCTAssertEqual(suggestions.count, 1)
        XCTAssertEqual(suggestions[0].title, "New Tab")
        XCTAssertEqual(suggestions[0].source, .web)
        XCTAssertEqual(suggestions[0].actionType, .shortcut)
        XCTAssertEqual(suggestions[0].reviewNotes, "docs")
    }

    func testParseAISuggestionsTreatsUnknownActionTypeAsUnsupported() throws {
        let data = """
            [{"title":"Mystery","actionType":"banana","actionValue":"x"}]
            """.data(using: .utf8)!

        let suggestions = try XCTUnwrap(CommandScoutService.parseAISuggestions(data))
        XCTAssertEqual(suggestions[0].actionType, .unsupported)
    }

    func testParseAISuggestionsRekeysDuplicateIDs() throws {
        let data = """
            {"suggestions":[
              {"id":"same","title":"One","actionType":"menu","actionValue":"App > File > One"},
              {"id":"same","title":"Two","actionType":"menu","actionValue":"App > File > Two"}
            ]}
            """.data(using: .utf8)!

        let suggestions = try XCTUnwrap(CommandScoutService.parseAISuggestions(data))
        XCTAssertEqual(suggestions.count, 2)
        XCTAssertNotEqual(suggestions[0].id, suggestions[1].id)
    }

    func testParseAISuggestionsReturnsNilForMalformedJSON() {
        XCTAssertNil(CommandScoutService.parseAISuggestions("not json".data(using: .utf8)!))
    }

    func testParseAISuggestionsResultReportsMalformedJSONDiagnostics() {
        let result = CommandScoutService.parseAISuggestionsResult("not json".data(using: .utf8)!)
        guard case .failure(let diagnostics) = result else {
            return XCTFail("Expected parse failure")
        }

        XCTAssertTrue(diagnostics.failureMessage.contains("AI JSON parse failed"))
        XCTAssertEqual(diagnostics.detectedShape, "invalid")
        XCTAssertTrue(diagnostics.rawPreview.contains("not json"))
    }

    func testParseAISuggestionsSupportsTopLevelJSONString() throws {
        let nestedJSON = #"{"suggestions":[{"title":"New Tab","actionType":"menu","actionValue":"App > File > New","suggestedSequence":"t n"}]}"#
        let wrapped = try JSONSerialization.data(withJSONObject: nestedJSON, options: [.fragmentsAllowed])

        let suggestions = try XCTUnwrap(CommandScoutService.parseAISuggestions(wrapped))
        XCTAssertEqual(suggestions.count, 1)
        XCTAssertEqual(suggestions[0].suggestedSequence, "tn")
    }

    func testParseAISuggestionsCapsOversizedOutput() {
        let items = (0..<65).map { index in
            """
            {"title":"Command \(index)","category":"Misc","source":"ai","actionType":"menu","actionValue":"App > File > Command \(index)","suggestedSequence":"m\(index % 10)","description":"","aiDescription":"","confidence":0.8,"sourceNotes":""}
            """
        }.joined(separator: ",")
        let data = #"{"suggestions":["# + items + #"]}"#
        let result = CommandScoutService.parseAISuggestionsResult(data.data(using: .utf8)!)

        guard case .success(let suggestions, let diagnostics) = result else {
            return XCTFail("Expected parse success")
        }

        XCTAssertEqual(suggestions.count, CommandScoutService.maxAISuggestions)
        XCTAssertEqual(diagnostics.originalCount, 65)
        XCTAssertEqual(diagnostics.keptCount, CommandScoutService.maxAISuggestions)
        XCTAssertTrue(diagnostics.warningMessage?.contains("showing top 60") == true)
    }

    func testDebugBundleRedactsSecrets() {
        let redacted = CommandScoutService.redactSecrets(
            """
            Authorization: Bearer sk-testSECRET123 x-api-key: abcdef1234567890 key=AIzaSECRET123456
            {"apiKey":"jsonSecretValue123", "x-goog-api-key": "googleSecretValue123"}
            """
        )
        XCTAssertFalse(redacted.contains("sk-testSECRET123"))
        XCTAssertFalse(redacted.contains("abcdef1234567890"))
        XCTAssertFalse(redacted.contains("AIzaSECRET123456"))
        XCTAssertFalse(redacted.contains("jsonSecretValue123"))
        XCTAssertFalse(redacted.contains("googleSecretValue123"))
    }

    func testAIProviderErrorSummarizesGeminiQuotaFailure() {
        let error = AIProviderError.httpFailure(
            statusCode: 429,
            body: """
            {"error":{"code":429,"message":"You exceeded your current quota.","status":"RESOURCE_EXHAUSTED"}}
            """
        )

        XCTAssertEqual(
            error.localizedDescription,
            "Provider quota or rate limit exceeded (HTTP 429): You exceeded your current quota."
        )
    }

    func testAIProviderErrorUserFacingGeminiQuotaMessageSuggestsFallbacks() {
        let error = AIProviderError.httpFailure(
            statusCode: 429,
            body: """
            {"error":{"code":429,"message":"You exceeded your current quota.","status":"RESOURCE_EXHAUSTED"}}
            """
        )
        let message = error.userFacingMessage(
            provider: .gemini,
            modelName: "gemini-3-flash-preview"
        )

        XCTAssertTrue(message.contains("Gemini quota or rate limit exceeded for gemini-3-flash-preview"))
        XCTAssertTrue(message.contains("gemini-2.5-flash"))
        XCTAssertFalse(message.contains(#""error""#))
    }

    func testAIProviderErrorUserFacingTimeoutSuggestsRecovery() {
        let error = AIProviderError.requestTimedOut(seconds: 180)
        let message = error.userFacingMessage(
            provider: .gemini,
            modelName: "gemma-4-31b-it"
        )

        XCTAssertTrue(message.contains("Gemini request timed out for gemma-4-31b-it after 180 seconds"))
        XCTAssertTrue(message.contains("disable web research"))
    }

    func testProviderRetryPolicyRetriesRateLimitAndServerErrors() {
        XCTAssertTrue(ProviderRetryPolicy.shouldRetry(statusCode: 429))
        XCTAssertTrue(ProviderRetryPolicy.shouldRetry(statusCode: 500))
        XCTAssertFalse(ProviderRetryPolicy.shouldRetry(statusCode: 400))
        XCTAssertFalse(ProviderRetryPolicy.shouldRetry(statusCode: 401))
    }

    func testProviderRetryPolicyUsesBoundedExponentialDelay() {
        XCTAssertEqual(ProviderRetryPolicy.delayNanoseconds(forAttempt: 1), 1_000_000_000)
        XCTAssertEqual(ProviderRetryPolicy.delayNanoseconds(forAttempt: 2), 2_000_000_000)
        XCTAssertEqual(ProviderRetryPolicy.delayNanoseconds(forAttempt: 4), 8_000_000_000)
    }

    func testProviderRetryPolicyHonorsRetryAfterWithCap() {
        let url = URL(string: "https://example.com")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: 429,
            httpVersion: nil,
            headerFields: ["Retry-After": "20"]
        )

        XCTAssertEqual(
            ProviderRetryPolicy.delayNanoseconds(forAttempt: 1, response: response),
            8_000_000_000
        )
    }

    func testOpenRouterProviderUsesStrictJSONSchemaAndWebPlugin() throws {
        let provider = OpenAIProvider(
            apiKey: "test",
            model: "google/gemini-3.1-flash",
            baseURL: "https://openrouter.ai/api/v1",
            webResearchEnabled: true
        )
        let body = provider.requestBody(system: "system", prompt: "prompt")

        XCTAssertTrue(provider.supportsWebResearch)
        XCTAssertEqual(body["temperature"] as? Double, 0.2)
        XCTAssertEqual(body["max_tokens"] as? Int, 4096)
        let providerPrefs = try XCTUnwrap(body["provider"] as? [String: Any])
        XCTAssertEqual(providerPrefs["require_parameters"] as? Bool, true)

        let responseFormat = try XCTUnwrap(body["response_format"] as? [String: Any])
        XCTAssertEqual(responseFormat["type"] as? String, "json_schema")
        let jsonSchema = try XCTUnwrap(responseFormat["json_schema"] as? [String: Any])
        XCTAssertEqual(jsonSchema["strict"] as? Bool, true)

        let plugins = try XCTUnwrap(body["plugins"] as? [[String: Any]])
        XCTAssertEqual(plugins.first?["id"] as? String, "web")
        XCTAssertEqual(plugins.first?["max_results"] as? Int, 3)
    }

    func testOpenRouterProviderCanBuildRelaxedFallbackRequest() throws {
        let provider = OpenAIProvider(
            apiKey: "test",
            model: "google/gemini-3-flash-preview",
            baseURL: "https://openrouter.ai/api/v1",
            webResearchEnabled: true
        )
        let body = provider.requestBody(
            system: "system",
            prompt: "prompt",
            openRouterMode: .relaxedJSON,
            includeWebPlugin: false
        )

        XCTAssertEqual(body["temperature"] as? Double, 0.2)
        XCTAssertEqual(body["max_tokens"] as? Int, 4096)
        XCTAssertNil(body["provider"])
        XCTAssertNil(body["plugins"])

        let responseFormat = try XCTUnwrap(body["response_format"] as? [String: Any])
        XCTAssertEqual(responseFormat["type"] as? String, "json_object")
        XCTAssertNil(responseFormat["json_schema"])
    }

    func testGenericOpenAICompatibleProviderDoesNotClaimWebResearch() {
        let provider = OpenAIProvider(
            apiKey: "test",
            model: "local/model",
            baseURL: "https://example.com/v1",
            webResearchEnabled: true
        )
        let body = provider.requestBody(system: "system", prompt: "prompt")

        XCTAssertFalse(provider.supportsWebResearch)
        XCTAssertNil(body["plugins"])
        XCTAssertEqual((body["response_format"] as? [String: Any])?["type"] as? String, "json_object")
    }

    func testGemmaModelsSupportGeminiWebResearchTools() {
        XCTAssertTrue(CommandScoutAIProviderKind.gemini.supportsWebResearch(modelName: "gemma-4-31b-it"))
        XCTAssertTrue(CommandScoutAIProviderKind.gemini.supportsWebResearch(modelName: "gemini-2.5-flash"))

        let gemmaProvider = GeminiProvider(apiKey: "test", model: "gemma-4-31b-it", webResearchEnabled: true)
        XCTAssertTrue(gemmaProvider.supportsWebResearch)
        XCTAssertNotNil(gemmaProvider.searchToolPayload["googleSearch"])
        XCTAssertNil(gemmaProvider.generationConfigPayload["responseMimeType"])
        XCTAssertEqual(gemmaProvider.generationConfigPayload["maxOutputTokens"] as? Int, 4096)

        let geminiProvider = GeminiProvider(apiKey: "test", model: "gemini-2.5-flash", webResearchEnabled: true)
        XCTAssertNotNil(geminiProvider.searchToolPayload["google_search"])
    }

    func testGeminiNonWebGenerationUsesJSONMimeMode() {
        let provider = GeminiProvider(apiKey: "test", model: "gemma-4-31b-it", webResearchEnabled: false)

        XCTAssertEqual(provider.generationConfigPayload["responseMimeType"] as? String, "application/json")
        XCTAssertEqual(provider.generationConfigPayload["maxOutputTokens"] as? Int, 4096)
    }

    func testGeminiResponseParserPrefersNonThoughtParts() throws {
        let data = """
        {
          "candidates": [
            {
              "content": {
                "parts": [
                  {"text": "internal reasoning", "thought": true},
                  {"text": "{\\"ok\\":true}"}
                ]
              }
            }
          ]
        }
        """.data(using: .utf8)!
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(ProviderResponseParser.geminiContent(from: json), #"{"ok":true}"#)
    }

    func testGeminiResponseParserFallsBackWhenAllPartsAreVisibleText() throws {
        let data = """
        {
          "candidates": [
            {
              "content": {
                "parts": [
                  {"text": "{\\"ok\\":"},
                  {"text": "true}"}
                ]
              }
            }
          ]
        }
        """.data(using: .utf8)!
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(ProviderResponseParser.geminiContent(from: json), #"{"ok":true}"#)
    }

    func testGeminiResponseParserScansAllCandidatesForVisibleText() throws {
        let data = """
        {
          "candidates": [
            {
              "finishReason": "MAX_TOKENS",
              "content": {
                "parts": []
              }
            },
            {
              "finishReason": "STOP",
              "content": {
                "parts": [
                  {"text": "{\\"ok\\":true}"}
                ]
              }
            }
          ]
        }
        """.data(using: .utf8)!
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(ProviderResponseParser.geminiContent(from: json), #"{"ok":true}"#)
    }

    func testGeminiNoContentDetailsIncludesFinishReasonAndUsage() throws {
        let data = """
        {
          "promptFeedback": {"blockReason": "SAFETY"},
          "candidates": [
            {"finishReason": "MAX_TOKENS", "content": {"parts": []}}
          ],
          "usageMetadata": {
            "promptTokenCount": 100,
            "thoughtsTokenCount": 4096,
            "totalTokenCount": 4196
          }
        }
        """.data(using: .utf8)!
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let details = try XCTUnwrap(ProviderResponseParser.geminiNoContentDetails(from: json))

        XCTAssertTrue(details.contains("prompt blocked: SAFETY"))
        XCTAssertTrue(details.contains("finishReason: MAX_TOKENS"))
        XCTAssertTrue(details.contains("thoughtsTokenCount: 4096"))
    }

    func testAIProviderNoContentUserMessageIncludesDetails() {
        let error = AIProviderError.noContent(details: "finishReason: MAX_TOKENS")
        let message = error.userFacingMessage(
            provider: .gemini,
            modelName: "gemma-4-31b-it"
        )

        XCTAssertTrue(message.contains("Gemini returned no text for gemma-4-31b-it"))
        XCTAssertTrue(message.contains("finishReason: MAX_TOKENS"))
        XCTAssertTrue(message.contains("disable web research"))
    }

    // MARK: - Category Guessing

    func testCategoryFromMenuPath() {
        let items = [
            CommandScoutMenuItem(appName: "App", enabled: true, path: "Edit > Copy", title: "Copy"),
        ]
        let suggestions = CommandScoutService.suggestionsFromMenuItems(items, appName: "App")
        XCTAssertEqual(suggestions[0].category, "Editing")
    }

    // MARK: - Cache

    func testClearMenuCacheRemovesEntries() {
        // Just verify the API exists and doesn't crash
        CommandScoutService.clearMenuCache()
        CommandScoutService.clearMenuCache(appName: "Safari")
    }

    // MARK: - Apply

    func testApplyCommandScoutSuggestionsCreatesCompactMultiKeyPath() throws {
        let session = ConfigEditorSession()
        session.load(root: emptyRoot(), validationErrors: [], selectedConfigKey: "Chrome", preserveExpansion: false)

        let suggestion = makeSuggestion(
            sequence: "b m",
            actionType: .menu,
            value: "Chrome > Bookmarks > Bookmark Manager",
            title: "Bookmark Manager"
        )
        let result = session.applyCommandScoutSuggestions([suggestion])

        XCTAssertEqual(result.insertedCount, 1)
        XCTAssertTrue(result.skippedMessages.isEmpty)
        guard case .group(let group) = session.root.actions.first else {
            return XCTFail("Expected root group")
        }
        XCTAssertEqual(group.key, "b")
        guard case .action(let action) = group.actions.first else {
            return XCTFail("Expected nested action")
        }
        XCTAssertEqual(action.key, "m")
        XCTAssertEqual(action.value, "Chrome > Bookmarks > Bookmark Manager")
    }

    func testApplyCommandScoutSuggestionsReportsSkippedItems() {
        let session = ConfigEditorSession()
        session.load(root: emptyRoot(), validationErrors: [], selectedConfigKey: "Chrome", preserveExpansion: false)

        let result = session.applyCommandScoutSuggestions([
            makeSuggestion(sequence: "", actionType: .menu, value: "Chrome > File > New", title: "Missing Sequence"),
            makeSuggestion(sequence: "x", actionType: .unsupported, value: "noop", title: "Unsupported"),
        ])

        XCTAssertEqual(result.insertedCount, 0)
        XCTAssertEqual(result.skippedMessages.count, 2)
    }

    // MARK: - Helpers

    private func emptyRoot() -> Group {
        Group(key: nil, label: "Root", stickyMode: nil, actions: [])
    }

    private func makeSuggestion(
        id: String = "test",
        sequence: String = "",
        actionType: CommandScoutActionType = .menu,
        value: String = "",
        title: String = "Test"
    ) -> CommandScoutSuggestion {
        CommandScoutSuggestion(
            id: id,
            title: title,
            category: "Misc",
            source: .liveMenu,
            actionType: actionType,
            actionValue: value,
            menuFallbackPaths: [],
            description: "",
            aiDescription: "",
            suggestedSequence: sequence,
            alternatives: [],
            confidence: 0.85,
            conflictStatus: .clear,
            reviewNotes: ""
        )
    }
}

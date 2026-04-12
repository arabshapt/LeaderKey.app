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
        XCTAssertEqual(CommandScoutSequenceNormalizer.normalizedSequence("t > n"), "t n")
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
        XCTAssertTrue(result[0].suggestedSequence.hasPrefix("t "))
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
        XCTAssertEqual(result[0].suggestedSequence, "t n")
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

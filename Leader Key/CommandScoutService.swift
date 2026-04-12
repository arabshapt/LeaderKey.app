import Foundation
import os

class CommandScoutService {

    // MARK: - Menu Inventory Cache

    private static var menuCache: [String: (items: [CommandScoutMenuItem], timestamp: Date)] = [:]
    private static let cacheTTL: TimeInterval = 300  // 5 minutes

    /// Fetch menu items for an app, using cache if fresh.
    /// Must be called from main thread (AX API requirement).
    static func fetchMenuItems(appName: String) -> CommandScoutMenuFetchResult {
        let cacheKey = appName.lowercased()

        if let cached = menuCache[cacheKey],
           Date().timeIntervalSince(cached.timestamp) < cacheTTL {
            return CommandScoutMenuFetchResult(items: cached.items, errorMessage: nil)
        }

        let spid = OSSignpostID(log: signpostLog)
        os_signpost(.begin, log: signpostLog, name: "CommandScout.menuScan", signpostID: spid, "%{public}s", appName)
        let json = KarabinerUserCommandReceiver.listMenuItemsJSON(app: appName)
        let result = menuFetchResult(appName: appName, rawJSON: json)
        if result.errorMessage == nil {
            menuCache[cacheKey] = (items: result.items, timestamp: Date())
        }
        os_signpost(.end, log: signpostLog, name: "CommandScout.menuScan", signpostID: spid)
        return result
    }

    /// Clear cached menu items for an app (or all if nil).
    static func clearMenuCache(appName: String? = nil) {
        if let appName = appName {
            menuCache.removeValue(forKey: appName.lowercased())
        } else {
            menuCache.removeAll()
        }
    }

    /// Full menu scan: fetch + convert + filter. Returns suggestions with no sequences assigned.
    static func scanMenuSuggestions(appName: String) -> [CommandScoutSuggestion] {
        scanMenuSuggestionResult(appName: appName).suggestions
    }

    /// Full menu scan with diagnostics. Returns suggestions with no sequences assigned.
    static func scanMenuSuggestionResult(appName: String) -> CommandScoutMenuSuggestionResult {
        let result = fetchMenuItems(appName: appName)
        return CommandScoutMenuSuggestionResult(
            suggestions: suggestionsFromMenuItems(result.items, appName: appName),
            errorMessage: result.errorMessage
        )
    }

    // MARK: - Validation

    /// Validate a list of suggestions against each other and an existing config root.
    /// Returns suggestions with updated `conflictStatus` fields.
    static func validate(
        suggestions: [CommandScoutSuggestion],
        existingRoot: Group
    ) -> [CommandScoutSuggestion] {
        let existingKeys = collectExistingSequences(from: existingRoot)
        let existingActionSignatures = collectExistingActionSignatures(from: existingRoot)
        var seenSequences = Set<String>()
        var seenActions = Set<String>()
        var result: [CommandScoutSuggestion] = []

        for var suggestion in suggestions {
            let tokens = suggestion.sequenceTokens
            let normalizedSeq = tokens.joined(separator: " ")
            let actionSig = actionSignature(type: suggestion.actionType, value: suggestion.actionValue)

            if tokens.isEmpty {
                suggestion.conflictStatus = .invalidSequence
            } else if existingKeys.contains(normalizedSeq) {
                suggestion.conflictStatus = .duplicateSequence
            } else if !seenSequences.insert(normalizedSeq).inserted {
                suggestion.conflictStatus = .duplicateSequence
            } else if suggestion.actionType == .unsupported {
                suggestion.conflictStatus = .unsupportedAction
            } else if !isValidActionValue(type: suggestion.actionType, value: suggestion.actionValue) {
                suggestion.conflictStatus = .invalidActionValue
            } else if existingActionSignatures.contains(actionSig) || !seenActions.insert(actionSig).inserted {
                suggestion.conflictStatus = .duplicateAction
            } else {
                suggestion.conflictStatus = .clear
            }

            result.append(suggestion)
        }

        return result
    }

    // MARK: - Menu Suggestions

    /// Noise menu titles to skip by default.
    static let filteredMenuTitles: Set<String> = [
        "About", "Services", "Hide", "Hide Others", "Show All", "Quit",
    ]

    /// Convert menu inventory items into suggestions.
    static func suggestionsFromMenuItems(
        _ items: [CommandScoutMenuItem],
        appName: String
    ) -> [CommandScoutSuggestion] {
        items.compactMap { item -> CommandScoutSuggestion? in
            guard item.enabled else { return nil }
            guard !isFilteredMenuItem(title: item.title, path: item.path) else { return nil }

            let category = guessCategory(from: item.path)

            return CommandScoutSuggestion(
                id: UUID().uuidString,
                title: item.title,
                category: category,
                source: .liveMenu,
                actionType: .menu,
                actionValue: "\(appName) > \(item.path)",
                menuFallbackPaths: [],
                description: item.path,
                aiDescription: "",
                suggestedSequence: "",
                alternatives: [],
                confidence: 0.85,
                conflictStatus: .clear,
                reviewNotes: ""
            )
        }
    }

    /// Assign mnemonic sequences to suggestions that don't have one.
    static func assignSequences(
        to suggestions: [CommandScoutSuggestion],
        existingRoot: Group,
        reservedKeys: [String] = []
    ) -> [CommandScoutSuggestion] {
        let existingKeys = collectExistingSequences(from: existingRoot)
        var usedSequences = existingKeys.union(Set(reservedKeys))
        var result: [CommandScoutSuggestion] = []

        for var suggestion in suggestions {
            if !suggestion.suggestedSequence.isEmpty {
                result.append(suggestion)
                continue
            }

            let prefix = categoryPrefix(for: suggestion.category)
            let mnemonic = mnemonic(for: suggestion.title)

            // Try: prefix + mnemonic
            let candidate = "\(prefix) \(mnemonic)"
            if usedSequences.insert(candidate).inserted {
                suggestion.suggestedSequence = candidate
            } else {
                // Try: prefix + first letter of title
                let firstLetter = String(suggestion.title.lowercased().prefix(1))
                let fallback = "\(prefix) \(firstLetter)"
                if usedSequences.insert(fallback).inserted {
                    suggestion.suggestedSequence = fallback
                    suggestion.reviewNotes = "Mnemonic '\(candidate)' taken, using '\(fallback)'"
                } else {
                    // 3-key fallback
                    let threeKey = "\(prefix) \(firstLetter) \(mnemonic)"
                    if usedSequences.insert(threeKey).inserted {
                        suggestion.suggestedSequence = threeKey
                        suggestion.reviewNotes = "Collision: using 3-key sequence"
                    }
                }
            }

            result.append(suggestion)
        }

        return result
    }

    // MARK: - Parse Menu Inventory JSON

    /// Decode menu inventory JSON (from `listMenuItemsJSON`) into items.
    static func parseMenuInventoryJSON(_ json: String) -> (app: String, items: [CommandScoutMenuItem])? {
        guard let data = json.data(using: .utf8) else { return nil }
        guard let response = try? JSONDecoder().decode(CommandScoutMenuInventoryResponse.self, from: data) else {
            return nil
        }
        return (app: response.app, items: response.items)
    }

    static func menuFetchResult(appName: String, rawJSON json: String) -> CommandScoutMenuFetchResult {
        if json.hasPrefix("ERROR:") {
            return CommandScoutMenuFetchResult(items: [], errorMessage: json)
        }
        guard let parsed = parseMenuInventoryJSON(json) else {
            return CommandScoutMenuFetchResult(
                items: [],
                errorMessage: "Failed to parse menu inventory for \(appName)"
            )
        }
        return CommandScoutMenuFetchResult(items: parsed.items, errorMessage: nil)
    }

    // MARK: - Private Helpers

    /// Collect all existing key sequences from config tree as normalized strings.
    private static func collectExistingSequences(from group: Group, prefix: [String] = []) -> Set<String> {
        var sequences = Set<String>()
        for item in group.actions {
            switch item {
            case .action(let action):
                if let key = action.key, !key.isEmpty {
                    let seq = (prefix + [key.lowercased()]).joined(separator: " ")
                    sequences.insert(seq)
                }
            case .group(let subgroup):
                if let key = subgroup.key, !key.isEmpty {
                    let subPrefix = prefix + [key.lowercased()]
                    let seq = subPrefix.joined(separator: " ")
                    sequences.insert(seq)
                    sequences.formUnion(collectExistingSequences(from: subgroup, prefix: subPrefix))
                }
            }
        }
        return sequences
    }

    private static func collectExistingActionSignatures(from group: Group) -> Set<String> {
        var signatures = Set<String>()
        for item in group.actions {
            switch item {
            case .action(let action):
                if let actionType = CommandScoutActionType(rawValue: action.type.rawValue) {
                    signatures.insert(actionSignature(type: actionType, value: action.value))
                }
            case .group(let subgroup):
                signatures.formUnion(collectExistingActionSignatures(from: subgroup))
            }
        }
        return signatures
    }

    private static func actionSignature(type: CommandScoutActionType, value: String) -> String {
        "\(type.rawValue):\(value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())"
    }

    private static func isValidActionValue(type: CommandScoutActionType, value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }

        switch type {
        case .menu:
            // Must contain " > " separator: "App > Menu > Item"
            return trimmed.contains(" > ") && trimmed.components(separatedBy: " > ").count >= 2
        case .shortcut, .keystroke, .url, .command, .application:
            return true
        case .macro, .unsupported:
            return false
        }
    }

    private static func isFilteredMenuItem(title: String, path: String) -> Bool {
        if filteredMenuTitles.contains(title) { return true }
        // Filter "Help > " search entries (dynamic search field items)
        if path.hasPrefix("Help > ") && path.components(separatedBy: " > ").count <= 2 { return false }
        return false
    }

    // MARK: - Category Guessing

    private static let categoryKeywords: [(keywords: [String], category: String)] = [
        (["Tab", "Tabs"], "Tabs"),
        (["Window", "Windows", "Arrange", "Minimize", "Zoom"], "Windows"),
        (["Navigate", "Go", "Back", "Forward", "Jump"], "Navigation"),
        (["Edit", "Copy", "Paste", "Cut", "Undo", "Redo", "Find", "Replace", "Select"], "Editing"),
        (["View", "Sidebar", "Toolbar", "Show", "Hide", "Toggle", "Appearance"], "View"),
        (["Developer", "Inspect", "Console", "Debug", "Source"], "Developer Tools"),
        (["Bookmark", "Bookmarks", "Favorite", "Favorites"], "Bookmarks"),
        (["Search", "Find"], "Search"),
        (["History", "Recent", "Reopen"], "History"),
    ]

    private static func guessCategory(from path: String) -> String {
        let components = path.components(separatedBy: " > ")
        // First menu level is usually the category
        if let topMenu = components.first {
            for (keywords, category) in categoryKeywords {
                if keywords.contains(where: { topMenu.localizedCaseInsensitiveContains($0) }) {
                    return category
                }
            }
        }
        // Check full path
        for (keywords, category) in categoryKeywords {
            if keywords.contains(where: { path.localizedCaseInsensitiveContains($0) }) {
                return category
            }
        }
        return "Misc"
    }

    // MARK: - Sequence Mnemonics

    private static let categoryPrefixes: [String: String] = [
        "Tabs": "t", "Windows": "w", "Navigation": "n", "Editing": "e",
        "View": "v", "Developer Tools": "d", "Bookmarks": "b",
        "Search": "s", "History": "h", "Misc": "m",
    ]

    private static func categoryPrefix(for category: String) -> String {
        categoryPrefixes[category] ?? "m"
    }

    private static func mnemonic(for title: String) -> String {
        let cleaned = title
            .replacingOccurrences(of: "...", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        // Use first consonant after first letter, or second letter
        let chars = Array(cleaned.filter { $0.isLetter })
        guard chars.count >= 2 else {
            return String(chars.first ?? Character("x"))
        }

        let consonants = "bcdfghjklmnpqrstvwxyz"
        for char in chars.dropFirst() {
            if consonants.contains(char) {
                return String(char)
            }
        }
        return String(chars[1])
    }

    // MARK: - AI Parsing and Debug Bundle

    static func parseAISuggestions(_ data: Data) -> [CommandScoutSuggestion]? {
        struct AIResponse: Codable {
            var suggestions: [AISuggestionItem]?
        }

        struct AISuggestionItem: Codable {
            var id: String?
            var title: String?
            var category: String?
            var source: String?
            var actionType: String?
            var actionValue: String?
            var description: String?
            var aiDescription: String?
            var confidence: Double?
            var sourceNotes: String?
        }

        let jsonData = normalizedJSONData(from: data)
        let items: [AISuggestionItem]
        if let response = try? JSONDecoder().decode(AIResponse.self, from: jsonData),
           let suggestions = response.suggestions {
            items = suggestions
        } else if let array = try? JSONDecoder().decode([AISuggestionItem].self, from: jsonData) {
            items = array
        } else {
            return nil
        }

        var usedIDs = Set<String>()
        return items.compactMap { item -> CommandScoutSuggestion? in
            guard let title = item.title?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !title.isEmpty,
                  let value = item.actionValue?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !value.isEmpty
            else { return nil }

            let proposedID = item.id?.trimmingCharacters(in: .whitespacesAndNewlines)
            let id: String
            if let proposedID, !proposedID.isEmpty, !usedIDs.contains(proposedID) {
                id = proposedID
            } else {
                id = UUID().uuidString
            }
            usedIDs.insert(id)

            return CommandScoutSuggestion(
                id: id,
                title: title,
                category: item.category?.nilIfBlank ?? "Misc",
                source: CommandScoutSuggestionSource(rawValue: item.source ?? "") ?? .ai,
                actionType: CommandScoutActionType(rawValue: item.actionType ?? "") ?? .unsupported,
                actionValue: value,
                menuFallbackPaths: [],
                description: item.description ?? "",
                aiDescription: item.aiDescription ?? "",
                suggestedSequence: "",
                alternatives: [],
                confidence: item.confidence ?? 0.6,
                conflictStatus: .clear,
                reviewNotes: item.sourceNotes ?? ""
            )
        }
    }

    static func debugBundle(
        appName: String,
        bundleId: String,
        statusMessage: String,
        scanError: String?,
        providerSettings: CommandScoutProviderSettings,
        suggestions: [CommandScoutSuggestion]
    ) -> String {
        let payload: [String: Any] = [
            "appName": appName,
            "bundleId": bundleId,
            "statusMessage": statusMessage,
            "scanError": scanError ?? "",
            "provider": providerSettings.providerKind.rawValue,
            "model": providerSettings.effectiveModelName,
            "webResearchEnabled": providerSettings.webResearchEnabled,
            "suggestionCount": suggestions.count,
            "suggestions": suggestions.map { suggestion in
                [
                    "title": suggestion.title,
                    "category": suggestion.category,
                    "source": suggestion.source.rawValue,
                    "actionType": suggestion.actionType.rawValue,
                    "actionValue": suggestion.actionValue,
                    "sequence": suggestion.suggestedSequence,
                    "confidence": suggestion.confidence,
                    "conflictStatus": suggestion.conflictStatus.rawValue,
                    "reviewNotes": suggestion.reviewNotes,
                ] as [String: Any]
            },
        ]

        let data = (try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys])) ?? Data()
        let text = String(data: data, encoding: .utf8) ?? "{}"
        return redactSecrets(text)
    }

    static func redactSecrets(_ text: String) -> String {
        let patterns = [
            #"Bearer\s+[A-Za-z0-9._\-]+"#,
            #"["']?(x-api-key|x-goog-api-key|Authorization)["']?\s*[:=]\s*["']?[A-Za-z0-9._\-]+"#,
            #"["']?(api[_-]?key|key)["']?\s*[:=]\s*["']?[A-Za-z0-9._\-]{12,}"#,
        ]
        var result = text
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                result = regex.stringByReplacingMatches(
                    in: result,
                    range: NSRange(result.startIndex..., in: result),
                    withTemplate: "[REDACTED]"
                )
            }
        }
        return result
    }

    private static func normalizedJSONData(from data: Data) -> Data {
        guard let text = String(data: data, encoding: .utf8) else { return data }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("```") else { return data }

        let lines = trimmed.components(separatedBy: .newlines)
        let body = lines
            .dropFirst()
            .dropLast(lines.last?.trimmingCharacters(in: .whitespacesAndNewlines) == "```" ? 1 : 0)
            .joined(separator: "\n")
        return body.data(using: .utf8) ?? data
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

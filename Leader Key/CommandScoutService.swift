import Foundation
import os

final class CommandScoutMenuCache {
    private struct Entry {
        let items: [CommandScoutMenuItem]
        let timestamp: Date
    }

    private let lock = NSLock()
    private var entries: [String: Entry] = [:]

    func items(for key: String, now: Date = Date(), ttl: TimeInterval) -> [CommandScoutMenuItem]? {
        lock.lock()
        defer { lock.unlock() }
        guard let entry = entries[key], now.timeIntervalSince(entry.timestamp) < ttl else {
            entries.removeValue(forKey: key)
            return nil
        }
        return entry.items
    }

    func store(_ items: [CommandScoutMenuItem], for key: String, timestamp: Date = Date()) {
        lock.lock()
        entries[key] = Entry(items: items, timestamp: timestamp)
        lock.unlock()
    }

    func clear(key: String? = nil) {
        lock.lock()
        if let key {
            entries.removeValue(forKey: key)
        } else {
            entries.removeAll()
        }
        lock.unlock()
    }
}

class CommandScoutService {
    static let maxAISuggestions = 60

    // MARK: - Menu Inventory Cache

    private static let menuCache = CommandScoutMenuCache()
    private static let cacheTTL: TimeInterval = 300  // 5 minutes

    /// Fetch menu items for an app, using cache if fresh.
    static func fetchMenuItems(appName: String) async -> CommandScoutMenuFetchResult {
        let cacheKey = appName.lowercased()

        if let cachedItems = menuCache.items(for: cacheKey, ttl: cacheTTL) {
            return CommandScoutMenuFetchResult(items: cachedItems, errorMessage: nil)
        }

        let spid = OSSignpostID(log: signpostLog)
        os_signpost(.begin, log: signpostLog, name: "CommandScout.menuScan", signpostID: spid, "%{public}s", appName)
        let json = await Task.detached(priority: .userInitiated) {
            KarabinerUserCommandReceiver.listMenuItemsJSON(app: appName)
        }.value
        let result = menuFetchResult(appName: appName, rawJSON: json)
        if result.errorMessage == nil {
            menuCache.store(result.items, for: cacheKey)
        }
        os_signpost(.end, log: signpostLog, name: "CommandScout.menuScan", signpostID: spid)
        return result
    }

    /// Clear cached menu items for an app (or all if nil).
    static func clearMenuCache(appName: String? = nil) {
        if let appName = appName {
            menuCache.clear(key: appName.lowercased())
        } else {
            menuCache.clear()
        }
    }

    /// Full menu scan: fetch + convert + filter. Returns suggestions with no sequences assigned.
    static func scanMenuSuggestions(appName: String) async -> [CommandScoutSuggestion] {
        await scanMenuSuggestionResult(appName: appName).suggestions
    }

    /// Full menu scan with diagnostics. Returns suggestions with no sequences assigned.
    static func scanMenuSuggestionResult(appName: String) async -> CommandScoutMenuSuggestionResult {
        let result = await fetchMenuItems(appName: appName)
        return CommandScoutMenuSuggestionResult(
            suggestions: suggestionsFromMenuItems(result.items, appName: appName),
            errorMessage: result.errorMessage
        )
    }

    static func resolvedScanMode(
        aiEnabled: Bool,
        menuResult: CommandScoutMenuSuggestionResult
    ) -> CommandScoutScanMode {
        guard aiEnabled else { return .menuOnly }
        if menuResult.suggestions.isEmpty, menuResult.errorMessage != nil {
            return .aiOnly
        }
        return .menuAndAI
    }

    static func runAIInventoryScan(
        provider: AIProviderClient,
        target: CommandScoutTarget,
        existingRoot: Group,
        menuSuggestions: [CommandScoutSuggestion],
        settings: CommandScoutProviderSettings
    ) async throws -> CommandScoutAIInventoryResult {
        let existingKeys = existingRoot.actions.compactMap { item -> String? in
            switch item {
            case .action(let action): return action.key
            case .group(let group): return group.key
            case .layer(let layer): return layer.key
            }
        }
        let configSummary = existingKeys.isEmpty ? "Empty" : existingKeys.joined(separator: ", ")
        let promptInventory = menuSuggestions.map { suggestion in
            [
                "actionValue": suggestion.actionValue,
                "shortcut": suggestion.shortcut ?? "",
            ]
        }
        let menuItemsJSON: String
        if let data = try? JSONSerialization.data(
            withJSONObject: promptInventory,
            options: [.sortedKeys]
        ), let encoded = String(data: data, encoding: .utf8) {
            menuItemsJSON = encoded
        } else {
            menuItemsJSON = "[]"
        }

        let prompt = CommandScoutPrompts.inventoryPrompt(
            target: target,
            existingConfigSummary: configSummary,
            fallbackSummary: "N/A",
            menuItemsJSON: menuItemsJSON,
            webResearchEnabled: settings.webResearchEnabled && provider.supportsWebResearch
        )
        let data = try await provider.generateJSON(
            system: CommandScoutPrompts.systemPrompt(for: target),
            prompt: prompt
        )

        switch parseAISuggestionsResult(data) {
        case .success(let aiSuggestions, let diagnostics):
            let scopedAISuggestions = aiSuggestions.compactMap { suggestion -> CommandScoutSuggestion? in
                guard target.allowedActionTypes.contains(suggestion.actionType) else { return nil }
                var scopedSuggestion = suggestion
                if target == .global, scopedSuggestion.actionType == .command {
                    let reviewNote = "Review this command before applying it."
                    if scopedSuggestion.reviewNotes.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ).isEmpty {
                        scopedSuggestion.reviewNotes = reviewNote
                    } else if !scopedSuggestion.reviewNotes.contains(reviewNote) {
                        scopedSuggestion.reviewNotes += " \(reviewNote)"
                    }
                }
                return scopedSuggestion
            }
            let mergeResult = mergeMenuAndAISuggestions(
                menuSuggestions: target.supportsMenuInventory ? menuSuggestions : [],
                aiSuggestions: scopedAISuggestions
            )
            return .success(
                CommandScoutAIInventorySuccess(
                    suggestions: mergeResult.suggestions,
                    aiSuggestionCount: scopedAISuggestions.count,
                    addedCount: mergeResult.addedCount,
                    diagnostics: diagnostics
                ))
        case .failure(let diagnostics):
            return .parseFailure(diagnostics)
        }
    }

    // MARK: - Validation

    /// Validate a list of suggestions against each other and an existing config root.
    /// Returns suggestions with updated `conflictStatus` fields.
    static func validate(
        suggestions: [CommandScoutSuggestion],
        existingRoot: Group
    ) -> [CommandScoutSuggestion] {
        var sequenceTrie = CommandScoutSequenceTrie(root: existingRoot)
        let existingActionSignatures = collectExistingActionSignatures(from: existingRoot)
        var seenActions = Set<String>()
        var result: [CommandScoutSuggestion] = []

        for var suggestion in suggestions {
            let tokens = suggestion.sequenceTokens
            let normalizedSeq = CommandScoutSequenceNormalizer.normalizedSequence(suggestion.suggestedSequence)
            let actionSig = actionSignature(type: suggestion.actionType, value: suggestion.actionValue)
            suggestion.suggestedSequence = normalizedSeq

            let sequenceFeasibility = sequenceTrie.feasibility(for: tokens)
            if !isValidSequenceTokens(tokens) {
                suggestion.conflictStatus = .invalidSequence
            } else if case .available = sequenceFeasibility {
                if suggestion.actionType == .unsupported {
                    suggestion.conflictStatus = .unsupportedAction
                } else if !isValidActionValue(type: suggestion.actionType, value: suggestion.actionValue) {
                    suggestion.conflictStatus = .invalidActionValue
                } else if existingActionSignatures.contains(actionSig) || seenActions.contains(actionSig) {
                    suggestion.conflictStatus = .duplicateAction
                } else {
                    suggestion.conflictStatus = .clear
                    seenActions.insert(actionSig)
                    _ = sequenceTrie.reserve(tokens)
                }
            } else {
                suggestion.conflictStatus = .duplicateSequence
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
                reviewNotes: "",
                shortcut: item.shortcut
            )
        }
    }

    /// Merge AI enrichment into native menu suggestions. Menu paths are
    /// case-folded and whitespace-normalized; every other action value keeps
    /// exact case so URLs and shortcut specifications are never conflated.
    static func mergeMenuAndAISuggestions(
        menuSuggestions: [CommandScoutSuggestion],
        aiSuggestions: [CommandScoutSuggestion]
    ) -> CommandScoutSuggestionMergeResult {
        var merged = menuSuggestions
        var menuIndexByIdentity: [String: Int] = [:]
        for (index, suggestion) in menuSuggestions.enumerated() {
            let identity = actionIdentity(type: suggestion.actionType, value: suggestion.actionValue)
            if menuIndexByIdentity[identity] == nil {
                menuIndexByIdentity[identity] = index
            }
        }

        var addedCount = 0
        for aiSuggestion in aiSuggestions {
            let identity = actionIdentity(
                type: aiSuggestion.actionType,
                value: aiSuggestion.actionValue
            )
            if let index = menuIndexByIdentity[identity] {
                if !aiSuggestion.suggestedSequence.isEmpty {
                    merged[index].suggestedSequence = CommandScoutSequenceNormalizer.normalizedSequence(
                        aiSuggestion.suggestedSequence)
                }
                if !aiSuggestion.aiDescription.isEmpty {
                    merged[index].aiDescription = aiSuggestion.aiDescription
                }
                if !aiSuggestion.category.isEmpty && aiSuggestion.category != "Misc" {
                    merged[index].category = aiSuggestion.category
                }
            } else {
                var unverifiedSuggestion = aiSuggestion
                if unverifiedSuggestion.actionType == .menu {
                    unverifiedSuggestion.source = .ai
                    unverifiedSuggestion.confidence = min(unverifiedSuggestion.confidence, 0.7)
                    let reviewNote = "Unverified AI menu path; review it against the app before applying."
                    if unverifiedSuggestion.reviewNotes.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ).isEmpty {
                        unverifiedSuggestion.reviewNotes = reviewNote
                    } else {
                        unverifiedSuggestion.reviewNotes += " \(reviewNote)"
                    }
                }
                merged.append(unverifiedSuggestion)
                addedCount += 1
            }
        }

        return CommandScoutSuggestionMergeResult(suggestions: merged, addedCount: addedCount)
    }

    /// Assign mnemonic sequences to suggestions that don't have one.
    static func assignSequences(
        to suggestions: [CommandScoutSuggestion],
        existingRoot: Group,
        reservedKeys: [String] = [],
        usageSnapshot: UsageStatsSnapshot = .empty,
        usageContext: UsageContext? = nil
    ) -> [CommandScoutSuggestion] {
        var sequenceTrie = CommandScoutSequenceTrie(root: existingRoot)
        for reservedKey in reservedKeys {
            let tokens = CommandScoutSequenceNormalizer.tokens(from: reservedKey)
            if isValidSequenceTokens(tokens) {
                _ = sequenceTrie.reserve(tokens)
            }
        }
        var result: [CommandScoutSuggestion] = []

        for var suggestion in suggestions {
            if !suggestion.suggestedSequence.isEmpty {
                suggestion.suggestedSequence = CommandScoutSequenceNormalizer.normalizedSequence(suggestion.suggestedSequence)
                if isValidSequenceTokens(suggestion.sequenceTokens),
                    sequenceTrie.reserve(suggestion.sequenceTokens)
                {
                    result.append(suggestion)
                    continue
                }
                suggestion.reviewNotes = "Proposed path was structurally unavailable; assigned a free alternative"
                suggestion.suggestedSequence = ""
            }

            let candidateBatches = sequenceCandidateBatches(for: suggestion)
            if let candidate = bestAvailableCandidate(
                in: candidateBatches,
                trie: sequenceTrie,
                usageSnapshot: usageSnapshot,
                usageContext: usageContext
            ) {
                suggestion.suggestedSequence = candidate.sequence
                _ = sequenceTrie.reserve(suggestion.sequenceTokens)
                if candidate.batchIndex > 0 || candidate.candidateIndex > 0 {
                    let structuralNote = suggestion.reviewNotes.isEmpty ? "" : "\(suggestion.reviewNotes). "
                    suggestion.reviewNotes = "\(structuralNote)Using free fallback '\(candidate.sequence)'"
                }
            } else {
                suggestion.reviewNotes = "No free sequence candidate in the 1-3 key namespace"
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
            case .layer(let layer):
                if let tapAction = layer.tapAction,
                    let actionType = CommandScoutActionType(rawValue: tapAction.type.rawValue)
                {
                    signatures.insert(actionSignature(type: actionType, value: tapAction.value))
                }
                signatures.formUnion(
                    collectExistingActionSignatures(
                        from: Group(
                            key: layer.key,
                            label: layer.label,
                            iconPath: layer.iconPath,
                            stickyMode: nil,
                            actions: layer.actions
                        )
                    )
                )
            }
        }
        return signatures
    }

    static func actionIdentity(type: CommandScoutActionType, value: String) -> String {
        let normalizedValue: String
        if type == .menu {
            normalizedValue = value.components(separatedBy: ">")
                .map { component in
                    component.split(whereSeparator: \.isWhitespace).joined(separator: " ")
                }
                .joined(separator: ">")
                .lowercased(with: Locale(identifier: "en_US_POSIX"))
        } else {
            normalizedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return "\(type.rawValue):\(normalizedValue)"
    }

    private static func actionSignature(type: CommandScoutActionType, value: String) -> String {
        actionIdentity(type: type, value: value)
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

    private static func isValidSequenceTokens(_ tokens: [String]) -> Bool {
        guard !tokens.isEmpty, tokens.count <= 3 else { return false }
        return tokens.allSatisfy(CommandScoutSequenceNormalizer.isAllowedToken)
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

    private static func sequenceCandidateBatches(for suggestion: CommandScoutSuggestion) -> [[String]] {
        let prefix = categoryPrefix(for: suggestion.category)
        let lowerMnemonic = mnemonic(for: suggestion.title).lowercased()
        let upperMnemonic = lowerMnemonic.uppercased()
        var suffixes = [lowerMnemonic, upperMnemonic]
        suffixes.append(contentsOf: CommandScoutSequenceNormalizer.punctuationTokens)

        let titleLetters = suggestion.title.lowercased().compactMap { character -> String? in
            let token = String(character)
            guard CommandScoutSequenceNormalizer.isAllowedToken(token), character.isLetter else {
                return nil
            }
            return token
        }
        for token in titleLetters where !suffixes.contains(token) {
            suffixes.append(token)
            suffixes.append(token.uppercased())
        }

        var seen = Set<String>()
        func uniqueValidBatch(_ candidates: [String]) -> [String] {
            candidates.filter { candidate in
                let tokens = CommandScoutSequenceNormalizer.tokens(from: candidate)
                return isValidSequenceTokens(tokens) && seen.insert(candidate).inserted
            }
        }

        let punctuationCount = CommandScoutSequenceNormalizer.punctuationTokens.count
        let titleSuffixes = suffixes.dropFirst(2 + punctuationCount)
        var batches = [
            uniqueValidBatch([prefix + lowerMnemonic]),
            uniqueValidBatch([prefix + upperMnemonic]),
            uniqueValidBatch(
                CommandScoutSequenceNormalizer.punctuationTokens.map { prefix + $0 }
            ),
        ]
        batches.append(contentsOf: titleSuffixes.map { uniqueValidBatch([prefix + $0]) })
        batches.append(
            contentsOf: suffixes.map { suffix in
                uniqueValidBatch([
                    prefix + lowerMnemonic + suffix,
                    prefix + upperMnemonic + suffix,
                ])
            })
        batches.append(contentsOf: suffixes.map { uniqueValidBatch([$0]) })
        return batches.filter { !$0.isEmpty }
    }

    private static func bestAvailableCandidate(
        in batches: [[String]],
        trie: CommandScoutSequenceTrie,
        usageSnapshot: UsageStatsSnapshot,
        usageContext: UsageContext?
    ) -> (sequence: String, batchIndex: Int, candidateIndex: Int)? {
        for (batchIndex, batch) in batches.enumerated() {
            let feasible = batch.enumerated().compactMap { candidateIndex, sequence
                -> (sequence: String, penalty: Int, usageCount: Int, candidateIndex: Int)? in
                let tokens = CommandScoutSequenceNormalizer.tokens(from: sequence)
                guard case .available(let physicalPenalty) = trie.feasibility(for: tokens) else {
                    return nil
                }
                let usageCount = usageContext.map {
                    usageSnapshot.count(context: $0, keys: tokens)
                } ?? 0
                return (sequence, physicalPenalty, usageCount, candidateIndex)
            }
            if let best = feasible.min(by: { lhs, rhs in
                if lhs.penalty != rhs.penalty {
                    return lhs.penalty < rhs.penalty
                }
                if lhs.usageCount != rhs.usageCount {
                    return lhs.usageCount > rhs.usageCount
                }
                return lhs.candidateIndex < rhs.candidateIndex
            }) {
                return (best.sequence, batchIndex, best.candidateIndex)
            }
        }
        return nil
    }

    // MARK: - AI Parsing and Debug Bundle

    static func parseAISuggestions(_ data: Data) -> [CommandScoutSuggestion]? {
        if case .success(let suggestions, _) = parseAISuggestionsResult(data) {
            return suggestions
        }
        return nil
    }

    static func parseAISuggestionsResult(_ data: Data) -> CommandScoutAIParseResult {
        let rawPreview = redactedPreview(from: data)

        guard let top = parseTopLevelJSON(from: data) else {
            return .failure(CommandScoutAIParseDiagnostics(
                reason: "response is not valid JSON and no embedded JSON block was found",
                detectedShape: "invalid",
                rawPreview: rawPreview,
                originalCount: 0,
                keptCount: 0
            ))
        }

        guard let rawItems = suggestionItems(from: top) else {
            return .failure(CommandScoutAIParseDiagnostics(
                reason: "expected a suggestions array or direct array",
                detectedShape: shapeDescription(for: top),
                rawPreview: rawPreview,
                originalCount: 0,
                keptCount: 0
            ))
        }

        var usedIDs = Set<String>()
        let suggestions = rawItems.compactMap { item -> CommandScoutSuggestion? in
            let title = (item["title"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
            let value = (item["actionValue"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let title, !title.isEmpty, let value, !value.isEmpty else { return nil }

            let proposedID = (item["id"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
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
                category: (item["category"] as? String)?.nilIfBlank ?? "Misc",
                source: CommandScoutSuggestionSource(rawValue: item["source"] as? String ?? "") ?? .ai,
                actionType: CommandScoutActionType(rawValue: (item["actionType"] as? String ?? "").lowercased()) ?? .unsupported,
                actionValue: value,
                menuFallbackPaths: [],
                description: item["description"] as? String ?? "",
                aiDescription: item["aiDescription"] as? String ?? "",
                suggestedSequence: CommandScoutSequenceNormalizer.normalizedSequence(
                    (item["suggestedSequence"] as? String)?.nilIfBlank ?? ""
                ),
                alternatives: parseAlternatives(item["alternatives"]),
                confidence: parseConfidence(item["confidence"]),
                conflictStatus: .clear,
                reviewNotes: item["sourceNotes"] as? String ?? "",
                shortcut: item["shortcut"] as? String
            )
        }

        guard !suggestions.isEmpty else {
            return .failure(CommandScoutAIParseDiagnostics(
                reason: "no usable suggestions contained title and actionValue",
                detectedShape: shapeDescription(for: top),
                rawPreview: rawPreview,
                originalCount: rawItems.count,
                keptCount: 0
            ))
        }

        let capped = cappedSuggestions(suggestions)
        let diagnostics = CommandScoutAIParseDiagnostics(
            reason: "parsed",
            detectedShape: shapeDescription(for: top),
            rawPreview: rawPreview,
            originalCount: suggestions.count,
            keptCount: capped.count
        )
        return .success(suggestions: capped, diagnostics: diagnostics)
    }

    static func debugBundle(
        appName: String,
        bundleId: String,
        statusMessage: String,
        scanError: String?,
        providerSettings: CommandScoutProviderSettings,
        suggestions: [CommandScoutSuggestion],
        aiParseDiagnostics: CommandScoutAIParseDiagnostics? = nil
    ) -> String {
        let payload: [String: Any] = [
            "appName": appName,
            "bundleId": bundleId,
            "statusMessage": statusMessage,
            "scanError": scanError ?? "",
            "aiParseDiagnostics": aiParseDiagnostics.map { diagnostics in
                [
                    "reason": diagnostics.reason,
                    "detectedShape": diagnostics.detectedShape,
                    "originalCount": diagnostics.originalCount,
                    "keptCount": diagnostics.keptCount,
                    "rawPreview": diagnostics.rawPreview,
                ] as [String: Any]
            } ?? [:],
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
                    "shortcut": suggestion.shortcut ?? "",
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

    /// Parse confidence from AI response — handles Double (0.9), String ("0.9"), or word ("high").
    private static func parseConfidence(_ value: Any?) -> Double {
        if let d = value as? Double { return d }
        if let i = value as? Int { return Double(i) }
        if let s = value as? String {
            if let d = Double(s) { return d }
            switch s.lowercased() {
            case "high": return 0.9
            case "medium": return 0.6
            case "low": return 0.3
            default: return 0.6
            }
        }
        return 0.6
    }

    private static func parseAlternatives(_ value: Any?) -> [String] {
        guard let alternatives = value as? [String] else { return [] }
        return alternatives
            .map(CommandScoutSequenceNormalizer.normalizedSequence)
            .filter { !$0.isEmpty }
    }

    private static func parseTopLevelJSON(from data: Data) -> Any? {
        if let top = parseJSONObject(from: data) {
            return top
        }

        let jsonData = normalizedJSONData(from: data)
        guard jsonData != data else { return nil }
        return parseJSONObject(from: jsonData)
    }

    private static func parseJSONObject(from data: Data) -> Any? {
        guard let top = try? JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) else { return nil }
        if let string = top as? String {
            let stringData = Data(string.utf8)
            if let nested = parseJSONObject(from: stringData) {
                return nested
            }

            let normalizedStringData = normalizedJSONData(from: stringData)
            if normalizedStringData != stringData,
               let nested = parseJSONObject(from: normalizedStringData) {
                return nested
            }
        }
        return top
    }

    private static func suggestionItems(from top: Any) -> [[String: Any]]? {
        if let dict = top as? [String: Any], let arr = dict["suggestions"] as? [[String: Any]] {
            return arr
        }
        if let arr = top as? [[String: Any]] {
            return arr
        }
        return nil
    }

    private static func cappedSuggestions(_ suggestions: [CommandScoutSuggestion]) -> [CommandScoutSuggestion] {
        guard suggestions.count > maxAISuggestions else { return suggestions }

        let grouped = Dictionary(grouping: suggestions.sorted { lhs, rhs in
            if lhs.confidence == rhs.confidence {
                return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }
            return lhs.confidence > rhs.confidence
        }, by: \.category)
        let categories = grouped.keys.sorted()
        var offsets = Dictionary(uniqueKeysWithValues: categories.map { ($0, 0) })
        var capped: [CommandScoutSuggestion] = []

        while capped.count < maxAISuggestions {
            var addedThisRound = false
            for category in categories where capped.count < maxAISuggestions {
                let offset = offsets[category] ?? 0
                guard let categorySuggestions = grouped[category], offset < categorySuggestions.count else {
                    continue
                }
                capped.append(categorySuggestions[offset])
                offsets[category] = offset + 1
                addedThisRound = true
            }
            if !addedThisRound { break }
        }

        return capped
    }

    private static func redactedPreview(from data: Data, limit: Int = 500) -> String {
        let text = String(data: data, encoding: .utf8) ?? "<binary>"
        return String(redactSecrets(text).prefix(limit))
    }

    private static func shapeDescription(for value: Any) -> String {
        if let dict = value as? [String: Any] {
            return "object(keys: \(dict.keys.sorted().joined(separator: ",")))"
        }
        if let array = value as? [Any] {
            return "array(count: \(array.count))"
        }
        if value is String {
            return "string"
        }
        return String(describing: type(of: value))
    }

    private static func normalizedJSONData(from data: Data) -> Data {
        guard let text = String(data: data, encoding: .utf8) else { return data }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // 1. Strip markdown fences if whole response is wrapped
        if trimmed.hasPrefix("```") {
            let lines = trimmed.components(separatedBy: .newlines)
            let body = lines
                .dropFirst()
                .dropLast(lines.last?.trimmingCharacters(in: .whitespacesAndNewlines) == "```" ? 1 : 0)
                .joined(separator: "\n")
            if let d = body.data(using: .utf8) { return d }
        }

        // 2. Already valid JSON
        if trimmed.hasPrefix("{") || trimmed.hasPrefix("[") {
            return data
        }

        // 3. Extract JSON from prose (e.g., Gemma with web research returns text around JSON)
        if let extracted = extractJSONBlock(from: trimmed) {
            return extracted
        }

        return data
    }

    /// Find the outermost JSON object or array in a string that may contain surrounding prose.
    private static func extractJSONBlock(from text: String) -> Data? {
        // Try markdown fenced block first (```json ... ```)
        if let fenceRange = text.range(of: "```json"),
           let endFence = text.range(of: "```", range: fenceRange.upperBound..<text.endIndex) {
            let body = text[fenceRange.upperBound..<endFence.lowerBound]
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if let d = body.data(using: .utf8) { return d }
        }

        // Try finding first { matched with last }, or first [ with last ]
        for (open, close) in [("{" as Character, "}" as Character), ("[", "]")] {
            guard let start = text.firstIndex(of: open),
                  let end = text.lastIndex(of: close),
                  start < end
            else { continue }
            let candidate = String(text[start...end])
            // Quick validation: must parse as JSON
            if let d = candidate.data(using: .utf8),
               (try? JSONSerialization.jsonObject(with: d)) != nil {
                return d
            }
        }

        return nil
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

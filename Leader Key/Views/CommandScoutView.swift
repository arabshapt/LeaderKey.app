import AppKit
import Defaults
import SwiftUI

struct CommandScoutView: View {
    @EnvironmentObject var config: UserConfig
    @ObservedObject var session: ConfigEditorSession
    @Environment(\.dismiss) private var dismiss

    let appContext: CommandScoutAppContext

    @State private var suggestions: [CommandScoutSuggestion] = []
    @State private var selectedIDs: Set<String> = []
    @State private var isScanning = false
    @State private var scanTask: Task<Void, Never>?
    @State private var activeScanID: UUID?
    @State private var statusMessage = ""
    @State private var scanError: String?
    @State private var showingHighRiskConfirmation = false
    @State private var lastAIParseDiagnostics: CommandScoutAIParseDiagnostics?

    // Provider settings
    @State private var providerKind: CommandScoutAIProviderKind = .gemini
    @State private var modelName = ""
    @State private var baseURL = ""
    @State private var webResearchEnabled = true
    @State private var apiKeyInput = ""
    @State private var hasStoredKey = false
    @State private var aiEnabled = false

    // Filters
    @State private var categoryFilter: String?
    @State private var sourceFilter: CommandScoutSuggestionSource?
    @State private var searchText = ""
    @State private var selectedSuggestionID: String?

    private var filteredSuggestions: [CommandScoutSuggestion] {
        var result = suggestions
        if let cat = categoryFilter {
            result = result.filter { $0.category == cat }
        }
        if let src = sourceFilter {
            result = result.filter { $0.source == src }
        }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            result = result.filter { suggestion in
                suggestion.title.localizedCaseInsensitiveContains(query)
                    || suggestion.category.localizedCaseInsensitiveContains(query)
                    || suggestion.actionValue.localizedCaseInsensitiveContains(query)
                    || suggestion.suggestedSequence.localizedCaseInsensitiveContains(query)
            }
        }
        return result
    }

    private var categories: [String] {
        Array(Set(suggestions.map(\.category))).sorted()
    }

    private var sources: [CommandScoutSuggestionSource] {
        Array(Set(suggestions.map(\.source))).sorted { $0.displayName < $1.displayName }
    }

    private var selectedSuggestion: CommandScoutSuggestion? {
        suggestions.first { $0.id == selectedSuggestionID }
    }

    private var currentProviderSettings: CommandScoutProviderSettings {
        CommandScoutProviderSettings(
            providerKind: providerKind,
            modelName: modelName,
            baseURL: baseURL,
            webResearchEnabled: webResearchEnabled
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            Divider()
            HSplitView {
                VStack(spacing: 0) {
                    controlsPanel
                    Divider()
                    suggestionTable
                }
                .frame(minWidth: 500)

                detailPanel
                    .frame(minWidth: 280, idealWidth: 320)
            }
            Divider()
            footerBar
        }
        .frame(minWidth: 900, minHeight: 600)
        .onAppear(perform: loadProviderSettings)
        .onDisappear(perform: cancelScan)
        .onChange(of: providerKind) { newProvider in
            modelName = newProvider.defaultModel
            apiKeyInput = ""
            hasStoredKey = KeychainHelper.hasKey(account: newProvider.keychainAccount)
        }
        .alert("Apply high-risk suggestions?", isPresented: $showingHighRiskConfirmation) {
            Button("Apply", role: .destructive) {
                applyValidatedSelected(allowHighRisk: true)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Selected command or application suggestions can run higher-risk actions. Review their values before applying.")
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            Text("Command Scout — \(appContext.appDisplayName)")
                .font(.headline)
            Spacer()
            Text(statusMessage)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Controls Panel

    private var controlsPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            providerControls

            if aiEnabled {
                apiControls

                if webResearchEnabled && !currentProviderSettings.supportsWebResearch {
                    Label(
                        "\(providerKind.displayName) does not support web research for this model here; Command Scout will run a non-web AI scan.",
                        systemImage: "exclamationmark.triangle"
                    )
                    .font(.caption)
                    .foregroundColor(.orange)
                }
            }

            TextField("Search suggestions", text: $searchText)
                .textFieldStyle(.roundedBorder)

            HStack(spacing: 8) {
                Button(action: startScan) {
                    Label(isScanning ? "Scanning..." : "Scan", systemImage: "play.fill")
                }
                .disabled(isScanning)

                if isScanning {
                    Button("Cancel") { cancelScan() }
                }

                Spacer()

                if sources.count > 1 {
                    Picker("Source", selection: Binding(
                        get: { sourceFilter?.rawValue ?? "All" },
                        set: { sourceFilter = $0 == "All" ? nil : CommandScoutSuggestionSource(rawValue: $0) }
                    )) {
                        Text("All").tag("All")
                        ForEach(sources) { src in
                            Text(src.displayName).tag(src.rawValue)
                        }
                    }
                    .frame(width: 130)
                }

                if !categories.isEmpty {
                    Picker("Category", selection: Binding(
                        get: { categoryFilter ?? "All" },
                        set: { categoryFilter = $0 == "All" ? nil : $0 }
                    )) {
                        Text("All").tag("All")
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .frame(width: 160)
                }
            }

            if let error = scanError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(12)
    }

    private var providerControls: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                aiToggle
                if aiEnabled {
                    providerPicker
                    modelField
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                aiToggle
                if aiEnabled {
                    HStack(spacing: 8) {
                        providerPicker
                        modelField
                    }
                }
            }
        }
    }

    private var apiControls: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) {
                apiKeyField
                apiKeyButtons
                baseURLField
                webResearchToggle
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    apiKeyField
                    apiKeyButtons
                }
                HStack(spacing: 8) {
                    baseURLField
                    webResearchToggle
                }
            }
        }
    }

    private var aiToggle: some View {
        Toggle("AI", isOn: $aiEnabled)
            .toggleStyle(.switch)
            .controlSize(.small)
    }

    private var providerPicker: some View {
        Picker("Provider", selection: $providerKind) {
            ForEach(CommandScoutAIProviderKind.allCases) { kind in
                Text(kind.displayName).tag(kind)
            }
        }
        .frame(width: 170)
    }

    private var modelField: some View {
        TextField("Model", text: $modelName)
            .textFieldStyle(.roundedBorder)
            .frame(minWidth: 180, maxWidth: 260)
    }

    private var apiKeyField: some View {
        SecureField("API Key", text: $apiKeyInput)
            .textFieldStyle(.roundedBorder)
            .frame(minWidth: 180, maxWidth: 260)
    }

    private var apiKeyButtons: some View {
        HStack(spacing: 6) {
            Button(hasStoredKey ? "Update Key" : "Save Key") {
                saveAPIKey()
            }
            .disabled(apiKeyInput.isEmpty)

            if hasStoredKey {
                Button("Clear Key") { clearAPIKey() }
            }
        }
    }

    @ViewBuilder
    private var baseURLField: some View {
        if providerKind == .openAICompatible {
            TextField("Base URL", text: $baseURL)
                .textFieldStyle(.roundedBorder)
                .frame(minWidth: 220, maxWidth: 340)
        }
    }

    private var webResearchToggle: some View {
        Toggle("Web research", isOn: $webResearchEnabled)
            .toggleStyle(.switch)
            .controlSize(.small)
    }

    // MARK: - Suggestion Table

    private var suggestionTable: some View {
        List(selection: $selectedSuggestionID) {
            ForEach(filteredSuggestions) { suggestion in
                suggestionRow(suggestion)
                    .tag(suggestion.id)
            }
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
    }

    private func suggestionRow(_ suggestion: CommandScoutSuggestion) -> some View {
        HStack(spacing: 8) {
            Toggle("", isOn: Binding(
                get: { selectedIDs.contains(suggestion.id) },
                set: { isOn in
                    if isOn { selectedIDs.insert(suggestion.id) }
                    else { selectedIDs.remove(suggestion.id) }
                }
            ))
            .toggleStyle(.checkbox)
            .labelsHidden()

            Text(CommandScoutSequenceNormalizer.normalizedSequence(suggestion.suggestedSequence))
                .font(.system(.body, design: .monospaced))
                .foregroundColor(suggestion.conflictStatus == .duplicateSequence ? .orange : .primary)
                .frame(width: 60, alignment: .leading)

            Text(suggestion.title)
                .lineLimit(1)
                .frame(minWidth: 120, alignment: .leading)

            Text(suggestion.category)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)

            Text(suggestion.actionType.displayName)
                .font(.caption)
                .frame(width: 60, alignment: .leading)

            confidenceBadge(suggestion.confidence)

            conflictBadge(suggestion.conflictStatus)

            Text(suggestion.source.displayName)
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .trailing)
        }
        .padding(.vertical, 2)
    }

    private func confidenceBadge(_ confidence: Double) -> some View {
        let percent = Int(confidence * 100)
        let color: Color = confidence >= 0.75 ? .green : confidence >= 0.5 ? .orange : .red
        return Text("\(percent)%")
            .font(.caption2)
            .foregroundColor(color)
            .frame(width: 35, alignment: .center)
    }

    private func conflictBadge(_ status: CommandScoutConflictStatus) -> some View {
        SwiftUI.Group {
            if status == .clear {
                EmptyView()
            } else {
                Text(status.displayName)
                    .font(.caption2)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(status == .duplicateSequence || status == .duplicateAction ? Color.orange.opacity(0.2) : Color.red.opacity(0.2))
                    .cornerRadius(3)
            }
        }
        .frame(width: 80, alignment: .center)
    }

    // MARK: - Detail Panel

    private var detailPanel: some View {
        SwiftUI.Group {
            if let suggestion = selectedSuggestion {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(suggestion.title).font(.headline)

                        if !suggestion.description.isEmpty {
                            LabeledContent("Description") { Text(suggestion.description) }
                        }
                        if !suggestion.aiDescription.isEmpty {
                            LabeledContent("AI Notes") { Text(suggestion.aiDescription) }
                        }

                        LabeledContent("Action Type") { Text(suggestion.actionType.displayName) }
                        LabeledContent("Value") {
                            TextField("Action value", text: bindingForSelectedSuggestion(\.actionValue))
                                .font(.system(.body, design: .monospaced))
                        }

                        LabeledContent("Sequence") {
                            HStack(spacing: 6) {
                                TextField("e.g. tn", text: bindingForSelectedSequence())
                                    .font(.system(.body, design: .monospaced))
                                    .frame(width: 80)

                                if suggestion.conflictStatus == .clear && !suggestion.suggestedSequence.isEmpty {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .help("No conflicts")
                                } else if suggestion.conflictStatus == .duplicateSequence {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                        .help("Duplicate sequence — change to resolve")
                                } else if suggestion.conflictStatus != .clear {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .help(suggestion.conflictStatus.displayName)
                                }
                            }
                        }

                        LabeledContent("Conflict") {
                            Text(suggestion.conflictStatus.displayName)
                                .foregroundColor(suggestion.conflictStatus == .clear ? .green : .orange)
                        }

                        if !suggestion.alternatives.isEmpty {
                            LabeledContent("Alternatives") {
                                Text(suggestion.alternatives.joined(separator: ", "))
                            }
                        }

                        if !suggestion.menuFallbackPaths.isEmpty {
                            LabeledContent("Fallback Paths") {
                                VStack(alignment: .leading) {
                                    ForEach(suggestion.menuFallbackPaths, id: \.self) { path in
                                        Text(path).font(.caption)
                                    }
                                }
                            }
                        }

                        if !suggestion.reviewNotes.isEmpty {
                            LabeledContent("Notes") {
                                Text(suggestion.reviewNotes)
                                    .foregroundColor(.orange)
                            }
                        }

                        LabeledContent("Source") { Text(suggestion.source.displayName) }
                        LabeledContent("Confidence") { Text("\(Int(suggestion.confidence * 100))%") }
                    }
                    .padding(16)
                }
            } else {
                VStack {
                    Spacer()
                    Text("Select a suggestion")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
    }

    // MARK: - Footer

    private var footerBar: some View {
        HStack(spacing: 12) {
            Button("Select High Confidence") { selectHighConfidence() }
            Button("Regenerate Sequences") { regenerateSequences() }
            Button("Copy Debug Bundle") { copyDebugBundle() }

            Spacer()

            Text("\(selectedIDs.count) selected")
                .font(.caption)
                .foregroundColor(.secondary)

            Button("Apply Selected") { applySelected() }
                .disabled(selectedIDs.isEmpty)
                .keyboardShortcut(.return, modifiers: .command)

            Button("Close") { dismiss() }
                .keyboardShortcut(.cancelAction)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Actions

    private func loadProviderSettings() {
        providerKind = Defaults[.commandScoutAIProvider]
        modelName = Defaults[.commandScoutAIModel]
        baseURL = Defaults[.commandScoutAIBaseURL]
        webResearchEnabled = Defaults[.commandScoutWebResearchEnabled]
        hasStoredKey = KeychainHelper.hasKey(account: providerKind.keychainAccount)
    }

    private func saveAPIKey() {
        let trimmed = apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let saved = KeychainHelper.save(account: providerKind.keychainAccount, key: trimmed)
        if saved {
            apiKeyInput = ""
            hasStoredKey = true
        } else {
            scanError = "Failed to save API key to Keychain. Check Console for details."
            hasStoredKey = KeychainHelper.hasKey(account: providerKind.keychainAccount)
        }
    }

    private func clearAPIKey() {
        KeychainHelper.delete(account: providerKind.keychainAccount)
        hasStoredKey = false
    }

    private func startScan() {
        cancelScan()
        let scanID = UUID()
        activeScanID = scanID
        isScanning = true
        scanError = nil
        lastAIParseDiagnostics = nil
        statusMessage = "Scanning menus..."

        // Save provider settings
        Defaults[.commandScoutAIProvider] = providerKind
        Defaults[.commandScoutAIModel] = modelName
        Defaults[.commandScoutAIBaseURL] = baseURL
        Defaults[.commandScoutWebResearchEnabled] = webResearchEnabled

        scanTask = Task {
            let menuResult = CommandScoutService.scanMenuSuggestionResult(appName: appContext.appName)
            guard !Task.isCancelled else { return }

            await MainActor.run {
                guard activeScanID == scanID else { return }
                suggestions = menuResult.suggestions
                scanError = menuResult.errorMessage
                statusMessage = "\(menuResult.suggestions.count) menu items found"
            }

            guard !Task.isCancelled else { return }
            if aiEnabled {
                await runAIScan(existingMenuSuggestions: menuResult.suggestions, scanID: scanID)
            }

            guard !Task.isCancelled else { return }
            await MainActor.run {
                guard activeScanID == scanID else { return }
                suggestions = CommandScoutService.assignSequences(
                    to: suggestions,
                    existingRoot: session.root
                )
                suggestions = CommandScoutService.validate(
                    suggestions: suggestions,
                    existingRoot: session.root
                )
                isScanning = false
                let warning = lastAIParseDiagnostics?.warningMessage.map { " \($0)" } ?? ""
                statusMessage = "\(suggestions.count) suggestions ready\(warning)"
                activeScanID = nil
                scanTask = nil
            }
        }
    }

    private func runAIScan(existingMenuSuggestions: [CommandScoutSuggestion], scanID: UUID) async {
        guard let apiKey = KeychainHelper.load(account: providerKind.keychainAccount) else {
            await MainActor.run {
                guard activeScanID == scanID else { return }
                scanError = "No API key stored for \(providerKind.displayName). Save a key first."
            }
            return
        }

        await MainActor.run {
            guard activeScanID == scanID else { return }
            statusMessage = "Running AI scan..."
        }

        let settings = currentProviderSettings

        let provider = AIProviderFactory.makeProvider(settings: settings, apiKey: apiKey)

        // Build existing config summary
        let existingKeys = session.root.actions.compactMap { item -> String? in
            switch item {
            case .action(let a): return a.key
            case .group(let g): return g.key
            case .layer(let l): return l.key
            }
        }
        let configSummary = existingKeys.isEmpty ? "Empty" : existingKeys.joined(separator: ", ")

        // Build menu items JSON for prompt
        let menuItemsJSON: String
        if let data = try? JSONEncoder().encode(existingMenuSuggestions.map(\.actionValue)),
           let str = String(data: data, encoding: .utf8) {
            menuItemsJSON = str
        } else {
            menuItemsJSON = "[]"
        }

        let prompt = CommandScoutPrompts.inventoryPrompt(
            appName: appContext.appName,
            bundleId: appContext.bundleId,
            existingConfigSummary: configSummary,
            fallbackSummary: "N/A",
            menuItemsJSON: menuItemsJSON,
            webResearchEnabled: settings.webResearchEnabled && provider.supportsWebResearch
        )

        do {
            let data = try await provider.generateJSON(
                system: CommandScoutPrompts.systemPrompt,
                prompt: prompt
            )
            guard !Task.isCancelled else { return }

            switch CommandScoutService.parseAISuggestionsResult(data) {
            case .success(let aiSuggestions, let diagnostics):
                await MainActor.run {
                    guard activeScanID == scanID else { return }
                    lastAIParseDiagnostics = diagnostics
                    // Merge: AI suggestions with matching actionValue enrich menu ones (keep AI sequence + description).
                    // Non-matching AI suggestions are added as new.
                    var menuByValue: [String: Int] = [:]
                    for (i, s) in suggestions.enumerated() {
                        menuByValue["\(s.actionType.rawValue):\(s.actionValue)"] = i
                    }
                    var newCount = 0
                    for ai in aiSuggestions {
                        let key = "\(ai.actionType.rawValue):\(ai.actionValue)"
                        if let idx = menuByValue[key] {
                            // Enrich existing menu suggestion with AI sequence + description
                            if !ai.suggestedSequence.isEmpty {
                                suggestions[idx].suggestedSequence = CommandScoutSequenceNormalizer.normalizedSequence(ai.suggestedSequence)
                            }
                            if !ai.aiDescription.isEmpty {
                                suggestions[idx].aiDescription = ai.aiDescription
                            }
                            if !ai.category.isEmpty && ai.category != "Misc" {
                                suggestions[idx].category = ai.category
                            }
                        } else {
                            suggestions.append(ai)
                            newCount += 1
                        }
                    }
                    let warning = diagnostics.warningMessage.map { " \($0)" } ?? ""
                    statusMessage = "\(suggestions.count) suggestions (\(aiSuggestions.count) from AI, \(newCount) new).\(warning)"
                }
            case .failure(let diagnostics):
                await MainActor.run {
                    guard activeScanID == scanID else { return }
                    lastAIParseDiagnostics = diagnostics
                    scanError = "\(diagnostics.failureMessage). Keeping menu suggestions only."
                    statusMessage = "\(suggestions.count) suggestions (AI parse failed)"
                }
            }
        } catch {
            await MainActor.run {
                guard activeScanID == scanID else { return }
                if let providerError = error as? AIProviderError {
                    scanError = providerError.userFacingMessage(
                        provider: settings.providerKind,
                        modelName: settings.effectiveModelName
                    )
                } else {
                    scanError = error.localizedDescription
                }
                statusMessage = "\(suggestions.count) suggestions (AI failed)"
            }
        }
    }

    private func cancelScan() {
        scanTask?.cancel()
        scanTask = nil
        activeScanID = nil
        isScanning = false
    }

    private func selectHighConfidence() {
        for suggestion in suggestions where suggestion.isSelectableByDefault {
            selectedIDs.insert(suggestion.id)
        }
    }

    private func regenerateSequences() {
        suggestions = suggestions.map {
            var suggestion = $0
            suggestion.suggestedSequence = ""
            return suggestion
        }
        suggestions = CommandScoutService.assignSequences(to: suggestions, existingRoot: session.root)
        suggestions = CommandScoutService.validate(suggestions: suggestions, existingRoot: session.root)
    }

    private func applySelected() {
        let selected = suggestions.filter { selectedIDs.contains($0.id) }
        if selected.contains(where: { $0.actionType.requiresExplicitSelection }) {
            showingHighRiskConfirmation = true
            return
        }

        applyValidatedSelected(allowHighRisk: false)
    }

    private func applyValidatedSelected(allowHighRisk: Bool) {
        let selected = suggestions.filter { selectedIDs.contains($0.id) }
        debugLog("[CommandScout] Apply: \(selected.count) selected")
        for s in selected {
            debugLog("[CommandScout]   - \(s.title): type=\(s.actionType.rawValue) seq=\(s.suggestedSequence) conflict=\(s.conflictStatus.rawValue) canCreate=\(s.canCreateAction) makeAction=\(s.makeAction() != nil)")
        }

        let validated = CommandScoutService.validate(suggestions: selected, existingRoot: session.root)
        mergeValidatedSuggestions(validated)

        let toApply = validated.filter {
            $0.conflictStatus == .clear
                && $0.canCreateAction
                && (allowHighRisk || !$0.actionType.requiresExplicitSelection)
        }

        debugLog("[CommandScout] After validation: \(toApply.count) to apply")
        for s in toApply {
            debugLog("[CommandScout]   + \(s.title): seq=\(s.sequenceTokens.joined()) type=\(s.actionType.rawValue)")
        }

        if toApply.isEmpty {
            let reasons = validated.map { "\($0.title): \($0.conflictStatus.rawValue)" }
            statusMessage = "Nothing applied — \(reasons.joined(separator: ", "))"
            return
        }
        let result = session.applyCommandScoutSuggestions(toApply)
        let blocked = validated.compactMap { suggestion -> String? in
            if suggestion.conflictStatus != .clear {
                return "\(suggestion.title): \(suggestion.conflictStatus.displayName)"
            }
            if !suggestion.canCreateAction {
                return "\(suggestion.title): cannot create action"
            }
            if !allowHighRisk && suggestion.actionType.requiresExplicitSelection {
                return "\(suggestion.title): needs explicit confirmation"
            }
            return nil
        }
        let skipped = blocked + result.skippedMessages
        if result.insertedCount == 0 {
            statusMessage = "Nothing applied — \(skipped.joined(separator: ", "))"
        } else if skipped.isEmpty {
            statusMessage = "Applied \(result.insertedCount) suggestions"
        } else {
            statusMessage = "Applied \(result.insertedCount), skipped \(skipped.count): \(skipped.joined(separator: ", "))"
        }
        selectedIDs.subtract(Set(toApply.map(\.id)))
    }

    private func bindingForSelectedSuggestion(
        _ keyPath: WritableKeyPath<CommandScoutSuggestion, String>
    ) -> Binding<String> {
        Binding(
            get: {
                guard let selectedSuggestion else { return "" }
                return selectedSuggestion[keyPath: keyPath]
            },
            set: { newValue in
                guard let selectedSuggestionID,
                      let index = suggestions.firstIndex(where: { $0.id == selectedSuggestionID })
                else { return }
                suggestions[index][keyPath: keyPath] = newValue
                suggestions = CommandScoutService.validate(suggestions: suggestions, existingRoot: session.root)
            }
        )
    }

    private func bindingForSelectedSequence() -> Binding<String> {
        Binding(
            get: {
                guard let selectedSuggestion else { return "" }
                return CommandScoutSequenceNormalizer.normalizedSequence(selectedSuggestion.suggestedSequence)
            },
            set: { newValue in
                guard let selectedSuggestionID,
                      let index = suggestions.firstIndex(where: { $0.id == selectedSuggestionID })
                else { return }
                suggestions[index].suggestedSequence = CommandScoutSequenceNormalizer.normalizedSequence(newValue)
                suggestions = CommandScoutService.validate(suggestions: suggestions, existingRoot: session.root)
            }
        )
    }

    private func mergeValidatedSuggestions(_ validated: [CommandScoutSuggestion]) {
        for validatedSuggestion in validated {
            guard let index = suggestions.firstIndex(where: { $0.id == validatedSuggestion.id }) else {
                continue
            }
            suggestions[index] = validatedSuggestion
        }
    }

    private func copyDebugBundle() {
        let settings = CommandScoutProviderSettings(
            providerKind: providerKind,
            modelName: modelName,
            baseURL: baseURL,
            webResearchEnabled: webResearchEnabled
        )
        let bundle = CommandScoutService.debugBundle(
            appName: appContext.appName,
            bundleId: appContext.bundleId,
            statusMessage: statusMessage,
            scanError: scanError,
            providerSettings: settings,
            suggestions: suggestions,
            aiParseDiagnostics: lastAIParseDiagnostics
        )
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(bundle, forType: .string)
        statusMessage = "Copied debug bundle"
    }
}

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
    @State private var selectedSuggestionID: String?

    private var filteredSuggestions: [CommandScoutSuggestion] {
        guard let filter = categoryFilter else { return suggestions }
        return suggestions.filter { $0.category == filter }
    }

    private var categories: [String] {
        Array(Set(suggestions.map(\.category))).sorted()
    }

    private var selectedSuggestion: CommandScoutSuggestion? {
        suggestions.first { $0.id == selectedSuggestionID }
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
            HStack(spacing: 12) {
                Toggle("AI", isOn: $aiEnabled)
                    .toggleStyle(.switch)
                    .controlSize(.small)

                if aiEnabled {
                    Picker("Provider", selection: $providerKind) {
                        ForEach(CommandScoutAIProviderKind.allCases) { kind in
                            Text(kind.displayName).tag(kind)
                        }
                    }
                    .frame(width: 160)

                    TextField("Model", text: $modelName)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 140)
                }
            }

            if aiEnabled {
                HStack(spacing: 8) {
                    SecureField("API Key", text: $apiKeyInput)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 200)

                    Button(hasStoredKey ? "Update Key" : "Save Key") {
                        saveAPIKey()
                    }
                    .disabled(apiKeyInput.isEmpty)

                    if hasStoredKey {
                        Button("Clear Key") { clearAPIKey() }
                    }

                    if providerKind == .openAICompatible {
                        TextField("Base URL", text: $baseURL)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 200)
                    }

                    Toggle("Web research", isOn: $webResearchEnabled)
                        .toggleStyle(.switch)
                        .controlSize(.small)
                }

                if webResearchEnabled && !providerKind.supportsWebResearch {
                    Label(
                        "\(providerKind.displayName) does not support web research here; Command Scout will run a non-web AI scan.",
                        systemImage: "exclamationmark.triangle"
                    )
                    .font(.caption)
                    .foregroundColor(.orange)
                }
            }

            HStack(spacing: 8) {
                Button(action: startScan) {
                    Label(isScanning ? "Scanning..." : "Scan", systemImage: "play.fill")
                }
                .disabled(isScanning)

                if isScanning {
                    Button("Cancel") { cancelScan() }
                }

                Spacer()

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

            Text(suggestion.suggestedSequence)
                .font(.system(.body, design: .monospaced))
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
                            TextField("Sequence", text: bindingForSelectedSuggestion(\.suggestedSequence))
                                .font(.system(.body, design: .monospaced))
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
                        LabeledContent("Conflict") { Text(suggestion.conflictStatus.displayName) }
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
        _ = KeychainHelper.save(account: providerKind.keychainAccount, key: trimmed)
        apiKeyInput = ""
        hasStoredKey = true
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
                statusMessage = "\(suggestions.count) suggestions ready"
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

        let settings = CommandScoutProviderSettings(
            providerKind: providerKind,
            modelName: modelName,
            baseURL: baseURL,
            webResearchEnabled: webResearchEnabled
        )

        let provider = AIProviderFactory.makeProvider(settings: settings, apiKey: apiKey)

        // Build existing config summary
        let existingKeys = session.root.actions.compactMap { item -> String? in
            switch item {
            case .action(let a): return a.key
            case .group(let g): return g.key
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

            if let aiSuggestions = CommandScoutService.parseAISuggestions(data) {
                await MainActor.run {
                    guard activeScanID == scanID else { return }
                    let existingValues = Set(suggestions.map { "\($0.actionType.rawValue):\($0.actionValue)" })
                    let newAI = aiSuggestions.filter { s in
                        !existingValues.contains("\(s.actionType.rawValue):\(s.actionValue)")
                    }
                    suggestions.append(contentsOf: newAI)
                    statusMessage = "\(suggestions.count) suggestions (\(newAI.count) from AI)"
                }
            } else {
                await MainActor.run {
                    guard activeScanID == scanID else { return }
                    scanError = "AI returned malformed JSON; keeping menu suggestions only."
                    statusMessage = "\(suggestions.count) suggestions (AI parse failed)"
                }
            }
        } catch {
            await MainActor.run {
                guard activeScanID == scanID else { return }
                scanError = error.localizedDescription
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
        let validated = CommandScoutService.validate(suggestions: selected, existingRoot: session.root)
        mergeValidatedSuggestions(validated)

        let toApply = validated.filter {
            $0.conflictStatus == .clear
                && $0.canCreateAction
                && (allowHighRisk || !$0.actionType.requiresExplicitSelection)
        }
        guard !toApply.isEmpty else { return }
        session.applyCommandScoutSuggestions(toApply)
        statusMessage = "Applied \(toApply.count) suggestions"
        selectedIDs.removeAll()
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
            suggestions: suggestions
        )
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(bundle, forType: .string)
        statusMessage = "Copied debug bundle"
    }
}

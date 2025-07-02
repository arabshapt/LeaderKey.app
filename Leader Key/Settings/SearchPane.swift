import Defaults
import Settings
import SwiftUI

struct SearchPane: View {
    private let contentWidth = 1000.0
    @EnvironmentObject private var config: UserConfig
    
    @State private var searchQuery = ""
    @State private var selectedMatchType: SearchMatchType = .all
    @State private var includeGroups = true
    @State private var searchResults: [SearchResult] = []
    @State private var isSearching = false
    @State private var selectedResult: SearchResult? = nil
    
    var body: some View {
        Settings.Container(contentWidth: contentWidth) {
            Settings.Section(title: "Search Your Leader Key Sequences") {
                VStack(alignment: .leading, spacing: 0) {
                    // Search controls (fixed at the top)
                    searchControls
                        .padding(.bottom, 16)
                    
                    Divider()
                        .padding(.bottom, 16)
                    
                    // Dynamic content area
                    if isSearching {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Searching...")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if searchQuery.isEmpty {
                        searchPlaceholder
                            .frame(maxHeight: .infinity)
                    } else if searchResults.isEmpty {
                        noResultsView
                            .frame(maxHeight: .infinity)
                    } else {
                        searchResultsList
                    }
                }
                .frame(minHeight: 600)
            }
        }
        .onChange(of: searchQuery) { _ in
            performSearch()
        }
        .onChange(of: selectedMatchType) { _ in
            performSearch()
        }
        .onChange(of: includeGroups) { _ in
            performSearch()
        }
    }
    
    private var searchControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search for sequences, descriptions, apps...", text: $searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .default))
                
                if !searchQuery.isEmpty {
                    Button(action: { searchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            HStack {
                Text("Search in:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("Search Type", selection: $selectedMatchType) {
                    ForEach(SearchMatchType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 300)
                
                Spacer()
                
                Toggle("Include Groups", isOn: $includeGroups)
                    .toggleStyle(.checkbox)
                    .font(.caption)
            }
        }
    }
    
    private var searchPlaceholder: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("Search Your Key Sequences")
                    .font(.headline)
                
                Text("Find any shortcut by typing:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    searchExampleRow(icon: "keyboard", text: "Key sequences: \"o s\" or \"terminal\"")
                    searchExampleRow(icon: "tag", text: "Labels: \"Safari\" or \"Open Browser\"")
                    searchExampleRow(icon: "link", text: "URLs: \"raycast\" or \"google.com\"")
                    searchExampleRow(icon: "app", text: "Applications: \"Xcode\" or \"Mail\"")
                    searchExampleRow(icon: "terminal", text: "Commands: \"ls\" or \"git status\"")
                }
                .font(.caption)
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private func searchExampleRow(icon: String, text: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 16)
            Text(text)
                .foregroundColor(.secondary)
        }
    }
    
    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No sequences found")
                .font(.headline)
            
            Text("Try a different search term or change the search type")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private var searchResultsList: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Results header
            HStack {
                Text("\(searchResults.count) result\(searchResults.count == 1 ? "" : "s") found")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if searchResults.count > 10 {
                    Text("Showing all results")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 8)
            
            // Results list
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(searchResults) { result in
                        SearchResultRow(
                            result: result,
                            isSelected: selectedResult?.id == result.id,
                            onSelect: { selectedResult = result }
                        )
                        
                        if result.id != searchResults.last?.id {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
            }
            .frame(maxHeight: 600)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
            )
        }
    }
    
    private func performSearch() {
        guard !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        
        // Perform search on background queue to avoid blocking UI
        DispatchQueue.global(qos: .userInitiated).async {
            let results = config.searchSequences(
                query: searchQuery,
                matchType: selectedMatchType,
                includeGroups: includeGroups
            )
            
            DispatchQueue.main.async {
                self.searchResults = results
                self.isSearching = false
            }
        }
    }
}

struct SearchResultRow: View {
    let result: SearchResult
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Icon
                actionIcon(item: result.item, iconSize: NSSize(width: 24, height: 24))
                
                VStack(alignment: .leading, spacing: 4) {
                    // Key sequence
                    HStack {
                        Text(result.keySequence)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        // Match type badge
                        Text(result.matchType.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.2))
                            .foregroundColor(.accentColor)
                            .cornerRadius(4)
                    }
                    
                    // Display name and type
                    HStack {
                        Text(result.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(result.typeDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.secondary.opacity(0.15))
                            .cornerRadius(3)
                        
                        Spacer()
                    }
                    
                    // Value description
                    if !result.valueDescription.isEmpty {
                        Text(result.valueDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    // Config name and match reason
                    HStack {
                        if result.configName != globalDefaultDisplayName {
                            Text(result.configName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.orange.opacity(0.15))
                                .foregroundColor(.orange)
                                .cornerRadius(3)
                        }
                        
                        Spacer()
                        
                        Text(result.matchReason)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                
                Spacer()
                
                // Action button
                Button(action: {
                    // TODO: Implement "Go to" functionality to open the item in General pane
                    goToResult(result)
                }) {
                    Image(systemName: "arrow.right.circle")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                .help("Go to this item in the General settings")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
    
    private func goToResult(_ result: SearchResult) {
        // This will be implemented to switch to General pane and highlight the item
        print("Go to result: \(result.keySequence) in \(result.configName)")
        // TODO: Add functionality to switch panes and navigate to the specific item
    }
}

struct SearchPane_Previews: PreviewProvider {
    static var previews: some View {
        let config = UserConfig()
        // Set up some sample data for preview
        config.root = Group(
            key: "",
            stickyMode: nil,
            actions: [
                .action(Action(key: "t", type: .application, value: "/Applications/Terminal.app")),
                .action(Action(key: "s", type: .application, value: "/Applications/Safari.app")),
                .group(Group(
                    key: "o",
                    stickyMode: nil,
                    actions: [
                        .action(Action(key: "g", type: .url, value: "https://google.com")),
                        .action(Action(key: "r", type: .url, value: "raycast://confetti"))
                    ]
                ))
            ]
        )
        
        return SearchPane()
            .environmentObject(config)
    }
}

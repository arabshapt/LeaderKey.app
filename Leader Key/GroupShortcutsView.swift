import SwiftUI
import Defaults
import KeyboardShortcuts

struct GroupShortcutsView: View {
    @EnvironmentObject private var config: UserConfig
    @Default(.groupShortcuts) var groupShortcuts
    @State private var selectedGroup: Group?
    @State private var searchText = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Configure global shortcuts for specific groups")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 5)
            
            Divider()
            
            searchField
            
            List {
                ForEach(filteredGroups, id: \.id) { group in
                    GroupShortcutRow(group: group)
                }
            }
            .frame(height: 300)
            .border(Color.primary.opacity(0.2), width: 1)
        }
        .padding()
    }
    
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search groups", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(7)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
        .padding(.bottom, 10)
    }
    
    private var filteredGroups: [GroupViewModel] {
        getAllGroups().filter { group in
            searchText.isEmpty || 
            group.name.localizedCaseInsensitiveContains(searchText) ||
            group.key.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func getAllGroups() -> [GroupViewModel] {
        var result: [GroupViewModel] = []
        
        // Add root group
        let rootPath = config.getGroupPath(for: config.root)
        result.append(GroupViewModel(
            id: UUID(),
            name: config.root.displayName,
            key: config.root.key ?? "",
            path: rootPath
        ))
        
        // Recursively add all subgroups
        findGroups(in: config.root, result: &result)
        
        return result
    }
    
    private func findGroups(in group: Group, result: inout [GroupViewModel]) {
        for item in group.actions {
            if case .group(let subgroup) = item {
                let path = config.getGroupPath(for: subgroup)
                result.append(GroupViewModel(
                    id: UUID(),
                    name: subgroup.displayName,
                    key: subgroup.key ?? "",
                    path: path
                ))
                findGroups(in: subgroup, result: &result)
            }
        }
    }
}

struct GroupShortcutRow: View {
    @Default(.groupShortcuts) var groupShortcuts
    let group: GroupViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(group.name)
                    .fontWeight(.medium)
                
                Text("Key: \(group.key)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            KeyboardShortcuts.Recorder(
                for: KeyboardShortcuts.Name.forGroup(group.path),
                onChange: { shortcut in
                    // When the shortcut changes, update our mapping
                    updateShortcutMapping(shortcut: shortcut != nil)
                }
            )
            .frame(width: 160)
        }
        .padding(.vertical, 4)
        .onAppear {
            // When a recorder appears, make sure its path exists in the mapping
            updateShortcutMapping(shortcut: KeyboardShortcuts.getShortcut(for: .forGroup(group.path)) != nil)
        }
    }
    
    private func updateShortcutMapping(shortcut: Bool) {
        var updatedShortcuts = groupShortcuts
        
        if shortcut {
            // Add or update the mapping
            updatedShortcuts[group.path] = group.path
        } else {
            // Remove the mapping if shortcut was cleared
            updatedShortcuts.removeValue(forKey: group.path)
        }
        
        groupShortcuts = updatedShortcuts
    }
}

struct GroupViewModel: Identifiable {
    let id: UUID
    let name: String
    let key: String
    let path: String
} 
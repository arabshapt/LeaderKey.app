import Defaults
import KeyboardShortcuts
import LaunchAtLogin
import Settings
import SwiftUI

struct GeneralPane: View {
  private let contentWidth = 1100.0
  @EnvironmentObject private var config: UserConfig
  @Default(.configDir) var configDir
  @Default(.theme) var theme
  @State private var expandedGroups = Set<[Int]>()
  @State private var showingRenameAlert = false
  @State private var newConfigNameInput = ""
  @State private var keyToLoad: String? = nil
  @State private var listSelection: String? = nil

  // Sorted list of config keys for the Picker
  var sortedConfigKeys: [String] {
      config.discoveredConfigFiles.keys.sorted { key1, key2 in
          // Prioritize Global Default
          if key1 == globalDefaultDisplayName { return true }
          if key2 == globalDefaultDisplayName { return false }
          // Prioritize Default App Config
          if key1 == defaultAppConfigDisplayName { return true }
          if key2 == defaultAppConfigDisplayName { return false }
          // Sort remaining app-specific keys alphabetically
          return key1 < key2
      }
  }

  var body: some View {
    Settings.Container(contentWidth: contentWidth) {
      // Wrap the main layout in a Settings.Section, providing an empty title
      Settings.Section(title: "") {
          // Main Horizontal Layout
          HStack(alignment: .top) {
              // --- Left Sidebar: Config List --- START ---
              VStack(alignment: .leading) {
                  Text("Configurations")
                      .font(.title2)
                      .padding(.bottom, 5)

                  List(selection: $listSelection) {
                      ForEach(sortedConfigKeys, id: \.self) { key in
                          HStack {
                              Text(key)
                                  .tag(key) // Needed for List selection binding
                                  .lineLimit(1)
                                  .truncationMode(.middle)
                              Spacer()
                              // Simple Rename Button - could be improved with context menu later
                              if key != globalDefaultDisplayName {
                                  Button {
                                      // Get current custom name or default name to pre-fill
                                      if let filePath = config.discoveredConfigFiles[key] {
                                          newConfigNameInput = Defaults[.configFileCustomNames][filePath] ?? key
                                      } else {
                                          newConfigNameInput = "" 
                                      }
                                      showingRenameAlert = true
                                  } label: {
                                      Image(systemName: "pencil.circle")
                                  }
                                  .buttonStyle(.plain) // Use plain style for subtle look in list
                                  .foregroundColor(.secondary)
                              }
                          }
                      }
                  }
                  .listStyle(.sidebar) // Use a sidebar style for the list
                  .frame(minWidth: 180, idealWidth: 200, maxWidth: 250) // Sidebar width
                  .onChange(of: listSelection) { newSelection in
                      guard let newKey = newSelection else { return } // Ignore nil selection
                      print("[GeneralPane onChange(listSelection)] Setting keyToLoad = \(newKey)")
                      self.keyToLoad = newKey // Update the trigger state for the task
                      // Also update the config's state, but asynchronously
                      DispatchQueue.main.async {
                          // Check if it actually changed to avoid redundant updates
                          if self.config.selectedConfigKeyForEditing != newKey {
                               print("[GeneralPane onChange(listSelection) async] Updating config.selectedConfigKeyForEditing = \(newKey)")
                              self.config.selectedConfigKeyForEditing = newKey
                          }
                      }
                  }
                  .onAppear {
                      if listSelection == nil { // Initialize only once
                           listSelection = config.selectedConfigKeyForEditing
                           print("[GeneralPane onAppear] Initialized listSelection to \(listSelection ?? "nil")")
                      }
                  }
                  // TODO: Add 'New' / 'Delete' buttons below the list?

              }
              // --- Left Sidebar: Config List --- END ---

              // Divider
              Divider()

              // --- Right Content Area: Config Editor --- START ---
              VStack(alignment: .leading) {
                  // Title (Optional - shows selected config)
                  Text("Editing: \(config.selectedConfigKeyForEditing)")
                      .font(.title3)
                      .padding(.bottom, 5)

                  // The existing config editor section
                  VStack(alignment: .leading, spacing: 8) {
                      VStack {
                          ConfigEditorView(group: $config.currentlyEditingGroup, expandedGroups: $expandedGroups)
                              .frame(minHeight: 500) // Ensure it has enough height
                              .focusable(false)
                      }
                      .padding(8)
                      .overlay(
                          RoundedRectangle(cornerRadius: 12)
                              .inset(by: 1)
                              .stroke(Color.primary, lineWidth: 1)
                              .opacity(0.1)
                      )

                      HStack {
                          // Left-aligned buttons
                          HStack(spacing: 8) {
                              Button("Save Changes") { config.saveCurrentlyEditingConfig() }
                              Button("Reload Current File") { config.reloadConfig() }
                          }

                          Spacer()

                          // Right-aligned buttons
                          HStack(spacing: 8) {
                              Button {
                                 withAnimation(.easeOut(duration: 0.1)) {
                                     expandAllGroups(in: config.currentlyEditingGroup, parentPath: [])
                                 }
                              } label: {
                                  Image(systemName: "chevron.down")
                                  Text("Expand all")
                              }

                              Button {
                                  withAnimation(.easeOut(duration: 0.1)) {
                                      expandedGroups.removeAll()
                                  }
                              } label: {
                                  Image(systemName: "chevron.right")
                                  Text("Collapse all")
                              }
                          }
                      }
                  }
                  Spacer() // Pushes content to the top
              }
              .frame(maxWidth: .infinity) // Allow right side to expand
              // --- Right Content Area: Config Editor --- END ---
          }
          .padding(.leading, -10) // Add negative leading padding to shift left
          .task(id: keyToLoad) {
              guard let key = keyToLoad else { return }
              
              print("[GeneralPane .task(id: keyToLoad)] Loading config for key: \(key)")
              self.expandedGroups.removeAll()
              self.config.loadConfigForEditing(key: key)
              
              self.keyToLoad = nil 
          }
      } // End of Settings.Section wrapping the HStack

      // Sections below the main HStack can remain as they were
      Settings.Section(title: "Theme") {
        Picker("Theme", selection: $theme) {
          ForEach(Theme.all, id: \.self) { value in
            Text(Theme.name(value)).tag(value)
          }
        }.frame(maxWidth: 170).labelsHidden()
      }

      Settings.Section(title: "App") {
        LaunchAtLogin.Toggle()
      }
    }
    .alert("Rename Configuration", isPresented: $showingRenameAlert, actions: {
        TextField("New Name", text: $newConfigNameInput)
        Button("Save") {
            // Get the non-optional selected key first
            let currentKey = config.selectedConfigKeyForEditing 
            // Now use if let for the dictionary lookup and combine other checks
            if let filePath = config.discoveredConfigFiles[currentKey],
               !newConfigNameInput.isEmpty,
               newConfigNameInput != globalDefaultDisplayName,
               newConfigNameInput != defaultAppConfigDisplayName {
                
                var currentCustomNames = Defaults[.configFileCustomNames]
                // Ensure the new name isn't already used (by a custom name or a default name)
                let existingCustomNamePaths = currentCustomNames.filter { $0.value == newConfigNameInput }.map { $0.key }
                let existingDefaultNamePaths = config.discoveredConfigFiles.filter { $0.key == newConfigNameInput }.map { $0.value }

                if existingCustomNamePaths.isEmpty && existingDefaultNamePaths.isEmpty {
                    currentCustomNames[filePath] = newConfigNameInput
                    Defaults[.configFileCustomNames] = currentCustomNames
                    // Select the new name and reload to refresh the UI/list
                    config.selectedConfigKeyForEditing = newConfigNameInput
                    config.reloadConfig() 
                } else {
                    // Handle name collision - maybe show another alert?
                    print("Error: Name '\(newConfigNameInput)' is already in use.")
                    // For simplicity, just print error for now.
                }
            } else {
                // Handle invalid input (e.g., empty name or trying to use reserved names)
                print("Error: Invalid name '\(newConfigNameInput)'. Cannot be empty or a reserved name.")
            }
        }
        Button("Cancel", role: .cancel) { }
    }, message: {
        Text("Enter a new name for the configuration '\(config.selectedConfigKeyForEditing)'. Reserved names '\(globalDefaultDisplayName)' and '\(defaultAppConfigDisplayName)' are not allowed.")
    })
  }

  private func expandAllGroups(in group: Group, parentPath: [Int]) {
    for (index, item) in group.actions.enumerated() {
      let currentPath = parentPath + [index]
      if case .group(let subgroup) = item {
        expandedGroups.insert(currentPath)
        expandAllGroups(in: subgroup, parentPath: currentPath)
      }
    }
  }
}

struct GeneralPane_Previews: PreviewProvider {
  static var previews: some View {
    // Preview needs adjustment if UserConfig init requires more
    let previewConfig = UserConfig()
    // Manually add some discovered files for preview
    previewConfig.discoveredConfigFiles = [
        globalDefaultDisplayName: "/path/to/config.json",
        defaultAppConfigDisplayName: "/path/to/app.default.json",
        "App: com.app.example": "/path/to/app.com.app.example.json",
        "App: com.another.app": "/path/to/app.com.another.app.json"
    ]
    previewConfig.currentlyEditingGroup = previewConfig.root // Set initial editing group for preview

    return GeneralPane()
      .environmentObject(previewConfig)
  }
}

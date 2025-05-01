import Defaults
import KeyboardShortcuts
import LaunchAtLogin
import Settings
import SwiftUI

struct GeneralPane: View {
  private let contentWidth = 450.0
  @EnvironmentObject private var config: UserConfig
  @Default(.configDir) var configDir
  @Default(.theme) var theme
  @State private var expandedGroups = Set<[Int]>()
  @State private var showingRenameAlert = false
  @State private var newConfigNameInput = ""

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
      Settings.Section(title: "Configuration File", verticalAlignment: .center) {
        HStack {
          Text("Editing:")
          Picker("Select Config", selection: $config.selectedConfigKeyForEditing) {
              ForEach(sortedConfigKeys, id: \.self) { key in
                  Text(key).tag(key)
              }
          }
          .labelsHidden()
          .onChange(of: config.selectedConfigKeyForEditing) { newKey in
              // First clear expanded groups to avoid any stale references
              expandedGroups.removeAll()
              
              // Use DispatchQueue to ensure state is updated before loading the new config
              DispatchQueue.main.async {
                  config.loadConfigForEditing(key: newKey)
              }
          }

          Button("Rename") {
              // Get current custom name or default name to pre-fill
              if let filePath = config.discoveredConfigFiles[config.selectedConfigKeyForEditing] {
                  newConfigNameInput = Defaults[.configFileCustomNames][filePath] ?? config.selectedConfigKeyForEditing
                  // Prevent renaming Global Default placeholder if it somehow lost its custom name
                  if newConfigNameInput == globalDefaultDisplayName { newConfigNameInput = "" }
              } else {
                  newConfigNameInput = "" // Should not happen ideally
              }
              showingRenameAlert = true
          }
          .disabled(config.selectedConfigKeyForEditing == globalDefaultDisplayName)
          // TODO: Add buttons for "New App Config" / "Delete App Config"?
        }
      }

      Settings.Section(
        title: "Config Content", bottomDivider: true, verticalAlignment: .top
      ) {
        VStack(alignment: .leading, spacing: 8) {
          VStack {
            // Use currentlyEditingGroup instead of config.root
            ConfigEditorView(group: $config.currentlyEditingGroup, expandedGroups: $expandedGroups)
              .frame(height: 500)
              // Probably horrible for accessibility but improves performance a ton
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
              // Use saveCurrentlyEditingConfig
              Button("Save Changes") {
                config.saveCurrentlyEditingConfig()
              }

              // Use reloadConfig (which reloads the selected one)
              Button("Reload Current File") {
                config.reloadConfig() // Reloads the currently selected config
              }
            }

            Spacer()

            // Right-aligned buttons (operate on currentlyEditingGroup)
            HStack(spacing: 8) {
              Button(action: {
                withAnimation(.easeOut(duration: 0.1)) {
                  // Use currentlyEditingGroup
                  expandAllGroups(in: config.currentlyEditingGroup, parentPath: [])
                }
              }) {
                Image(systemName: "chevron.down")
                Text("Expand all")
              }

              Button(action: {
                withAnimation(.easeOut(duration: 0.1)) {
                  expandedGroups.removeAll()
                }
              }) {
                Image(systemName: "chevron.right")
                Text("Collapse all")
              }
            }
          }
        }
      }

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

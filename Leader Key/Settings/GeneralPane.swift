import Defaults
import KeyboardShortcuts
import LaunchAtLogin
import Settings
import SwiftUI

struct GeneralPane: View {
  private let contentWidth = 800.0
  @EnvironmentObject private var config: UserConfig
  @Default(.configDir) var configDir
  @Default(.theme) var theme
  @State private var expandedGroups = Set<[Int]>()

  // Sorted list of config keys for the Picker
  var sortedConfigKeys: [String] {
      config.discoveredConfigFiles.keys.sorted { key1, key2 in
          if key1 == defaultEditKey { return true }
          if key2 == defaultEditKey { return false }
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
              config.loadConfigForEditing(key: newKey)
              // Reset expanded state when changing file
              expandedGroups = Set<[Int]>()
          }
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
        defaultEditKey: "/path/to/config.json",
        "com.app.example": "/path/to/app.com.app.example.json"
    ]
    previewConfig.currentlyEditingGroup = previewConfig.root // Set initial editing group for preview

    return GeneralPane()
      .environmentObject(previewConfig)
  }
}

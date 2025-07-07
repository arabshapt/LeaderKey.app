import Defaults
import KeyboardShortcuts
import LaunchAtLogin
import Settings
import SwiftUI
import AppKit

struct GeneralPane: View {
  private let contentWidth = 1100.0
  @EnvironmentObject private var config: UserConfig
  @Default(.configDir) var configDir
  @Default(.theme) var theme
  @State private var expandedGroups = Set<[Int]>()
  @State private var showingRenameAlert = false
  @State private var newConfigNameInput = ""
  @State private var filePathToRename: String? = nil
  @State private var keyToLoad: String? = nil
  @State private var listSelection: String? = nil
  @State private var showingAddConfigSheet = false

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
                                          filePathToRename = filePath
                                          showingRenameAlert = true
                                      } else {
                                          // Handle case where path isn't found (should not happen here)
                                          print("Error: Could not find file path for key '\(key)' when preparing rename.")
                                          filePathToRename = nil
                                          newConfigNameInput = ""
                                      }
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
                  .frame(minWidth: 180, idealWidth: 200, maxWidth: 220) // Reduced maxWidth
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
                  
                  // --- Add Config Button ---
                  Button {
                      showingAddConfigSheet = true
                  } label: {
                      Label("Add Config", systemImage: "plus")
                  }
                  .buttonStyle(.borderless)
                  .padding(.top, 4)

                  // Spacer to push button to top-left alignment
                  Spacer(minLength: 0)

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
                          .padding(.trailing) // Add trailing padding here
                      }
                  }
                  Spacer() // Pushes content to the top
              }
              .frame(maxWidth: .infinity) // Allow right side to expand
              // --- Right Content Area: Config Editor --- END ---
          }
          .padding(.leading, -40) // Increased negative padding to shift left further
          .task(id: keyToLoad) {
              guard let key = keyToLoad else { return } // Only run if keyToLoad is set
              
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
            // Use the file path stored when the rename button was clicked
            guard let path = filePathToRename else {
                print("Error: filePathToRename is nil during save.")
                return
            }

            // Now use if let for the dictionary lookup and combine other checks
            if !newConfigNameInput.isEmpty,
               newConfigNameInput != globalDefaultDisplayName,
               newConfigNameInput != defaultAppConfigDisplayName 
            {
                var currentCustomNames = Defaults[.configFileCustomNames]
                // Ensure the new name isn't already used (by a custom name or a default name)
                // Note: Check against other values in currentCustomNames, EXCLUDING the current path itself
                let existingCustomNamePaths = currentCustomNames.filter { $0.key != path && $0.value == newConfigNameInput }.map { $0.key }
                let existingDefaultNamePaths = config.discoveredConfigFiles.filter { $0.value != path && $0.key == newConfigNameInput }.map { $0.value }

                if existingCustomNamePaths.isEmpty && existingDefaultNamePaths.isEmpty {
                    print("Saving new name '\(newConfigNameInput)' for path '\(path)'")
                    currentCustomNames[path] = newConfigNameInput
                    Defaults[.configFileCustomNames] = currentCustomNames
                    
                    // Store the new name to select it after reload
                    let nameToSelect = newConfigNameInput
                    
                    // Reload config FIRST to update the list source
                    config.reloadConfig()
                    
                    // Update list selection AFTER reload starts (async)
                    DispatchQueue.main.async {
                        print("Setting listSelection to '\(nameToSelect)' after reload.")
                        listSelection = nameToSelect
                        // Also update the config's internal selection state if needed, though reload might handle it
                        // config.selectedConfigKeyForEditing = nameToSelect 
                    }
                } else {
                    // Handle name collision
                    print("Error: Name '\(newConfigNameInput)' is already in use.")
                }
            } else {
                // Handle invalid input
                print("Error: Invalid name '\(newConfigNameInput)'. Cannot be empty or a reserved name.")
            }
        }
        Button("Cancel", role: .cancel) { }
    }, message: {
        // Construct the message dynamically
        var messageText = "Enter a new name for the configuration '\(config.selectedConfigKeyForEditing)'."
        // Fix URL creation for file paths
        if let path = filePathToRename { // Unwrap path first
            let url = URL(fileURLWithPath: path) // Create URL directly
            if !url.lastPathComponent.isEmpty { // Check lastPathComponent
                messageText += "\n(File: \(url.lastPathComponent))"
            } else { // Handle case where lastPathComponent might be empty for some reason
                messageText += "\n(Path: ...\(path.suffix(40)))"
            }
        } // Fallback is implicitly handled if path is nil
        
        messageText += "\n\nReserved names '\(globalDefaultDisplayName)' and '\(defaultAppConfigDisplayName)' are not allowed."
        return Text(messageText)
    })
    // Sheet for creating new configs
    .sheet(isPresented: $showingAddConfigSheet) {
        AddConfigSheet()
            .environmentObject(config) // Pass environment
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

// MARK: - AddConfigSheet
private struct AddConfigSheet: View {
    @EnvironmentObject var config: UserConfig
    @Environment(\.dismiss) private var dismiss

    // Running applications with a bundle id & regular activation policy
    private var runningApps: [NSRunningApplication] {
        NSWorkspace.shared.runningApplications
            .filter { $0.bundleIdentifier != nil && $0.activationPolicy == .regular }
            .sorted { ($0.localizedName ?? "") < ($1.localizedName ?? "") }
    }

    @State private var selectedApp: NSRunningApplication? = NSWorkspace.shared.frontmostApplication
    @State private var showManualEntry = false
    @State private var manualBundleId = ""
    @State private var customDisplayName = ""

    private var effectiveBundleId: String {
        if showManualEntry {
            return manualBundleId.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return selectedApp?.bundleIdentifier ?? ""
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Create New Configuration")
                .font(.title2)

            // Picker for running applications
            Picker("Application", selection: $selectedApp) {
                ForEach(runningApps, id: \.processIdentifier) { app in
                    HStack {
                        Image(nsImage: app.icon ?? NSImage())
                            .resizable()
                            .frame(width: 16, height: 16)
                        Text(app.localizedName ?? app.bundleIdentifier ?? "Unknown")
                    }
                    .tag(app as NSRunningApplication?)
                }
            }
            .disabled(showManualEntry)

            // Advanced manual entry
            Toggle("Advanced: Enter bundle identifier manually", isOn: $showManualEntry)

            if showManualEntry {
                TextField("com.example.app", text: $manualBundleId)
                    .textFieldStyle(.roundedBorder)
            }

            // Pick an application that isn't currently running
            Button("Choose App from Disk…") {
                presentOpenPanel()
            }

            Divider()

            TextField("Optional sidebar name", text: $customDisplayName)
                .textFieldStyle(.roundedBorder)

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Create") {
                    createConfig()
                }
                .disabled(effectiveBundleId.isEmpty)
            }
        }
        .padding(24)
        .frame(minWidth: 400)
    }

    private func createConfig() {
        let _ = config.createConfigForApp(
            bundleId: effectiveBundleId,
            templateKey: nil,
            customName: customDisplayName.isEmpty ? nil : customDisplayName
        )
        // Dismiss regardless; success/failure alerts handled in helper
        dismiss()
    }

    // Presents an NSOpenPanel allowing the user to select a .app bundle and extracts its bundle identifier
    private func presentOpenPanel() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.application]
        panel.canChooseDirectories = true // .app is technically a directory
        panel.canChooseFiles = true   // Allow selecting bundle as a file
        panel.title = "Select an Application"

        if panel.runModal() == .OK, let url = panel.url {
            if let bundle = Bundle(url: url), let bundleId = bundle.bundleIdentifier {
                manualBundleId = bundleId
                showManualEntry = true
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

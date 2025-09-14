import AppKit
import Defaults
import KeyboardShortcuts
import LaunchAtLogin
import Settings
import SwiftUI

// Profile sheet presentation mode
enum ProfileSheetMode: Identifiable {
  case create
  case edit(LeaderKeyProfile)
  
  var id: String {
    switch self {
    case .create:
      return "create"
    case .edit(let profile):
      return "edit_\(profile.id.uuidString)"
    }
  }
}

struct GeneralPane: View {
  private let contentWidth = SettingsConfig.contentWidth
  @EnvironmentObject private var config: UserConfig
  @Default(.configDir) var configDir
  @Default(.theme) var theme
  @Default(.showFallbackItems) var showFallbackItems
  @State private var expandedGroups = Set<[Int]>()
  @State private var showingRenameAlert = false
  @State private var showingDeleteAlert = false
  @State private var newConfigNameInput = ""
  @State private var filePathToRename: String?
  @State private var keyToLoad: String?
  @State private var listSelection: String?
  @State private var showingAddConfigSheet = false
  @State private var keyToDelete: String?
  @State private var highlightedPath: [Int]?
  @State private var hasInitialized = false
  
  // Profile management
  @ObservedObject private var profileManager = ProfileManager.shared
  @State private var profileSheetMode: ProfileSheetMode?
  @State private var showingDeleteConfirmation = false
  @State private var profileToDelete: LeaderKeyProfile?

  // Sorted list of config keys for the Picker
  var sortedConfigKeys: [String] {
    config.discoveredConfigFiles.keys.sorted { key1, key2 in
      // Prioritize Fallback App Config
      if key1 == defaultAppConfigDisplayName { return true }
      if key2 == defaultAppConfigDisplayName { return false }
      // Sort remaining app-specific keys alphabetically
      return key1 < key2
    }
  }

  var renameAlertMessage: String {
    var messageText =
      "Enter a new name for the configuration '\(config.selectedConfigKeyForEditing)'."
    // Fix URL creation for file paths
    if let path = filePathToRename {  // Unwrap path first
      let url = URL(fileURLWithPath: path)  // Create URL directly
      if !url.lastPathComponent.isEmpty {  // Check lastPathComponent
        messageText += "\n(File: \(url.lastPathComponent))"
      } else {  // Handle case where lastPathComponent might be empty for some reason
        messageText += "\n(Path: ...\(path.suffix(40)))"
      }
    }  // Fallback is implicitly handled if path is nil

    messageText +=
      "\n\nReserved name '\(defaultAppConfigDisplayName)' is not allowed."
    return messageText
  }

  var body: some View {
    Settings.Container(contentWidth: contentWidth) {
      // Wrap the main layout in a Settings.Section, providing an empty title
      Settings.Section(title: "") {
        // Main Horizontal Layout
        HStack(alignment: .top, spacing: 0) {
          // --- Profile Vertical Bar --- START ---
          VStack(spacing: 6) {
            ForEach(profileManager.profiles) { profile in
              ProfileIconView(
                profile: profile,
                isActive: profile.id == profileManager.activeProfile?.id,
                action: {
                  profileManager.setActiveProfile(profile)
                  config.switchToProfile(profile)
                }
              )
            }
            
            // Add profile button
            Button(action: {
              print("[GeneralPane Add Button] Creating new profile")
              profileSheetMode = .create
            }) {
              Image(systemName: "plus.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("Add new profile")
            
            Spacer()
          }
          .frame(width: 44)
          .padding(.vertical, 4)
          .background(Color.black.opacity(0.05))
          
          Divider()
          
          // --- Left Sidebar: Config List --- START ---
          VStack(alignment: .leading, spacing: 4) {
            
            // Profile selector with management buttons
            HStack(spacing: 2) {
              Picker("", selection: Binding(
                get: { profileManager.activeProfile?.id ?? UUID() },
                set: { newId in
                  if let profile = profileManager.profiles.first(where: { $0.id == newId }) {
                    profileManager.setActiveProfile(profile)
                    config.switchToProfile(profile)
                  }
                }
              )) {
                ForEach(profileManager.profiles) { profile in
                  Text(profile.name).tag(profile.id)
                }
              }
              .pickerStyle(.menu)
              .frame(width: 120)
              
              Button(action: {
                print("[GeneralPane Add Button 2] Creating new profile")
                profileSheetMode = .create
              }) {
                Image(systemName: "plus")
              }
              .buttonStyle(.borderless)
              .help("Add new profile")
              
              Button(action: {
                print("[GeneralPane Edit Button] Clicked. activeProfile: \(profileManager.activeProfile?.name ?? "nil")")
                if let activeProfile = profileManager.activeProfile {
                  print("[GeneralPane Edit Button] Setting profileSheetMode to edit: \(activeProfile.name)")
                  profileSheetMode = .edit(activeProfile)
                } else {
                  print("[GeneralPane Edit Button] ERROR: activeProfile is nil, cannot edit")
                }
              }) {
                Image(systemName: "pencil")
              }
              .buttonStyle(.borderless)
              .disabled(profileManager.activeProfile == nil)
              .help("Edit current profile")
              
              Button(action: {
                if let activeProfile = profileManager.activeProfile,
                   profileManager.profiles.count > 1 {
                  profileToDelete = activeProfile
                  showingDeleteConfirmation = true
                }
              }) {
                Image(systemName: "trash")
              }
              .buttonStyle(.borderless)
              .foregroundColor(.red)
              .disabled(profileManager.profiles.count <= 1)
              .help("Delete current profile")
            }

            List(selection: $listSelection) {
              ForEach(sortedConfigKeys, id: \.self) { key in
                HStack {
                  // Show app icon for app-specific configs
                  if let bundleId = config.extractBundleId(from: key),
                    let appIcon = config.getAppIcon(for: bundleId)
                  {
                    Image(nsImage: appIcon)
                      .resizable()
                      .frame(width: 16, height: 16)
                  }

                  Text(key)
                    .tag(key)  // Needed for List selection binding
                    .lineLimit(1)
                    .truncationMode(.middle)
                  Spacer()
                  // Simple Rename Button - could be improved with context menu later
                  if key != defaultAppConfigDisplayName {
                    Button {
                      // Get current custom name or default name to pre-fill
                      if let filePath = config.discoveredConfigFiles[key] {
                        // Try to get name from metadata first
                        if let metadata = config.loadMetadata(for: filePath),
                          let customName = metadata.customName
                        {
                          newConfigNameInput = customName
                        } else {
                          // Fall back to Defaults or use the key
                          newConfigNameInput = Defaults[.configFileCustomNames][filePath] ?? key
                        }
                        filePathToRename = filePath
                        showingRenameAlert = true
                      } else {
                        // Handle case where path isn't found (should not happen here)
                        print(
                          "Error: Could not find file path for key '\(key)' when preparing rename.")
                        filePathToRename = nil
                        newConfigNameInput = ""
                      }
                    } label: {
                      Image(systemName: "pencil.circle")
                    }
                    .buttonStyle(.plain)  // Use plain style for subtle look in list
                    .foregroundColor(.secondary)

                    // Delete button
                    Button {
                      keyToDelete = key
                      showingDeleteAlert = true
                    } label: {
                      Image(systemName: "trash")
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.red)
                  }
                }
              }
            }
            .listStyle(.sidebar)  // Use a sidebar style for the list
            .frame(minWidth: 180, idealWidth: 200, maxWidth: 220)  // Reduced maxWidth
            .onChange(of: listSelection) { newSelection in
              guard let newKey = newSelection else { return }  // Ignore nil selection
              print("[GeneralPane onChange(listSelection)] Setting keyToLoad = \(newKey)")
              self.keyToLoad = newKey  // Update the trigger state for the task
              // Also update the config's state, but asynchronously
              DispatchQueue.main.async {
                // Check if it actually changed to avoid redundant updates
                if self.config.selectedConfigKeyForEditing != newKey {
                  print(
                    "[GeneralPane onChange(listSelection) async] Updating config.selectedConfigKeyForEditing = \(newKey)"
                  )
                  self.config.selectedConfigKeyForEditing = newKey
                  // Config loading will set isActivelyEditing = false automatically
                }
              }
            }
            .onAppear {
              if listSelection == nil {  // Initialize only once
                listSelection = config.selectedConfigKeyForEditing
                print(
                  "[GeneralPane onAppear] Initialized listSelection to \(listSelection ?? "nil")")
              }
            }
            .onChange(of: config.selectedConfigKeyForEditing) { newSelectedKey in
              // Update the sidebar selection when the config's selected key changes
              if listSelection != newSelectedKey {
                print(
                  "[GeneralPane onChange(selectedConfigKeyForEditing)] Updating listSelection from \(listSelection ?? "nil") to \(newSelectedKey)"
                )
                listSelection = newSelectedKey
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

            // Validation Summary
            ValidationSummaryView(
              errors: config.validationErrors,
              onErrorTap: { error in
                // Navigate to the error location by expanding groups if needed
                expandToPath(error.path)
              }
            )
            .padding([.bottom], 8)

            // The existing config editor section
            VStack(alignment: .leading, spacing: 8) {
              VStack {
                ConfigEditorView(
                  group: $config.currentlyEditingGroup, expandedGroups: $expandedGroups
                )
                .frame(minHeight: 500)  // Ensure it has enough height
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
                  Button("Save Changes") {
                    config.saveAndFinalize()
                  }
                  Button("Reload Current File") {
                    config.reloadConfig()
                    // Reload will set isActivelyEditing = false automatically
                  }
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
                .padding(.trailing)  // Add trailing padding here
              }
            }
            Spacer()  // Pushes content to the top
          }
          .frame(maxWidth: .infinity)  // Allow right side to expand
          // --- Right Content Area: Config Editor --- END ---
        }
        .padding(.leading, -80)  // Pull left edge to window border
        .task(id: keyToLoad) {
          guard let key = keyToLoad else { return }  // Only run if keyToLoad is set

          print("[GeneralPane .task(id: keyToLoad)] Loading config for key: \(key)")
          self.expandedGroups.removeAll()
          self.config.loadConfigForEditing(key: key)

          self.keyToLoad = nil
        }
        .onReceive(
          NotificationCenter.default.publisher(for: Notification.Name("NavigateToSearchResult"))
        ) { notification in
          guard let path = notification.userInfo?["path"] as? [Int] else { return }

          print("[GeneralPane] Received navigation request for path: \(path)")

          // Check if this is from error navigation (has isError flag) or regular navigation
          let isErrorNavigation = notification.userInfo?["isError"] as? Bool ?? false

          if isErrorNavigation {
            // For errors, expand only parent groups (existing behavior)
            expandToPath(path)
          } else {
            // For regular navigation from Leader Key, collapse all groups first then expand target
            expandedGroups.removeAll()
            expandFullPath(path)
          }

          // Set highlighted path
          highlightedPath = path

          // Clear highlight after a delay
          DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            highlightedPath = nil
          }
        }
      }  // End of Settings.Section wrapping the HStack

      // Sections below the main HStack can remain as they were
      Settings.Section(title: "Theme") {
        Picker("Theme", selection: $theme) {
          ForEach(Theme.all, id: \.self) { value in
            Text(Theme.name(value)).tag(value)
          }
        }.frame(maxWidth: 170).labelsHidden()
      }

      Settings.Section(title: "FB") {
        Toggle("Show fallback items", isOn: $showFallbackItems)
        Text(
          "Show items inherited from Fallback App Config in both the settings editor and Leader Key panels. Fallback items appear with visual indicators and can be overridden to create app-specific versions."
        )
        .font(.caption)
        .foregroundColor(.secondary)
      }

      Settings.Section(title: "App") {
        LaunchAtLogin.Toggle()
      }
    }
    .alert(
      "Rename Configuration", isPresented: $showingRenameAlert,
      actions: {
        TextField("New Name", text: $newConfigNameInput)
        Button("Save") {
          // Use the file path stored when the rename button was clicked
          guard let path = filePathToRename else {
            print("Error: filePathToRename is nil during save.")
            return
          }

          // Now use if let for the dictionary lookup and combine other checks
          if !newConfigNameInput.isEmpty,
            newConfigNameInput != defaultAppConfigDisplayName
          {
            // Check for name collisions
            let existingDefaultNamePaths = config.discoveredConfigFiles.filter {
              $0.value != path && $0.key == newConfigNameInput
            }.map { $0.value }

            if existingDefaultNamePaths.isEmpty {
              print("Saving new name '\(newConfigNameInput)' for path '\(path)'")

              // Save to metadata file instead of Defaults
              config.updateMetadataCustomName(newConfigNameInput, for: path)

              // Also update Defaults for backward compatibility (will be removed in future)
              var currentCustomNames = Defaults[.configFileCustomNames]
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
            print(
              "Error: Invalid name '\(newConfigNameInput)'. Cannot be empty or a reserved name.")
          }
        }
        Button("Cancel", role: .cancel) {}
      },
      message: {
        Text(renameAlertMessage)
      }
    )
    // Delete confirmation alert
    .alert(
      "Delete Configuration", isPresented: $showingDeleteAlert,
      actions: {
        Button("Delete", role: .destructive) {
          if let key = keyToDelete {
            _ = config.deleteConfig(displayKey: key)
          }
          keyToDelete = nil
        }
        Button("Cancel", role: .cancel) {
          keyToDelete = nil
        }
      },
      message: {
        Text(
          "Are you sure you want to delete the configuration ‘\(keyToDelete ?? "")’? This action cannot be undone."
        )
      }
    )
    // Sheet for creating new configs
    .sheet(isPresented: $showingAddConfigSheet) {
      AddConfigSheet()
        .environmentObject(config)  // Pass environment
    }
    // Sheet for managing profiles
    .sheet(item: $profileSheetMode) { mode in
      switch mode {
      case .create:
        ProfileManagementSheet(
          profileManager: profileManager,
          profileToEdit: nil
        )
        .onAppear {
          print("[GeneralPane sheet] Showing ProfileManagementSheet in CREATE mode")
        }
      case .edit(let profile):
        ProfileManagementSheet(
          profileManager: profileManager,
          profileToEdit: profile
        )
        .onAppear {
          print("[GeneralPane sheet] Showing ProfileManagementSheet in EDIT mode for profile: \(profile.name)")
        }
      }
    }
    // Alert for profile deletion confirmation
    .alert("Delete Profile", isPresented: $showingDeleteConfirmation) {
      Button("Cancel", role: .cancel) { }
      Button("Delete", role: .destructive) {
        if let profile = profileToDelete {
          _ = profileManager.deleteProfile(profile)
          // After deletion, switch to the new active profile's config
          if let newActiveProfile = profileManager.activeProfile {
            config.switchToProfile(newActiveProfile)
          }
        }
      }
    } message: {
      if let profile = profileToDelete {
        Text("Are you sure you want to delete the profile '\(profile.name)'? This action cannot be undone.")
      }
    }
    .onAppear {
      print("[GeneralPane onAppear] View appeared. profileManager.activeProfile: \(profileManager.activeProfile?.name ?? "nil")")
      print("[GeneralPane onAppear] profileManager.profiles.count: \(profileManager.profiles.count)")
      
      // Only switch to active profile's config on initial load
      // This prevents switching when LeaderKey is activated while settings are open
      if !hasInitialized {
        if let activeProfile = profileManager.activeProfile {
          print("[GeneralPane onAppear] Switching to profile: \(activeProfile.name)")
          config.switchToProfile(activeProfile)
        } else {
          print("[GeneralPane onAppear] No active profile to switch to")
        }
        hasInitialized = true
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: .profileDidChange)) { notification in
      print("[GeneralPane onReceive] Received profileDidChange notification")
      if let profile = notification.userInfo?["profile"] as? LeaderKeyProfile {
        print("[GeneralPane onReceive] Notification profile: \(profile.name)")
      }
      
      // Reload profiles when changed externally (e.g., via keyboard shortcut)
      print("[GeneralPane onReceive] Reloading profiles...")
      profileManager.loadProfiles()
      print("[GeneralPane onReceive] After reload - activeProfile: \(profileManager.activeProfile?.name ?? "nil")")
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

  private func expandToPath(_ path: [Int]) {
    // Expand all parent groups along the path to make the error item visible
    var currentPath: [Int] = []
    for index in path.dropLast() {
      currentPath.append(index)
      // Check if this path represents a group
      if let item = ConfigValidator.findItem(in: config.currentlyEditingGroup, at: currentPath),
        case .group = item
      {
        expandedGroups.insert(currentPath)
      }
    }
  }

  private func expandFullPath(_ path: [Int]) {
    // Expand all groups in the path, including the target group
    var currentPath: [Int] = []
    for index in path {
      currentPath.append(index)
      // Check if this path represents a group
      if let item = ConfigValidator.findItem(in: config.currentlyEditingGroup, at: currentPath),
        case .group = item
      {
        expandedGroups.insert(currentPath)
        print("[GeneralPane] expandFullPath: Expanded group at path \(currentPath)")
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
  @State private var selectedTemplate = "Empty"
  @State private var isOverlayConfig = false

  private var effectiveBundleId: String {
    if showManualEntry {
      return manualBundleId.trimmingCharacters(in: .whitespacesAndNewlines)
    } else {
      return selectedApp?.bundleIdentifier ?? ""
    }
  }

  private var templateOptions: [String] {
    var options = ["Empty"]
    options.append(
      contentsOf: config.discoveredConfigFiles.keys.sorted { key1, key2 in
        if key1 == defaultAppConfigDisplayName { return true }
        if key2 == defaultAppConfigDisplayName { return false }
        return key1 < key2
      })
    return options
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
      .onChange(of: selectedApp) { newApp in
        if !showManualEntry {
          customDisplayName = newApp?.localizedName ?? ""
        }
      }

      // Advanced manual entry
      Toggle("Advanced: Enter bundle identifier manually", isOn: $showManualEntry)
        .onChange(of: showManualEntry) { manual in
          if manual {
            selectedApp = nil  // clear dropdown selection
          }
        }

      if showManualEntry {
        TextField("com.example.app", text: $manualBundleId)
          .textFieldStyle(.roundedBorder)
      }

      // Pick an application that isn't currently running
      Button("Choose App from Disk…") {
        presentOpenPanel()
      }

      Divider()

      // Template selection
      VStack(alignment: .leading, spacing: 8) {
        Text("Start with:")
          .font(.headline)

        Picker("Template", selection: $selectedTemplate) {
          ForEach(templateOptions, id: \.self) { template in
            Text(template).tag(template)
          }
        }
        .pickerStyle(.menu)
        .frame(maxWidth: .infinity, alignment: .leading)

        Text(
          "Choose a configuration to use as a starting point, or select 'Empty' to start from scratch."
        )
        .font(.caption)
        .foregroundColor(.secondary)
      }

      TextField("Optional sidebar name", text: $customDisplayName)
        .textFieldStyle(.roundedBorder)

      Divider()

      // Overlay configuration toggle
      VStack(alignment: .leading, spacing: 8) {
        Toggle("Overlay Configuration", isOn: $isOverlayConfig)
          .font(.headline)

        Text(
          "Overlay configurations are used when apps like Raycast or Alfred show overlay windows. They have a '.overlay' suffix in the filename."
        )
        .font(.caption)
        .foregroundColor(.secondary)
      }

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
    let templateKey = selectedTemplate == "Empty" ? "EMPTY_TEMPLATE" : selectedTemplate
    _ = config.createConfigForApp(
      bundleId: effectiveBundleId,
      templateKey: templateKey,
      customName: customDisplayName.isEmpty ? nil : customDisplayName,
      isOverlay: isOverlayConfig
    )
    // Dismiss regardless; success/failure alerts handled in helper
    dismiss()
  }

  // Presents an NSOpenPanel allowing the user to select a .app bundle and extracts its bundle identifier
  private func presentOpenPanel() {
    let panel = NSOpenPanel()
    panel.allowsMultipleSelection = false
    panel.allowedContentTypes = [.application]
    panel.canChooseDirectories = true  // .app is technically a directory
    panel.canChooseFiles = true  // Allow selecting bundle as a file
    panel.title = "Select an Application"

    if panel.runModal() == .OK, let url = panel.url {
      if let bundle = Bundle(url: url), let bundleId = bundle.bundleIdentifier {
        manualBundleId = bundleId
        showManualEntry = true
        if let name = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String {
          customDisplayName = name
        } else {
          customDisplayName = url.deletingPathExtension().lastPathComponent
        }
      }
    }
  }
}

// MARK: - ProfileIconView
private struct ProfileIconView: View {
  let profile: LeaderKeyProfile
  let isActive: Bool
  let action: () -> Void
  
  private var initials: String {
    let words = profile.name.split(separator: " ")
    if words.count >= 2 {
      // Take first letter of first two words
      return String(words[0].prefix(1) + words[1].prefix(1)).uppercased()
    } else {
      // Take first two letters of single word
      return String(profile.name.prefix(2)).uppercased()
    }
  }
  
  var body: some View {
    Button(action: action) {
      ZStack {
        RoundedRectangle(cornerRadius: 8)
          .fill(isActive ? Color.accentColor : Color.secondary.opacity(0.2))
          .frame(width: 36, height: 36)
        
        if let iconName = profile.iconName {
          // Use custom icon if available
          Image(systemName: iconName)
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(isActive ? .white : .primary)
        } else {
          // Fallback to initials
          Text(initials)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(isActive ? .white : .primary)
        }
      }
    }
    .buttonStyle(.plain)
    .help(profile.name)
    .scaleEffect(isActive ? 1.05 : 1.0)
    .animation(.easeInOut(duration: 0.1), value: isActive)
  }
}

struct GeneralPane_Previews: PreviewProvider {
  static var previews: some View {
    // Preview needs adjustment if UserConfig init requires more
    let previewConfig = UserConfig()
    // Manually add some discovered files for preview
    previewConfig.discoveredConfigFiles = [
      defaultAppConfigDisplayName: "/path/to/app-fallback-config.json",
      "App: com.app.example": "/path/to/app.com.app.example.json",
      "App: com.another.app": "/path/to/app.com.another.app.json",
    ]
    previewConfig.currentlyEditingGroup = previewConfig.root  // Set initial editing group for preview

    return GeneralPane()
      .environmentObject(previewConfig)
  }
}

// MARK: - ValidationSummaryView
private struct ValidationSummaryView: View {
  let errors: [ValidationError]
  let onErrorTap: ((ValidationError) -> Void)?

  init(errors: [ValidationError], onErrorTap: ((ValidationError) -> Void)? = nil) {
    self.errors = errors
    self.onErrorTap = onErrorTap
  }

  var body: some View {
    if errors.isEmpty {
      HStack(spacing: 8) {
        Image(systemName: "checkmark.circle.fill")
          .foregroundColor(.green)
        Text("No validation issues")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(Color.green.opacity(0.1))
      .cornerRadius(8)
    } else {
      VStack(alignment: .leading, spacing: 8) {
        // Summary header
        HStack(spacing: 8) {
          Image(systemName: "exclamationmark.triangle.fill")
            .foregroundColor(summaryIconColor)
          Text("\(errors.count) validation \(errors.count == 1 ? "issue" : "issues")")
            .font(.caption)
            .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(summaryBackgroundColor)
        .cornerRadius(8)

        // Error list
        LazyVStack(alignment: .leading, spacing: 4) {
          ForEach(errors) { error in
            ValidationErrorRow(error: error, onTap: onErrorTap)
          }
        }
        .padding(.horizontal, 8)
      }
      .padding(.vertical, 4)
      .background(Color(.controlBackgroundColor))
      .cornerRadius(12)
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(Color.gray.opacity(0.2), lineWidth: 1)
      )
    }
  }

  private var summaryIconColor: Color {
    let hasErrors = errors.contains { $0.severity == .error }
    return hasErrors ? .red : .orange
  }

  private var summaryBackgroundColor: Color {
    let hasErrors = errors.contains { $0.severity == .error }
    return hasErrors ? Color.red.opacity(0.1) : Color.orange.opacity(0.1)
  }
}

// MARK: - ProfileManagementSheet
struct ProfileManagementSheet: View {
  @ObservedObject var profileManager: ProfileManager
  let profileToEdit: LeaderKeyProfile?
  
  @Environment(\.dismiss) private var dismiss
  @State private var profileName: String = ""
  @State private var selectedIcon: String? = nil
  @State private var showingError = false
  @State private var errorMessage = ""
  
  // Popular SF Symbols for profiles
  private let iconOptions = [
    "person.circle.fill",
    "briefcase.fill",
    "gamecontroller.fill",
    "house.fill",
    "laptopcomputer",
    "desktopcomputer",
    "iphone",
    "star.fill",
    "heart.fill",
    "bolt.fill",
    "flame.fill",
    "moon.fill",
    "sun.max.fill",
    "cloud.fill",
    "book.fill",
    "music.note",
    "video.fill",
    "mic.fill",
    "headphones",
    "airplane",
    "car.fill",
    "bicycle",
    "figure.walk",
    "figure.run"
  ]
  
  var isEditing: Bool {
    let editing = profileToEdit != nil
    print("[ProfileManagementSheet] isEditing computed: \(editing), profileToEdit: \(profileToEdit?.name ?? "nil")")
    return editing
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      Text(isEditing ? "Edit Profile" : "Create New Profile")
        .font(.title2)
        .fontWeight(.semibold)
      
      VStack(alignment: .leading, spacing: 8) {
        Text("Profile Name")
          .font(.headline)
        
        TextField("Enter profile name", text: $profileName)
          .textFieldStyle(.roundedBorder)
        
        Text("Choose a descriptive name for this profile (e.g., Work, Personal, Gaming)")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      
      VStack(alignment: .leading, spacing: 8) {
        Text("Profile Icon")
          .font(.headline)
        
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 12) {
            ForEach(iconOptions, id: \.self) { iconName in
              Button(action: {
                selectedIcon = iconName
              }) {
                ZStack {
                  RoundedRectangle(cornerRadius: 8)
                    .fill(selectedIcon == iconName ? Color.accentColor : Color.secondary.opacity(0.2))
                    .frame(width: 44, height: 44)
                  
                  Image(systemName: iconName)
                    .font(.system(size: 20))
                    .foregroundColor(selectedIcon == iconName ? .white : .primary)
                }
              }
              .buttonStyle(.plain)
            }
          }
          .padding(.vertical, 4)
        }
        
        Text("Select an icon for this profile (optional)")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      
      if !isEditing {
        VStack(alignment: .leading, spacing: 8) {
          Text("Activation Shortcut")
            .font(.headline)
          
          if let profile = profileToEdit {
            KeyboardShortcuts.Recorder("", name: profile.keyboardShortcutName)
          } else {
            Text("Set the keyboard shortcut after creating the profile")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
      } else if let profile = profileToEdit {
        VStack(alignment: .leading, spacing: 8) {
          Text("Activation Shortcut")
            .font(.headline)
          
          KeyboardShortcuts.Recorder("", name: profile.keyboardShortcutName)
          
          Text("This shortcut will activate the \(profile.name) profile")
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
      
      Spacer()
      
      HStack {
        Button("Cancel") {
          dismiss()
        }
        .keyboardShortcut(.escape)
        
        Spacer()
        
        Button(isEditing ? "Save" : "Create") {
          if validateAndSave() {
            dismiss()
          }
        }
        .keyboardShortcut(.return)
        .disabled(profileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
      }
    }
    .padding(24)
    .frame(minWidth: 400, minHeight: 250)
    .onAppear {
      print("[ProfileManagementSheet onAppear] profileToEdit: \(profileToEdit?.name ?? "nil")")
      print("[ProfileManagementSheet onAppear] profileManager.activeProfile: \(profileManager.activeProfile?.name ?? "nil")")
      
      if let profile = profileToEdit {
        print("[ProfileManagementSheet onAppear] Loading profile data: \(profile.name)")
        profileName = profile.name
        selectedIcon = profile.iconName
      } else if isEditing {
        print("[ProfileManagementSheet onAppear] WARNING: isEditing is true but profileToEdit is nil")
        // Fallback: if we're editing but profileToEdit is nil, use active profile
        if let activeProfile = profileManager.activeProfile {
          print("[ProfileManagementSheet onAppear] Using fallback activeProfile: \(activeProfile.name)")
          profileName = activeProfile.name
          selectedIcon = activeProfile.iconName
        }
      } else {
        print("[ProfileManagementSheet onAppear] Creating new profile mode")
      }
    }
    .alert("Error", isPresented: $showingError) {
      Button("OK") { }
    } message: {
      Text(errorMessage)
    }
  }
  
  private func validateAndSave() -> Bool {
    let trimmedName = profileName.trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard !trimmedName.isEmpty else {
      errorMessage = "Profile name cannot be empty"
      showingError = true
      return false
    }
    
    // Check for duplicate names (excluding current profile if editing)
    let isDuplicate = profileManager.profiles.contains { profile in
      if let editing = profileToEdit, editing.id == profile.id {
        return false
      }
      return profile.name.lowercased() == trimmedName.lowercased()
    }
    
    if isDuplicate {
      errorMessage = "A profile with this name already exists"
      showingError = true
      return false
    }
    
    if let profile = profileToEdit {
      // Edit existing profile
      profileManager.updateProfile(profile, name: trimmedName, iconName: selectedIcon)
    } else {
      // Create new profile
      let newProfile = profileManager.createProfile(name: trimmedName, iconName: selectedIcon)
      // Make it active if it's the only one
      if profileManager.profiles.count == 1 {
        profileManager.setActiveProfile(newProfile)
      }
    }
    
    return true
  }
}

private struct ValidationErrorRow: View {
  let error: ValidationError
  let onTap: ((ValidationError) -> Void)?

  var body: some View {
    let errorContent = VStack(alignment: .leading, spacing: 2) {
      Text(error.message)
        .font(.caption)
        .foregroundColor(.primary)

      if let suggestion = error.suggestion {
        Text("💡 \(suggestion)")
          .font(.caption2)
          .foregroundColor(.secondary)
      }
    }

    return Button(action: {
      onTap?(error)
    }) {
      HStack(spacing: 8) {
        Image(systemName: error.severity.iconName)
          .foregroundColor(error.severity == .error ? .red : .orange)
          .font(.system(size: 12, weight: .medium))
          .frame(width: 16)

        errorContent
        Spacer()

        if onTap != nil {
          Image(systemName: "chevron.right")
            .font(.caption2)
            .foregroundColor(.secondary)
        }
      }
      .padding(8)
    }
    .buttonStyle(PlainButtonStyle())
  }
}

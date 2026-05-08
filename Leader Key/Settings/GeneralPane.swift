import AppKit
import Defaults
import KeyboardShortcuts
import LaunchAtLogin
import Settings
import SwiftUI

struct GeneralPane: View {
  private let contentWidth = SettingsConfig.contentWidth
  @EnvironmentObject private var config: UserConfig
  @Default(.configDir) var configDir
  @Default(.theme) var theme
  @Default(.showFallbackItems) var showFallbackItems
  @Default(.useNativeOutlineConfigEditor) var useNativeOutlineConfigEditor
  @State private var expandedGroups = Set<[Int]>()
  @StateObject private var nativeEditorSession = ConfigEditorSession()
  @State private var showingRenameAlert = false
  @State private var showingDeleteAlert = false
  @State private var newConfigNameInput = ""
  @State private var filePathToRename: String?
  @State private var keyToLoad: String?
  @State private var listSelection: String?
  @State private var showingAddConfigSheet = false
  @State private var showingManageTagsSheet = false
  @State private var keyToDelete: String?
  @State private var highlightedPath: [Int]?
  @State private var showingCommandScout = false
  @State private var commandScoutConfigKeyToPresent: String?
  @State private var showingCommandScoutMissingConfigAlert = false
  @State private var commandScoutMissingConfigAlertMessage = ""

  // Sorted list of config keys for the Picker
  var sortedConfigKeys: [String] {
    config.discoveredConfigFiles.keys.sorted { key1, key2 in
      // Prioritize Global Default
      if key1 == globalDefaultDisplayName { return true }
      if key2 == globalDefaultDisplayName { return false }
      // Prioritize Fallback App Config
      if key1 == defaultAppConfigDisplayName { return true }
      if key2 == defaultAppConfigDisplayName { return false }
      if key1 == normalFallbackConfigDisplayName { return true }
      if key2 == normalFallbackConfigDisplayName { return false }
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
      "\n\nReserved names '\(globalDefaultDisplayName)', '\(defaultAppConfigDisplayName)', and '\(normalFallbackConfigDisplayName)' are not allowed."
    return messageText
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
                  if !config.isProtectedConfig(displayKey: key) {
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

            HStack(spacing: 8) {
              Button {
                showingAddConfigSheet = true
              } label: {
                Label("Add Config", systemImage: "plus")
              }
              .buttonStyle(.borderless)

              Button {
                showingManageTagsSheet = true
              } label: {
                Label("Manage Tags", systemImage: "tag")
              }
              .buttonStyle(.borderless)
            }
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

            if let regularBundleId = config.extractRegularAppBundleId(from: config.selectedConfigKeyForEditing) {
              TagAssignmentsEditor(bundleId: regularBundleId, normalMode: false)
                .environmentObject(config)
                .padding(.bottom, 8)
            } else if let normalBundleId = config.extractNormalAppBundleId(from: config.selectedConfigKeyForEditing) {
              TagAssignmentsEditor(bundleId: normalBundleId, normalMode: true)
                .environmentObject(config)
                .padding(.bottom, 8)
            }

            // The existing config editor section
            VStack(alignment: .leading, spacing: 8) {
              VStack {
                if useNativeOutlineConfigEditor {
                  NativeConfigEditorView(session: nativeEditorSession)
                    .frame(minHeight: 500)
                } else {
                  ConfigEditorView(
                    group: $config.currentlyEditingGroup, expandedGroups: $expandedGroups
                  )
                  .frame(minHeight: 500)  // Ensure it has enough height
                  .focusable(false)
                }
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
                    if useNativeOutlineConfigEditor {
                      nativeEditorSession.commitToUserConfig()
                    }
                    config.saveAndFinalize()
                  }
                  Button("Reload Current File") {
                    config.reloadConfig()
                    // Reload will set isActivelyEditing = false automatically
                  }

                  if useNativeOutlineConfigEditor,
                    config.extractRegularAppBundleId(from: config.selectedConfigKeyForEditing) != nil
                  {
                    Button {
                      openCommandScout(forConfigKey: config.selectedConfigKeyForEditing)
                    } label: {
                      Label("Command Scout...", systemImage: "magnifyingglass")
                    }
                  }
                }

                Spacer()

                // Right-aligned buttons
                HStack(spacing: 8) {
                  Button {
                    if useNativeOutlineConfigEditor {
                      nativeEditorSession.expandAll()
                    } else {
                      withAnimation(.easeOut(duration: 0.1)) {
                        expandAllGroups(in: config.currentlyEditingGroup, parentPath: [])
                      }
                    }
                  } label: {
                    Image(systemName: "chevron.down")
                    Text("Expand all")
                  }

                  Button {
                    if useNativeOutlineConfigEditor {
                      nativeEditorSession.collapseAll()
                    } else {
                      withAnimation(.easeOut(duration: 0.1)) {
                        expandedGroups.removeAll()
                      }
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
        .task(id: keyToLoad) {
          guard let key = keyToLoad else { return }  // Only run if keyToLoad is set

          print("[GeneralPane .task(id: keyToLoad)] Loading config for key: \(key)")
          self.expandedGroups.removeAll()
          self.config.loadConfigForEditing(key: key)
          refreshNativeSession()

          self.keyToLoad = nil
        }
        .onReceive(Events.shared.publisher) { event in
          if event == .didReload {
            refreshNativeSession()
          }
        }
        .onChange(of: showFallbackItems) { newValue in
          if useNativeOutlineConfigEditor {
            nativeEditorSession.showFallbackItems = newValue
          }
        }
        .onAppear {
          refreshNativeSession()
          consumePendingCommandScoutOpen()
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
            if useNativeOutlineConfigEditor {
              nativeEditorSession.reveal(path: path, collapseBeforeExpand: false)
            } else {
              expandToPath(path)
            }
          } else {
            // For regular navigation from Leader Key, collapse all groups first then expand target
            if useNativeOutlineConfigEditor {
              nativeEditorSession.reveal(path: path, collapseBeforeExpand: true)
            } else {
              expandedGroups.removeAll()
              expandFullPath(path)
            }
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
            newConfigNameInput != globalDefaultDisplayName,
            newConfigNameInput != defaultAppConfigDisplayName,
            newConfigNameInput != normalFallbackConfigDisplayName
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
      AddConfigSheet(onCreateAndScout: { configKey in
        openCommandScout(forConfigKey: configKey)
      })
      .environmentObject(config)
    }
    .sheet(isPresented: $showingManageTagsSheet) {
      ManageTagsSheet()
        .environmentObject(config)
    }
    .sheet(isPresented: $showingCommandScout, onDismiss: {
      commandScoutConfigKeyToPresent = nil
    }) {
      if let selected = commandScoutConfigKeyToPresent,
         let appContext = CommandScoutAppContext.resolve(selectedConfigKey: selected, userConfig: config) {
        CommandScoutView(session: nativeEditorSession, appContext: appContext)
          .environmentObject(config)
      }
    }
    .onChange(of: config.commandScoutPendingBundleId) { pendingBundleId in
      guard pendingBundleId != nil else { return }
      consumePendingCommandScoutOpen()
    }
    .alert("Command Scout", isPresented: $showingCommandScoutMissingConfigAlert) {
      Button("OK", role: .cancel) {}
    } message: {
      Text(commandScoutMissingConfigAlertMessage)
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
    if useNativeOutlineConfigEditor {
      nativeEditorSession.reveal(path: path, collapseBeforeExpand: false)
      return
    }

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
    if useNativeOutlineConfigEditor {
      nativeEditorSession.reveal(path: path, collapseBeforeExpand: false)
      return
    }

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

  private func openCommandScout(forConfigKey configKey: String) {
    guard useNativeOutlineConfigEditor else {
      showCommandScoutMissingConfig("Command Scout requires the native outline editor.")
      return
    }
    guard config.discoveredConfigFiles[configKey] != nil,
      config.extractRegularAppBundleId(from: configKey) != nil
    else {
      showCommandScoutMissingConfig("Create an app-specific config before opening Command Scout.")
      return
    }

    if config.selectedConfigKeyForEditing != configKey {
      expandedGroups.removeAll()
      config.loadConfigForEditing(key: configKey)
    }

    listSelection = configKey
    keyToLoad = nil
    refreshNativeSession()
    commandScoutConfigKeyToPresent = configKey
    showingCommandScout = true
  }

  private func consumePendingCommandScoutOpen() {
    guard let bundleId = config.commandScoutPendingBundleId else { return }
    config.commandScoutPendingBundleId = nil
    guard let configKey = config.discoveredConfigFiles.keys.first(where: {
      config.extractRegularAppBundleId(from: $0) == bundleId
    }) else {
      showCommandScoutMissingConfig(
        "No app config exists for \(bundleId). Create one first, then run Command Scout.")
      return
    }

    openCommandScout(forConfigKey: configKey)
  }

  private func showCommandScoutMissingConfig(_ message: String) {
    commandScoutMissingConfigAlertMessage = message
    showingCommandScoutMissingConfigAlert = true
  }

  private func refreshNativeSession() {
    guard useNativeOutlineConfigEditor else { return }
    nativeEditorSession.bind(to: config)
  }
}

// MARK: - Tags
private struct TagAssignmentsEditor: View {
  @EnvironmentObject private var config: UserConfig
  let bundleId: String
  let normalMode: Bool

  private var registry: TagsRegistry {
    config.loadTagsRegistry()
  }

  private var assignedTagIds: [String] {
    config.assignedTagIds(for: bundleId, normalMode: normalMode, registry: registry)
  }

  private var availableTags: [TagDefinition] {
    registry.tags.filter { !assignedTagIds.contains($0.id) }
  }

  private var warnings: [TagShadowWarning] {
    config.tagShadowWarnings(for: bundleId, normalMode: normalMode)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Label(normalMode ? "Normal Tags" : "Tags", systemImage: "tag")
          .font(.headline)
        Text("Top tag wins")
          .font(.caption)
          .foregroundStyle(.secondary)
        Spacer()
        Menu {
          if availableTags.isEmpty {
            Text("No tags available")
          } else {
            ForEach(availableTags, id: \.id) { tag in
              Button(tag.name) {
                config.updateTagAssignments(
                  bundleId: bundleId,
                  normalMode: normalMode,
                  tagIds: assignedTagIds + [tag.id]
                )
              }
            }
          }
        } label: {
          Label("Add Tag", systemImage: "plus")
        }
      }

      if assignedTagIds.isEmpty {
        Text("No tags assigned to this configuration.")
          .font(.caption)
          .foregroundStyle(.secondary)
      } else {
        ForEach(Array(assignedTagIds.enumerated()), id: \.element) { index, tagId in
          HStack(spacing: 8) {
            Text(config.tagDisplayName(for: tagId, registry: registry))
              .lineLimit(1)
            Spacer()
            Button {
              config.moveAssignedTag(bundleId: bundleId, normalMode: normalMode, tagId: tagId, direction: -1)
            } label: {
              Image(systemName: "chevron.up")
            }
            .disabled(index == 0)
            .help("Move tag earlier. Earlier tags have higher priority.")

            Button {
              config.moveAssignedTag(bundleId: bundleId, normalMode: normalMode, tagId: tagId, direction: 1)
            } label: {
              Image(systemName: "chevron.down")
            }
            .disabled(index == assignedTagIds.count - 1)
            .help("Move tag later.")

            Button(role: .destructive) {
              config.updateTagAssignments(
                bundleId: bundleId,
                normalMode: normalMode,
                tagIds: assignedTagIds.filter { $0 != tagId }
              )
            } label: {
              Image(systemName: "minus.circle")
            }
            .help("Remove tag assignment")
          }
        }
      }

      if !warnings.isEmpty {
        VStack(alignment: .leading, spacing: 4) {
          ForEach(warnings.prefix(5)) { warning in
            Label(warning.message, systemImage: "exclamationmark.triangle")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
          if warnings.count > 5 {
            Text("\(warnings.count - 5) more override warning\(warnings.count - 5 == 1 ? "" : "s")")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }
      }
    }
    .padding(10)
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
  }
}

private struct ManageTagsSheet: View {
  @EnvironmentObject private var config: UserConfig
  @Environment(\.dismiss) private var dismiss
  @State private var registry = TagsRegistry()
  @State private var selectedTagId: String?
  @State private var newTagName = ""
  @State private var renameTagName = ""

  private var selectedTag: TagDefinition? {
    registry.tags.first(where: { $0.id == selectedTagId })
  }

  var body: some View {
    HStack(spacing: 0) {
      VStack(alignment: .leading, spacing: 10) {
        Text("Tags")
          .font(.title2)
        List(selection: $selectedTagId) {
          ForEach(registry.tags, id: \.id) { tag in
            HStack {
              Image(systemName: "tag")
                .foregroundStyle(.secondary)
              VStack(alignment: .leading, spacing: 2) {
                Text(tag.name)
                  .lineLimit(1)
                Text(referenceSummary(for: tag.id))
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
            }
            .tag(tag.id as String?)
          }
        }
        .frame(minWidth: 220)

        HStack {
          TextField("New tag name", text: $newTagName)
          Button {
            if let tag = config.createTag(name: newTagName) {
              newTagName = ""
              refresh(selecting: tag.id)
            }
          } label: {
            Label("Create", systemImage: "plus")
          }
          .disabled(newTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
      }
      .padding()

      Divider()

      VStack(alignment: .leading, spacing: 12) {
        if let tag = selectedTag {
          Text(tag.name)
            .font(.title2)
          Text("ID: \(tag.id)")
            .font(.caption)
            .foregroundStyle(.secondary)

          TextField("Tag name", text: $renameTagName)
          HStack {
            Button {
              _ = config.renameTag(id: tag.id, name: renameTagName)
              refresh(selecting: tag.id)
            } label: {
              Label("Rename", systemImage: "pencil")
            }
            .disabled(renameTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            Button {
              openTagConfig(tagId: tag.id, normalMode: false)
            } label: {
              Label("Edit Tag Config", systemImage: "square.and.pencil")
            }

            Button {
              openTagConfig(tagId: tag.id, normalMode: true)
            } label: {
              Label("Edit Normal Tag Config", systemImage: "square.and.pencil")
            }
          }

          let references = config.tagReferences(for: tag.id, registry: registry)
          if references.isEmpty {
            Text("No app assignments.")
              .foregroundStyle(.secondary)
          } else {
            Text("Assigned to")
              .font(.headline)
            ForEach(references) { reference in
              Text("\(reference.normalMode ? "Normal" : "App"): \(reference.bundleId)")
                .font(.caption)
            }
          }

          Spacer()

          Button(role: .destructive) {
            let removeAssignments = !references.isEmpty
            if config.deleteTag(id: tag.id, removeAssignments: removeAssignments) {
              refresh(selecting: nil)
            }
          } label: {
            Label(references.isEmpty ? "Delete Tag" : "Delete Tag and Remove Assignments", systemImage: "trash")
          }
        } else {
          Text("Select a tag to rename, edit, or delete it.")
            .foregroundStyle(.secondary)
          Spacer()
        }

        HStack {
          Spacer()
          Button("Done") { dismiss() }
            .keyboardShortcut(.defaultAction)
        }
      }
      .padding()
      .frame(minWidth: 420)
    }
    .frame(width: 760, height: 460)
    .onAppear {
      refresh(selecting: selectedTagId ?? registry.tags.first?.id)
    }
    .onChange(of: selectedTagId) { tagId in
      renameTagName = registry.tags.first(where: { $0.id == tagId })?.name ?? ""
    }
  }

  private func refresh(selecting tagId: String?) {
    registry = config.loadTagsRegistry()
    if let tagId, registry.tags.contains(where: { $0.id == tagId }) {
      selectedTagId = tagId
    } else {
      selectedTagId = registry.tags.first?.id
    }
    renameTagName = selectedTag?.name ?? ""
  }

  private func referenceSummary(for tagId: String) -> String {
    let references = config.tagReferences(for: tagId, registry: registry)
    guard !references.isEmpty else { return "No assignments" }
    let appCount = references.filter { !$0.normalMode }.count
    let normalCount = references.filter(\.normalMode).count
    return "\(appCount) app, \(normalCount) normal"
  }

  private func openTagConfig(tagId: String, normalMode: Bool) {
    guard let path = config.ensureTagConfigFile(tagId: tagId, normalMode: normalMode) else { return }
    config.reloadConfig()
    let fallbackKey =
      "\(normalMode ? normalTagConfigDisplayPrefix : tagConfigDisplayPrefix)\(config.tagDisplayName(for: tagId))"
    let displayKey = config.discoveredConfigFiles.first(where: { $0.value == path })?.key ?? fallbackKey
    config.selectedConfigKeyForEditing = displayKey
    config.loadConfigForEditing(key: displayKey)
    dismiss()
  }
}

// MARK: - AddConfigSheet
private struct AddConfigSheet: View {
  @EnvironmentObject var config: UserConfig
  @Environment(\.dismiss) private var dismiss
  let onCreateAndScout: (String) -> Void

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
  @State private var createsNormalModeConfig = false

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
        if key1 == globalDefaultDisplayName { return true }
        if key2 == globalDefaultDisplayName { return false }
        if key1 == defaultAppConfigDisplayName { return true }
        if key2 == defaultAppConfigDisplayName { return false }
        if key1 == normalFallbackConfigDisplayName { return true }
        if key2 == normalFallbackConfigDisplayName { return false }
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

      Toggle("Create normal mode config", isOn: $createsNormalModeConfig)
        .toggleStyle(.checkbox)

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

      HStack {
        Spacer()
        Button("Cancel") { dismiss() }
        Button("Create") {
          createConfig()
        }
        .disabled(effectiveBundleId.isEmpty)
        Button("Create and Scout...") {
          createConfig(openCommandScout: true)
        }
        .disabled(effectiveBundleId.isEmpty || createsNormalModeConfig)
      }
    }
    .padding(24)
    .frame(minWidth: 400)
  }

  private func createConfig(openCommandScout: Bool = false) {
    let templateKey = openCommandScout || selectedTemplate == "Empty" ? "EMPTY_TEMPLATE" : selectedTemplate
    let createdKey = config.createConfigForApp(
      bundleId: effectiveBundleId,
      templateKey: templateKey,
      customName: customDisplayName.isEmpty ? nil : customDisplayName,
      normalMode: createsNormalModeConfig
    )
    // Dismiss regardless; success/failure alerts handled in helper
    dismiss()
    if openCommandScout, let createdKey {
      DispatchQueue.main.async {
        onCreateAndScout(createdKey)
      }
    }
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

struct GeneralPane_Previews: PreviewProvider {
  static var previews: some View {
    // Preview needs adjustment if UserConfig init requires more
    let previewConfig = UserConfig()
    // Manually add some discovered files for preview
    previewConfig.discoveredConfigFiles = [
      globalDefaultDisplayName: "/path/to/global-config.json",
      defaultAppConfigDisplayName: "/path/to/app-fallback-config.json",
      normalFallbackConfigDisplayName: "/path/to/normal-fallback-config.json",
      "App: com.app.example": "/path/to/app.com.app.example.json",
      "Normal: com.app.example": "/path/to/normal-app.com.app.example.json",
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

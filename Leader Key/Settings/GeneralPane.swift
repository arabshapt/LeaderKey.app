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
  @State private var expandedGroups = Set<[Int]>()
  @State private var showingRenameAlert = false
  @State private var showingDeleteAlert = false
  @State private var newConfigNameInput = ""
  @State private var filePathToRename: String?
  @State private var listSelection: String?
  @State private var keyToDelete: String?
  @State private var highlightedPath: [Int]?

  @StateObject private var profileManager = ProfileManager()
  @State private var newProfileName = ""
  @State private var showingAddProfileAlert = false
  @State private var showingAddConfigSheet = false

  var renameAlertMessage: String {
    var messageText =
        "Enter a new name for the profile '\(config.selectedProfileName)'."
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

            List(selection: $config.selectedProfileName) {
                ForEach(profileManager.profiles) { profile in
                    HStack {
                        Text(profile.name)
                        Spacer()
                        KeyboardShortcuts.Recorder(for: profile.shortcutName)
                    }
                    .tag(profile.name)
                    .contextMenu {
                        Button("Rename") {
                            newConfigNameInput = profile.name
                            config.selectedProfileName = profile.name
                            showingRenameAlert = true
                        }
                        Button("Delete", role: .destructive) {
                            config.selectedProfileName = profile.name
                            showingDeleteAlert = true
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .frame(minWidth: 180, idealWidth: 200, maxWidth: 220)
            .onChange(of: config.selectedProfileName) { newProfileName in
                config.reload(for: newProfileName)
            }

            // --- Add Profile Button ---
            Button {
                showingAddProfileAlert = true
            } label: {
                Label("Add Profile", systemImage: "plus")
            }
            .buttonStyle(.borderless)
            .padding(.top, 4)

            // --- Add Config Button ---
            Button {
                showingAddConfigSheet = true
            } label: {
                Label("Add App Config", systemImage: "plus.square.on.square")
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
            Text("Editing: \(config.selectedProfileName)")
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
                    config.reload(for: config.selectedProfileName)
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
    .alert("Add Profile", isPresented: $showingAddProfileAlert) {
        TextField("Profile Name", text: $newProfileName)
        Button("Create") {
            if !newProfileName.isEmpty {
                profileManager.createProfile(name: newProfileName)
                newProfileName = ""
            }
        }
        Button("Cancel", role: .cancel) {
            newProfileName = ""
        }
    }
    .alert("Rename Profile", isPresented: $showingRenameAlert) {
        TextField("New Name", text: $newConfigNameInput)
        Button("Save") {
            if let profile = profileManager.profiles.first(where: { $0.name == config.selectedProfileName }) {
                profileManager.renameProfile(profile, to: newConfigNameInput)
                config.selectedProfileName = newConfigNameInput
            }
        }
        Button("Cancel", role: .cancel) {}
    }
    // Delete confirmation alert
    .alert("Delete Profile", isPresented: $showingDeleteAlert) {
        Button("Delete", role: .destructive) {
            if let profile = profileManager.profiles.first(where: { $0.name == config.selectedProfileName }) {
                profileManager.deleteProfile(profile)
                config.selectedProfileName = "default"
            }
        }
        Button("Cancel", role: .cancel) {}
    } message: {
        Text("Are you sure you want to delete the profile ‘\(config.selectedProfileName)’? This action cannot be undone.")
    }
    .sheet(isPresented: $showingAddConfigSheet) {
        AddConfigSheet(profileName: config.selectedProfileName)
            .environmentObject(config)
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


private struct AddConfigSheet: View {
    @EnvironmentObject var config: UserConfig
    @Environment(\.dismiss) private var dismiss
    let profileName: String

    private var runningApps: [NSRunningApplication] {
        NSWorkspace.shared.runningApplications
            .filter { $0.bundleIdentifier != nil && $0.activationPolicy == .regular }
            .sorted { ($0.localizedName ?? "") < ($1.localizedName ?? "") }
    }

    @State private var selectedApp: NSRunningApplication? = NSWorkspace.shared.frontmostApplication
    @State private var showManualEntry = false
    @State private var manualBundleId = ""
    @State private var customDisplayName = ""
    @State private var isOverlayConfig = false

    private var effectiveBundleId: String {
        if showManualEntry {
            return manualBundleId.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return selectedApp?.bundleIdentifier ?? ""
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Create New App-Specific Config")
                .font(.title2)

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

            Toggle("Advanced: Enter bundle identifier manually", isOn: $showManualEntry)
                .onChange(of: showManualEntry) { manual in
                    if manual {
                        selectedApp = nil
                    }
                }

            if showManualEntry {
                TextField("com.example.app", text: $manualBundleId)
                    .textFieldStyle(.roundedBorder)
            }

            Button("Choose App from Disk…") {
                presentOpenPanel()
            }

            Divider()

            TextField("Optional sidebar name", text: $customDisplayName)
                .textFieldStyle(.roundedBorder)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Toggle("Overlay Configuration", isOn: $isOverlayConfig)
                    .font(.headline)
                Text("Overlay configurations are used when apps like Raycast or Alfred show overlay windows. They have a '.overlay' suffix in the filename.")
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
        config.createAppConfig(
            for: effectiveBundleId,
            in: profileName,
            customName: customDisplayName.isEmpty ? nil : customDisplayName,
            isOverlay: isOverlayConfig
        )
        dismiss()
    }

    private func presentOpenPanel() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.application]
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
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
    previewConfig.discoveredProfiles = ["default", "work"]
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

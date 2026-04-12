// swiftlint:disable line_length
import Defaults
import KeyboardShortcuts
import LaunchAtLogin
import Settings
import SwiftUI

struct AdvancedPane: View {
  private let contentWidth = SettingsConfig.contentWidth

  @EnvironmentObject private var config: UserConfig

  @Default(.configDir) var configDir
  @Default(.modifierKeyConfiguration) var modifierKeyConfiguration
  @Default(.autoOpenCheatsheet) var autoOpenCheatsheet
  @Default(.cheatsheetDelayMS) var cheatsheetDelayMS
  @Default(.reactivateBehavior) var reactivateBehavior
  @Default(.reloadSuccessSound) var reloadSuccessSound
  @Default(.showAppIconsInCheatsheet) var showAppIconsInCheatsheet
  @Default(.automaticallyChecksForUpdates) var automaticallyChecksForUpdates
  @Default(.resetOnCmdRelease) var resetOnCmdRelease
  @Default(.panelTopOffsetPercent) var panelTopOffsetPercent
  @Default(.panelClickThrough) var panelClickThrough
  @Default(.enableVerboseLogging) var enableVerboseLogging
  @Default(.commandShellPreference) var commandShellPreference
  @Default(.loadShellRCFiles) var loadShellRCFiles
  @Default(.customShellPath) var customShellPath
  @Default(.inputMethodPreference) var inputMethodPreference
  @Default(.karabinerTsRepoPath) var karabinerTsRepoPath
  @Default(.gokuBinaryPath) var gokuBinaryPath
  @Default(.karabiner2Backend) var karabiner2Backend

  @State private var isCustomShellValid = false
  @State private var showingAlternativeMappings = false
  @State private var karabinerTsValidationMessage: String?
  @State private var karabinerTsValidationSucceeded: Bool?
  @State private var isSyncingGokuProfile = false
  @State private var gokuProfileSyncMessage: String?
  @State private var gokuProfileSyncSucceeded: Bool?
  @State private var gokuValidationMessage: String?
  @State private var gokuValidationSucceeded: Bool?

  var body: some View {
    ScrollView {
      Settings.Container(contentWidth: contentWidth) {
        Settings.Section(
          title: "Config directory",
          bottomDivider: true
        ) {
          HStack {
            Text(configDir).lineLimit(1).truncationMode(.middle)
          }
          HStack {
            Button("Choose…") {
              let panel = NSOpenPanel()
              panel.allowsMultipleSelection = false
              panel.canChooseDirectories = true
              panel.canChooseFiles = false
              if panel.runModal() != .OK { return }
              guard let selectedPath = panel.url else { return }
              configDir = selectedPath.path
            }
            Button("Reveal") {
              NSWorkspace.shared.activateFileViewerSelecting([
                config.url
              ])
            }

            Button("Reset") {
              configDir = UserConfig.defaultDirectory()
            }
          }
        }

        Settings.Section(
          title: "Karabiner Integration", bottomDivider: true
        ) {
          VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
              Text("Karabiner Elements integration with state machine transport")
                .font(.callout)
                .foregroundColor(.secondary)

              Text("⚠️ Requires Karabiner Elements to be installed")
                  .font(.callout)
                  .foregroundColor(.orange)

                HStack {
                  Text("Backend:")
                  Picker("", selection: $karabiner2Backend) {
                    ForEach(Karabiner2Backend.allCases) { backend in
                      Text(backend.displayName).tag(backend)
                    }
                  }
                  .frame(width: 220)
                  .labelsHidden()
                }

                Text(karabiner2Backend.description)
                  .font(.caption)
                  .foregroundColor(.secondary)

                if karabiner2Backend.usesKarabinerTsExport {
                  HStack(alignment: .center, spacing: 10) {
                    Text("Repo path:")
                      .foregroundColor(.secondary)

                    TextField("Path to karabiner.ts repo", text: $karabinerTsRepoPath)
                      .textFieldStyle(.roundedBorder)
                      .frame(width: 320)

                    Button("Choose…") {
                      let panel = NSOpenPanel()
                      panel.allowsMultipleSelection = false
                      panel.canChooseDirectories = true
                      panel.canChooseFiles = false
                      if panel.runModal() != .OK { return }
                      guard let selectedPath = panel.url else { return }
                      karabinerTsRepoPath = selectedPath.path
                    }

                    Button("Validate repo") {
                      let result = KarabinerTsExportService.shared.validateKarabinerTsRepo()
                      karabinerTsValidationSucceeded = result.success
                      karabinerTsValidationMessage = result.message
                    }

                    Button("Reset") {
                      karabinerTsRepoPath = defaultKarabinerTsRepoPath()
                    }

                    if !karabinerTsRepoPath.isEmpty {
                      Button("Reveal") {
                        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: karabinerTsRepoPath)
                      }
                    }

                    Spacer()
                  }
                  .padding(.top, 6)

                  if let karabinerTsValidationMessage {
                    Text(karabinerTsValidationMessage)
                      .font(.caption)
                      .foregroundColor(karabinerTsValidationSucceeded == true ? .green : .orange)
                  }

                  VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 10) {
                      Button(isSyncingGokuProfile ? "Syncing Goku Profile…" : "Sync Goku EDN to karabiner.ts") {
                        syncGokuProfileToKarabinerTs()
                      }
                      .disabled(isSyncingGokuProfile)

                      Button("Copy Socket Shell Command") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(
                          "printf 'sync-goku-profile\\n' | nc -U /tmp/leaderkey.sock",
                          forType: .string
                        )
                      }

                      Spacer()
                    }

                    Text("Raycast sends `sync-goku-profile` to `/tmp/leaderkey.sock`; shell scripts can use the copied command.")
                      .font(.caption)
                      .foregroundColor(.secondary)

                    if let gokuProfileSyncMessage {
                      Text(gokuProfileSyncMessage)
                        .font(.caption)
                        .foregroundColor(gokuProfileSyncSucceeded == true ? .green : .orange)
                    }
                  }
                  .padding(.top, 6)
                }

                if karabiner2Backend.usesLegacyGoku {
                  HStack(alignment: .center, spacing: 10) {
                    Text("goku binary:")
                      .foregroundColor(.secondary)

                    TextField("PATH lookup (goku)", text: $gokuBinaryPath)
                      .textFieldStyle(.roundedBorder)
                      .frame(width: 320)

                    Button("Validate goku") {
                      let result = GokuCompilerService.shared.validateGokuBinary()
                      gokuValidationSucceeded = result.success
                      gokuValidationMessage = result.message
                    }

                    Button("Use PATH") {
                      gokuBinaryPath = ""
                    }

                    Spacer()
                  }
                  .padding(.top, 6)

                  if let gokuValidationMessage {
                    Text(gokuValidationMessage)
                      .font(.caption)
                      .foregroundColor(gokuValidationSucceeded == true ? .green : .orange)
                  }
                }

                HStack(spacing: 12) {
                  Button("Configure Alternative Keys") {
                    showingAlternativeMappings = true
                  }
                  .help("Set up alternative key mappings to trigger Leader Key actions without entering Leader Key mode")

                  Spacer()
                }
                .padding(.top, 8)

                DisclosureGroup("Legacy Goku EDN Export") {
                  VStack(alignment: .leading, spacing: 8) {
                    Text(
                      "Automatic export now uses the selected backend above. These buttons are for legacy/manual EDN workflows."
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)

                    HStack(spacing: 12) {
                      Button("Export EDN") {
                        let content = KarabinerExporter.exportConfiguration(
                          userConfig: config, format: .karabiner2EDN)
                        _ = KarabinerExporter.saveToFile(content, format: .karabiner2EDN)
                      }

                      Button("Export & Inject EDN") {
                        let content = KarabinerExporter.exportConfiguration(
                          userConfig: config, format: .karabiner2EDN)
                        let savedPath = KarabinerExporter.saveToFile(content, format: .karabiner2EDN)

                        let alert = NSAlert()
                        alert.messageText = "Legacy Export & Inject Complete"
                        alert.informativeText = "Configuration exported to:\n\(savedPath?.path ?? "Unknown")\n\nLegacy marker-based injection applies to karabiner.edn."
                        alert.alertStyle = .informational
                        alert.addButton(withTitle: "OK")
                        alert.runModal()
                      }

                      Button("Open Export Folder") {
                        let exportDir = (Defaults[.configDir] as NSString).appendingPathComponent("export")
                        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: exportDir)
                      }

                      Spacer()
                    }

                    // Marker injection instructions
                    VStack(alignment: .leading, spacing: 4) {
                      Text("Add these markers to your karabiner.edn for injection:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                      Text(";;; LEADERKEY_APPLICATIONS_START / END")
                        .font(.system(size: 10, design: .monospaced))
                        .padding(4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)

                      Text(";;; LEADERKEY_MAIN_START / END")
                        .font(.system(size: 10, design: .monospaced))
                        .padding(4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)

                      HStack(spacing: 8) {
                        Button(action: {
                          let markers = """
                            ;;; LEADERKEY_APPLICATIONS_START
                            ;; Leader Key applications will be injected here
                            ;;; LEADERKEY_APPLICATIONS_END
                            """
                          NSPasteboard.general.clearContents()
                          NSPasteboard.general.setString(markers, forType: .string)
                        }) {
                          Label("Copy App Markers", systemImage: "doc.on.clipboard")
                            .font(.system(size: 11))
                        }
                        .buttonStyle(.bordered)

                        Button(action: {
                          let markers = """
                            ;;; LEADERKEY_MAIN_START
                            ;; Leader Key main rules will be injected here
                            ;;; LEADERKEY_MAIN_END
                            """
                          NSPasteboard.general.clearContents()
                          NSPasteboard.general.setString(markers, forType: .string)
                        }) {
                          Label("Copy Main Markers", systemImage: "doc.on.clipboard")
                            .font(.system(size: 11))
                        }
                        .buttonStyle(.bordered)
                      }
                      .padding(.top, 4)
                    }
                  }
                  .padding(.top, 4)
                }
            }
          }
        }

        Settings.Section(
          title: "Modifier Keys", bottomDivider: true
        ) {
          VStack(alignment: .leading, spacing: 16) {
            HStack {
              Picker("", selection: $modifierKeyConfiguration) {
                ForEach(ModifierKeyConfig.allCases) { config in
                  Text(config.description).tag(config)
                }
              }
              .frame(width: 280)
              .labelsHidden()
            }

            VStack(alignment: .leading, spacing: 8) {
              Text(
                "Group Actions: When the modifier key is held while pressing a group key, it runs all actions in that group and its sub-groups."
              )
              .font(.callout)
              .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
              Text(
                "Sticky Mode: When the modifier key is held while triggering an action, Leader Key stays open after the action completes."
              )
              .font(.callout)
              .foregroundColor(.secondary)
            }

            // Show the cmd release option only when cmd is used for sticky mode
            if modifierKeyConfiguration == .controlGroupOptionSticky {
              Defaults.Toggle(
                "Reset and close on ⌘ release", key: .resetOnCmdRelease
              )
              .help(
                "When enabled, releasing the Command key will reset Leader Key and close the window"
              )
            }
          }
          .padding(.top, 2)
        }

        Settings.Section(title: "Cheatsheet", bottomDivider: true) {
          HStack(alignment: .firstTextBaseline) {
            Picker("Show", selection: $autoOpenCheatsheet) {
              Text("Always").tag(AutoOpenCheatsheetSetting.always)
              Text("After …").tag(AutoOpenCheatsheetSetting.delay)
              Text("Never").tag(AutoOpenCheatsheetSetting.never)
            }.frame(width: 120)

            if autoOpenCheatsheet == .delay {
              TextField(
                "", value: $cheatsheetDelayMS, formatter: NumberFormatter()
              )
              .frame(width: 50)
              Text("milliseconds")
            }

            Spacer()
          }

          Text(
            "The cheatsheet can always be manually shown by \"?\" when Leader Key is activated."
          )
          .padding(.vertical, 2)

          Defaults.Toggle(
            "Show expanded groups in cheatsheet", key: .expandGroupsInCheatsheet)
          Defaults.Toggle(
            "Show icons", key: .showAppIconsInCheatsheet)
          Defaults.Toggle(
            "Use favicons for URLs", key: .showFaviconsInCheatsheet
          ).padding(.leading, 20).disabled(!showAppIconsInCheatsheet)
          Defaults.Toggle(
            "Show item details in cheatsheet", key: .showDetailsInCheatsheet)

        }

        Settings.Section(title: "Activation", bottomDivider: true) {
          VStack(alignment: .leading) {
            Text(
              "Pressing the global shortcut key while Leader Key is active should …"
            )

            Picker(
              "Reactivation behavior", selection: $reactivateBehavior
            ) {
              Text("Hide Leader Key").tag(ReactivateBehavior.hide)
              Text("Reset group selection").tag(ReactivateBehavior.reset)
              Text("Do nothing").tag(ReactivateBehavior.nothing)
            }
            .labelsHidden()
            .frame(width: 220)

            // New slider for panel vertical offset percentage
            HStack {
              Text("Panel vertical offset: ")
              Slider(value: $panelTopOffsetPercent, in: 0.1...0.5, step: 0.01)
                .frame(width: 150)
              Text("\(Int(panelTopOffsetPercent * 100))%")
                .frame(width: 40, alignment: .leading)
            }
          }
        }



        Settings.Section(title: "Command Execution", bottomDivider: true) {
          VStack(alignment: .leading, spacing: 12) {
            HStack {
              Text("Shell:")
              Picker("", selection: $commandShellPreference) {
                ForEach(ShellPreference.allCases) { shell in
                  Text(shell.description).tag(shell)
                }
              }
              .frame(width: 200)
              .labelsHidden()
            }

            // Show custom shell path field when Custom is selected
            if commandShellPreference == .custom {
              HStack {
                Text("Path:")
                TextField("e.g., /opt/homebrew/bin/fish", text: $customShellPath)
                  .textFieldStyle(.roundedBorder)
                  .frame(width: 300)
                  .onChange(of: customShellPath) { newPath in
                    isCustomShellValid = ShellPreference.isValidShellPath(newPath)
                  }

                // Validation indicator
                if !customShellPath.isEmpty {
                  Image(
                    systemName: isCustomShellValid
                      ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
                  )
                  .foregroundColor(isCustomShellValid ? .green : .orange)
                  .help(
                    isCustomShellValid ? "Valid shell executable" : "Invalid or non-executable path"
                  )
                }

                Button("Browse…") {
                  let panel = NSOpenPanel()
                  panel.allowsMultipleSelection = false
                  panel.canChooseDirectories = false
                  panel.canChooseFiles = true
                  panel.directoryURL = URL(fileURLWithPath: "/")
                  panel.message = "Select a shell executable"

                  if panel.runModal() == .OK, let url = panel.url {
                    customShellPath = url.path
                    isCustomShellValid = ShellPreference.isValidShellPath(customShellPath)
                  }
                }
              }

              if !customShellPath.isEmpty && !isCustomShellValid {
                Text(
                  "The specified path is not a valid executable. Commands will fall back to the system shell."
                )
                .font(.caption)
                .foregroundColor(.orange)
              }

              Text(
                "Common custom shell paths: /opt/homebrew/bin/fish, /usr/local/bin/zsh, /opt/homebrew/bin/nu"
              )
              .font(.caption)
              .foregroundColor(.secondary)
            }

            Defaults.Toggle(
              "Load shell configuration files",
              key: .loadShellRCFiles
            )
            .help(
              "When enabled, commands run with login shell mode to load .zshrc, .bashrc, and other shell configuration files"
            )

            Text(
              "Shell configuration files provide access to aliases, custom functions, and environment variables defined in your shell's RC files."
            )
            .font(.callout)
            .foregroundColor(.secondary)
            .padding(.top, 4)
          }
          .onAppear {
            // Validate custom shell path on view appear
            if commandShellPreference == .custom {
              isCustomShellValid = ShellPreference.isValidShellPath(customShellPath)
            }
          }
        }

        Settings.Section(title: "Other") {
          Defaults.Toggle("Show Leader Key in menubar", key: .showMenuBarIcon)
          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Text("Reload success sound")
              Spacer()
              Picker("", selection: $reloadSuccessSound) {
                ForEach(ReloadSuccessSound.allCases) { sound in
                  Text(sound.displayName).tag(sound)
                }
              }
              .labelsHidden()
              .frame(maxWidth: 180)
            }

            Text(reloadSuccessSound.description)
              .font(.callout)
              .foregroundColor(.secondary)
          }
          Defaults.Toggle(
            "Force English keyboard layout", key: .forceEnglishKeyboardLayout)
          Defaults.Toggle("Automatically check for updates", key: .automaticallyChecksForUpdates)
          Defaults.Toggle("Allow mouse clicks through panel", key: .panelClickThrough)
          Defaults.Toggle("Enable verbose logging (diagnostics)", key: .enableVerboseLogging)
          // Defaults.Toggle("Use Stealth Mode", key: .useStealthMode)
        }

        // --- Add Reset Section Here --- START ---
        Settings.Section(title: "Configuration Names") {
          HStack {
            Button("Reset Custom Config Names", role: .destructive) {
              print("[AdvancedPane] Resetting custom config names.")
              Defaults[.configFileCustomNames] = [:]
              // We need to tell UserConfig to reload so GeneralPane gets updated.
              // Assuming UserConfig is accessible via @EnvironmentObject 'config'.
              config.reloadConfig()
            }
            Spacer()  // Push button to the left
          }
          Text(
            "This will remove all custom names you have assigned to your configuration files in the General settings pane. The configurations will revert to their default names (e.g., 'App: com.apple.finder')."
          )
          .font(.callout)
          .foregroundColor(.secondary)
          .padding(.top, 4)
        }
        // --- Add Reset Section Here --- END ---

      }
    }
    .frame(width: contentWidth + 60)
    .frame(minHeight: 600)
    .sheet(isPresented: $showingAlternativeMappings) {
      AlternativeMappingsView()
    }
    .onAppear {
      let normalizedBackend = karabiner2Backend.normalized
      if karabiner2Backend != normalizedBackend {
        karabiner2Backend = normalizedBackend
      }
    }
  }

  private func syncGokuProfileToKarabinerTs() {
    guard !isSyncingGokuProfile else { return }
    isSyncingGokuProfile = true
    gokuProfileSyncMessage = nil
    gokuProfileSyncSucceeded = nil

    DispatchQueue.global(qos: .utility).async {
      let result = KarabinerTsExportService.shared.migrateGokuProfileToKarabinerTs()

      DispatchQueue.main.async {
        isSyncingGokuProfile = false
        gokuProfileSyncSucceeded = result.success
        gokuProfileSyncMessage = result.message
        if result.success {
          config.reloadConfig()
        }
      }
    }
  }

}

struct AdvancedPane_Previews: PreviewProvider {
  static var previews: some View {
    return AdvancedPane()
    //      .environmentObject(UserConfig())
  }
}

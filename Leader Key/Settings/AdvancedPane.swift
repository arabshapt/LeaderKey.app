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
  @Default(.karBinaryPath) var karBinaryPath
  @Default(.gokuBinaryPath) var gokuBinaryPath
  @Default(.karabiner2Backend) var karabiner2Backend

  @State private var isCustomShellValid = false
  @State private var showingAlternativeMappings = false
  @State private var karValidationMessage: String?
  @State private var karValidationSucceeded: Bool?
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

                if karabiner2Backend.requiresKar {
                  HStack(alignment: .center, spacing: 10) {
                    Text("kar binary:")
                      .foregroundColor(.secondary)

                    TextField("PATH lookup (kar)", text: $karBinaryPath)
                      .textFieldStyle(.roundedBorder)
                      .frame(width: 320)

                    Button("Validate kar") {
                      let result = KarCompilerService.shared.validateKarBinary()
                      karValidationSucceeded = result.success
                      karValidationMessage = result.message
                    }

                    Button("Use PATH") {
                      karBinaryPath = ""
                    }

                    Spacer()
                  }
                  .padding(.top, 6)

                  if let karValidationMessage {
                    Text(karValidationMessage)
                      .font(.caption)
                      .foregroundColor(karValidationSucceeded == true ? .green : .orange)
                  }
                }

                if karabiner2Backend.requiresGoku {
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
                  Button("Export Karabiner 2.0 EDN (Legacy)") {
                    let content = KarabinerExporter.exportConfiguration(
                      userConfig: config, format: .karabiner2EDN)
                    _ = KarabinerExporter.saveToFile(content, format: .karabiner2EDN)
                  }

                  Button("Export & Inject Legacy EDN") {
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
                  .help("Legacy/manual EDN export and marker-based injection")

                  Button("Open Legacy EDN Folder") {
                    let configDir = NSHomeDirectory() + "/.config/karabiner.edn.d"
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: configDir)
                  }

                  Spacer()
                }
                .padding(.top, 8)

                HStack(spacing: 12) {
                  Button("Configure Alternative Keys") {
                    showingAlternativeMappings = true
                  }
                  .help("Set up alternative key mappings to trigger Leader Key actions without entering Leader Key mode")

                  Spacer()
                }

                Text(
                  "Karabiner 2.0 automatic export now uses kar + send_user_command. The EDN buttons above are kept for legacy/manual workflows."
                )
                .font(.caption)
                .foregroundColor(.secondary)

                // Legacy EDN injection info section
                VStack(alignment: .leading, spacing: 8) {
                  HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle.fill")
                      .foregroundColor(.blue)
                      .font(.system(size: 14))

                    VStack(alignment: .leading, spacing: 6) {
                      Text("Legacy EDN Injection Into karabiner.edn")
                        .font(.system(size: 12, weight: .semibold))

                      Text("Leader Key can inject legacy EDN output into your main karabiner.edn file using special marker comments.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                      Text("Add these markers to your karabiner.edn:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)

                      VStack(alignment: .leading, spacing: 4) {
                        Text("In :applications section:")
                          .font(.system(size: 11, weight: .medium))
                          .foregroundColor(.secondary)

                        Text(";;; LEADERKEY_APPLICATIONS_START\n;;; LEADERKEY_APPLICATIONS_END")
                          .font(.system(size: 10, design: .monospaced))
                          .padding(6)
                          .background(Color.gray.opacity(0.1))
                          .cornerRadius(4)

                        Text("In :main section:")
                          .font(.system(size: 11, weight: .medium))
                          .foregroundColor(.secondary)
                          .padding(.top, 4)

                        Text(";;; LEADERKEY_MAIN_START\n;;; LEADERKEY_MAIN_END")
                          .font(.system(size: 10, design: .monospaced))
                          .padding(6)
                          .background(Color.gray.opacity(0.1))
                          .cornerRadius(4)
                      }

                      Text("• Content between markers is replaced on each export")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)

                      Text("• 'Leader Key - Activation Shortcuts' section is preserved if it exists")
                        .font(.caption)
                        .foregroundColor(.secondary)

                      Text("• Your custom rules outside markers remain untouched")
                        .font(.caption)
                        .foregroundColor(.secondary)

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
                      .padding(.top, 6)
                    }
                  }
                  .padding(12)
                  .background(Color.blue.opacity(0.05))
                  .cornerRadius(8)
                }
                .padding(.top, 8)
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
  }

}

struct AdvancedPane_Previews: PreviewProvider {
  static var previews: some View {
    return AdvancedPane()
    //      .environmentObject(UserConfig())
  }
}

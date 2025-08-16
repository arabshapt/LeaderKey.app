// swiftlint:disable line_length
import Defaults
import KeyboardShortcuts
import LaunchAtLogin
import Settings
import SwiftUI

struct AdvancedPane: View {
  private let contentWidth = SettingsConfig.contentWidth

  @EnvironmentObject private var config: UserConfig
  @ObservedObject private var overlayDetector = OverlayDetector.shared

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
  @Default(.overlayDetectionEnabled) var overlayDetectionEnabled
  @Default(.overlayApps) var overlayApps
  @Default(.enableVerboseLogging) var enableVerboseLogging
  @Default(.commandShellPreference) var commandShellPreference
  @Default(.loadShellRCFiles) var loadShellRCFiles
  @Default(.customShellPath) var customShellPath
  @Default(.commandEnvironmentVariables) var commandEnvironmentVariables
  @Default(.commandWorkingDirectory) var commandWorkingDirectory
  @Default(.customWorkingDirectoryPath) var customWorkingDirectoryPath
  @Default(.commandTimeoutSeconds) var commandTimeoutSeconds
  @Default(.commandOutputMode) var commandOutputMode
  @Default(.useInteractiveShell) var useInteractiveShell
  @Default(.customShellArguments) var customShellArguments
  @Default(.preCommandHook) var preCommandHook
  @Default(.postCommandHook) var postCommandHook
  @Default(.enableCommandHooks) var enableCommandHooks

  @State private var hasAccessibilityPermissions = false
  @State private var isCustomShellValid = false
  @State private var newEnvKey = ""
  @State private var newEnvValue = ""
  @State private var isCustomWorkingDirValid = true

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
              "Reset and close on ⌘ release", key: .resetOnCmdRelease)
              .help("When enabled, releasing the Command key will reset Leader Key and close the window")
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

      Settings.Section(title: "Overlay Detection", bottomDivider: true) {
        VStack(alignment: .leading, spacing: 12) {
          Defaults.Toggle("Enable overlay detection", key: .overlayDetectionEnabled)
            .help("Detect overlay windows (like Raycast/Alfred) for separate configs")

          if overlayDetectionEnabled {
            // Permission Status
            VStack(alignment: .leading, spacing: 8) {
              HStack {
                Text("Accessibility Permissions:")
                  .font(.subheadline)
                  .fontWeight(.medium)

                Spacer()

                HStack {
                  Image(systemName: hasAccessibilityPermissions ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(hasAccessibilityPermissions ? .green : .orange)

                  Text(hasAccessibilityPermissions ? "Granted" : "Required")
                    .font(.caption)
                    .foregroundColor(hasAccessibilityPermissions ? .green : .orange)
                }
              }

              if !hasAccessibilityPermissions {
                HStack {
                  Button("Request Permissions") {
                    _ = OverlayDetector.shared.requestAccessibilityPermissions()
                    updatePermissionStatus()
                  }

                  Button("Open System Settings") {
                    OverlayDetector.shared.openAccessibilitySettings()
                  }
                }
                .font(.caption)

                Text("Accessibility permissions are required to detect overlay windows. Please enable 'Leader Key' in System Settings > Privacy & Security > Accessibility.")
                  .font(.caption)
                  .foregroundColor(.secondary)
                  .padding(.top, 2)
              }
            }
            .padding(.bottom, 8)

            // Overlay Apps Configuration
            VStack(alignment: .leading, spacing: 8) {
              Text("Overlay Apps (Bundle IDs):")
                .font(.subheadline)
                .fontWeight(.medium)

              ForEach(overlayApps.indices, id: \.self) { index in
                HStack {
                  TextField("Bundle ID (e.g., com.raycast.macos)", text: Binding(
                    get: { overlayApps[index] },
                    set: { newValue in
                      overlayApps[index] = newValue
                    }
                  ))

                  Button(action: {
                    overlayApps.remove(at: index)
                  }) {
                    Image(systemName: "minus.circle.fill")
                      .foregroundColor(.red)
                  }
                  .buttonStyle(BorderlessButtonStyle())
                  .help("Remove this overlay app")
                }
              }

              Button(action: {
                overlayApps.append("")
              }) {
                HStack {
                  Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                  Text("Add overlay app")
                }
              }
              .buttonStyle(BorderlessButtonStyle())

              Text("Overlay configs use '.overlay' suffix (e.g., 'app.com.raycast.macos.overlay.json')")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
            }
            .padding(.bottom, 8)

            // Live Detection Display
            VStack(alignment: .leading, spacing: 8) {
              Text("Current Detection:")
                .font(.subheadline)
                .fontWeight(.medium)
              
              if !overlayDetector.currentDetection.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                  // Detection status with visual indicator
                  HStack(spacing: 8) {
                    Image(systemName: detectionStatusIcon)
                      .foregroundColor(detectionStatusColor)
                      .font(.system(size: 12, weight: .medium))
                    
                    Text("Status: \(detectionStatusText)")
                      .font(.caption)
                      .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("Updated: \(timeFormatter.string(from: overlayDetector.lastUpdated))")
                      .font(.caption2)
                      .foregroundColor(.secondary)
                  }
                  
                  // Detection details
                  Text(overlayDetector.currentDetection)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .padding(8)
                    .background(detectionBackgroundColor)
                    .cornerRadius(8)
                    .overlay(
                      RoundedRectangle(cornerRadius: 8)
                        .stroke(detectionStatusColor.opacity(0.3), lineWidth: 1)
                    )
                }
              } else {
                Text("Detection not running")
                  .font(.caption)
                  .foregroundColor(.secondary)
                  .padding(8)
                  .background(Color.gray.opacity(0.1))
                  .cornerRadius(8)
              }

              // Continuous Testing Toggle
              HStack {
                Text("Continuous Testing:")
                  .font(.subheadline)
                  .fontWeight(.medium)

                Spacer()

                Button(overlayDetector.isContinuousTestingEnabled ? "Stop Continuous Testing" : "Start Continuous Testing") {
                  OverlayDetector.shared.toggleContinuousTesting()
                }
                .disabled(!hasAccessibilityPermissions)
              }

              if overlayDetector.isContinuousTestingEnabled {
                Text("🔍 Continuous testing active - check Console.app for real-time detection logs (search for '[OverlayDetector]')")
                  .font(.caption)
                  .foregroundColor(.blue)
                  .padding(8)
                  .background(Color.blue.opacity(0.1))
                  .cornerRadius(4)
              }
            }
          }
        }
        .onAppear {
          updatePermissionStatus()
          if overlayDetectionEnabled && hasAccessibilityPermissions {
            OverlayDetector.shared.startRealtimeDetection()
          }
        }
        .onDisappear {
          OverlayDetector.shared.stopRealtimeDetection()
        }
        .onChange(of: overlayDetectionEnabled) { enabled in
          if enabled {
            updatePermissionStatus()
            if hasAccessibilityPermissions {
              OverlayDetector.shared.startRealtimeDetection()
            }
          } else {
            OverlayDetector.shared.stopRealtimeDetection()
            // Stop continuous testing if overlay detection is disabled
            OverlayDetector.shared.stopContinuousTesting()
          }
        }
        .onChange(of: hasAccessibilityPermissions) { hasPermissions in
          if overlayDetectionEnabled {
            if hasPermissions {
              OverlayDetector.shared.startRealtimeDetection()
            } else {
              OverlayDetector.shared.stopRealtimeDetection()
            }
          }
        }
      }

      Settings.Section(title: "Command Execution", bottomDivider: true) {
        VStack(alignment: .leading, spacing: 16) {
          // Shell Selection
          VStack(alignment: .leading, spacing: 8) {
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
                  Image(systemName: isCustomShellValid ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(isCustomShellValid ? .green : .orange)
                    .help(isCustomShellValid ? "Valid shell executable" : "Invalid or non-executable path")
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
                Text("The specified path is not a valid executable. Commands will fall back to the system shell.")
                  .font(.caption)
                  .foregroundColor(.orange)
              }
            }
          }
          
          // Shell Configuration
          VStack(alignment: .leading, spacing: 8) {
            Defaults.Toggle(
              "Load shell configuration files (RC files)",
              key: .loadShellRCFiles
            )
            .help("When enabled, commands run with login shell mode to load .zshrc, .bashrc, and other shell configuration files")
            
            Defaults.Toggle(
              "Use interactive shell mode",
              key: .useInteractiveShell
            )
            .help("Enable interactive mode (-i flag) for commands that require TTY or user input")
            
            HStack {
              Text("Custom arguments:")
              TextField("e.g., --noprofile", text: $customShellArguments)
                .textFieldStyle(.roundedBorder)
                .frame(width: 200)
                .help("Additional shell arguments (space-separated)")
            }
          }
          
          Divider()
          
          // Working Directory
          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Text("Working Directory:")
              Picker("", selection: $commandWorkingDirectory) {
                ForEach(WorkingDirectoryMode.allCases) { mode in
                  Text(mode.description).tag(mode)
                }
              }
              .frame(width: 180)
              .labelsHidden()
            }
            
            if commandWorkingDirectory == .custom {
              HStack {
                Text("Path:")
                TextField("e.g., /Users/name/projects", text: $customWorkingDirectoryPath)
                  .textFieldStyle(.roundedBorder)
                  .frame(width: 300)
                  .onChange(of: customWorkingDirectoryPath) { newPath in
                    let fm = FileManager.default
                    var isDir: ObjCBool = false
                    isCustomWorkingDirValid = fm.fileExists(atPath: newPath, isDirectory: &isDir) && isDir.boolValue
                  }
                
                if !customWorkingDirectoryPath.isEmpty {
                  Image(systemName: isCustomWorkingDirValid ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(isCustomWorkingDirValid ? .green : .orange)
                    .help(isCustomWorkingDirValid ? "Valid directory" : "Directory does not exist")
                }
                
                Button("Browse…") {
                  let panel = NSOpenPanel()
                  panel.allowsMultipleSelection = false
                  panel.canChooseDirectories = true
                  panel.canChooseFiles = false
                  panel.message = "Select working directory"
                  
                  if panel.runModal() == .OK, let url = panel.url {
                    customWorkingDirectoryPath = url.path
                  }
                }
              }
            }
          }
          
          // Command Timeout
          HStack {
            Text("Command timeout:")
            TextField("", value: $commandTimeoutSeconds, formatter: NumberFormatter())
              .frame(width: 60)
              .textFieldStyle(.roundedBorder)
            Text("seconds (0 = no timeout)")
            Spacer()
          }
          
          // Output Handling
          HStack {
            Text("Output handling:")
            Picker("", selection: $commandOutputMode) {
              ForEach(CommandOutputMode.allCases) { mode in
                Text(mode.description).tag(mode)
              }
            }
            .frame(width: 200)
            .labelsHidden()
          }
          
          Divider()
          
          // Environment Variables
          VStack(alignment: .leading, spacing: 8) {
            Text("Environment Variables:")
              .font(.subheadline)
              .fontWeight(.medium)
            
            // Display existing environment variables
            ForEach(Array(commandEnvironmentVariables.keys.sorted()), id: \.self) { key in
              HStack {
                Text(key)
                  .frame(width: 120, alignment: .leading)
                  .lineLimit(1)
                Text("=")
                  .foregroundColor(.secondary)
                Text(commandEnvironmentVariables[key] ?? "")
                  .lineLimit(1)
                  .truncationMode(.middle)
                Spacer()
                Button(action: {
                  commandEnvironmentVariables.removeValue(forKey: key)
                }) {
                  Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
                .help("Remove this environment variable")
              }
              .padding(.vertical, 2)
            }
            
            // Add new environment variable
            HStack {
              TextField("Name", text: $newEnvKey)
                .frame(width: 120)
                .textFieldStyle(.roundedBorder)
              Text("=")
                .foregroundColor(.secondary)
              TextField("Value", text: $newEnvValue)
                .textFieldStyle(.roundedBorder)
              Button(action: {
                if !newEnvKey.isEmpty && !newEnvValue.isEmpty {
                  commandEnvironmentVariables[newEnvKey] = newEnvValue
                  newEnvKey = ""
                  newEnvValue = ""
                }
              }) {
                Image(systemName: "plus.circle.fill")
                  .foregroundColor(.green)
              }
              .buttonStyle(BorderlessButtonStyle())
              .disabled(newEnvKey.isEmpty || newEnvValue.isEmpty)
              .help("Add environment variable")
            }
            
            Text("Environment variables are passed to all command executions")
              .font(.caption)
              .foregroundColor(.secondary)
          }
          
          Divider()
          
          // Command Hooks
          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Defaults.Toggle("Enable command hooks", key: .enableCommandHooks)
                .help("Run custom commands before and after each command execution")
              Spacer()
            }
            
            if enableCommandHooks {
              VStack(alignment: .leading, spacing: 8) {
                HStack {
                  Text("Pre-command:")
                    .frame(width: 100, alignment: .leading)
                  TextField("e.g., source ~/.profile", text: $preCommandHook)
                    .textFieldStyle(.roundedBorder)
                    .help("Command to run before the main command")
                }
                
                HStack {
                  Text("Post-command:")
                    .frame(width: 100, alignment: .leading)
                  TextField("e.g., echo 'Done'", text: $postCommandHook)
                    .textFieldStyle(.roundedBorder)
                    .help("Command to run after the main command")
                }
                
                Text("Hooks run in the same shell session. Use $COMMAND to reference the main command in hooks.")
                  .font(.caption)
                  .foregroundColor(.secondary)
                
                Text("Example: Pre: 'export PATH=/custom/bin:$PATH', Post: 'notify-send \"Command completed\"'")
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
            }
          }
        }
        .onAppear {
          // Validate custom paths on view appear
          if commandShellPreference == .custom {
            isCustomShellValid = ShellPreference.isValidShellPath(customShellPath)
          }
          if commandWorkingDirectory == .custom {
            let fm = FileManager.default
            var isDir: ObjCBool = false
            isCustomWorkingDirValid = fm.fileExists(atPath: customWorkingDirectoryPath, isDirectory: &isDir) && isDir.boolValue
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
              Spacer() // Push button to the left
          }
          Text("This will remove all custom names you have assigned to your configuration files in the General settings pane. The configurations will revert to their default names (e.g., 'App: com.apple.finder').")
            .font(.callout)
            .foregroundColor(.secondary)
            .padding(.top, 4)
      }
      // --- Add Reset Section Here --- END ---

    }
    }
    .frame(width: contentWidth + 60)
    .frame(minHeight: 600)
  }

  private func updatePermissionStatus() {
    hasAccessibilityPermissions = OverlayDetector.shared.hasAccessibilityPermissions()
  }
  
  // MARK: - Visual Indicators
  
  private var timeFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.timeStyle = .medium
    return formatter
  }
  
  private var detectionStatusIcon: String {
    if overlayDetector.currentDetection.contains("Overlay detection is disabled") {
      return "pause.circle.fill"
    } else if overlayDetector.currentDetection.contains("Accessibility permissions required") {
      return "exclamationmark.triangle.fill"
    } else if overlayDetector.currentDetection.contains("Overlay: true") {
      return "checkmark.circle.fill"
    } else if overlayDetector.currentDetection.contains("App: none") {
      return "circle.fill"
    } else {
      return "app.fill"
    }
  }
  
  private var detectionStatusColor: Color {
    if overlayDetector.currentDetection.contains("Overlay detection is disabled") {
      return .gray
    } else if overlayDetector.currentDetection.contains("Accessibility permissions required") {
      return .orange
    } else if overlayDetector.currentDetection.contains("Overlay: true") {
      return .green
    } else if overlayDetector.currentDetection.contains("App: none") {
      return .gray
    } else {
      return .blue
    }
  }
  
  private var detectionStatusText: String {
    if overlayDetector.currentDetection.contains("Overlay detection is disabled") {
      return "Disabled"
    } else if overlayDetector.currentDetection.contains("Accessibility permissions required") {
      return "No Permissions"
    } else if overlayDetector.currentDetection.contains("Overlay: true") {
      return "Overlay Detected"
    } else if overlayDetector.currentDetection.contains("App: none") {
      return "No App"
    } else {
      return "Normal App"
    }
  }
  
  private var detectionBackgroundColor: Color {
    detectionStatusColor.opacity(0.1)
  }
}

struct AdvancedPane_Previews: PreviewProvider {
  static var previews: some View {
    return AdvancedPane()
    //      .environmentObject(UserConfig())
  }
}

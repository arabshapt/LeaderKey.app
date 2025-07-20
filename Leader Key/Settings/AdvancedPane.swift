// swiftlint:disable line_length
import Defaults
import KeyboardShortcuts
import LaunchAtLogin
import Settings
import SwiftUI

struct AdvancedPane: View {
  private let contentWidth = 900.0

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
  @Default(.overlayDetectionEnabled) var overlayDetectionEnabled
  @Default(.overlayApps) var overlayApps
  
  @State private var hasAccessibilityPermissions = false
  @State private var testResult = ""
  @State private var showingTestResult = false
  @State private var isContinuousTestingEnabled = false

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
            
            // Test Detection
            VStack(alignment: .leading, spacing: 8) {
              HStack {
                Text("Testing:")
                  .font(.subheadline)
                  .fontWeight(.medium)
                
                Spacer()
                
                Button("Test Detection") {
                  testResult = OverlayDetector.shared.testDetection()
                  showingTestResult = true
                }
                .disabled(!hasAccessibilityPermissions)
              }
              
              // Continuous Testing Toggle
              HStack {
                Text("Continuous Testing:")
                  .font(.subheadline)
                  .fontWeight(.medium)
                
                Spacer()
                
                Button(isContinuousTestingEnabled ? "Stop Continuous Testing" : "Start Continuous Testing") {
                  OverlayDetector.shared.toggleContinuousTesting()
                  isContinuousTestingEnabled = OverlayDetector.shared.isContinuousTestingEnabled
                }
                .disabled(!hasAccessibilityPermissions)
              }
              
              if isContinuousTestingEnabled {
                Text("🔍 Continuous testing active - check Console.app for real-time detection logs (search for '[OverlayDetector]')")
                  .font(.caption)
                  .foregroundColor(.blue)
                  .padding(8)
                  .background(Color.blue.opacity(0.1))
                  .cornerRadius(4)
              }
              
              if showingTestResult {
                VStack(alignment: .leading, spacing: 4) {
                  Text("Detection Result:")
                    .font(.caption)
                    .fontWeight(.medium)
                  
                  Text(testResult)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(4)
                  
                  Button("Clear") {
                    showingTestResult = false
                    testResult = ""
                  }
                  .font(.caption)
                }
              }
            }
          }
        }
        .onAppear {
          updatePermissionStatus()
          updateContinuousTestingState()
        }
        .onChange(of: overlayDetectionEnabled) { _ in
          if overlayDetectionEnabled {
            updatePermissionStatus()
          } else {
            // Stop continuous testing if overlay detection is disabled
            if isContinuousTestingEnabled {
              OverlayDetector.shared.stopContinuousTesting()
              updateContinuousTestingState()
            }
          }
        }
      }
      
      Settings.Section(title: "Other") {
        Defaults.Toggle("Show Leader Key in menubar", key: .showMenuBarIcon)
        Defaults.Toggle(
          "Force English keyboard layout", key: .forceEnglishKeyboardLayout)
        Defaults.Toggle("Automatically check for updates", key: .automaticallyChecksForUpdates)
        Defaults.Toggle("Allow mouse clicks through panel", key: .panelClickThrough)
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
  }
  
  private func updatePermissionStatus() {
    hasAccessibilityPermissions = OverlayDetector.shared.hasAccessibilityPermissions()
  }
  
  private func updateContinuousTestingState() {
    isContinuousTestingEnabled = OverlayDetector.shared.isContinuousTestingEnabled
  }
}

struct AdvancedPane_Previews: PreviewProvider {
  static var previews: some View {
    return AdvancedPane()
    //      .environmentObject(UserConfig())
  }
}

import Defaults
import Settings
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct AdvancedPane: View {
  @EnvironmentObject private var config: UserConfig
  @Default(.forceEnglishKeyboardLayout) var forceEnglishKeyboardLayout
  @Default(.modifierKeyConfiguration) var modifierKeyConfiguration
  @Default(.reactivateBehavior) var reactivateBehavior
  @Default(.inputMethodType) var inputMethodType
  @Default(.unixSocketPath) var unixSocketPath

  var body: some View {
    Settings.Container(contentWidth: SettingsConfig.contentWidth) {
      Settings.Section(
        title: "Keyboard",
        description: "Configure keyboard related options."
      ) {
        Form {
          Toggle(isOn: $forceEnglishKeyboardLayout) {
            Text("Force English keyboard layout")
              .frame(minWidth: 150, alignment: .leading)
          }
          .padding(.trailing, 100)
          .help(
            "When set to on, keys will be mapped to their position on a US English QWERTY keyboard."
          )

          Picker(
            selection: $modifierKeyConfiguration,
            label: Text("Modifier key behavior")
          ) {
            ForEach(ModifierKeyConfig.allCases) { key in
              Text(key.description).tag(key)
            }
          }
          .frame(width: 350)
          .help(
            "Configure what modifier keys do when used with Leader Key. Group sequences run all actions in a group instead of navigating. Sticky mode keeps the window open after executing an action."
          )
        }
      }

      Settings.Section(
        title: "Window Behavior",
        description: "Configure how the window behaves."
      ) {
        Form {
          Picker(
            selection: $reactivateBehavior,
            label: Text("On reactivation")
          ) {
            Text("Hide window").tag(ReactivateBehavior.hide)
            Text("Reset state").tag(ReactivateBehavior.reset)
            Text("Do nothing").tag(ReactivateBehavior.nothing)
          }
          .padding(.trailing, 100)
          .help(
            "What to do when the activation key is pressed while the window is already visible."
          )
        }
      }
      
      Settings.Section(
        title: "Input Method",
        description: "Configure how LeaderKey receives keyboard input."
      ) {
        Form {
          Picker(
            selection: $inputMethodType,
            label: Text("Input method")
          ) {
            ForEach(InputMethodType.allCases) { method in
              Text(method.description).tag(method)
            }
          }
          .frame(width: 400)
          .help(inputMethodType.statusDescription)
          
          if inputMethodType == .unixSocket {
            HStack {
              Text("Socket path")
                .frame(minWidth: 150, alignment: .leading)
              TextField("Socket path", text: $unixSocketPath)
                .textFieldStyle(.roundedBorder)
                .frame(width: 250)
            }
            .help("Path to the Unix socket file for communication with Karabiner Elements.")
            
            // Status indicator could go here
            HStack {
              Text("Status")
                .frame(minWidth: 150, alignment: .leading)
              Text("Disconnected")
                .foregroundColor(.orange)
                .frame(width: 250, alignment: .leading)
            }
            .help("Current connection status of the Unix socket.")
            
            // Configuration export button
            HStack {
              Text("Karabiner Config")
                .frame(minWidth: 150, alignment: .leading)
              Button("Export Configuration") {
                exportKarabinerConfiguration()
              }
              .frame(width: 250, alignment: .leading)
            }
            .help("Export a Karabiner Elements configuration file for use with Unix socket mode.")
          }
          
          if inputMethodType.requiresAccessibilityPermissions {
            HStack {
              Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.orange)
              Text("Requires Accessibility permissions")
                .foregroundColor(.secondary)
                .font(.caption)
            }
            .padding(.top, 4)
          } else {
            HStack {
              Image(systemName: "checkmark.circle")
                .foregroundColor(.green)
              Text("No system permissions required")
                .foregroundColor(.secondary)
                .font(.caption)
            }
            .padding(.top, 4)
          }
        }
      }
    }
  }
  
  // MARK: - Private Methods
  
  private func exportKarabinerConfiguration() {
    let savePanel = NSSavePanel()
    savePanel.title = "Export Karabiner Configuration"
    savePanel.message = "Choose where to save the Karabiner Elements configuration file"
    savePanel.nameFieldStringValue = "leaderkey-integration.json"
    savePanel.allowedContentTypes = [.json]
    savePanel.canCreateDirectories = true
    
    savePanel.begin { result in
      guard result == .OK, let url = savePanel.url else { return }
      
      do {
        let configuration = KarabinerConfig.Configuration(
          activationKey: "k",
          activationModifiers: ["left_command", "left_shift"],
          socketPath: unixSocketPath,
          escapeKey: "escape"
        )
        
        try KarabinerConfig.exportToFile(configuration: configuration, to: url)
        
        // Show success alert
        DispatchQueue.main.async {
          let alert = NSAlert()
          alert.messageText = "Configuration Exported Successfully"
          alert.informativeText = """
          The Karabiner Elements configuration has been saved to:
          \(url.path)
          
          To use this configuration:
          1. Open Karabiner Elements
          2. Go to Complex Modifications
          3. Click "Add rule"
          4. Click "Import more rules from the Internet (Open a web browser)"
          5. Click "Import" next to the exported file
          """
          alert.alertStyle = .informational
          alert.addButton(withTitle: "OK")
          alert.runModal()
        }
        
      } catch {
        // Show error alert
        DispatchQueue.main.async {
          let alert = NSAlert()
          alert.messageText = "Export Failed"
          alert.informativeText = "Failed to export Karabiner configuration: \(error.localizedDescription)"
          alert.alertStyle = .warning
          alert.addButton(withTitle: "OK")
          alert.runModal()
        }
      }
    }
  }
}

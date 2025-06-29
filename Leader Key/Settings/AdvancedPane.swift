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

  var body: some View {
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
        }
      }
      Settings.Section(title: "Other") {
        Defaults.Toggle("Show Leader Key in menubar", key: .showMenuBarIcon)
        Defaults.Toggle(
          "Force English keyboard layout", key: .forceEnglishKeyboardLayout)
        Defaults.Toggle("Automatically check for updates", key: .automaticallyChecksForUpdates)
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

struct AdvancedPane_Previews: PreviewProvider {
  static var previews: some View {
    return AdvancedPane()
    //      .environmentObject(UserConfig())
  }
}

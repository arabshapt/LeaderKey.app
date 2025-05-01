import Defaults
import Settings
import SwiftUI

struct AdvancedPane: View {
  @EnvironmentObject private var config: UserConfig
  @Default(.forceEnglishKeyboardLayout) var forceEnglishKeyboardLayout
  @Default(.modifierKeyConfiguration) var modifierKeyConfiguration
  @Default(.reactivateBehavior) var reactivateBehavior

  var body: some View {
    Settings.Container(contentWidth: 450.0) {
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
    }
  }
} 
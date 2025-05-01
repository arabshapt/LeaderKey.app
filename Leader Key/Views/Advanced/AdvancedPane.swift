import Defaults
import Settings
import SwiftUI

struct AdvancedPane: View {
  @EnvironmentObject private var config: UserConfig
  @Default(.forceEnglishKeyboardLayout) var forceEnglishKeyboardLayout
  @Default(.modifierKeyConfiguration) var modifierKeyConfiguration
  @Default(.reactivateBehavior) var reactivateBehavior
  @Default(.useStealthMode) var useStealthMode

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
      
      Settings.Section(
        title: "Stealth Mode",
        description: "Configure stealth mode behavior."
      ) {
        Form {
          Toggle(isOn: $useStealthMode) {
            Text("Enable stealth mode")
              .frame(minWidth: 150, alignment: .leading)
          }
          .padding(.trailing, 100)
          .help(
            "When enabled, Leader Key will use a non-blocking event tap to monitor keypresses without interfering with other applications."
          )
          
          VStack(alignment: .leading, spacing: 8) {
            Text("What is Stealth Mode?")
              .fontWeight(.medium)
            
            Text("Stealth Mode monitors keypresses without consuming them, allowing your shortcuts to work even when other apps have keyboard focus. This means:")
              .fixedSize(horizontal: false, vertical: true)
            
            Text("• Your shortcuts won't interfere with other apps")
              .fixedSize(horizontal: false, vertical: true)
            Text("• Leader Key can recognize your shortcuts without taking focus")
              .fixedSize(horizontal: false, vertical: true)
            Text("• All shortcuts continue to work exactly as configured")
              .fixedSize(horizontal: false, vertical: true)
            
            Text("Note: Stealth mode requires Accessibility permissions. You may need to add Leader Key to System Settings > Privacy & Security > Accessibility.")
              .font(.caption)
              .foregroundColor(.secondary)
              .fixedSize(horizontal: false, vertical: true)
              .padding(.top, 8)
          }
          .padding(.top, 8)
          .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
    }
  }
} 
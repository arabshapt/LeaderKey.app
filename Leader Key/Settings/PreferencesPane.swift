import Defaults
import Settings
import SwiftUI

struct PreferencesPane: View {
  private let contentWidth = SettingsConfig.contentWidth
  private let timeoutRange = 250...10000

  @Default(.leaderSequenceTimeoutEnabled) private var leaderSequenceTimeoutEnabled
  @Default(.leaderSequenceTimeoutMS) private var leaderSequenceTimeoutMS
  @Default(.normalSequenceTimeoutEnabled) private var normalSequenceTimeoutEnabled
  @Default(.normalSequenceTimeoutMS) private var normalSequenceTimeoutMS
  @Default(.hintOverlayVisible) private var hintOverlayVisible

  var body: some View {
    ScrollView {
      Settings.Container(contentWidth: contentWidth) {
        Settings.Section(title: "Sequences", bottomDivider: true) {
          VStack(alignment: .leading, spacing: 16) {
            timeoutRow(
              title: "Leader Key sequence timeout",
              isEnabled: $leaderSequenceTimeoutEnabled,
              milliseconds: $leaderSequenceTimeoutMS
            )

            timeoutRow(
              title: "Normal mode sequence timeout",
              isEnabled: $normalSequenceTimeoutEnabled,
              milliseconds: $normalSequenceTimeoutMS
            )
          }
        }

        Settings.Section(title: "Overlay") {
          Defaults.Toggle("Show Leader Key hint overlay", key: .hintOverlayVisible)
          Text("When hidden, Leader Key sequences still run but the main hint panel stays off.")
            .font(.callout)
            .foregroundColor(.secondary)
        }
      }
    }
    .frame(width: contentWidth + 60)
    .frame(minHeight: 600)
  }

  private func timeoutRow(
    title: String,
    isEnabled: Binding<Bool>,
    milliseconds: Binding<Int>
  ) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Toggle(title, isOn: isEnabled)

      HStack(spacing: 12) {
        Text("Timeout")
          .foregroundColor(.secondary)

        TextField(
          "2000",
          value: Binding(
            get: { milliseconds.wrappedValue },
            set: { milliseconds.wrappedValue = clampedTimeout($0) }
          ),
          formatter: NumberFormatter()
        )
        .frame(width: 90)
        .textFieldStyle(.roundedBorder)
        .disabled(!isEnabled.wrappedValue)

        Text("ms")
          .foregroundColor(.secondary)

        Slider(
          value: Binding(
            get: { Double(milliseconds.wrappedValue) },
            set: { milliseconds.wrappedValue = clampedTimeout(Int($0.rounded())) }
          ),
          in: Double(timeoutRange.lowerBound)...Double(timeoutRange.upperBound),
          step: 50
        )
        .frame(width: 240)
        .disabled(!isEnabled.wrappedValue)
      }
    }
    .onChange(of: milliseconds.wrappedValue) { newValue in
      let clamped = clampedTimeout(newValue)
      if clamped != newValue {
        milliseconds.wrappedValue = clamped
      }
    }
  }

  private func clampedTimeout(_ value: Int) -> Int {
    min(max(value, timeoutRange.lowerBound), timeoutRange.upperBound)
  }
}

struct PreferencesPane_Previews: PreviewProvider {
  static var previews: some View {
    PreferencesPane()
  }
}

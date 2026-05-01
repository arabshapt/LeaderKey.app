import AVFoundation
import Defaults
import KeyboardShortcuts
import Settings
import SwiftUI

struct VoicePane: View {
  private let contentWidth = SettingsConfig.contentWidth

  @Default(.voiceDispatcherEnabled) private var voiceDispatcherEnabled
  @Default(.voicePrewarmMicrophone) private var voicePrewarmMicrophone
  @Default(.voiceDispatchMode) private var voiceDispatchMode
  @Default(.voicePlannerMode) private var voicePlannerMode
  @Default(.voiceSTTModel) private var voiceSTTModel
  @Default(.voiceLlamaServerURL) private var voiceLlamaServerURL
  @Default(.voiceTier2Model) private var voiceTier2Model
  @Default(.voiceTier2ModelPath) private var voiceTier2ModelPath
  @Default(.voiceTier2FallbackModel) private var voiceTier2FallbackModel
  @Default(.voiceTier3Model) private var voiceTier3Model
  @Default(.voiceTier3ModelPath) private var voiceTier3ModelPath
  @Default(.voiceGroqPlannerModel) private var voiceGroqPlannerModel
  @Default(.voiceGeminiPlannerModel) private var voiceGeminiPlannerModel

  @State private var groqAPIKeyInput = ""
  @State private var hasStoredGroqAPIKey = false
  @State private var geminiAPIKeyInput = ""
  @State private var hasStoredGeminiAPIKey = false
  @State private var keychainMessage: String?
  @State private var microphoneMessage = ""

  var body: some View {
    ScrollView {
      Settings.Container(contentWidth: contentWidth) {
        Settings.Section(title: "Voice Dispatcher", bottomDivider: true) {
          VStack(alignment: .leading, spacing: 14) {
            Defaults.Toggle("Enable voice dispatcher", key: .voiceDispatcherEnabled)
              .onChange(of: voiceDispatcherEnabled) { _ in
                notifyVoiceSettingsChanged()
              }

            Defaults.Toggle("Prewarm microphone to avoid clipping the first word", key: .voicePrewarmMicrophone)
              .onChange(of: voicePrewarmMicrophone) { _ in
                notifyVoiceSettingsChanged()
              }

            Text(
              "Prewarming keeps the audio engine running while voice is enabled, with a short pre-roll buffer. Turn it off to avoid idle microphone work; macOS may show the microphone indicator while this is on."
            )
            .font(.callout)
            .foregroundColor(.secondary)

            Text("Voice stays dry-run unless execution is explicitly enabled below.")
              .font(.callout)
              .foregroundColor(.secondary)
          }
        }

        Settings.Section(title: "Shortcuts", bottomDivider: true) {
          VStack(alignment: .leading, spacing: 12) {
            KeyboardShortcuts.Recorder(
              "Toggle recording",
              name: .voiceToggleRecord
            )

            KeyboardShortcuts.Recorder(
              "Push and hold to talk",
              name: .voiceHoldToTalk
            )

            Text(
              "Hold-to-talk transcribes when the key is released. Voice dispatch mode (dry-run or execute) is controlled in the Dispatch section below."
            )
              .font(.callout)
              .foregroundColor(.secondary)
          }
          .disabled(!voiceDispatcherEnabled)
        }

        Settings.Section(title: "Speech to Text", bottomDivider: true) {
          VStack(alignment: .leading, spacing: 12) {
            HStack {
              Text("Groq model")
              Spacer()
              Picker("", selection: $voiceSTTModel) {
                ForEach(VoiceSTTModel.allCases) { model in
                  Text(model.displayName).tag(model)
                }
              }
              .labelsHidden()
              .frame(width: 240)
            }

            Text(voiceSTTModel.description)
              .font(.callout)
              .foregroundColor(.secondary)

            HStack(spacing: 10) {
              SecureField("Groq API key", text: $groqAPIKeyInput)
                .textFieldStyle(.roundedBorder)
                .frame(width: 360)

              Button("Save") {
                saveGroqAPIKey()
              }
              .disabled(groqAPIKeyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

              Button("Delete") {
                deleteGroqAPIKey()
              }
              .disabled(!hasStoredGroqAPIKey)
            }

            HStack(spacing: 8) {
              Image(
                systemName: hasStoredGroqAPIKey
                  ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
              )
                .foregroundColor(hasStoredGroqAPIKey ? .green : .orange)
              Text(hasStoredGroqAPIKey ? "Groq key stored in Keychain" : "No Groq key stored")
                .font(.callout)
                .foregroundColor(.secondary)
            }

            if let keychainMessage {
              Text(keychainMessage)
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
          .disabled(!voiceDispatcherEnabled)
        }

        Settings.Section(title: "Microphone", bottomDivider: true) {
          VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
              Button("Check Microphone Permission") {
                requestMicrophoneAccess()
              }

              Text(microphoneMessage)
                .font(.callout)
                .foregroundColor(.secondary)
            }

            Text(
              "macOS will prompt for microphone access the first time recording starts or when you check permission here."
            )
              .font(.callout)
              .foregroundColor(.secondary)
          }
          .disabled(!voiceDispatcherEnabled)
        }

        Settings.Section(title: "Dispatch", bottomDivider: true) {
          VStack(alignment: .leading, spacing: 12) {
            HStack {
              Text("Mode")
              Spacer()
              Picker("", selection: $voiceDispatchMode) {
                ForEach(VoiceDispatchMode.allCases) { mode in
                  Text(mode.displayName).tag(mode)
                }
              }
              .labelsHidden()
              .frame(width: 220)
            }

            Text(voiceDispatchMode.description)
              .font(.callout)
              .foregroundColor(voiceDispatchMode == .execute ? .orange : .secondary)
          }
          .disabled(!voiceDispatcherEnabled)
        }

        Settings.Section(title: "Planner Tiers") {
          VStack(alignment: .leading, spacing: 12) {
            HStack {
              Text("Planner")
              Spacer()
              Picker("", selection: $voicePlannerMode) {
                ForEach(VoicePlannerMode.allCases) { mode in
                  Text(mode.displayName).tag(mode)
                }
              }
              .labelsHidden()
              .frame(width: 180)
            }

            Text(voicePlannerMode.description)
              .font(.callout)
              .foregroundColor(.secondary)

            DisclosureGroup("Local planner settings") {
              VStack(alignment: .leading, spacing: 10) {
                labeledTextField("Server URL", text: $voiceLlamaServerURL)
                labeledTextField("Tier 2 model", text: $voiceTier2Model)
                labeledTextField("Tier 2 GGUF path", text: $voiceTier2ModelPath)
                labeledTextField("Tier 2 fallback", text: $voiceTier2FallbackModel)
                labeledTextField("Tier 3 model", text: $voiceTier3Model)
                labeledTextField("Tier 3 GGUF path", text: $voiceTier3ModelPath)
              }
              .padding(.top, 8)
            }

            DisclosureGroup("Groq Cloud planner settings") {
              VStack(alignment: .leading, spacing: 10) {
                labeledTextField("Groq planner model", text: $voiceGroqPlannerModel)
                Text("Uses your Groq API key from the STT section above.")
                  .font(.callout)
                  .foregroundColor(.secondary)
              }
              .padding(.top, 8)
            }

            DisclosureGroup("Gemini planner settings") {
              VStack(alignment: .leading, spacing: 10) {
                labeledTextField("Gemini planner model", text: $voiceGeminiPlannerModel)

                HStack(spacing: 10) {
                  SecureField("Gemini API key", text: $geminiAPIKeyInput)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 360)

                  Button("Save") {
                    saveGeminiAPIKey()
                  }
                  .disabled(geminiAPIKeyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                  Button("Delete") {
                    deleteGeminiAPIKey()
                  }
                  .disabled(!hasStoredGeminiAPIKey)
                }

                HStack(spacing: 8) {
                  Image(
                    systemName: hasStoredGeminiAPIKey
                      ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
                  )
                    .foregroundColor(hasStoredGeminiAPIKey ? .green : .orange)
                  Text(hasStoredGeminiAPIKey ? "Gemini key stored in Keychain" : "No Gemini key stored")
                    .font(.callout)
                    .foregroundColor(.secondary)
                }
              }
              .padding(.top, 8)
            }

            Defaults.Toggle(
              "Notify when llama-server is unreachable",
              key: .voiceNotifyTierUnavailable
            )
          }
          .disabled(!voiceDispatcherEnabled)
        }
      }
    }
    .frame(width: contentWidth + 60)
    .frame(minHeight: 600)
    .onAppear {
      refreshStoredKeyState()
      microphoneMessage = currentMicrophoneStatusMessage()
    }
  }

  private func labeledTextField(_ title: String, text: Binding<String>) -> some View {
    HStack(spacing: 10) {
      Text(title)
        .foregroundColor(.secondary)
        .frame(width: 130, alignment: .trailing)

      TextField(title, text: text)
        .textFieldStyle(.roundedBorder)
        .frame(width: 420)
    }
  }

  private func saveGroqAPIKey() {
    let trimmed = groqAPIKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return }

    if KeychainHelper.save(account: VoiceKeychain.groqAPIKeyAccount, key: trimmed) {
      groqAPIKeyInput = ""
      keychainMessage = "Groq key saved."
    } else {
      keychainMessage = "Failed to save Groq key."
    }
    refreshStoredKeyState()
  }

  private func deleteGroqAPIKey() {
    _ = KeychainHelper.delete(account: VoiceKeychain.groqAPIKeyAccount)
    groqAPIKeyInput = ""
    keychainMessage = "Groq key deleted."
    refreshStoredKeyState()
  }

  private func saveGeminiAPIKey() {
    let trimmed = geminiAPIKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return }

    if KeychainHelper.save(account: VoiceKeychain.geminiAPIKeyAccount, key: trimmed) {
      geminiAPIKeyInput = ""
      keychainMessage = "Gemini key saved."
    } else {
      keychainMessage = "Failed to save Gemini key."
    }
    refreshStoredKeyState()
  }

  private func deleteGeminiAPIKey() {
    _ = KeychainHelper.delete(account: VoiceKeychain.geminiAPIKeyAccount)
    geminiAPIKeyInput = ""
    keychainMessage = "Gemini key deleted."
    refreshStoredKeyState()
  }

  private func refreshStoredKeyState() {
    hasStoredGroqAPIKey = KeychainHelper.hasKey(account: VoiceKeychain.groqAPIKeyAccount)
    hasStoredGeminiAPIKey = KeychainHelper.hasKey(account: VoiceKeychain.geminiAPIKeyAccount)
  }

  private func requestMicrophoneAccess() {
    switch AVCaptureDevice.authorizationStatus(for: .audio) {
    case .authorized:
      microphoneMessage = "Microphone access granted."
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .audio) { granted in
        DispatchQueue.main.async {
          microphoneMessage = granted ? "Microphone access granted." : "Microphone access denied."
          notifyVoiceSettingsChanged()
        }
      }
    case .denied:
      microphoneMessage = "Microphone access denied in System Settings."
    case .restricted:
      microphoneMessage = "Microphone access restricted."
    @unknown default:
      microphoneMessage = "Microphone permission unknown."
    }
  }

  private func currentMicrophoneStatusMessage() -> String {
    switch AVCaptureDevice.authorizationStatus(for: .audio) {
    case .authorized:
      return "Microphone access granted."
    case .notDetermined:
      return "Microphone access not requested."
    case .denied:
      return "Microphone access denied in System Settings."
    case .restricted:
      return "Microphone access restricted."
    @unknown default:
      return "Microphone permission unknown."
    }
  }

  private func notifyVoiceSettingsChanged() {
    NotificationCenter.default.post(name: .voiceSettingsDidChange, object: nil)
  }
}

struct VoicePane_Previews: PreviewProvider {
  static var previews: some View {
    VoicePane()
  }
}

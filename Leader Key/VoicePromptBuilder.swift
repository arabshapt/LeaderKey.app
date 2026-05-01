import Foundation

struct VoicePromptBuilder {
  static func build(config _: UserConfig, bundleId _: String?) -> String? {
    // Whisper prompts behave like prior transcript context. Catalog terms caused short-clip
    // hallucinations, so keep STT unprimed and let dispatcher fuzzy matching handle vocabulary.
    nil
  }
}

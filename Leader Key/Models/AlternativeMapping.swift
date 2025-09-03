import Foundation

// MARK: - Alternative Key Mapping Model

struct AlternativeMapping: Codable, Identifiable, Equatable {
  let id: UUID
  let originalKey: String           // The key to create an alternative for (e.g., "hyphen")
  let alternativeKey: String        // Alternative key to use (e.g., "l")
  let conditions: [String]          // Conditions like "caps_lock-mode", "fn-mode"
  let appAlias: String?            // Optional app-specific context
  let description: String?          // Optional user description
  
  init(
    id: UUID = UUID(),
    originalKey: String,
    alternativeKey: String,
    conditions: [String],
    appAlias: String? = nil,
    description: String? = nil
  ) {
    self.id = id
    self.originalKey = originalKey
    self.alternativeKey = alternativeKey
    self.conditions = conditions
    self.appAlias = appAlias
    self.description = description
  }
}

// MARK: - Alternative Mappings Manager

class AlternativeMappingsManager: ObservableObject {
  static let shared = AlternativeMappingsManager()
  
  @Published var mappings: [AlternativeMapping] = []
  
  private let storageKey = "alternativeMappings"
  
  init() {
    loadMappings()
  }
  
  func loadMappings() {
    if let data = UserDefaults.standard.data(forKey: storageKey),
       let decoded = try? JSONDecoder().decode([AlternativeMapping].self, from: data) {
      mappings = decoded
    }
  }
  
  func saveMappings() {
    if let encoded = try? JSONEncoder().encode(mappings) {
      UserDefaults.standard.set(encoded, forKey: storageKey)
    }
  }
  
  func addMapping(_ mapping: AlternativeMapping) {
    mappings.append(mapping)
    saveMappings()
  }
  
  func updateMapping(_ mapping: AlternativeMapping) {
    if let index = mappings.firstIndex(where: { $0.id == mapping.id }) {
      mappings[index] = mapping
      saveMappings()
    }
  }
  
  func deleteMapping(_ mapping: AlternativeMapping) {
    mappings.removeAll { $0.id == mapping.id }
    saveMappings()
  }
  
  func deleteMapping(at offsets: IndexSet) {
    mappings.remove(atOffsets: offsets)
    saveMappings()
  }
  
  // Helper to find mappings for a specific key
  func mappings(for key: String) -> [AlternativeMapping] {
    return mappings.filter { $0.originalKey == key }
  }
  
  // Helper to find mappings for a specific app
  func mappings(for appAlias: String?) -> [AlternativeMapping] {
    if let alias = appAlias {
      return mappings.filter { $0.appAlias == alias }
    } else {
      return mappings.filter { $0.appAlias == nil }
    }
  }
}

// MARK: - Common Conditions

struct CommonCondition {
  let id: String
  let displayName: String
  let description: String
  
  static let commonConditions = [
    CommonCondition(id: "caps_lock-mode", displayName: "Caps Lock Mode", description: "When Caps Lock is held"),
    CommonCondition(id: "fn-mode", displayName: "Fn Mode", description: "When Fn key is held"),
    CommonCondition(id: "cmd-mode", displayName: "Command Mode", description: "When Command key is held"),
    CommonCondition(id: "ctrl-mode", displayName: "Control Mode", description: "When Control key is held"),
    CommonCondition(id: "opt-mode", displayName: "Option Mode", description: "When Option key is held"),
    CommonCondition(id: "shift-mode", displayName: "Shift Mode", description: "When Shift key is held"),
    CommonCondition(id: "hyper-mode", displayName: "Hyper Mode", description: "When Hyper key is active"),
    CommonCondition(id: "tilde-mode", displayName: "Tilde Mode", description: "When tilde mode is active"),
  ]
}
import Foundation
import Defaults

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
  @Published var currentSetName: String = "default"
  @Published var availableSets: [String: String] = [:] // Display name -> filename (without .json)
  @Published var hasUnsavedChanges: Bool = false
  
  private let mappingsFolder = "alternative-mappings"
  private let storageKey = "alternativeMappings" // For migration
  private let fileManager = FileManager.default
  
  init() {
    ensureMappingsDirectory()
    migrateFromUserDefaults()
    discoverMappingSets()
    loadMappings()
  }
  
  // MARK: - Directory Management
  
  func getMappingsDirectory() -> String {
    // Check if there's an active profile
    let configDir: String
    if let activeProfileId = Defaults[.activeProfileId],
       let profiles = Defaults[.leaderKeyProfiles] as? [LeaderKeyProfile],
       let activeProfile = profiles.first(where: { $0.id == activeProfileId }) {
      configDir = activeProfile.directoryPath
    } else {
      configDir = Defaults[.configDir]
    }
    return (configDir as NSString).appendingPathComponent(mappingsFolder)
  }
  
  private func ensureMappingsDirectory() {
    let dir = getMappingsDirectory()
    if !fileManager.fileExists(atPath: dir) {
      try? fileManager.createDirectory(atPath: dir, withIntermediateDirectories: true)
    }
  }
  
  // MARK: - File Operations
  
  func loadMappings() {
    loadFromFile(filename: currentSetName)
  }
  
  func saveMappings() {
    saveToFile(filename: currentSetName)
    hasUnsavedChanges = false
  }
  
  func loadFromFile(filename: String) {
    let path = getFilePath(for: filename)
    
    if let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
       let decoded = try? JSONDecoder().decode([AlternativeMapping].self, from: data) {
      mappings = decoded
      currentSetName = filename
      hasUnsavedChanges = false
    } else if filename == "default" {
      // If default doesn't exist, start with empty
      mappings = []
      saveToFile(filename: "default")
    }
  }
  
  func saveToFile(filename: String) {
    let path = getFilePath(for: filename)
    
    if let encoded = try? JSONEncoder().encode(mappings) {
      try? encoded.write(to: URL(fileURLWithPath: path))
      
      // Save metadata
      saveMetadata(for: filename)
      
      // Update available sets
      discoverMappingSets()
    }
  }
  
  private func getFilePath(for filename: String) -> String {
    let cleanFilename = filename.hasSuffix(".json") ? filename : "\(filename).json"
    return (getMappingsDirectory() as NSString).appendingPathComponent(cleanFilename)
  }
  
  // MARK: - Metadata
  
  private func saveMetadata(for filename: String) {
    let metaPath = (getMappingsDirectory() as NSString)
      .appendingPathComponent("\(filename).meta.json")
    
    let metadata: [String: Any] = [
      "customName": availableSets[filename] ?? filename.capitalized,
      "modifiedAt": ISO8601DateFormatter().string(from: Date()),
      "mappingCount": mappings.count
    ]
    
    if let data = try? JSONSerialization.data(withJSONObject: metadata) {
      try? data.write(to: URL(fileURLWithPath: metaPath))
    }
  }
  
  private func loadMetadata(for filename: String) -> [String: Any]? {
    let metaPath = (getMappingsDirectory() as NSString)
      .appendingPathComponent("\(filename).meta.json")
    
    if let data = try? Data(contentsOf: URL(fileURLWithPath: metaPath)),
       let metadata = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
      return metadata
    }
    return nil
  }
  
  // MARK: - Migration
  
  private func migrateFromUserDefaults() {
    // Only migrate if we don't have a default file yet
    let defaultPath = getFilePath(for: "default")
    
    if !fileManager.fileExists(atPath: defaultPath) {
      // Check for UserDefaults data
      if let data = UserDefaults.standard.data(forKey: storageKey),
         let decoded = try? JSONDecoder().decode([AlternativeMapping].self, from: data) {
        // Save to default file
        mappings = decoded
        saveToFile(filename: "default")
        
        // Clear UserDefaults after successful migration
        UserDefaults.standard.removeObject(forKey: storageKey)
        
        print("[AlternativeMappings] Migrated \(decoded.count) mappings from UserDefaults")
      }
    }
  }
  
  // MARK: - Discovery
  
  func discoverMappingSets() {
    availableSets.removeAll()
    
    let dir = getMappingsDirectory()
    let url = URL(fileURLWithPath: dir)
    
    if let files = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) {
      for file in files {
        let filename = file.lastPathComponent
        
        // Skip metadata files
        if filename.hasSuffix(".meta.json") {
          continue
        }
        
        // Process mapping files
        if filename.hasSuffix(".json") {
          let baseName = String(filename.dropLast(5)) // Remove .json
          
          // Load display name from metadata or use formatted default
          if let metadata = loadMetadata(for: baseName),
             let customName = metadata["customName"] as? String {
            availableSets[baseName] = customName
          } else {
            // Format the filename nicely
            let displayName = baseName
              .replacingOccurrences(of: "-", with: " ")
              .replacingOccurrences(of: "_", with: " ")
              .capitalized
            availableSets[baseName] = displayName
          }
        }
      }
    }
    
    // Ensure default exists
    if !availableSets.keys.contains("default") {
      availableSets["default"] = "Default"
    }
  }
  
  // MARK: - Set Management
  
  func switchToSet(name: String) {
    if hasUnsavedChanges {
      // In a real app, we'd show an alert asking to save
      saveMappings()
    }
    
    currentSetName = name
    loadFromFile(filename: name)
  }
  
  func saveAsNewSet(name: String) -> Bool {
    let filename = name
      .lowercased()
      .replacingOccurrences(of: " ", with: "-")
      .replacingOccurrences(of: "/", with: "-")
    
    // Check if already exists
    if availableSets.keys.contains(filename) {
      return false
    }
    
    saveToFile(filename: filename)
    currentSetName = filename
    availableSets[filename] = name
    return true
  }
  
  func deleteSet(name: String) -> Bool {
    // Don't allow deleting default
    if name == "default" {
      return false
    }
    
    // Don't allow deleting current set without switching first
    if name == currentSetName {
      switchToSet(name: "default")
    }
    
    let jsonPath = getFilePath(for: name)
    let metaPath = (getMappingsDirectory() as NSString)
      .appendingPathComponent("\(name).meta.json")
    
    // Delete both files
    try? fileManager.removeItem(atPath: jsonPath)
    try? fileManager.removeItem(atPath: metaPath)
    
    // Update available sets
    discoverMappingSets()
    
    return true
  }
  
  func renameSet(from oldName: String, to newName: String) -> Bool {
    // Don't allow renaming default
    if oldName == "default" {
      return false
    }
    
    // Update metadata with new display name
    let metaPath = (getMappingsDirectory() as NSString)
      .appendingPathComponent("\(oldName).meta.json")
    
    if var metadata = loadMetadata(for: oldName) {
      metadata["customName"] = newName
      if let data = try? JSONSerialization.data(withJSONObject: metadata) {
        try? data.write(to: URL(fileURLWithPath: metaPath))
        availableSets[oldName] = newName
        return true
      }
    }
    
    return false
  }
  
  // MARK: - CRUD Operations
  
  func addMapping(_ mapping: AlternativeMapping) {
    mappings.append(mapping)
    hasUnsavedChanges = true
    saveMappings()
  }
  
  func updateMapping(_ mapping: AlternativeMapping) {
    if let index = mappings.firstIndex(where: { $0.id == mapping.id }) {
      mappings[index] = mapping
      hasUnsavedChanges = true
      saveMappings()
    }
  }
  
  func deleteMapping(_ mapping: AlternativeMapping) {
    mappings.removeAll { $0.id == mapping.id }
    hasUnsavedChanges = true
    saveMappings()
  }
  
  func deleteMapping(at offsets: IndexSet) {
    mappings.remove(atOffsets: offsets)
    hasUnsavedChanges = true
    saveMappings()
  }
  
  // MARK: - Helpers
  
  func mappings(for key: String) -> [AlternativeMapping] {
    return mappings.filter { $0.originalKey == key }
  }
  
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
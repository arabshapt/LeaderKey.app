import Cocoa
import Defaults
import Foundation

// MARK: - Directory Management & File Operations
extension UserConfig {

  static func defaultDirectory() -> String {
    let appSupportDir = FileManager.default.urls(
      for: .applicationSupportDirectory, in: .userDomainMask)[0]
    let path = (appSupportDir.path as NSString).appendingPathComponent(
      "Leader Key")
    do {
      try FileManager.default.createDirectory(
        atPath: path, withIntermediateDirectories: true)
    } catch {
      fatalError("Failed to create config directory: \(error)")  // Include error
    }
    return path
  }

  internal func ensureValidConfigDirectory() {
    // If we have a current profile, use its directory
    if let profile = currentProfile {
      let profileDir = profile.directoryPath
      
      // Ensure profile directory exists
      if !fileManager.fileExists(atPath: profileDir) {
        do {
          try fileManager.createDirectory(
            atPath: profileDir,
            withIntermediateDirectories: true,
            attributes: nil
          )
        } catch {
          print("Failed to create profile directory: \(error)")
        }
      }
      
      // Don't use the old configDir for profiles
      return
    }
    
    // Fallback to old behavior if no profile (shouldn't happen)
    let dir = Defaults[.configDir]
    let defaultDir = Self.defaultDirectory()

    if !fileManager.fileExists(atPath: dir) {
      alertHandler.showAlert(
        style: .warning,
        message:
          "Config directory does not exist: \(dir)\nResetting to default location."
      )
      Defaults[.configDir] = defaultDir
    }

    // Migrate old config filenames to new ones
    migrateConfigFilenames()
  }

  private func migrateConfigFilenames() {
    let configDir = Defaults[.configDir]

    // Migrate old config files to app-fallback-config.json
    // First try migrating global-config.json if it exists
    let oldGlobalPath = (configDir as NSString).appendingPathComponent("global-config.json")
    let newFallbackPath = (configDir as NSString).appendingPathComponent(fileName)
    
    if fileManager.fileExists(atPath: oldGlobalPath)
      && !fileManager.fileExists(atPath: newFallbackPath)
    {
      do {
        try fileManager.moveItem(atPath: oldGlobalPath, toPath: newFallbackPath)
        print("[Migration] Renamed global-config.json to \(fileName)")
      } catch {
        print("[Migration] Failed to rename global-config.json: \(error)")
      }
    }
    
    // Also migrate config.json if it still exists (from older versions)
    let oldConfigPath = (configDir as NSString).appendingPathComponent("config.json")
    if fileManager.fileExists(atPath: oldConfigPath)
      && !fileManager.fileExists(atPath: newFallbackPath)
    {
      do {
        try fileManager.moveItem(atPath: oldConfigPath, toPath: newFallbackPath)
        print("[Migration] Renamed config.json to \(fileName)")
      } catch {
        print("[Migration] Failed to rename config.json: \(error)")
      }
    }

    // Migrate app.default.json to app-fallback-config.json  
    let oldDefaultAppPath = (configDir as NSString).appendingPathComponent("app.default.json")
    let finalFallbackPath = (configDir as NSString).appendingPathComponent(defaultAppConfigFileName)

    if fileManager.fileExists(atPath: oldDefaultAppPath)
      && !fileManager.fileExists(atPath: finalFallbackPath)
    {
      do {
        try fileManager.moveItem(atPath: oldDefaultAppPath, toPath: finalFallbackPath)
        print("[Migration] Renamed app.default.json to \(defaultAppConfigFileName)")
      } catch {
        print("[Migration] Failed to rename app.default.json: \(error)")
      }
    }
  }

  var path: String {
    if let profile = currentProfile {
      return (profile.directoryPath as NSString).appendingPathComponent(fileName)
    }
    return (Defaults[.configDir] as NSString).appendingPathComponent(fileName)
  }

  var url: URL {
    URL(fileURLWithPath: path)
  }

  var exists: Bool {
    fileManager.fileExists(atPath: path)
  }

  internal func ensureDefaultAppConfigExists() {
    let configDir = currentProfile?.directoryPath ?? Defaults[.configDir]
    let defaultAppConfigPath = (configDir as NSString).appendingPathComponent(
      defaultAppConfigFileName)
    guard !fileManager.fileExists(atPath: defaultAppConfigPath) else { return }

    do {
      try bootstrapDefaultAppConfig()
    } catch {
      handleError(error, critical: false)  // Non-critical since it's a fallback config
    }
  }

  private func bootstrapDefaultAppConfig() throws {
    guard let data = defaultConfig.data(using: .utf8) else {
      throw NSError(
        domain: "UserConfig",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Failed to encode fallback app config"]
      )
    }
    let defaultAppConfigPath = (Defaults[.configDir] as NSString).appendingPathComponent(
      defaultAppConfigFileName)
    try data.write(to: URL(fileURLWithPath: defaultAppConfigPath))
  }

  private func writeFile(data: Data) throws {
    try data.write(to: url)
  }

  private func readFile() throws -> String {
    try String(contentsOfFile: path, encoding: .utf8)
  }
}

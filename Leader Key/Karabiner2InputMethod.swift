import AppKit
import Foundation

final class Karabiner2InputMethod: InputMethod {
  private weak var delegate: InputMethodDelegate?
  private let socketServer = UnixSocketServer.shared
  private var lastHealthCheck = Date()
  private var currentState: Int32 = 0

  var isActive: Bool {
    return socketServer.getStatistics().contains("Running: true")
  }

  var healthStatus: InputMethodHealthStatus {
    let karabinerRunning = isKarabinerRunning()
    let socketActive = isActive

    let isHealthy = karabinerRunning && socketActive
    let message: String

    if !karabinerRunning {
      message = "Karabiner Elements is not running (required for Karabiner 2.0 mode)"
    } else if !socketActive {
      message = "Unix socket server is not active"
    } else {
      message = "Karabiner 2.0 state machine integration is active"
    }

    return InputMethodHealthStatus(
      isHealthy: isHealthy,
      message: message,
      lastCheckTime: lastHealthCheck
    )
  }

  func start(with delegate: InputMethodDelegate) -> Bool {
    self.delegate = delegate

    socketServer.delegate = self

    let success = socketServer.start()

    if success {
      debugLog("[Karabiner2InputMethod] Started successfully")
      exportCurrentConfiguration()
    } else {
      debugLog("[Karabiner2InputMethod] Failed to start")
    }

    return success
  }

  func stop() {
    socketServer.stop()
    currentState = 0
    debugLog("[Karabiner2InputMethod] Stopped")
  }

  func checkHealth() -> Bool {
    lastHealthCheck = Date()
    return isKarabinerRunning() && isActive
  }

  func getStatistics() -> String {
    return """
      \(socketServer.getStatistics())
      Current State: \(currentState)
      Mode: Karabiner 2.0 (State Machine)
      """
  }

  private func exportCurrentConfiguration() {
    guard let appDelegate = NSApplication.shared.delegate as? AppDelegate,
      let userConfig = appDelegate.controller?.userConfig
    else {
      debugLog("[Karabiner2InputMethod] Failed to get user config for export")
      return
    }

    // 1. Load global config (already loaded in userConfig)
    let globalConfig = userConfig
    
    // 2. Discover all app configs in Application Support directory
    let configDir = NSHomeDirectory() + "/Library/Application Support/Leader Key"
    var appConfigs: [(bundleId: String, config: UserConfig, customName: String?)] = []
    
    do {
      let files = try FileManager.default.contentsOfDirectory(atPath: configDir)
      for file in files {
        // Match app config files (app.{bundleId}.json) but exclude .meta.json files
        if file.hasPrefix("app.") && file.hasSuffix(".json") && !file.hasSuffix(".meta.json") && file != "app-fallback-config.json" {
          // Extract bundle ID from filename
          let bundleId = String(file.dropFirst(4).dropLast(5)) // Remove "app." and ".json"
          
          // Skip certain system configs and any with .meta in the bundle ID
          if bundleId == "default" || bundleId.contains("Leader-Key") || bundleId.contains("leaderkey") || bundleId.contains(".meta") {
            debugLog("[Karabiner2InputMethod] Skipping config: bundleId=\(bundleId)")
            continue
          }
          
          debugLog("[Karabiner2InputMethod] Processing file: \(file) → bundleId: \(bundleId)")
          
          // Try to read custom name from meta file
          var customName: String? = nil
          let metaFilePath = configDir + "/app.\(bundleId).meta.json"
          if FileManager.default.fileExists(atPath: metaFilePath) {
            do {
              let metaData = try Data(contentsOf: URL(fileURLWithPath: metaFilePath))
              let metadata = try JSONDecoder().decode(Karabiner2Exporter.AppMetadata.self, from: metaData)
              customName = metadata.customName
              debugLog("[Karabiner2InputMethod] Found custom name for \(bundleId): \(customName ?? "nil")")
            } catch {
              debugLog("[Karabiner2InputMethod] Failed to read meta file for \(bundleId): \(error)")
            }
          }
          
          // Load and merge the app config with fallback
          let appConfigPath = configDir + "/" + file
          if let appSpecificConfig = loadAndMergeAppConfig(
            bundleId: bundleId, 
            configPath: appConfigPath, 
            globalConfig: globalConfig
          ) {
            debugLog("[Karabiner2InputMethod] Adding to appConfigs: bundleId=\(bundleId), customName=\(customName ?? "nil")")
            appConfigs.append((bundleId: bundleId, config: appSpecificConfig, customName: customName))
          }
        }
      }
    } catch {
      debugLog("[Karabiner2InputMethod] Failed to list config directory: \(error)")
    }
    
    debugLog("[Karabiner2InputMethod] Found \(appConfigs.count) app-specific configs")
    for (bundleId, _, customName) in appConfigs {
      debugLog("[Karabiner2InputMethod] Final appConfig: bundleId=\(bundleId), customName=\(customName ?? "nil")")
    }
    
    // 3. Generate unified EDN with hierarchical organization
    let (ednContent, stateMappings) = Karabiner2Exporter.generateUnifiedGokuEDNHierarchical(
      globalConfig: globalConfig,
      appConfigs: appConfigs
    )
    
    // 4. Save to single unified file
    let outputDir = NSHomeDirectory() + "/.config/karabiner.edn.d"
    let filePath = outputDir + "/leaderkey-unified.edn"

    do {
      try FileManager.default.createDirectory(
        atPath: outputDir, withIntermediateDirectories: true, attributes: nil)

      try ednContent.write(toFile: filePath, atomically: true, encoding: .utf8)

      debugLog("[Karabiner2InputMethod] Exported unified configuration to \(filePath)")
      
      // Save state mappings as JSON
      let mappingFilePath = outputDir + "/leaderkey-state-mappings.json"
      let encoder = JSONEncoder()
      encoder.outputFormatting = .prettyPrinted
      let mappingData = try encoder.encode(stateMappings)
      try mappingData.write(to: URL(fileURLWithPath: mappingFilePath))
      
      debugLog("[Karabiner2InputMethod] Exported \(stateMappings.count) state mappings to \(mappingFilePath)")

      let task = Process()
      task.launchPath = "/bin/sh"
      task.arguments = [
        "-c",
        "which goku && goku --dry-run || echo 'Goku not found - please install with: brew install yqrashawn/goku/goku'",
      ]

      let pipe = Pipe()
      task.standardOutput = pipe
      task.standardError = pipe

      task.launch()
      task.waitUntilExit()

      if let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
      {
        debugLog("[Karabiner2InputMethod] Goku validation output: \(output)")
      }

    } catch {
      debugLog("[Karabiner2InputMethod] Failed to export configuration: \(error)")
    }
  }
  
  // Helper to load an app config and merge with fallback
  private func loadAndMergeAppConfig(bundleId: String, configPath: String, globalConfig: UserConfig) -> UserConfig? {
    // Use UserConfig's existing getConfig method which handles merging with fallback
    let mergedRoot = globalConfig.getConfig(for: bundleId)
    
    // Create a new UserConfig with the merged root
    let appConfig = UserConfig()
    appConfig.root = mergedRoot
    return appConfig
  }

  private func isKarabinerRunning() -> Bool {
    let karabinerBundleIDs = [
      "org.pqrs.Karabiner-Elements.Settings",
      "org.pqrs.Karabiner-Menu",
      "org.pqrs.Karabiner-NotificationWindow",
      "org.pqrs.Karabiner-EventViewer",
    ]

    let runningApps = NSWorkspace.shared.runningApplications
    let hasKarabinerApp = runningApps.contains { app in
      if let bundleID = app.bundleIdentifier {
        return karabinerBundleIDs.contains(bundleID)
      }
      return false
    }

    if !hasKarabinerApp {
      return isKarabinerGrabberRunning()
    }

    return hasKarabinerApp
  }

  private func isKarabinerGrabberRunning() -> Bool {
    let task = Process()
    task.launchPath = "/bin/sh"
    task.arguments = ["-c", "pgrep -x karabiner_grabber"]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = Pipe()

    do {
      try task.run()
      task.waitUntilExit()
      return task.terminationStatus == 0
    } catch {
      debugLog("[Karabiner2InputMethod] Failed to check karabiner_grabber: \(error)")
      return false
    }
  }
}

extension Karabiner2InputMethod: UnixSocketServerDelegate {
  func unixSocketServerDidReceiveActivation(bundleId: String?) {
    debugLog("[Karabiner2InputMethod] Received activation, bundleId: \(bundleId ?? "nil")")
    currentState = 1
    delegate?.inputMethodDidReceiveActivation(bundleId: bundleId)
  }

  func unixSocketServerDidReceiveKey(_ keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
    debugLog("[Karabiner2InputMethod] Received key: \(keyCode), modifiers: \(modifiers)")
    delegate?.inputMethodDidReceiveKey(keyCode, modifiers: modifiers)
  }

  func unixSocketServerDidReceiveDeactivation() {
    debugLog("[Karabiner2InputMethod] Received deactivation")
    currentState = 0
    delegate?.inputMethodDidReceiveDeactivation()
  }

  func unixSocketServerDidReceiveSequence(_ sequence: String) {
    debugLog("[Karabiner2InputMethod] Received sequence: \(sequence)")
    currentState = 0
    delegate?.inputMethodDidReceiveSequence(sequence)
  }
  
  func unixSocketServerDidReceiveStateId(_ stateId: Int32) {
    debugLog("[Karabiner2InputMethod] Received state ID: \(stateId)")
    currentState = 0
    delegate?.inputMethodDidReceiveStateId(stateId)
  }

  func unixSocketServerRequestState() -> [String: Any] {
    var state = delegate?.inputMethodDidRequestState() ?? ["active": false]
    state["currentState"] = currentState
    state["mode"] = "karabiner2"
    return state
  }
}

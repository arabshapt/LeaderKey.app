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

  func exportCurrentConfiguration() {
    // Export all profiles instead of just the current one
    exportAllProfiles()
  }

  func exportAllProfiles() {
    debugLog("[Karabiner2InputMethod] Starting export of all profiles")

    // Get all profiles from ProfileManager
    let profileManager = ProfileManager.shared
    let allProfiles = profileManager.profiles

    guard !allProfiles.isEmpty else {
      debugLog("[Karabiner2InputMethod] No profiles found to export")
      return
    }

    // Structure to hold all profile configurations
    var allProfileConfigs: [(profile: LeaderKeyProfile, fallbackConfig: UserConfig, appConfigs: [(bundleId: String, config: UserConfig, customName: String?)])] = []

    // Process each profile
    for (profileIndex, profile) in allProfiles.enumerated() {
      debugLog("[Karabiner2InputMethod] Processing profile \(profileIndex): \(profile.name)")

      // Load the profile's configuration
      let userConfig = UserConfig()
      userConfig.currentProfile = profile

      // Load fallback config for this profile
      let fallbackConfig = userConfig

      // Discover all app configs in profile-specific directory
      let configDir = profile.directoryPath
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
              continue
            }

            // Try to read custom name from meta file
            var customName: String? = nil
            let metaFilePath = configDir + "/app.\(bundleId).meta.json"
            if FileManager.default.fileExists(atPath: metaFilePath) {
              do {
                let metaData = try Data(contentsOf: URL(fileURLWithPath: metaFilePath))
                let metadata = try JSONDecoder().decode(Karabiner2Exporter.AppMetadata.self, from: metaData)
                customName = metadata.customName
              } catch {
                debugLog("[Karabiner2InputMethod] Failed to read meta file for \(bundleId): \(error)")
              }
            }

            // Load and merge the app config with fallback
            let appConfigPath = configDir + "/" + file
            if let appSpecificConfig = loadAndMergeAppConfig(
              bundleId: bundleId,
              configPath: appConfigPath,
              fallbackConfig: fallbackConfig
            ) {
              appConfigs.append((bundleId: bundleId, config: appSpecificConfig, customName: customName))
            }
          }
        }
      } catch {
        debugLog("[Karabiner2InputMethod] Failed to list config directory for profile \(profile.name): \(error)")
      }

      allProfileConfigs.append((profile: profile, fallbackConfig: fallbackConfig, appConfigs: appConfigs))
    }

    debugLog("[Karabiner2InputMethod] Collected configs for \(allProfileConfigs.count) profiles")

    // 3. Generate unified EDN for all profiles
    let (ednContent, stateMappings) = Karabiner2Exporter.generateAllProfilesEDN(
      allProfileConfigs: allProfileConfigs
    )
    
    // 4. Save to all-profiles file
    let outputDir = NSHomeDirectory() + "/.config/karabiner.edn.d"
    let filePath = outputDir + "/leaderkey-all-profiles.edn"

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
      
      // Inject into main karabiner.edn if markers exist
      // Check if activation shortcuts already exist in target file
      let configPath = NSHomeDirectory() + "/.config/karabiner.edn"
      var hasExistingActivationShortcuts = false
      
      if FileManager.default.fileExists(atPath: configPath) {
        if let existingContent = try? String(contentsOfFile: configPath, encoding: .utf8) {
          hasExistingActivationShortcuts = existingContent.contains("\"Leader Key - Activation Shortcuts\"")
        }
      }
      
      // Extract sections, excluding activation shortcuts if they already exist
      let (applications, mainRules, activationShortcuts) = Karabiner2Exporter.extractSectionsForInjection(
        from: ednContent,
        includeActivationShortcuts: true  // Always extract, but we'll decide whether to inject
      )
      
      // Prepare rules for injection
      var rulesToInject = mainRules
      
      // Only add activation shortcuts if they don't already exist
      if !hasExistingActivationShortcuts, let activationShortcuts = activationShortcuts {
        debugLog("[Karabiner2InputMethod] Including activation shortcuts (not found in existing file)")
        rulesToInject.insert(activationShortcuts, at: 0)  // Add at beginning
      } else if hasExistingActivationShortcuts {
        debugLog("[Karabiner2InputMethod] Preserving existing activation shortcuts")
      }
      
      if !applications.isEmpty || !rulesToInject.isEmpty {
        // Try injection with auto-add markers on first attempt
        let injectionResult = Karabiner2Exporter.injectIntoMainKarabinerEDN(
          applications: applications,
          mainRules: rulesToInject,
          autoAddMarkers: true,  // Auto-add markers if missing
          preserveActivationShortcuts: hasExistingActivationShortcuts  // Preserve if they exist
        )
        
        switch injectionResult {
        case .success:
          debugLog("[Karabiner2InputMethod] Successfully injected Leader Key config into main karabiner.edn")
        case .noMarkersFound:
          debugLog("[Karabiner2InputMethod] No injection markers found in karabiner.edn - add markers to enable injection")
        case .partialMarkersFound(let missing):
          debugLog("[Karabiner2InputMethod] Incomplete markers in karabiner.edn, missing: \(missing.joined(separator: ", "))")
        case .fileNotFound:
          debugLog("[Karabiner2InputMethod] karabiner.edn not found - injection skipped")
        case .error(let message):
          debugLog("[Karabiner2InputMethod] Injection failed: \(message)")
        }
      }

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
  private func loadAndMergeAppConfig(bundleId: String, configPath: String, fallbackConfig: UserConfig) -> UserConfig? {
    // Use UserConfig's existing getConfig method which handles merging with fallback
    let mergedRoot = fallbackConfig.getConfig(for: bundleId)
    
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

  func unixSocketServerDidReceiveSettings() {
    debugLog("[Karabiner2InputMethod] Received settings command")
    delegate?.inputMethodDidReceiveSettings()
  }

  func unixSocketServerDidReceiveSequence(_ sequence: String) {
    debugLog("[Karabiner2InputMethod] Received sequence: \(sequence)")
    currentState = 0
    delegate?.inputMethodDidReceiveSequence(sequence)
  }
  
  func unixSocketServerDidReceiveStateId(_ stateId: Int32, sticky: Bool) {
    debugLog("[Karabiner2InputMethod] Received state ID: \(stateId), sticky: \(sticky)")
    currentState = 0
    delegate?.inputMethodDidReceiveStateId(stateId, sticky: sticky)
  }

  func unixSocketServerDidReceiveShake() {
    debugLog("[Karabiner2InputMethod] Received shake command")
    delegate?.inputMethodDidReceiveShake()
  }

  func unixSocketServerRequestState() -> [String: Any] {
    var state = delegate?.inputMethodDidRequestState() ?? ["active": false]
    state["currentState"] = currentState
    state["mode"] = "karabiner2"
    return state
  }
}

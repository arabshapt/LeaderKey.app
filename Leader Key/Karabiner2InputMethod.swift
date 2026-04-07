import AppKit
import Defaults
import Foundation

final class Karabiner2InputMethod: InputMethod {
  private weak var delegate: InputMethodDelegate?
  private let socketServer = UnixSocketServer.shared
  private let userCommandReceiver = KarabinerUserCommandReceiver()
  private var lastHealthCheck = Date()
  private var currentState: Int32 = 0
  private var lastKarabinerTsExportError: String?

  var isActive: Bool {
    return socketServer.getStatistics().contains("Running: true")
  }

  var healthStatus: InputMethodHealthStatus {
    let karabinerRunning = isKarabinerRunning()
    let socketActive = isActive
    let userCommandActive = userCommandReceiver.isRunning
    let backend = Defaults[.karabiner2Backend]
    let karabinerTsHealthy = !backend.requiresKarabinerTsExport || lastKarabinerTsExportError == nil

    let isHealthy = karabinerRunning && socketActive && userCommandActive && karabinerTsHealthy
    let message: String

    if !karabinerRunning {
      message = "Karabiner Elements is not running (required for Karabiner 2.0 mode)"
    } else if !socketActive {
      message = "Unix socket server is not active"
    } else if !userCommandActive {
      message = "Karabiner user command receiver is not active"
    } else if backend.requiresKarabinerTsExport, let lastKarabinerTsExportError {
      message = "karabiner.ts export is unhealthy: \(lastKarabinerTsExportError)"
    } else {
      let backendLabel = backend.displayName
      message = "Karabiner 2.0 state machine integration is active (socket + send_user_command + \(backendLabel))"
    }

    return InputMethodHealthStatus(
      isHealthy: isHealthy,
      message: message,
      lastCheckTime: lastHealthCheck
    )
  }

  func start(with delegate: InputMethodDelegate, onExportComplete: (() -> Void)? = nil) -> Bool {
    self.delegate = delegate

    userCommandReceiver.delegate = delegate as? UnixSocketServerDelegate
    let receiverSuccess = userCommandReceiver.start()

    if receiverSuccess {
      debugLog("[Karabiner2InputMethod] Started successfully")
      if !isActive {
        debugLog("[Karabiner2InputMethod] Warning: app-level control socket is not active")
      }
      DispatchQueue.global(qos: .utility).async { [weak self] in
        self?.exportCurrentConfiguration(caller: "start")
        // Notify caller on main thread that export is done and state mappings file is fresh.
        // This avoids data races: callers should defer loadStateMappings() to this callback
        // rather than calling it immediately after start() returns.
        if let onExportComplete = onExportComplete {
          DispatchQueue.main.async {
            onExportComplete()
          }
        }
      }
    } else {
      debugLog("[Karabiner2InputMethod] Failed to start")
    }

    return receiverSuccess
  }

  func stop() {
    userCommandReceiver.stop()
    currentState = 0
    debugLog("[Karabiner2InputMethod] Stopped")
  }

  func checkHealth() -> Bool {
    lastHealthCheck = Date()
    return isKarabinerRunning() && isActive && userCommandReceiver.isRunning
  }

  func getStatistics() -> String {
    return """
      \(socketServer.getStatistics())
      User Command Receiver: \(userCommandReceiver.isRunning ? "Running" : "Stopped")
      User Command Socket: \(userCommandReceiver.socketPath)
      Backend: \(Defaults[.karabiner2Backend].displayName)
      Current State: \(currentState)
      Mode: Karabiner 2.0 (State Machine)
      """
  }

  var transportState: Int32 {
    currentState
  }

  func recordTransportState(_ state: Int32) {
    currentState = state
  }

  private static let exportLock = NSLock()
  private static var lastExportStartTime: CFAbsoluteTime = 0

  func exportCurrentConfiguration(caller: String = "unknown") {
    // Debounce: skip if an export started within the last 2 seconds (from any thread/caller)
    Self.exportLock.lock()
    let sinceLastStart = CFAbsoluteTimeGetCurrent() - Self.lastExportStartTime
    if sinceLastStart < 2.0 {
      Self.exportLock.unlock()
      debugLog("[Benchmark] Export skipped — started \(String(format: "%.0f", sinceLastStart * 1000))ms ago (caller: \(caller))")
      return
    }
    Self.lastExportStartTime = CFAbsoluteTimeGetCurrent()
    Self.exportLock.unlock()

    let pipelineStart = CFAbsoluteTimeGetCurrent()
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
    
    let discoveryElapsed = CFAbsoluteTimeGetCurrent() - pipelineStart
    debugLog("[Karabiner2InputMethod] Found \(appConfigs.count) app-specific configs")
    debugLog("[Benchmark] Config discovery: \(String(format: "%.0f", discoveryElapsed * 1000))ms")

    let backend = Defaults[.karabiner2Backend]

    if backend.requiresKarabinerTsExport {
      let karStart = CFAbsoluteTimeGetCurrent()
      exportUsingKar(globalConfig: globalConfig, appConfigs: appConfigs)
      debugLog("[Benchmark] karabiner.ts export: \(String(format: "%.0f", (CFAbsoluteTimeGetCurrent() - karStart) * 1000))ms")
    }

    guard backend.requiresGoku else {
      debugLog("[Benchmark] Total pipeline: \(String(format: "%.0f", (CFAbsoluteTimeGetCurrent() - pipelineStart) * 1000))ms")
      return
    }

    // 3. Generate unified EDN with hierarchical organization
    let ednGenStart = CFAbsoluteTimeGetCurrent()
    let (ednContent, stateMappings) = Karabiner2Exporter.generateUnifiedGokuEDNHierarchical(
      globalConfig: globalConfig,
      appConfigs: appConfigs
    )
    
    debugLog("[Benchmark] EDN generation: \(String(format: "%.0f", (CFAbsoluteTimeGetCurrent() - ednGenStart) * 1000))ms")

    // 4. Save to single unified file
    let fileIOStart = CFAbsoluteTimeGetCurrent()
    let outputDir = (Defaults[.configDir] as NSString).appendingPathComponent("export")
    let filePath = outputDir + "/leaderkey-unified.edn"

    do {
      try FileManager.default.createDirectory(
        atPath: outputDir, withIntermediateDirectories: true, attributes: nil)

      try ednContent.write(toFile: filePath, atomically: true, encoding: .utf8)

      debugLog("[Karabiner2InputMethod] Exported unified configuration to \(filePath)")
      try saveStateMappings(stateMappings, outputDir: outputDir)
      
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
      let specificConfigRules = Karabiner2Exporter.generateCanonicalSpecificConfigRules(
        appConfigs: appConfigs
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
      
      if !applications.isEmpty || !rulesToInject.isEmpty || !specificConfigRules.isEmpty {
        // Try injection with auto-add markers on first attempt
        let injectionResult = Karabiner2Exporter.injectIntoMainKarabinerEDN(
          applications: applications,
          mainRules: rulesToInject,
          specificConfigRules: specificConfigRules,
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

      debugLog("[Benchmark] File I/O + injection: \(String(format: "%.0f", (CFAbsoluteTimeGetCurrent() - fileIOStart) * 1000))ms")

      if FileManager.default.fileExists(atPath: configPath) {
        let gokuStart = CFAbsoluteTimeGetCurrent()
        let gokuResult = GokuCompilerService.shared.compileAndApply(configPath: configPath)
        debugLog("[Benchmark] Goku compilation: \(String(format: "%.0f", (CFAbsoluteTimeGetCurrent() - gokuStart) * 1000))ms")
        debugLog("[Karabiner2InputMethod] \(gokuResult.message)")
      } else {
        debugLog("[Karabiner2InputMethod] goku skipped: karabiner.edn not found")
      }

      debugLog("[Benchmark] Total pipeline: \(String(format: "%.0f", (CFAbsoluteTimeGetCurrent() - pipelineStart) * 1000))ms")
    } catch {
      debugLog("[Karabiner2InputMethod] Failed to export configuration: \(error)")
    }
  }

  /// Exports the current configuration using the karabiner.ts backend.
  ///
  /// ## Pipeline Data Flow
  /// ```
  /// exportUsingKar (this method)
  ///   1. generateKarConfig  → managedRules + stateMappings (CPU)
  ///   2. applyRules          → patches karabiner.json for Karabiner Elements
  ///   3. saveStateMappings   → writes leaderkey-state-mappings.json   ← MUST complete synchronously
  ///   4. (background)        → generates .ts module source file
  ///
  /// AppDelegate.runExportRefresh (caller)
  ///   calls exportCurrentConfiguration()      (steps 1-3 above)
  ///   then  loadStateMappings()                (reads file from step 3)
  ///   then  builds actionCache from mappings
  /// ```
  ///
  /// **IMPORTANT**: `saveStateMappings` (step 3) MUST run synchronously before this method returns.
  /// `AppDelegate.loadStateMappings()` reads the same file immediately after this call completes.
  /// Deferring step 3 to a background thread will cause "No mapping found" errors for new config items.
  private func exportUsingKar(
    globalConfig: UserConfig,
    appConfigs: [(bundleId: String, config: UserConfig, customName: String?)]
  ) {
    let service = KarabinerTsExportService.shared

    do {
      // === CRITICAL PATH: generateKarConfig + applyRules + saveStateMappings ===

      let t0 = CFAbsoluteTimeGetCurrent()
      let export = Karabiner2Exporter.generateKarConfig(
        globalConfig: globalConfig,
        appConfigs: appConfigs
      )
      let t1 = CFAbsoluteTimeGetCurrent()

      // Phase 2: Patch karabiner.json with managed rules (the critical output).
      try autoreleasepool {
        try service.applyRules(export.managedRules)
      }
      let t2 = CFAbsoluteTimeGetCurrent()

      lastKarabinerTsExportError = nil

      debugLog("[Benchmark] kar generateKarConfig: \(String(format: "%.0f", (t1 - t0) * 1000))ms")
      debugLog("[Benchmark] kar applyRules (karabiner.json patch): \(String(format: "%.0f", (t2 - t1) * 1000))ms")
      debugLog("[Benchmark] kar critical path: \(String(format: "%.0f", (t2 - t0) * 1000))ms")
      debugLog("[Karabiner2InputMethod] Applied \(export.managedRules.count) LeaderKey rules via karabiner.ts")

      // === State mappings: sort + save synchronously ===
      // AppDelegate.loadStateMappings() reads this file right after exportCurrentConfiguration returns.
      // See runExportRefresh() in AppDelegate.swift — it calls loadStateMappings() on main queue
      // immediately after this method completes. If these are deferred to background, the load
      // will read stale data and new state IDs will produce "No mapping found" errors.
      let sortedMappings = Karabiner2Exporter.sortMappings(export.stateMappings)
      let configDir = Defaults[.configDir]
      let outputDir = (configDir as NSString).appendingPathComponent("export")
      try FileManager.default.createDirectory(
        atPath: outputDir, withIntermediateDirectories: true, attributes: nil)
      try saveStateMappings(sortedMappings, outputDir: outputDir)
      let t3 = CFAbsoluteTimeGetCurrent()
      debugLog("[Benchmark] kar sortMappings+save: \(String(format: "%.0f", (t3 - t2) * 1000))ms")

      // === DEFERRED: only moduleSource generation (nothing reads the .ts file immediately) ===
      let managedRules = export.managedRules
      DispatchQueue.global(qos: .utility).async {
        let bgStart = CFAbsoluteTimeGetCurrent()
        autoreleasepool {
          let moduleSource = Karabiner2Exporter.generateModuleSource(managedRules: managedRules)
          do {
            try service.writeRepoFiles(repoModuleSource: moduleSource)
          } catch {
            debugLog("[Karabiner2InputMethod] Background: failed to write repo files: \(error)")
          }
        }
        debugLog("[Benchmark] kar background work (moduleSource): \(String(format: "%.0f", (CFAbsoluteTimeGetCurrent() - bgStart) * 1000))ms")
      }
    } catch {
      lastKarabinerTsExportError = error.localizedDescription
      debugLog("[Karabiner2InputMethod] Failed to export via karabiner.ts: \(error)")
    }
  }

  private func saveStateMappings(_ stateMappings: [Karabiner2Exporter.StateMapping], outputDir: String) throws {
    let mappingFilePath = outputDir + "/leaderkey-state-mappings.json"
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let mappingData = try encoder.encode(stateMappings)
    try mappingData.write(to: URL(fileURLWithPath: mappingFilePath))
    debugLog("[Karabiner2InputMethod] Exported \(stateMappings.count) state mappings to \(mappingFilePath)")
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

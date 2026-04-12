import AppKit
import Darwin
import Foundation

enum URLPlaceholderExpander {
  private static let frontmostBundleIdPlaceholder = "{frontmostBundleId}"
  private static let encodedFrontmostBundleIdPlaceholder = "%7BfrontmostBundleId%7D"
  
  enum ExpansionError: LocalizedError {
    case unresolved(String)
    
    var errorDescription: String? {
      switch self {
      case .unresolved(let message):
        return message
      }
    }
  }

  static func expand(_ rawValue: String, preferredFrontmostBundleId: String? = nil) -> Result<String, ExpansionError> {
    guard rawValue.contains(frontmostBundleIdPlaceholder)
        || rawValue.localizedCaseInsensitiveContains(encodedFrontmostBundleIdPlaceholder) else {
      return .success(rawValue)
    }

    guard let bundleId = resolvedFrontmostBundleId(preferred: preferredFrontmostBundleId) else {
      return .failure(.unresolved("Could not resolve {frontmostBundleId} for URL: \(rawValue)"))
    }

    let expanded = rawValue
      .replacingOccurrences(of: frontmostBundleIdPlaceholder, with: bundleId)
      .replacingOccurrences(of: encodedFrontmostBundleIdPlaceholder, with: bundleId)
      .replacingOccurrences(of: encodedFrontmostBundleIdPlaceholder.lowercased(), with: bundleId)

    return .success(expanded)
  }

  private static func resolvedFrontmostBundleId(preferred: String?) -> String? {
    if let sanitizedPreferred = sanitizeBundleId(preferred) {
      return sanitizedPreferred
    }

    return sanitizeBundleId(NSWorkspace.shared.frontmostApplication?.bundleIdentifier)
  }

  private static func sanitizeBundleId(_ value: String?) -> String? {
    guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
          !trimmed.isEmpty,
          trimmed != "__FALLBACK__",
          trimmed != Bundle.main.bundleIdentifier else {
      return nil
    }

    return trimmed
  }
}

final class KarabinerUserCommandReceiver {
  private struct MenuInventoryItem: Encodable {
    let appName: String
    let enabled: Bool
    let path: String
    let title: String
  }

  private struct MenuInventoryResponse: Encodable {
    let app: String
    let items: [MenuInventoryItem]
  }

  private enum MenuSelectionResult {
    case success
    case notFound(String)
    case pressFailed(String)
  }

  private let receiverQueue = DispatchQueue(label: "com.leaderkey.usercommand.receiver")
  private var socketHandle: Int32 = -1
  private var readSource: DispatchSourceRead?
  private var recvBuffer = [UInt8](repeating: 0, count: 32 * 1024)  // Reusable receive buffer

  weak var delegate: UnixSocketServerDelegate?
  private(set) var isRunning = false

  var socketPath: String {
    Self.defaultSocketPath()
  }

  func start() -> Bool {
    guard !isRunning else { return true }

    unlink(socketPath)

    let fd = socket(AF_UNIX, SOCK_DGRAM, 0)
    guard fd >= 0 else {
      debugLog("[KarabinerUserCommandReceiver] socket(dgram) failed: \(String(cString: strerror(errno)))")
      return false
    }

    guard var addr = makeSockaddrUn(for: socketPath) else {
      close(fd)
      unlink(socketPath)
      return false
    }

    var receiveBufferBytes = 128 * 1024
    _ = setsockopt(
      fd,
      SOL_SOCKET,
      SO_RCVBUF,
      &receiveBufferBytes,
      socklen_t(MemoryLayout.size(ofValue: receiveBufferBytes)))

    let bindResult = withUnsafePointer(to: &addr) { addrPtr in
      addrPtr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPtr in
        bind(fd, sockaddrPtr, socklen_t(MemoryLayout<sockaddr_un>.size))
      }
    }

    guard bindResult == 0 else {
      debugLog(
        "[KarabinerUserCommandReceiver] bind(dgram) failed: \(String(cString: strerror(errno))) path=\(socketPath)")
      close(fd)
      unlink(socketPath)
      return false
    }

    socketHandle = fd
    let source = DispatchSource.makeReadSource(fileDescriptor: fd, queue: receiverQueue)
    source.setEventHandler { [weak self] in
      self?.receiveDatagram()
    }
    source.setCancelHandler { [weak self] in
      guard let self else { return }
      if self.socketHandle >= 0 {
        close(self.socketHandle)
        self.socketHandle = -1
      }
      unlink(self.socketPath)
    }
    readSource = source
    source.resume()

    isRunning = true
    debugLog("[KarabinerUserCommandReceiver] Listening on \(socketPath)")
    return true
  }

  func stop() {
    guard isRunning else { return }

    readSource?.cancel()
    readSource = nil
    if socketHandle >= 0 {
      close(socketHandle)
      socketHandle = -1
    }
    unlink(socketPath)
    isRunning = false
    debugLog("[KarabinerUserCommandReceiver] Stopped")
  }

  private func receiveDatagram() {
    guard socketHandle >= 0 else { return }

    let bytesRead = recvfrom(socketHandle, &recvBuffer, recvBuffer.count, 0, nil, nil)
    guard bytesRead > 0 else { return }

    var endIndex = Int(bytesRead)
    if endIndex > 0 && recvBuffer[endIndex - 1] == 0x0A { endIndex -= 1 }
    if endIndex > 0 && recvBuffer[endIndex - 1] == 0x0D { endIndex -= 1 }
    guard endIndex > 0 else { return }

    let data = Data(recvBuffer[0..<endIndex])
    do {
      let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
      handleIncomingPayload(json)
    } catch {
      debugLog("[KarabinerUserCommandReceiver] Failed to decode datagram JSON: \(error)")
    }
  }

  private func handleIncomingPayload(_ payload: Any) {
    // Handle v1 structured payloads — forward to seqd or handle locally
    if let dict = payload as? [String: Any],
       let type = dict["type"] as? String {
      handleV1Payload(type: type, dict: dict)
      return
    }

    guard let command = KarabinerCommandRouter.normalizeSendUserCommandPayload(payload) else {
      debugLog("[KarabinerUserCommandReceiver] Ignoring unsupported payload: \(payload)")
      return
    }

    let response = KarabinerCommandRouter.route(command: command, delegate: delegate)
    if response != "OK" && !response.hasPrefix("{") {
      debugLog("[KarabinerUserCommandReceiver] Command '\(command)' failed: \(response)")
    }
  }

  private func handleV1Payload(type: String, dict: [String: Any]) {
    switch type {
    case "open_app":
      guard let app = dict["app"] as? String else {
        debugLog("[KarabinerUserCommandReceiver] v1 open_app missing 'app'")
        return
      }
      openApp(app)

    case "open_app_toggle":
      guard let app = dict["app"] as? String else {
        debugLog("[KarabinerUserCommandReceiver] v1 open_app_toggle missing 'app'")
        return
      }
      openAppToggle(app)

    case "open":
      guard let target = dict["target"] as? String else {
        debugLog("[KarabinerUserCommandReceiver] v1 open missing 'target'")
        return
      }
      let expandedTarget: String
      switch URLPlaceholderExpander.expand(target) {
      case .success(let value):
        expandedTarget = value
      case .failure(let error):
        debugLog("[KarabinerUserCommandReceiver] v1 open: \(error.localizedDescription)")
        return
      }
      guard let url = URL(string: expandedTarget) else {
        debugLog("[KarabinerUserCommandReceiver] v1 open: invalid URL '\(expandedTarget)'")
        return
      }
      let background = dict["background"] as? Bool ?? false
      DispatchQueue.main.async {
        let config = NSWorkspace.OpenConfiguration()
        config.activates = !background
        NSWorkspace.shared.open(url, configuration: config)
      }

    case "open_with_app":
      guard let app = dict["app"] as? String, let target = dict["target"] as? String else {
        debugLog("[KarabinerUserCommandReceiver] v1 open_with_app missing 'app' or 'target'")
        return
      }
      openWithApp(appPath: app, target: target)

    case "menu":
      guard let app = dict["app"] as? String, let path = dict["path"] as? String else {
        debugLog("[KarabinerUserCommandReceiver] v1 menu missing 'app' or 'path'")
        return
      }
      let fallbackPaths = (dict["fallbackPaths"] as? [String])?
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty } ?? []
      Self.selectMenuItemImpl(app: app, path: path, fallbackPaths: fallbackPaths)

    case "intellij":
      guard let action = dict["action"] as? String else {
        debugLog("[KarabinerUserCommandReceiver] v1 intellij missing 'action'")
        return
      }
      let delay = dict["delay"] as? Int
      KarabinerUserCommandReceiver.sendToIntelliJSocket(action: action, delay: delay)

    case "keystroke":
      guard let spec = dict["spec"] as? String else {
        debugLog("[KarabinerUserCommandReceiver] v1 keystroke missing 'spec'")
        return
      }
      let app = dict["app"] as? String
      let focus = dict["focus"] as? Bool ?? false
      KarabinerUserCommandReceiver.sendKeystroke(app: app, spec: spec, focusApp: focus)

    default:
      debugLog("[KarabinerUserCommandReceiver] Unknown v1 type: \(type)")
    }
  }

  // MARK: - Native app management

  private struct AppCacheEntry {
    var url: URL?
    var bundleId: String?
    var pid: pid_t?
  }

  private struct RunningAppLookup {
    let runningApp: NSRunningApplication
    let strategy: String
  }

  /// Cache: app string → resolved metadata for fast repeated lookup.
  private static var appCache: [String: AppCacheEntry] = [:]
  private static let appCacheLock = NSLock()

  private static func appCacheEntry(for app: String) -> AppCacheEntry? {
    appCacheLock.lock()
    defer { appCacheLock.unlock() }
    return appCache[app]
  }

  private static func updateAppCache(_ app: String, mutate: (inout AppCacheEntry) -> Void) {
    appCacheLock.lock()
    defer { appCacheLock.unlock() }

    var entry = appCache[app] ?? AppCacheEntry()
    mutate(&entry)
    appCache[app] = entry
  }

  private static func normalizedAppName(_ app: String) -> String {
    (app as NSString)
      .lastPathComponent
      .replacingOccurrences(of: ".app", with: "")
  }

  private static func normalizedBundleURL(_ url: URL) -> URL {
    url.resolvingSymlinksInPath().standardizedFileURL
  }

  static func metadataMatchesResolvedApp(
    bundleURL: URL?,
    bundleId: String?,
    resolvedURL: URL,
    resolvedBundleId: String
  ) -> Bool {
    if let bundleId, bundleId == resolvedBundleId {
      return true
    }

    if let bundleURL {
      return normalizedBundleURL(bundleURL) == normalizedBundleURL(resolvedURL)
    }

    return false
  }

  private static func updateCacheFromRunningApp(
    _ app: String,
    runningApp: NSRunningApplication,
    resolved: (url: URL, bundleId: String)? = nil
  ) {
    updateAppCache(app) { entry in
      if let resolved {
        entry.url = resolved.url
        entry.bundleId = resolved.bundleId
      } else if let bundleURL = runningApp.bundleURL {
        entry.url = bundleURL
      }
      if resolved == nil, let bundleIdentifier = runningApp.bundleIdentifier {
        entry.bundleId = bundleIdentifier
      }
      entry.pid = runningApp.processIdentifier
    }
  }

  private static func isValidCachedPID(
    _ runningApp: NSRunningApplication,
    resolved: (url: URL, bundleId: String)?,
    cachedBundleId: String?,
    expectedAppName: String
  ) -> Bool {
    if let resolved {
      return metadataMatchesResolvedApp(
        bundleURL: runningApp.bundleURL,
        bundleId: runningApp.bundleIdentifier,
        resolvedURL: resolved.url,
        resolvedBundleId: resolved.bundleId)
    }

    if let cachedBundleId, !cachedBundleId.isEmpty {
      return runningApp.bundleIdentifier == cachedBundleId
    }

    return runningApp.localizedName == expectedAppName
  }

  private static func resolveApp(_ app: String) -> (url: URL, bundleId: String)? {
    guard let url = resolveAppURL(app) else { return nil }
    guard let bundle = Bundle(url: url),
          let bundleId = bundle.bundleIdentifier else { return nil }

    if let cached = appCacheEntry(for: app) {
      let cacheMatches = metadataMatchesResolvedApp(
        bundleURL: cached.url,
        bundleId: cached.bundleId,
        resolvedURL: url,
        resolvedBundleId: bundleId)
      if !cacheMatches {
        debugLog(
          "[KarabinerUserCommandReceiver] app: refreshing stale cache for '\(app)' cachedBundleId=\(cached.bundleId ?? "nil") resolvedBundleId=\(bundleId)"
        )
      }
    }

    updateAppCache(app) { entry in
      let cachedURL = entry.url
      let cachedBundleId = entry.bundleId

      entry.url = url
      entry.bundleId = bundleId
      if let existingPID = entry.pid,
         existingPID > 0,
         !metadataMatchesResolvedApp(
           bundleURL: cachedURL,
           bundleId: cachedBundleId,
           resolvedURL: url,
           resolvedBundleId: bundleId)
      {
        entry.pid = 0
      }
    }

    return (url: url, bundleId: bundleId)
  }

  private static func resolveAppURL(_ app: String) -> URL? {
    // Full path (e.g. /Applications/Safari.app)
    if app.contains("/") {
      let url = URL(fileURLWithPath: app)
      if FileManager.default.fileExists(atPath: app) { return url }
      return nil
    }
    // App name — search standard locations
    for dir in ["/Applications", "/System/Applications", "/System/Applications/Utilities",
                NSString("~/Applications").expandingTildeInPath] {
      let path = "\(dir)/\(app).app"
      if FileManager.default.fileExists(atPath: path) {
        return URL(fileURLWithPath: path)
      }
    }
    return nil
  }

  /// Find a running app using seq-style lookup order: cached PID, cached bundle ID, then name scan.
  private static func findRunningAppLookup(_ app: String) -> RunningAppLookup? {
    let expectedAppName = normalizedAppName(app)
    let resolved = resolveApp(app)
    let cached = appCacheEntry(for: app)

    // Cache the running apps list to avoid multiple expensive system calls
    let allRunningApps = NSWorkspace.shared.runningApplications

    if let cachedPID = cached?.pid,
       cachedPID > 0,
       let runningApp = allRunningApps.first(where: {
         $0.processIdentifier == cachedPID
       }),
       isValidCachedPID(
         runningApp,
         resolved: resolved,
         cachedBundleId: cached?.bundleId,
         expectedAppName: expectedAppName)
    {
      updateCacheFromRunningApp(app, runningApp: runningApp, resolved: resolved)
      return RunningAppLookup(runningApp: runningApp, strategy: "cached_pid")
    }

    if let resolved,
       let runningApp = NSRunningApplication.runningApplications(withBundleIdentifier: resolved.bundleId).first {
      updateCacheFromRunningApp(app, runningApp: runningApp, resolved: resolved)
      return RunningAppLookup(runningApp: runningApp, strategy: "cached_bundle")
    }

    if let resolved,
       let runningApp = allRunningApps.first(where: {
         $0.localizedName == expectedAppName
           && metadataMatchesResolvedApp(
             bundleURL: $0.bundleURL,
             bundleId: $0.bundleIdentifier,
             resolvedURL: resolved.url,
             resolvedBundleId: resolved.bundleId)
       })
    {
      updateCacheFromRunningApp(app, runningApp: runningApp, resolved: resolved)
      return RunningAppLookup(runningApp: runningApp, strategy: "name_scan")
    }

    if resolved == nil,
       let runningApp = allRunningApps.first(where: { $0.localizedName == expectedAppName }) {
      updateCacheFromRunningApp(app, runningApp: runningApp)
      return RunningAppLookup(runningApp: runningApp, strategy: "name_scan")
    }

    return nil
  }

  private static func findRunningApp(_ app: String) -> NSRunningApplication? {
    findRunningAppLookup(app)?.runningApp
  }

  static func openAppDirectly(_ app: String) {
    openAppImpl(app, toggle: false)
  }

  static func openAppToggleDirectly(_ app: String) {
    openAppImpl(app, toggle: true)
  }

  private func openApp(_ app: String) {
    Self.openAppImpl(app, toggle: false)
  }

  private func openAppToggle(_ app: String) {
    Self.openAppImpl(app, toggle: true)
  }

  private static func openAppImpl(_ app: String, toggle: Bool) {
    guard let resolved = Self.resolveApp(app) else {
      let actionName = toggle ? "open_app_toggle" : "open_app"
      debugLog("[KarabinerUserCommandReceiver] v1 \(actionName): cannot resolve '\(app)'")
      return
    }

    ThreadOptimization.executeOnMain {
      if let lookup = Self.findRunningAppLookup(app) {
        let running = lookup.runningApp

        if toggle && running.isActive {
          running.hide()
          debugLog("[KarabinerUserCommandReceiver] app: hid '\(app)' mode=\(lookup.strategy)")
          return
        }

        if Self.shouldCheckForReopen(running) && Self.runningAppNeedsReopen(running) {
          let launchMethod = launchApp(resolved)
          let action = toggle ? "open_app_toggle" : "open_app"
          debugLog(
            "[KarabinerUserCommandReceiver] \(action): reopened '\(app)' mode=\(lookup.strategy) reason=no_regular_window via \(launchMethod)"
          )
          return
        }

        if Self.activateRunningApp(running) {
          let action = toggle ? "open_app_toggle" : "open_app"
          debugLog("[KarabinerUserCommandReceiver] \(action): activated '\(app)' mode=\(lookup.strategy)")
          return
        }

        debugLog(
          "[KarabinerUserCommandReceiver] app: activation failed for '\(app)' mode=\(lookup.strategy), falling back to launch"
        )
      }

      let launchMethod = launchApp(resolved)
      let action = toggle ? "open_app_toggle" : "open_app"
      debugLog("[KarabinerUserCommandReceiver] \(action): launched '\(app)' via \(launchMethod)")
    }
  }

  private static func activateRunningApp(_ runningApp: NSRunningApplication) -> Bool {
    runningApp.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
  }

  private static func shouldCheckForReopen(_ runningApp: NSRunningApplication) -> Bool {
    // The expensive window-state check is only needed when the target app is already
    // active. That is the case where activate() can be a no-op while the app still
    // owns the menu bar but has no visible windows, as with Messages after Cmd+W.
    runningApp.isActive
  }

  static func runningAppHasRegularWindow(pid: pid_t, windowList: [[String: Any]]) -> Bool {
    let targetPID = Int(pid)

    return windowList.contains { windowInfo in
      guard let ownerPID = (windowInfo[kCGWindowOwnerPID as String] as? NSNumber)?.intValue,
            ownerPID == targetPID else {
        return false
      }

      let layer = (windowInfo[kCGWindowLayer as String] as? NSNumber)?.intValue ?? 0
      guard layer == 0 else { return false }

      guard let bounds = windowInfo[kCGWindowBounds as String] as? [String: Any] else {
        return true
      }

      let width = (bounds["Width"] as? NSNumber)?.doubleValue ?? 0
      let height = (bounds["Height"] as? NSNumber)?.doubleValue ?? 0
      return width > 1 && height > 1
    }
  }

  private static func runningAppHasUsableAXWindow(pid: pid_t) -> Bool? {
    let appElement = AXUIElementCreateApplication(pid)
    var windowsRef: CFTypeRef?
    let error = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsRef)

    guard error == .success else {
      debugLog(
        "[KarabinerUserCommandReceiver] app: AX window lookup failed for pid=\(pid) error=\(error.rawValue)"
      )
      return nil
    }

    guard let windows = windowsRef as? [AXUIElement] else { return false }

    return windows.contains { window in
      if let role = axGetString(window, attr: kAXRoleAttribute), role != kAXWindowRole as String {
        return false
      }

      if let size = axGetSize(window, attr: kAXSizeAttribute),
         size.width <= 1 || size.height <= 1 {
        return false
      }

      return true
    }
  }

  private static func runningAppNeedsReopen(_ runningApp: NSRunningApplication) -> Bool {
    if let hasAXWindow = runningAppHasUsableAXWindow(pid: runningApp.processIdentifier) {
      return !hasAXWindow
    }

    let options: CGWindowListOption = [.optionAll, .excludeDesktopElements]
    guard let windowList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
      // If window inspection fails, preserve the reported Messages case where the app
      // stays frontmost after closing its last window.
      return runningApp.isActive
    }

    return !runningAppHasRegularWindow(pid: runningApp.processIdentifier, windowList: windowList)
  }

  static func openLaunchArguments(forBundleIdentifier bundleId: String) -> [String] {
    ["-b", bundleId]
  }

  private static func launchApp(_ resolved: (url: URL, bundleId: String)) -> String {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
    task.arguments = openLaunchArguments(forBundleIdentifier: resolved.bundleId)

    let stderrPipe = Pipe()
    task.standardError = stderrPipe

    do {
      try task.run()
      task.waitUntilExit()
      if task.terminationStatus == 0 {
        return "open-bundle-id"
      }

      let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
      let stderrMessage = String(data: stderrData, encoding: .utf8)?
        .trimmingCharacters(in: .whitespacesAndNewlines)
      let details: String
      if let stderrMessage, !stderrMessage.isEmpty {
        details = ": \(stderrMessage)"
      } else {
        details = ""
      }
      debugLog(
        "[KarabinerUserCommandReceiver] app: open exited \(task.terminationStatus) for bundle '\(resolved.bundleId)'\(details)"
      )
    } catch {
      debugLog("[KarabinerUserCommandReceiver] app: failed to launch bundle '\(resolved.bundleId)' via open: \(error)")
    }

    let config = NSWorkspace.OpenConfiguration()
    NSWorkspace.shared.openApplication(at: resolved.url, configuration: config)
    return "NSWorkspace"
  }

  private func openWithApp(appPath: String, target: String) {
    guard let resolved = Self.resolveApp(appPath) else {
      debugLog("[KarabinerUserCommandReceiver] v1 open_with_app: cannot resolve app '\(appPath)'")
      return
    }
    let targetURL: URL
    if target.contains("://") {
      guard let url = URL(string: target) else {
        debugLog("[KarabinerUserCommandReceiver] v1 open_with_app: invalid URL '\(target)'")
        return
      }
      targetURL = url
    } else {
      targetURL = URL(fileURLWithPath: target)
    }
    DispatchQueue.main.async {
      let config = NSWorkspace.OpenConfiguration()
      NSWorkspace.shared.open([targetURL], withApplicationAt: resolved.url, configuration: config)
    }
  }

  // MARK: - Menu item selection (AX API)

  /// Public entry point for direct calls (e.g. from Controller)
  static func selectMenuItemDirectly(app appName: String, path: String, fallbackPaths: [String] = []) {
    selectMenuItemImpl(app: appName, path: path, fallbackPaths: fallbackPaths)
  }

  static func listMenuItemsJSON(app appName: String) -> String {
    guard let running = Self.findRunningApp(appName) else {
      return "ERROR: App not running: \(appName)"
    }

    let appElement = AXUIElementCreateApplication(running.processIdentifier)
    var menuBarRef: CFTypeRef?
    let err = AXUIElementCopyAttributeValue(appElement, kAXMenuBarAttribute as CFString, &menuBarRef)
    guard err == .success, let menuBarRef else {
      return "ERROR: No menu bar for \(appName) (AXError \(err.rawValue))"
    }
    let menuBar = unsafeBitCast(menuBarRef, to: AXUIElement.self)

    var seenPaths = Set<String>()
    var items: [MenuInventoryItem] = []
    _ = Self.collectLeafMenuItems(
      from: menuBar,
      appName: appName,
      currentPath: [],
      results: &items,
      seenPaths: &seenPaths)
    items.sort { $0.path.localizedCaseInsensitiveCompare($1.path) == .orderedAscending }

    let response = MenuInventoryResponse(app: appName, items: items)
    let encoder = JSONEncoder()
    guard let data = try? encoder.encode(response),
          let json = String(data: data, encoding: .utf8) else {
      return "ERROR: Failed to encode menu inventory"
    }

    return json
  }

  private func selectMenuItem(app appName: String, path: String) {
    Self.selectMenuItemImpl(app: appName, path: path, fallbackPaths: [])
  }

  private static func selectMenuItemImpl(app appName: String, path: String, fallbackPaths: [String]) {
    guard let running = Self.findRunningApp(appName) else {
      debugLog("[menu] app not running: \(appName)")
      return
    }

    DispatchQueue.global(qos: .userInitiated).async {
      let appElement = AXUIElementCreateApplication(running.processIdentifier)

      var menuBarRef: CFTypeRef?
      let err = AXUIElementCopyAttributeValue(appElement, kAXMenuBarAttribute as CFString, &menuBarRef)
      guard err == .success, let menuBarRef else {
        debugLog("[menu] no menu bar for \(appName) (AXError \(err.rawValue))")
        return
      }
      let menuBar = unsafeBitCast(menuBarRef, to: AXUIElement.self)

      for (index, candidatePath) in ([path] + fallbackPaths).enumerated() {
        switch Self.selectMenuItem(menuBar: menuBar, appName: appName, path: candidatePath) {
        case .success:
          if index > 0 {
            debugLog("[menu] ok via fallback[\(index)]: \(appName) > \(candidatePath)")
          }
          return
        case .notFound(let message):
          if index == fallbackPaths.count {
            debugLog(message)
          }
          continue
        case .pressFailed(let message):
          debugLog(message)
          return
        }
      }
    }
  }

  private static func selectMenuItem(menuBar: AXUIElement, appName: String, path: String) -> MenuSelectionResult {
    let parts = Self.splitMenuPath(path)
    guard !parts.isEmpty else {
      return .notFound("[menu] empty path")
    }

    guard let first = Self.axFindDescendant(menuBar, title: parts[0], depth: 6) else {
      let tops = Self.axChildTitles(menuBar)
      return .notFound("[menu] part not found: '\(parts[0])' in [\(tops.joined(separator: ", "))]")
    }

    var current: AXUIElement = first
    for i in 1..<parts.count {
      guard let next = Self.axFindDescendant(current, title: parts[i], depth: 6) else {
        return .notFound("[menu] part not found: '\(parts[i])' for \(appName) > \(path)")
      }
      current = next
    }

    let pressErr = AXUIElementPerformAction(current, kAXPressAction as CFString)
    if pressErr != .success {
      return .pressFailed("[menu] press failed for \(appName) > \(path) (AXError \(pressErr.rawValue))")
    }

    debugLog("[menu] ok: \(appName) > \(path)")
    return .success
  }

  /// Split menu path by ">" or "/" delimiter, trimming whitespace
  private static func splitMenuPath(_ path: String) -> [String] {
    let delimiter: Character
    if path.contains(">") {
      delimiter = ">"
    } else if path.contains("/") {
      delimiter = "/"
    } else {
      return [path.trimmingCharacters(in: .whitespaces)]
    }
    return path.split(separator: delimiter)
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .filter { !$0.isEmpty }
  }

  /// Get title of an AX element (tries kAXTitleAttribute then kAXDescriptionAttribute)
  private static func axGetTitle(_ element: AXUIElement) -> String? {
    for attr in [kAXTitleAttribute, kAXDescriptionAttribute] as [String] {
      var ref: CFTypeRef?
      if AXUIElementCopyAttributeValue(element, attr as CFString, &ref) == .success,
         let str = ref as? String, !str.isEmpty {
        return str
      }
    }
    return nil
  }

  private static func axGetString(_ element: AXUIElement, attr: String) -> String? {
    var ref: CFTypeRef?
    guard AXUIElementCopyAttributeValue(element, attr as CFString, &ref) == .success,
          let str = ref as? String,
          !str.isEmpty else {
      return nil
    }

    return str
  }

  private static func axGetBool(_ element: AXUIElement, attr: String) -> Bool? {
    var ref: CFTypeRef?
    guard AXUIElementCopyAttributeValue(element, attr as CFString, &ref) == .success else {
      return nil
    }

    if let number = ref as? NSNumber {
      return number.boolValue
    }

    return nil
  }

  private static func axGetSize(_ element: AXUIElement, attr: String) -> CGSize? {
    var ref: CFTypeRef?
    guard AXUIElementCopyAttributeValue(element, attr as CFString, &ref) == .success,
          let ref,
          CFGetTypeID(ref) == AXValueGetTypeID() else {
      return nil
    }

    let value = unsafeBitCast(ref, to: AXValue.self)
    guard AXValueGetType(value) == .cgSize else { return nil }

    var size = CGSize.zero
    guard AXValueGetValue(value, .cgSize, &size) else { return nil }
    return size
  }

  /// Find a child element by title (direct children only)
  private static func axChildren(_ parent: AXUIElement) -> [AXUIElement] {
    var childrenRef: CFTypeRef?
    guard AXUIElementCopyAttributeValue(parent, kAXChildrenAttribute as CFString, &childrenRef) == .success,
          let children = childrenRef as? [AXUIElement] else { return [] }
    return children
  }

  private static func axFindChild(_ parent: AXUIElement, title: String) -> AXUIElement? {
    for child in axChildren(parent) {
      if let t = axGetTitle(child), t == title { return child }
    }
    return nil
  }

  /// Find a descendant element by title (bounded depth search, like seq)
  private static func axFindDescendant(_ parent: AXUIElement, title: String, depth: Int) -> AXUIElement? {
    guard depth > 0 else { return nil }
    // Check direct children first
    if let direct = axFindChild(parent, title: title) { return direct }
    // Recurse into children
    for child in axChildren(parent) {
      if let found = axFindDescendant(child, title: title, depth: depth - 1) { return found }
    }
    return nil
  }

  /// Get titles of direct children (for debug logging on failure)
  private static func axChildTitles(_ parent: AXUIElement) -> [String] {
    return axChildren(parent).compactMap { axGetTitle($0) }
  }

  @discardableResult
  private static func collectLeafMenuItems(
    from element: AXUIElement,
    appName: String,
    currentPath: [String],
    results: inout [MenuInventoryItem],
    seenPaths: inout Set<String>
  ) -> Bool {
    let role = axGetString(element, attr: kAXRoleAttribute)
    let rawTitle = axGetTitle(element)?.trimmingCharacters(in: .whitespacesAndNewlines)
    let title = rawTitle?.isEmpty == false ? rawTitle : nil
    let nextPath = (title != nil && role != kAXMenuBarRole as String) ? currentPath + [title!] : currentPath

    var foundLeafInChildren = false
    for child in axChildren(element) {
      if collectLeafMenuItems(
        from: child,
        appName: appName,
        currentPath: nextPath,
        results: &results,
        seenPaths: &seenPaths)
      {
        foundLeafInChildren = true
      }
    }

    let isLeafMenuItem = role == kAXMenuItemRole as String && title != nil && !nextPath.isEmpty && !foundLeafInChildren
    if isLeafMenuItem {
      let path = nextPath.joined(separator: " > ")
      if seenPaths.insert(path).inserted {
        results.append(
          MenuInventoryItem(
            appName: appName,
            enabled: axGetBool(element, attr: kAXEnabledAttribute) ?? true,
            path: path,
            title: title!
          ))
      }
      return true
    }

    return foundLeafInChildren
  }

  private static func defaultSocketPath() -> String {
    "/Library/Application Support/org.pqrs/tmp/user/\(geteuid())/user_command_receiver.sock"
  }

  private func makeSockaddrUn(for path: String) -> sockaddr_un? {
    guard !path.isEmpty else {
      debugLog("[KarabinerUserCommandReceiver] Invalid socket path: empty")
      return nil
    }

    var addr = sockaddr_un()
    addr.sun_family = sa_family_t(AF_UNIX)

    let maxPathLength = MemoryLayout.size(ofValue: addr.sun_path)
    let utf8Length = path.utf8CString.count
    guard utf8Length <= maxPathLength else {
      debugLog("[KarabinerUserCommandReceiver] Invalid socket path (too long): \(path)")
      return nil
    }

    path.withCString { cString in
      withUnsafeMutablePointer(to: &addr.sun_path) { pathPtr in
        pathPtr.withMemoryRebound(to: CChar.self, capacity: maxPathLength) { charPtr in
          strncpy(charPtr, cString, maxPathLength - 1)
          charPtr[maxPathLength - 1] = 0
        }
      }
    }

    return addr
  }

  // MARK: - IntelliJ UDS communication

  private static let intellijSocketPath = "/tmp/intellij-leaderkey.sock"

  /// Send an action to IntelliJ via Unix Domain Socket (fire-and-forget).
  /// Public so Controller can call it directly for the `intellij` action type.
  ///
  /// Value format:
  ///   Single:   "ReformatCode"
  ///   Multiple: "SaveAll,ReformatCode"
  ///   Delay:    "SaveAll,ReformatCode|100"   (100ms between actions)
  static func sendToIntelliJSocket(action: String, delay: Int? = nil) {
    // Parse optional delay suffix: "SaveAll,ReformatCode|100"
    let parts = action.components(separatedBy: "|")
    let actionStr = parts[0]
    let resolvedDelay: Int? = delay ?? (parts.count > 1 ? Int(parts[1].trimmingCharacters(in: .whitespaces)) : nil)

    DispatchQueue.global(qos: .userInitiated).async {
      let fd = socket(AF_UNIX, SOCK_STREAM, 0)
      guard fd >= 0 else {
        debugLog("[KarabinerUserCommandReceiver] intellij: socket() failed")
        return
      }
      defer { close(fd) }

      var addr = sockaddr_un()
      addr.sun_family = sa_family_t(AF_UNIX)
      let path = intellijSocketPath
      let maxLen = MemoryLayout.size(ofValue: addr.sun_path)
      path.withCString { cString in
        withUnsafeMutablePointer(to: &addr.sun_path) { pathPtr in
          pathPtr.withMemoryRebound(to: CChar.self, capacity: maxLen) { charPtr in
            strncpy(charPtr, cString, maxLen - 1)
            charPtr[maxLen - 1] = 0
          }
        }
      }

      let connectResult = withUnsafePointer(to: &addr) { ptr in
        ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockPtr in
          Darwin.connect(fd, sockPtr, socklen_t(MemoryLayout<sockaddr_un>.size))
        }
      }
      guard connectResult == 0 else {
        debugLog("[KarabinerUserCommandReceiver] intellij: connect() failed — is IntelliJ running?")
        return
      }

      // Build JSON payload — same format the IntelliJ UDS server expects
      var json: String
      if actionStr.contains(",") {
        json = "{\"actions\":\"\(actionStr)\""
        if let d = resolvedDelay { json += ",\"delay\":\(d)" }
        json += "}"
      } else {
        json = "{\"action\":\"\(actionStr)\"}"
      }
      json += "\n"

      json.withCString { cString in
        _ = Darwin.write(fd, cString, strlen(cString))
      }

      debugLog("[KarabinerUserCommandReceiver] intellij: sent '\(action)' to \(path)")
    }
  }

  // MARK: - Keystroke simulation (CGEventPostToPid)

  #if DEBUG
    private static func formatTimingMilliseconds(_ nanoseconds: UInt64) -> String {
      String(format: "%.3f", Double(nanoseconds) / 1_000_000)
    }
  #endif

  private static func postKeystroke(
    keyDown: CGEvent, keyUp: CGEvent, to runningApp: NSRunningApplication
  ) -> pid_t {
    let pid = runningApp.processIdentifier
    keyDown.postToPid(pid)
    keyUp.postToPid(pid)
    return pid
  }

  private static func activateRunningAppAsync(_ runningApp: NSRunningApplication) {
    DispatchQueue.main.async {
      _ = activateRunningApp(runningApp)
    }
  }

  /// Send a keystroke to a specific app (by PID) or system-wide.
  /// Uses CGEvent.postToPid for background injection when app is specified.
  static func sendKeystroke(app appName: String?, spec: String, focusApp: Bool = false) {
    guard let (keyCode, flags) = CompactShortcut.parse(spec) else {
      debugLog("[KarabinerUserCommandReceiver] keystroke: invalid spec '\(spec)'")
      return
    }

    guard let source = CGEventSource(stateID: .hidSystemState),
          let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true),
          let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false) else {
      debugLog("[KarabinerUserCommandReceiver] keystroke: failed to create CGEvent")
      return
    }

    keyDown.flags = flags
    keyUp.flags = flags

    #if DEBUG
      let totalStart = DispatchTime.now().uptimeNanoseconds
    #endif

    if let appName = appName {
      #if DEBUG
        let resolveStart = DispatchTime.now().uptimeNanoseconds
      #endif

      if let lookup = findRunningAppLookup(appName) {
        #if DEBUG
          let resolveDuration = DispatchTime.now().uptimeNanoseconds - resolveStart
          let postStart = DispatchTime.now().uptimeNanoseconds
        #endif

        let pid = postKeystroke(keyDown: keyDown, keyUp: keyUp, to: lookup.runningApp)
        if focusApp {
          activateRunningAppAsync(lookup.runningApp)
        }

        #if DEBUG
          let postDuration = DispatchTime.now().uptimeNanoseconds - postStart
          let totalDuration = DispatchTime.now().uptimeNanoseconds - totalStart
          debugLog(
            "[KarabinerUserCommandReceiver] keystroke: sent '\(spec)' to \(appName) (pid \(pid)) mode=\(lookup.strategy) focus=\(focusApp) resolve_ms=\(formatTimingMilliseconds(resolveDuration)) post_ms=\(formatTimingMilliseconds(postDuration)) total_ms=\(formatTimingMilliseconds(totalDuration))"
          )
        #else
          debugLog("[KarabinerUserCommandReceiver] keystroke: sent '\(spec)' to \(appName) (pid \(pid)) focus=\(focusApp)")
        #endif
      } else {
        #if DEBUG
          let resolveDuration = DispatchTime.now().uptimeNanoseconds - resolveStart
          let totalDuration = DispatchTime.now().uptimeNanoseconds - totalStart
          debugLog(
            "[KarabinerUserCommandReceiver] keystroke: app '\(appName)' not running mode=unresolved focus=\(focusApp) resolve_ms=\(formatTimingMilliseconds(resolveDuration)) total_ms=\(formatTimingMilliseconds(totalDuration))"
          )
        #else
          debugLog("[KarabinerUserCommandReceiver] keystroke: app '\(appName)' not running focus=\(focusApp)")
        #endif
      }
    } else {
      #if DEBUG
        let postStart = DispatchTime.now().uptimeNanoseconds
      #endif

      keyDown.post(tap: .cghidEventTap)
      keyUp.post(tap: .cghidEventTap)

      #if DEBUG
        let postDuration = DispatchTime.now().uptimeNanoseconds - postStart
        let totalDuration = DispatchTime.now().uptimeNanoseconds - totalStart
        debugLog(
          "[KarabinerUserCommandReceiver] keystroke: sent '\(spec)' system-wide mode=system_wide post_ms=\(formatTimingMilliseconds(postDuration)) total_ms=\(formatTimingMilliseconds(totalDuration))"
        )
      #else
        debugLog("[KarabinerUserCommandReceiver] keystroke: sent '\(spec)' system-wide")
      #endif
    }
  }
}

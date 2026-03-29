import AppKit
import Darwin
import Foundation

final class KarabinerUserCommandReceiver {
  private let receiverQueue = DispatchQueue(label: "com.leaderkey.usercommand.receiver")
  private var socketHandle: Int32 = -1
  private var readSource: DispatchSourceRead?

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

    var buffer = [UInt8](repeating: 0, count: 32 * 1024)
    let bytesRead = recvfrom(socketHandle, &buffer, buffer.count, 0, nil, nil)
    guard bytesRead > 0 else { return }

    var endIndex = Int(bytesRead)
    if endIndex > 0 && buffer[endIndex - 1] == 0x0A { endIndex -= 1 }
    if endIndex > 0 && buffer[endIndex - 1] == 0x0D { endIndex -= 1 }
    guard endIndex > 0 else { return }

    let data = Data(buffer[0..<endIndex])
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
      guard let url = URL(string: target) else {
        debugLog("[KarabinerUserCommandReceiver] v1 open: invalid URL '\(target)'")
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
      selectMenuItem(app: app, path: path)

    default:
      debugLog("[KarabinerUserCommandReceiver] Unknown v1 type: \(type)")
    }
  }

  // MARK: - Native app management

  /// Cache: app string → (appURL, bundleId). Avoids repeated FileManager + Bundle lookups.
  private static var appCache: [String: (url: URL, bundleId: String)] = [:]

  private static func resolveApp(_ app: String) -> (url: URL, bundleId: String)? {
    if let cached = appCache[app] { return cached }

    guard let url = resolveAppURL(app) else { return nil }
    guard let bundle = Bundle(url: url),
          let bundleId = bundle.bundleIdentifier else { return nil }

    let entry = (url: url, bundleId: bundleId)
    appCache[app] = entry
    return entry
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

  /// Find a running app using cached bundle ID for instant lookup
  private static func findRunningApp(_ app: String) -> NSRunningApplication? {
    if let resolved = resolveApp(app) {
      return NSRunningApplication.runningApplications(withBundleIdentifier: resolved.bundleId).first
    }
    // Fallback: try app name match
    let name = (app as NSString).lastPathComponent.replacingOccurrences(of: ".app", with: "")
    return NSWorkspace.shared.runningApplications.first { $0.localizedName == name }
  }

  private func openApp(_ app: String) {
    guard let resolved = Self.resolveApp(app) else {
      debugLog("[KarabinerUserCommandReceiver] v1 open_app: cannot resolve '\(app)'")
      return
    }
    DispatchQueue.main.async {
      // Fast path: activate directly if already running (cached bundle ID lookup)
      if let running = NSRunningApplication.runningApplications(withBundleIdentifier: resolved.bundleId).first {
        running.activate()
        return
      }
      // Slow path: launch via LaunchServices
      let config = NSWorkspace.OpenConfiguration()
      NSWorkspace.shared.openApplication(at: resolved.url, configuration: config)
    }
  }

  private func openAppToggle(_ app: String) {
    guard let resolved = Self.resolveApp(app) else {
      debugLog("[KarabinerUserCommandReceiver] v1 open_app_toggle: cannot resolve '\(app)'")
      return
    }
    DispatchQueue.main.async {
      if let running = NSRunningApplication.runningApplications(withBundleIdentifier: resolved.bundleId).first {
        if running.isActive {
          running.hide()
        } else {
          running.activate()
        }
      } else {
        let config = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.openApplication(at: resolved.url, configuration: config)
      }
    }
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
  static func selectMenuItemDirectly(app appName: String, path: String) {
    selectMenuItemImpl(app: appName, path: path)
  }

  private func selectMenuItem(app appName: String, path: String) {
    Self.selectMenuItemImpl(app: appName, path: path)
  }

  private static func selectMenuItemImpl(app appName: String, path: String) {
    // Find running app PID — use cache for bundle ID lookup
    let pid: pid_t
    if let running = Self.findRunningApp(appName) {
      pid = running.processIdentifier
    } else {
      // Fallback: match by localized name
      guard let running = NSWorkspace.shared.runningApplications.first(where: { $0.localizedName == appName }) else {
        debugLog("[menu] app not running: \(appName)")
        return
      }
      pid = running.processIdentifier
    }

    // Parse menu path: supports ">" and "/" delimiters
    let parts = Self.splitMenuPath(path)
    guard !parts.isEmpty else {
      debugLog("[menu] empty path")
      return
    }

    DispatchQueue.global(qos: .userInitiated).async {
      let appElement = AXUIElementCreateApplication(pid)

      var menuBarRef: CFTypeRef?
      let err = AXUIElementCopyAttributeValue(appElement, kAXMenuBarAttribute as CFString, &menuBarRef)
      guard err == .success, let menuBar = menuBarRef else {
        debugLog("[menu] no menu bar for \(appName) (AXError \(err.rawValue))")
        return
      }

      // First component: descendant search (depth 6) to handle inconsistent menu structures
      guard let first = Self.axFindDescendant(menuBar as! AXUIElement, title: parts[0], depth: 6) else {
        let tops = Self.axChildTitles(menuBar as! AXUIElement)
        debugLog("[menu] part not found: '\(parts[0])' in [\(tops.joined(separator: ", "))]")
        return
      }

      // Remaining components: descendant search at each level
      var current: AXUIElement = first
      for i in 1..<parts.count {
        guard let next = Self.axFindDescendant(current, title: parts[i], depth: 6) else {
          debugLog("[menu] part not found: '\(parts[i])'")
          return
        }
        current = next
      }

      let pressErr = AXUIElementPerformAction(current, kAXPressAction as CFString)
      if pressErr != .success {
        debugLog("[menu] press failed (AXError \(pressErr.rawValue))")
      } else {
        debugLog("[menu] ok: \(appName) > \(path)")
      }
    }
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

  /// Find a child element by title (direct children only)
  private static func axFindChild(_ parent: AXUIElement, title: String) -> AXUIElement? {
    var childrenRef: CFTypeRef?
    guard AXUIElementCopyAttributeValue(parent, kAXChildrenAttribute as CFString, &childrenRef) == .success,
          let children = childrenRef as? [AXUIElement] else { return nil }
    for child in children {
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
    var childrenRef: CFTypeRef?
    guard AXUIElementCopyAttributeValue(parent, kAXChildrenAttribute as CFString, &childrenRef) == .success,
          let children = childrenRef as? [AXUIElement] else { return nil }
    for child in children {
      if let found = axFindDescendant(child, title: title, depth: depth - 1) { return found }
    }
    return nil
  }

  /// Get titles of direct children (for debug logging on failure)
  private static func axChildTitles(_ parent: AXUIElement) -> [String] {
    var childrenRef: CFTypeRef?
    guard AXUIElementCopyAttributeValue(parent, kAXChildrenAttribute as CFString, &childrenRef) == .success,
          let children = childrenRef as? [AXUIElement] else { return [] }
    return children.compactMap { axGetTitle($0) }
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
}

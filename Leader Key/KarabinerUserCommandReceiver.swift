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

    default:
      debugLog("[KarabinerUserCommandReceiver] Unknown v1 type: \(type)")
    }
  }

  // MARK: - Native app management

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

  private func openApp(_ app: String) {
    guard let appURL = Self.resolveAppURL(app) else {
      debugLog("[KarabinerUserCommandReceiver] v1 open_app: cannot resolve '\(app)'")
      return
    }
    DispatchQueue.main.async {
      let config = NSWorkspace.OpenConfiguration()
      NSWorkspace.shared.openApplication(at: appURL, configuration: config)
    }
  }

  private func openAppToggle(_ app: String) {
    guard let appURL = Self.resolveAppURL(app) else {
      debugLog("[KarabinerUserCommandReceiver] v1 open_app_toggle: cannot resolve '\(app)'")
      return
    }
    DispatchQueue.main.async {
      // If app is frontmost, hide it; otherwise open/activate it
      if let frontApp = NSWorkspace.shared.frontmostApplication,
         frontApp.bundleURL == appURL {
        frontApp.hide()
      } else {
        let config = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.openApplication(at: appURL, configuration: config)
      }
    }
  }

  private func openWithApp(appPath: String, target: String) {
    guard let appURL = Self.resolveAppURL(appPath) else {
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
      NSWorkspace.shared.open([targetURL], withApplicationAt: appURL, configuration: config)
    }
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

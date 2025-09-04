import AppKit
import Foundation

final class UnixSocketServer {
  static let shared = UnixSocketServer()

  private let socketPath = "/tmp/leaderkey.sock"
  private var socketHandle: Int32 = -1
  private var acceptSource: DispatchSourceRead?
  private let queue = DispatchQueue(label: "com.leaderkey.socket", attributes: .concurrent)
  private let keyProcessingQueue = DispatchQueue(
    label: "com.leaderkey.keyprocessing", qos: .userInteractive)

  weak var delegate: UnixSocketServerDelegate?

  private var totalCommands: UInt64 = 0
  private var isRunning = false

  private init() {}

  func start() -> Bool {
    guard !isRunning else {
      debugLog("[UnixSocketServer] Already running")
      return true
    }

    unlink(socketPath)

    socketHandle = socket(AF_UNIX, SOCK_STREAM, 0)
    guard socketHandle >= 0 else {
      debugLog("[UnixSocketServer] Failed to create socket: \(String(cString: strerror(errno)))")
      return false
    }

    var reuseAddr = 1
    setsockopt(
      socketHandle, SOL_SOCKET, SO_REUSEADDR, &reuseAddr,
      socklen_t(MemoryLayout.size(ofValue: reuseAddr)))

    var addr = sockaddr_un()
    addr.sun_family = sa_family_t(AF_UNIX)

    socketPath.withCString { pathCString in
      withUnsafeMutablePointer(to: &addr.sun_path.0) { pathPtr in
        strcpy(pathPtr, pathCString)
      }
    }

    let bindResult = withUnsafePointer(to: &addr) { addrPtr in
      addrPtr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPtr in
        bind(socketHandle, sockaddrPtr, socklen_t(MemoryLayout<sockaddr_un>.size))
      }
    }

    guard bindResult >= 0 else {
      debugLog("[UnixSocketServer] Failed to bind socket: \(String(cString: strerror(errno)))")
      close(socketHandle)
      return false
    }

    guard listen(socketHandle, 5) >= 0 else {
      debugLog("[UnixSocketServer] Failed to listen on socket: \(String(cString: strerror(errno)))")
      close(socketHandle)
      return false
    }

    acceptSource = DispatchSource.makeReadSource(fileDescriptor: socketHandle, queue: queue)
    acceptSource?.setEventHandler { [weak self] in
      self?.acceptConnection()
    }
    acceptSource?.resume()

    isRunning = true
    debugLog("[UnixSocketServer] Started listening on \(socketPath)")
    return true
  }

  func stop() {
    guard isRunning else { return }

    acceptSource?.cancel()
    acceptSource = nil

    if socketHandle >= 0 {
      close(socketHandle)
      socketHandle = -1
    }

    unlink(socketPath)
    isRunning = false
    debugLog("[UnixSocketServer] Stopped")
  }

  private func acceptConnection() {
    var clientAddr = sockaddr_un()
    var clientAddrLen = socklen_t(MemoryLayout<sockaddr_un>.size)

    let clientSocket = withUnsafeMutablePointer(to: &clientAddr) { addrPtr in
      addrPtr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPtr in
        accept(socketHandle, sockaddrPtr, &clientAddrLen)
      }
    }

    guard clientSocket >= 0 else {
      debugLog(
        "[UnixSocketServer] Failed to accept connection: \(String(cString: strerror(errno)))")
      return
    }

    queue.async { [weak self] in
      self?.handleClient(socket: clientSocket)
    }
  }

  private func handleClient(socket: Int32) {
    defer { close(socket) }

    let bufferSize = 1024
    let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferSize)
    defer { buffer.deallocate() }

    let bytesRead = recv(socket, buffer, bufferSize - 1, 0)
    guard bytesRead > 0 else {
      return
    }

    buffer[bytesRead] = 0
    let command = String(cString: buffer).trimmingCharacters(in: .whitespacesAndNewlines)

    totalCommands += 1

    keyProcessingQueue.async { [weak self] in
      self?.processCommand(command, socket: socket)
    }
  }

  private func processCommand(_ command: String, socket: Int32) {
    debugLog("[UnixSocketServer] Received command: \(command)")

    let parts = command.split(separator: " ")
    guard !parts.isEmpty else {
      sendResponse("ERROR: Empty command", to: socket)
      return
    }

    let action = String(parts[0]).lowercased()

    switch action {
    case "activate":
      let bundleId = parts.count > 1 ? String(parts[1]) : nil
      delegate?.unixSocketServerDidReceiveActivation(bundleId: bundleId)
      sendResponse("OK", to: socket)

    case "key":
      guard parts.count > 1 else {
        sendResponse("ERROR: Key command requires keycode", to: socket)
        return
      }

      let keyString = String(parts[1])
      let keyCode: UInt16

      // Try to parse as numeric keycode first
      if let numericKeyCode = UInt16(keyString) {
        keyCode = numericKeyCode
      } else {
        // Otherwise, convert character/string to keycode
        guard let convertedKeyCode = characterToKeyCode(keyString) else {
          sendResponse("ERROR: Invalid key: \(keyString)", to: socket)
          return
        }
        keyCode = convertedKeyCode
      }

      let modifiers = parseModifiers(from: parts.dropFirst(2))
      delegate?.unixSocketServerDidReceiveKey(keyCode, modifiers: modifiers)
      sendResponse("OK", to: socket)

    case "deactivate":
      delegate?.unixSocketServerDidReceiveDeactivation()
      sendResponse("OK", to: socket)

    case "settings":
      delegate?.unixSocketServerDidReceiveSettings()
      sendResponse("OK", to: socket)

    case "sequence":
      guard parts.count > 1 else {
        sendResponse("ERROR: Sequence command requires keys", to: socket)
        return
      }
      let sequence = parts.dropFirst().joined(separator: " ")
      delegate?.unixSocketServerDidReceiveSequence(sequence)
      sendResponse("OK", to: socket)
    
    case "stateid":
      guard parts.count > 1 else {
        sendResponse("ERROR: stateid command requires a state ID", to: socket)
        return
      }
      if parts.count > 1, let stateId = Int32(parts[1]) {
        // Check for optional sticky flag
        let sticky = parts.count > 2 && parts[2].lowercased() == "sticky"
        delegate?.unixSocketServerDidReceiveStateId(stateId, sticky: sticky)
        sendResponse("OK", to: socket)
      } else {
        sendResponse("ERROR: Invalid state ID", to: socket)
      }

    case "state":
      if let state = delegate?.unixSocketServerRequestState() {
        let response = formatState(state)
        sendResponse(response, to: socket)
      } else {
        sendResponse("{\"active\": false}", to: socket)
      }

    case "shake":
      delegate?.unixSocketServerDidReceiveShake()
      sendResponse("OK", to: socket)

    default:
      sendResponse("ERROR: Unknown command: \(action)", to: socket)
    }
  }

  private func characterToKeyCode(_ character: String) -> UInt16? {
    // Handle special keys first
    switch character.lowercased() {
    case "spacebar", "space": return 49
    case "return", "return_or_enter", "enter": return 36
    case "tab": return 48
    case "delete", "delete_or_backspace", "backspace": return 51
    case "escape", "esc": return 53
    case "period", ".": return 47
    case "comma", ",": return 43
    case "semicolon", ";": return 41
    case "slash", "/": return 44
    case "backslash", "\\": return 42
    case "minus", "hyphen", "-": return 27
    case "equal", "equals", "=": return 24
    case "left_bracket", "open_bracket", "[": return 33
    case "right_bracket", "close_bracket", "]": return 30
    case "quote", "'", "\"": return 39
    case "grave", "backtick", "`": return 50
    default:
      break
    }

    // Handle single character
    guard character.count == 1 else { return nil }
    let char = character.lowercased().first!

    // Letter keys
    switch char {
    case "a": return 0
    case "b": return 11
    case "c": return 8
    case "d": return 2
    case "e": return 14
    case "f": return 3
    case "g": return 5
    case "h": return 4
    case "i": return 34
    case "j": return 38
    case "k": return 40
    case "l": return 37
    case "m": return 46
    case "n": return 45
    case "o": return 31
    case "p": return 35
    case "q": return 12
    case "r": return 15
    case "s": return 1
    case "t": return 17
    case "u": return 32
    case "v": return 9
    case "w": return 13
    case "x": return 7
    case "y": return 16
    case "z": return 6

    // Number keys
    case "0": return 29
    case "1": return 18
    case "2": return 19
    case "3": return 20
    case "4": return 21
    case "5": return 23
    case "6": return 22
    case "7": return 26
    case "8": return 28
    case "9": return 25

    default:
      return nil
    }
  }

  private func parseModifiers(from parts: ArraySlice<Substring>) -> NSEvent.ModifierFlags {
    var flags = NSEvent.ModifierFlags()
    for part in parts {
      switch part.lowercased() {
      case "cmd", "command":
        flags.insert(.command)
      case "shift":
        flags.insert(.shift)
      case "option", "alt":
        flags.insert(.option)
      case "control", "ctrl":
        flags.insert(.control)
      default:
        break
      }
    }
    return flags
  }

  private func formatState(_ state: [String: Any]) -> String {
    guard let data = try? JSONSerialization.data(withJSONObject: state, options: .prettyPrinted),
      let json = String(data: data, encoding: .utf8)
    else {
      return "{\"error\": \"Failed to serialize state\"}"
    }
    return json
  }

  private func sendResponse(_ response: String, to socket: Int32) {
    response.withCString { cString in
      _ = send(socket, cString, strlen(cString), 0)
    }
  }

  func getStatistics() -> String {
    return """
      Unix Socket Server Statistics:
      - Total Commands: \(totalCommands)
      - Socket Path: \(socketPath)
      - Running: \(isRunning)
      """
  }
}

protocol UnixSocketServerDelegate: AnyObject {
  func unixSocketServerDidReceiveActivation(bundleId: String?)
  func unixSocketServerDidReceiveKey(_ keyCode: UInt16, modifiers: NSEvent.ModifierFlags)
  func unixSocketServerDidReceiveDeactivation()
  func unixSocketServerDidReceiveSettings()
  func unixSocketServerDidReceiveSequence(_ sequence: String)
  func unixSocketServerDidReceiveStateId(_ stateId: Int32, sticky: Bool)
  func unixSocketServerDidReceiveShake()
  func unixSocketServerRequestState() -> [String: Any]
}

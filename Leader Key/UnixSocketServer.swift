import AppKit
import Darwin
import Foundation

final class UnixSocketServer {
  static let shared = UnixSocketServer()

  struct Statistics: Equatable, Sendable {
    let totalCommands: UInt64
    let socketPath: String
    let isRunning: Bool
  }

  private let socketPath: String
  private var socketHandle: Int32 = -1
  private var acceptSource: DispatchSourceRead?
  private let queue = DispatchQueue(label: "com.leaderkey.socket", attributes: .concurrent)
  private let keyProcessingQueue = DispatchQueue(
    label: "com.leaderkey.keyprocessing", qos: .userInteractive)
  private let stateLock = NSLock()

  weak var delegate: UnixSocketServerDelegate?

  private var totalCommands: UInt64 = 0
  private var running = false

  init(socketPath: String = "/tmp/leaderkey.sock") {
    self.socketPath = socketPath
  }

  var isRunning: Bool {
    stateLock.lock()
    defer { stateLock.unlock() }
    return running
  }

  func start() -> Bool {
    stateLock.lock()
    defer { stateLock.unlock() }

    guard !running else {
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
      socketHandle = -1
      return false
    }

    guard listen(socketHandle, 5) >= 0 else {
      debugLog("[UnixSocketServer] Failed to listen on socket: \(String(cString: strerror(errno)))")
      close(socketHandle)
      socketHandle = -1
      return false
    }

    acceptSource = DispatchSource.makeReadSource(fileDescriptor: socketHandle, queue: queue)
    acceptSource?.setEventHandler { [weak self] in
      self?.acceptConnection()
    }
    acceptSource?.resume()

    running = true
    debugLog("[UnixSocketServer] Started listening on \(socketPath)")
    return true
  }

  func stop() {
    stateLock.lock()
    defer { stateLock.unlock() }

    guard running else { return }

    acceptSource?.cancel()
    acceptSource = nil

    if socketHandle >= 0 {
      close(socketHandle)
      socketHandle = -1
    }

    unlink(socketPath)
    running = false
    debugLog("[UnixSocketServer] Stopped")
  }

  private func acceptConnection() {
    var clientAddr = sockaddr_un()
    var clientAddrLen = socklen_t(MemoryLayout<sockaddr_un>.size)

    stateLock.lock()
    let serverSocket = socketHandle
    stateLock.unlock()
    guard serverSocket >= 0 else { return }

    let clientSocket = withUnsafeMutablePointer(to: &clientAddr) { addrPtr in
      addrPtr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPtr in
        accept(serverSocket, sockaddrPtr, &clientAddrLen)
      }
    }

    guard clientSocket >= 0 else {
      debugLog(
        "[UnixSocketServer] Failed to accept connection: \(String(cString: strerror(errno)))")
      return
    }

    disableSigPipe(for: clientSocket)

    queue.async { [weak self] in
      self?.handleClient(socket: clientSocket)
    }
  }

  private func handleClient(socket: Int32) {
    var data = Data()
    var buffer = [UInt8](repeating: 0, count: 4096)

    while true {
      let bufferCount = buffer.count
      let bytesRead = buffer.withUnsafeMutableBytes { rawBuffer -> Int in
        guard let baseAddress = rawBuffer.baseAddress else {
          return -1
        }
        return recv(socket, baseAddress, bufferCount, 0)
      }
      if bytesRead > 0 {
        buffer.withUnsafeBufferPointer { rawBuffer in
          if let baseAddress = rawBuffer.baseAddress {
            data.append(baseAddress, count: bytesRead)
          }
        }
        continue
      }

      if bytesRead == 0 {
        break
      }

      if errno == EINTR {
        continue
      }

      debugLog("[UnixSocketServer] Failed to read command: \(String(cString: strerror(errno)))")
      close(socket)
      return
    }

    guard !data.isEmpty else {
      close(socket)
      return
    }

    let command = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)

    stateLock.lock()
    totalCommands += 1
    stateLock.unlock()

    keyProcessingQueue.async { [weak self] in
      self?.processCommand(command, socket: socket)
      close(socket)
    }
  }

  private func processCommand(_ command: String, socket: Int32) {
    debugLog("[UnixSocketServer] Received command: \(command)")
    let response = KarabinerCommandRouter.route(command: command, delegate: delegate)
    sendResponse(response, to: socket)
  }

  private func sendResponse(_ response: String, to socket: Int32) {
    let bytes = Array(response.utf8)
    var totalSent = 0

    while totalSent < bytes.count {
      let sent = bytes.withUnsafeBytes { rawBuffer -> Int in
        guard let baseAddress = rawBuffer.baseAddress else {
          return -1
        }

        let nextPointer = baseAddress.advanced(by: totalSent)
        return send(socket, nextPointer, bytes.count - totalSent, 0)
      }

      guard sent > 0 else {
        let sendError = errno
        if sendError != EPIPE && sendError != ECONNRESET {
          debugLog("[UnixSocketServer] Failed to send response: \(String(cString: strerror(sendError)))")
        }
        break
      }
      totalSent += sent
    }
  }

  private func disableSigPipe(for socket: Int32) {
    var noSigPipe: Int32 = 1
    let result = setsockopt(
      socket,
      SOL_SOCKET,
      SO_NOSIGPIPE,
      &noSigPipe,
      socklen_t(MemoryLayout.size(ofValue: noSigPipe))
    )

    if result != 0 {
      debugLog("[UnixSocketServer] Failed to disable SIGPIPE: \(String(cString: strerror(errno)))")
    }
  }

  func statisticsSnapshot() -> Statistics {
    stateLock.lock()
    defer { stateLock.unlock() }
    return Statistics(
      totalCommands: totalCommands,
      socketPath: socketPath,
      isRunning: running
    )
  }

  func getStatistics() -> String {
    let statistics = statisticsSnapshot()
    return """
      Unix Socket Server Statistics:
      - Total Commands: \(statistics.totalCommands)
      - Socket Path: \(statistics.socketPath)
      - Running: \(statistics.isRunning)
      """
  }
}

protocol UnixSocketServerDelegate: AnyObject {
  func unixSocketServerDidReceiveActivation(bundleId: String?)
  func unixSocketServerDidReceiveApplyConfig()
  func unixSocketServerDidReceiveGokuProfileSync() -> String
  func unixSocketServerDidReceiveKey(_ keyCode: UInt16, modifiers: NSEvent.ModifierFlags)
  func unixSocketServerDidReceiveDeactivation()
  func unixSocketServerDidReceiveSettings()
  func unixSocketServerDidReceiveSequence(_ sequence: String)
  func unixSocketServerDidReceiveStateId(_ stateId: Int32, sticky: Bool, bundleId: String?)
  func unixSocketServerDidReceiveNormalModeStatus(_ status: StatusItem.NormalModeStatus)
  func unixSocketServerDidReceiveHintOverlay(_ command: HintOverlayCommand)
  func unixSocketServerDidReceiveShake()
  func unixSocketServerRequestState() -> [String: Any]
  func unixSocketServerDidReceiveCommandScoutOpen(bundleId: String, source: String)
  func unixSocketServerDidReceiveShortcutMapOpen(bundleId: String?)
  /// Returns the JSON response written directly to the requesting socket. Must complete synchronously.
  func unixSocketServerDidReceiveDispatchExecute(_ payload: [String: Any]) -> String
}

enum HintOverlayCommand {
  case on
  case off
  case toggle
}

import AppKit
import Darwin
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

    disableSigPipe(for: clientSocket)

    queue.async { [weak self] in
      self?.handleClient(socket: clientSocket)
    }
  }

  private func handleClient(socket: Int32) {
    let bufferSize = 1024
    let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferSize)
    defer { buffer.deallocate() }

    let bytesRead = recv(socket, buffer, bufferSize - 1, 0)
    guard bytesRead > 0 else {
      close(socket)
      return
    }

    buffer[bytesRead] = 0
    let command = String(cString: buffer).trimmingCharacters(in: .whitespacesAndNewlines)

    totalCommands += 1

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
  func unixSocketServerDidReceiveApplyConfig()
  func unixSocketServerDidReceiveGokuProfileSync() -> String
  func unixSocketServerDidReceiveKey(_ keyCode: UInt16, modifiers: NSEvent.ModifierFlags)
  func unixSocketServerDidReceiveDeactivation()
  func unixSocketServerDidReceiveSettings()
  func unixSocketServerDidReceiveSequence(_ sequence: String)
  func unixSocketServerDidReceiveStateId(_ stateId: Int32, sticky: Bool)
  func unixSocketServerDidReceiveNormalModeStatus(active: Bool)
  func unixSocketServerDidReceiveShake()
  func unixSocketServerRequestState() -> [String: Any]
  func unixSocketServerDidReceiveCommandScoutOpen(bundleId: String, source: String)
}

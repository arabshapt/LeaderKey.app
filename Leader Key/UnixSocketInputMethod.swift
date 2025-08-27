import Foundation
import Network

/// Unix socket input method that receives keypresses from Karabiner Elements
final class UnixSocketInputMethod: InputMethod {
    
    weak var delegate: InputMethodDelegate?
    
    private var listener: NWListener?
    private var connections: [NWConnection] = []
    private let queue = DispatchQueue(label: "com.leaderkey.unixsocket", qos: .userInteractive)
    private var isRunning = false
    
    // Socket configuration
    private let socketPath = "/tmp/leaderkey.sock"
    private var messageCount: Int64 = 0
    private var errorCount: Int64 = 0
    private var startTime: Date?
    
    var isActive: Bool {
        return isRunning && listener?.state == .ready
    }
    
    func start() -> Bool {
        guard !isRunning else { return true }
        
        // Clean up any existing socket file
        try? FileManager.default.removeItem(atPath: socketPath)
        
        do {
            // Create Unix domain socket listener
            let parameters = NWParameters()
            parameters.defaultProtocolStack.transportProtocol = NWProtocolTCP.Options()
            parameters.requiredLocalEndpoint = NWEndpoint.unix(path: socketPath)
            
            listener = try NWListener(using: parameters)
            
            // Handle new connections
            listener?.newConnectionHandler = { [weak self] connection in
                self?.handleNewConnection(connection)
            }
            
            // Handle state changes
            listener?.stateUpdateHandler = { [weak self] state in
                self?.handleListenerStateChange(state)
            }
            
            // Start listening
            listener?.start(queue: queue)
            
            isRunning = true
            startTime = Date()
            debugLog("[UnixSocketInputMethod] Started listening on \(socketPath)")
            
            return true
            
        } catch {
            debugLog("[UnixSocketInputMethod] Failed to start: \(error)")
            delegate?.inputMethod(self, didEncounterError: error)
            return false
        }
    }
    
    func stop() {
        guard isRunning else { return }
        
        // Cancel all connections
        for connection in connections {
            connection.cancel()
        }
        connections.removeAll()
        
        // Stop listener
        listener?.cancel()
        listener = nil
        
        // Clean up socket file
        try? FileManager.default.removeItem(atPath: socketPath)
        
        isRunning = false
        debugLog("[UnixSocketInputMethod] Stopped")
    }
    
    func getStatistics() -> String {
        let uptime = startTime.map { Date().timeIntervalSince($0) } ?? 0
        
        return """
        Unix Socket Input Method Statistics:
        - Status: \(isActive ? "Active" : "Inactive")
        - Socket Path: \(socketPath)
        - Active Connections: \(connections.count)
        - Messages Processed: \(messageCount)
        - Errors: \(errorCount)
        - Uptime: \(String(format: "%.1f", uptime))s
        """
    }
    
    // MARK: - Private Methods
    
    private func handleNewConnection(_ connection: NWConnection) {
        debugLog("[UnixSocketInputMethod] New connection established")
        
        connections.append(connection)
        
        // Handle connection state changes
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .cancelled, .failed:
                self?.connections.removeAll(where: { $0 === connection })
                debugLog("[UnixSocketInputMethod] Connection closed")
            default:
                break
            }
        }
        
        // Start receiving messages
        connection.start(queue: queue)
        receiveMessage(from: connection)
    }
    
    private func handleListenerStateChange(_ state: NWListener.State) {
        switch state {
        case .ready:
            debugLog("[UnixSocketInputMethod] Listener ready")
        case .failed(let error):
            debugLog("[UnixSocketInputMethod] Listener failed: \(error)")
            delegate?.inputMethod(self, didEncounterError: error)
            errorCount += 1
        case .cancelled:
            debugLog("[UnixSocketInputMethod] Listener cancelled")
        default:
            break
        }
    }
    
    private func receiveMessage(from connection: NWConnection) {
        // Receive data with length prefix (4 bytes for message length)
        connection.receive(minimumIncompleteLength: 4, maximumLength: 4) { [weak self] lengthData, _, isComplete, error in
            guard let self = self else { return }
            
            if let error = error {
                debugLog("[UnixSocketInputMethod] Error receiving length: \(error)")
                self.errorCount += 1
                return
            }
            
            guard let lengthData = lengthData, lengthData.count == 4 else {
                if isComplete {
                    // Connection closed normally
                    self.connections.removeAll(where: { $0 === connection })
                    return
                }
                debugLog("[UnixSocketInputMethod] Invalid length data")
                self.errorCount += 1
                return
            }
            
            // Parse message length (big endian)
            let messageLength = lengthData.withUnsafeBytes { bytes in
                UInt32(bigEndian: bytes.load(as: UInt32.self))
            }
            
            // Receive the actual message
            connection.receive(minimumIncompleteLength: Int(messageLength), maximumLength: Int(messageLength)) { messageData, _, isComplete, error in
                if let error = error {
                    debugLog("[UnixSocketInputMethod] Error receiving message: \(error)")
                    self.errorCount += 1
                    return
                }
                
                guard let messageData = messageData else {
                    if isComplete {
                        self.connections.removeAll(where: { $0 === connection })
                        return
                    }
                    debugLog("[UnixSocketInputMethod] No message data")
                    self.errorCount += 1
                    return
                }
                
                // Process the message
                self.processReceivedData(messageData, from: connection)
                
                // Continue receiving if connection is still active
                if !isComplete {
                    self.receiveMessage(from: connection)
                }
            }
        }
    }
    
    private func processReceivedData(_ data: Data, from connection: NWConnection) {
        do {
            // Parse JSON message
            let message = try JSONDecoder().decode(UnixSocketMessage.self, from: data)
            messageCount += 1
            
            debugLog("[UnixSocketInputMethod] Received message: \(message.type)")
            
            // Send response back to Karabiner
            let response = handleMessage(message)
            sendResponse(response, to: connection)
            
        } catch {
            debugLog("[UnixSocketInputMethod] Failed to parse message: \(error)")
            errorCount += 1
            
            let errorResponse = UnixSocketResponse(
                status: "error",
                message: "Failed to parse JSON: \(error.localizedDescription)"
            )
            sendResponse(errorResponse, to: connection)
        }
    }
    
    private func handleMessage(_ message: UnixSocketMessage) -> UnixSocketResponse {
        switch message.type {
        case .activate:
            // Activation signal from Karabiner - LeaderKey should show
            debugLog("[UnixSocketInputMethod] Received activation signal")
            
            // Notify delegate to show the LeaderKey window
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.inputMethodDidRequestActivation(self)
            }
            
            return UnixSocketResponse(status: "ok", message: "activated")
            
        case .deactivate:
            // Deactivation signal - LeaderKey should hide
            debugLog("[UnixSocketInputMethod] Received deactivation signal")
            delegate?.inputMethodDidReceiveEscape(self)
            return UnixSocketResponse(status: "ok", message: "deactivated")
            
        case .escape:
            // ESC key pressed
            debugLog("[UnixSocketInputMethod] ESC received")
            delegate?.inputMethodDidReceiveEscape(self)
            return UnixSocketResponse(status: "ok", message: "escape_handled")
            
        case .keydown:
            // Key press event
            guard let inputEvent = message.toInputEvent() else {
                return UnixSocketResponse(status: "error", message: "Invalid key event")
            }
            
            // Check for ESC key code (53)
            if inputEvent.keyCode == 53 {
                delegate?.inputMethodDidReceiveEscape(self)
            } else {
                // Dispatch on main thread for UI updates
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.inputMethod(self, didReceiveKeyDown: inputEvent)
                }
            }
            
            return UnixSocketResponse(status: "ok", message: "key_processed")
            
        case .keyup:
            // Key release event
            guard let inputEvent = message.toInputEvent() else {
                return UnixSocketResponse(status: "error", message: "Invalid key event")
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.inputMethod(self, didReceiveKeyUp: inputEvent)
            }
            
            return UnixSocketResponse(status: "ok", message: "key_processed")
            
        case .flagsChanged:
            // Modifier keys changed
            guard let inputEvent = message.toInputEvent() else {
                return UnixSocketResponse(status: "error", message: "Invalid flags event")
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.inputMethod(self, didReceiveFlagsChanged: inputEvent)
            }
            
            return UnixSocketResponse(status: "ok", message: "flags_processed")
        }
    }
    
    private func sendResponse(_ response: UnixSocketResponse, to connection: NWConnection) {
        do {
            let responseData = try JSONEncoder().encode(response)
            
            // Send with length prefix
            var length = UInt32(responseData.count).bigEndian
            let lengthData = Data(bytes: &length, count: 4)
            
            // Send length first
            connection.send(content: lengthData, completion: .contentProcessed { _ in
                // Then send the actual response
                connection.send(content: responseData, completion: .contentProcessed { _ in
                    // Response sent
                })
            })
            
        } catch {
            debugLog("[UnixSocketInputMethod] Failed to send response: \(error)")
            errorCount += 1
        }
    }
    
    deinit {
        stop()
    }
}
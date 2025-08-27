import Foundation

/// Message structure for Unix socket communication with Karabiner
struct UnixSocketMessage: Codable {
    enum MessageType: String, Codable {
        case keydown = "keydown"
        case keyup = "keyup"
        case escape = "escape"
        case activate = "activate"
        case deactivate = "deactivate"
        case flagsChanged = "flags_changed"
    }
    
    let type: MessageType
    let key: String?
    let keyCode: UInt16?
    let modifiers: [String]?
    let timestamp: TimeInterval?
    
    /// Convert to InputEvent
    func toInputEvent() -> InputEvent? {
        guard let keyCode = keyCode else { return nil }
        
        let modifierFlags = ModifierFlags(strings: modifiers ?? [])
        
        return InputEvent(
            keyCode: keyCode,
            key: key,
            modifiers: modifierFlags,
            timestamp: timestamp ?? Date().timeIntervalSince1970,
            source: .unixSocket
        )
    }
}

/// Response message to send back to Karabiner
struct UnixSocketResponse: Codable {
    let status: String  // "ok" or "error"
    let message: String?
}

/// Protocol for Unix socket message handler
protocol UnixSocketMessageHandler {
    func handleMessage(_ message: UnixSocketMessage) -> UnixSocketResponse
}
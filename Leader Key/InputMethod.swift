import Foundation
import CoreGraphics
import AppKit

/// Protocol defining an input method for receiving keyboard events
protocol InputMethod: AnyObject {
    /// Delegate to handle received key events
    var delegate: InputMethodDelegate? { get set }
    
    /// Whether the input method is currently active
    var isActive: Bool { get }
    
    /// Start listening for input events
    func start() -> Bool
    
    /// Stop listening for input events
    func stop()
    
    /// Get statistics or diagnostic information
    func getStatistics() -> String
}

/// Delegate protocol for handling events from an input method
protocol InputMethodDelegate: AnyObject {
    /// Called when a key down event is received
    func inputMethod(_ inputMethod: InputMethod, didReceiveKeyDown event: InputEvent)
    
    /// Called when a key up event is received
    func inputMethod(_ inputMethod: InputMethod, didReceiveKeyUp event: InputEvent)
    
    /// Called when modifier flags change
    func inputMethod(_ inputMethod: InputMethod, didReceiveFlagsChanged event: InputEvent)
    
    /// Called when the input method encounters an error
    func inputMethod(_ inputMethod: InputMethod, didEncounterError error: Error)
    
    /// Called when ESC is pressed to deactivate
    func inputMethodDidReceiveEscape(_ inputMethod: InputMethod)
    
    /// Called when the input method requests LeaderKey window activation
    func inputMethodDidRequestActivation(_ inputMethod: InputMethod)
}

/// Represents an input event from any input method
struct InputEvent {
    let keyCode: UInt16
    let key: String?
    let modifiers: ModifierFlags
    let timestamp: TimeInterval
    let source: InputEventSource
    
    /// Convert to NSEvent.ModifierFlags for compatibility
    var nsModifierFlags: NSEvent.ModifierFlags {
        var flags = NSEvent.ModifierFlags()
        if modifiers.contains(.command) { flags.insert(.command) }
        if modifiers.contains(.shift) { flags.insert(.shift) }
        if modifiers.contains(.option) { flags.insert(.option) }
        if modifiers.contains(.control) { flags.insert(.control) }
        if modifiers.contains(.function) { flags.insert(.function) }
        return flags
    }
}

/// Source of the input event
enum InputEventSource {
    case cgEventTap
    case unixSocket
    case synthetic  // For internally generated events
}

/// Platform-independent modifier flags
struct ModifierFlags: OptionSet {
    let rawValue: UInt32
    
    init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    static let command = ModifierFlags(rawValue: 1 << 0)
    static let shift = ModifierFlags(rawValue: 1 << 1)
    static let option = ModifierFlags(rawValue: 1 << 2)
    static let control = ModifierFlags(rawValue: 1 << 3)
    static let function = ModifierFlags(rawValue: 1 << 4)
    
    /// Create from CGEventFlags
    init(cgEventFlags: CGEventFlags) {
        var flags = ModifierFlags(rawValue: 0)
        if cgEventFlags.contains(.maskCommand) { flags.insert(.command) }
        if cgEventFlags.contains(.maskShift) { flags.insert(.shift) }
        if cgEventFlags.contains(.maskAlternate) { flags.insert(.option) }
        if cgEventFlags.contains(.maskControl) { flags.insert(.control) }
        if cgEventFlags.contains(.maskSecondaryFn) { flags.insert(.function) }
        self = flags
    }
    
    /// Create from string array (for JSON parsing)
    init(strings: [String]) {
        var flags = ModifierFlags(rawValue: 0)
        for str in strings {
            switch str.lowercased() {
            case "cmd", "command": flags.insert(.command)
            case "shift": flags.insert(.shift)
            case "opt", "option", "alt", "alternate": flags.insert(.option)
            case "ctrl", "control": flags.insert(.control)
            case "fn", "function": flags.insert(.function)
            default: break
            }
        }
        self = flags
    }
}
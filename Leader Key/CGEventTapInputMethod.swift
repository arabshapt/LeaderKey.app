import Foundation
import CoreGraphics
import Cocoa

/// Adapter that wraps the existing DualEventTapManager to conform to InputMethod protocol
final class CGEventTapInputMethod: InputMethod {
    
    weak var delegate: InputMethodDelegate?
    private let dualTapManager = DualEventTapManager()
    private var isRunning = false
    
    // Store callback reference to prevent deallocation
    private var callbackUserInfo: Unmanaged<CGEventTapInputMethod>?
    
    var isActive: Bool {
        return isRunning
    }
    
    func start() -> Bool {
        guard !isRunning else { return true }
        
        // Create user info for the callback
        callbackUserInfo = Unmanaged.passUnretained(self)
        
        // Create dual taps with our callback
        let success = dualTapManager.createDualTaps(
            callback: cgEventTapCallback,
            userInfo: callbackUserInfo?.toOpaque()
        )
        
        if success {
            isRunning = true
            debugLog("[CGEventTapInputMethod] Started successfully")
        } else {
            debugLog("[CGEventTapInputMethod] Failed to start")
            callbackUserInfo = nil
        }
        
        return success
    }
    
    func stop() {
        guard isRunning else { return }
        
        dualTapManager.stopDualTaps()
        isRunning = false
        callbackUserInfo = nil
        debugLog("[CGEventTapInputMethod] Stopped")
    }
    
    func getStatistics() -> String {
        return dualTapManager.getStatistics()
    }
    
    /// Process a CGEvent and convert it to InputEvent
    func processCGEvent(_ cgEvent: CGEvent, type: CGEventType) -> Unmanaged<CGEvent>? {
        // Handle tap disabled events
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            debugLog("[CGEventTapInputMethod] Tap disabled - triggering failover")
            dualTapManager.handleInstantFailover()
            return nil
        }
        
        // Get key code and modifiers
        let keyCode = UInt16(cgEvent.getIntegerValueField(.keyboardEventKeycode))
        let modifiers = ModifierFlags(cgEventFlags: cgEvent.flags)
        
        // Get key character if possible (only for keyDown/keyUp events)
        var key: String? = nil
        if (type == .keyDown || type == .keyUp), let nsEvent = NSEvent(cgEvent: cgEvent) {
            key = nsEvent.charactersIgnoringModifiers
        }
        
        // Create InputEvent
        let inputEvent = InputEvent(
            keyCode: keyCode,
            key: key,
            modifiers: modifiers,
            timestamp: Date().timeIntervalSince1970,
            source: .cgEventTap
        )
        
        // Check for ESC key (keyCode 53)
        if keyCode == 53 && type == .keyDown {
            delegate?.inputMethodDidReceiveEscape(self)
            return nil // Consume ESC
        }
        
        // Dispatch to delegate based on event type
        switch type {
        case .keyDown:
            delegate?.inputMethod(self, didReceiveKeyDown: inputEvent)
            return nil // Consume all keyDown events when active
            
        case .keyUp:
            delegate?.inputMethod(self, didReceiveKeyUp: inputEvent)
            return Unmanaged.passRetained(cgEvent) // Pass through key up events
            
        case .flagsChanged:
            delegate?.inputMethod(self, didReceiveFlagsChanged: inputEvent)
            return Unmanaged.passRetained(cgEvent) // Pass through flag changes
            
        default:
            return Unmanaged.passRetained(cgEvent)
        }
    }
    
    deinit {
        stop()
    }
}

// MARK: - C Callback Function

/// Global C callback function for CGEventTap
private func cgEventTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let userInfo = userInfo else {
        return Unmanaged.passRetained(event)
    }
    
    // Get the CGEventTapInputMethod instance
    let inputMethod = Unmanaged<CGEventTapInputMethod>.fromOpaque(userInfo).takeUnretainedValue()
    
    // Process the event through the input method
    return inputMethod.processCGEvent(event, type: type)
}
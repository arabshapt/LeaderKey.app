# Leader Key Technical Insights

## Window Management Philosophy

### Non-Key Window Design
Leader Key's window is intentionally designed to NOT become a key window (`canBecomeKey = false`). This critical design decision ensures:

1. **Raycast Compatibility**: When Leader Key appears, it doesn't steal focus from Raycast's overlay window, allowing both to coexist
2. **Overlay App Compatibility**: Works with Alfred, Spotlight, and other overlay applications without closing them
3. **No Focus Stealing**: The window appears visually but doesn't disrupt the user's current focus context

### Window Ordering Strategy
- Uses `orderFront` instead of `makeKeyAndOrderFront`
- Window becomes visible without becoming key/main
- Preserves the key window state of other applications

## Event Tap Architecture

### Global Event Monitoring
Since the window can't receive keyboard events directly (non-key window), Leader Key relies entirely on a global event tap:
- Monitors all keyboard events system-wide
- Processes events before they reach their target application
- Can consume events (return true) or pass them through (return false)

### Event Tap Resilience
macOS can disable event taps that:
- Take too long to process events (>1 second)
- Experience high CPU load
- Have permission issues

### Safeguards Implemented

1. **Adaptive Health Check**
   - Starts checking every 1 second
   - Backs off to 10 seconds when healthy
   - Immediately returns to 1s checks when problems detected
   - Minimal CPU overhead (just checking a boolean flag)

2. **Automatic Recovery**
   - Re-enables disabled event taps
   - Full restart if re-enable fails
   - Hides stuck windows during recovery

3. **State Recovery Timer** (5 seconds)
   - Detects inconsistent states (window visible but no active sequence)
   - Respects user opacity settings (window can have 0 opacity)
   - Automatically hides stuck windows

4. **Force Reset** (Cmd+Shift+Ctrl+K)
   - Registered as global hotkey (works independently of event tap)
   - Nuclear option that always works
   - Clears all state, hides window, restarts event tap

## Escape Key Handling

### Enhanced Escape Processing
```swift
// Checks multiple conditions to ensure reliable escape
if isWindowVisible || windowAlpha > 0 || hasActiveSequence {
    hide()
    resetSequenceState()
    return true // Consume escape
}
```

### Why Multiple Checks?
- `isWindowVisible`: Normal case
- `windowAlpha > 0`: Window might be transparent but technically visible
- `hasActiveSequence`: State might be active even if window is hidden

## Opacity and Transparency

### User-Configurable Opacity
- Normal mode opacity: 0.0 to 1.0 (default 0.9)
- Sticky mode opacity: 0.0 to 1.0 (default 0.7)
- Users can set opacity to 0 for invisible operation
- State recovery respects these settings (only checks `isVisible`, not opacity)

## Modifier Key Handling

### Sticky Mode
- Holding modifier keys (Cmd/Ctrl/Option) triggers sticky mode
- Different opacity in sticky mode for visual feedback
- Configurable which modifier does what (group sequences vs sticky mode)

### Smart Modifier Tracking
- Tracks modifier state changes
- Handles modifier-only shortcuts (e.g., Cmd+Shift+K)
- Prevents activation during typing (checks for non-modifier keys)

## Performance Optimizations

### Lazy Window Creation
- Window created on first show, not at app launch
- Reduces memory footprint when not in use

### Event Processing
- Early exit for non-relevant events
- Minimal processing in event tap callback
- Defers heavy work to main queue when needed

## Configuration System

### Multi-Level Configs
1. Default config
2. App-specific configs
3. Overlay-specific configs (Raycast, Alfred)

### Overlay Detection
- Can detect when Raycast/Alfred windows are active
- Loads specific configs for overlay contexts
- Optional feature (disabled by default)

## Known Edge Cases

### High CPU Scenarios
- Event tap may be disabled by system
- Adaptive health check ensures recovery within 1 second
- Force reset always available as fallback

### Multiple Monitors
- Window positioning accounts for screen with mouse
- Respects user's offset preferences

### Rapid Activation
- Reactivation behavior configurable (reset, hide, nothing)
- Prevents confusing states from rapid key presses

## Testing Considerations

### Window State Testing
- Can't rely on window being key for tests
- Must test through event tap simulation
- State recovery makes testing timing-sensitive

### Event Tap Testing
- Requires accessibility permissions
- May behave differently under test runners
- Force reset provides test recovery mechanism

## Security and Permissions

### Accessibility Requirements
- Required for global event tap
- Prompts user on first launch
- Graceful degradation if permissions revoked

### No Sensitive Data in Memory
- Doesn't store passwords or sensitive keystrokes
- Only tracks modifier states and activation sequences

## Future Considerations

### Potential Improvements
1. Per-app event tap health check intervals
2. Visual indicator when event tap is recovering
3. Telemetry for event tap failure patterns
4. Alternative input methods (mouse gestures, touchpad)

### Architectural Constraints
- Must remain non-key window for overlay compatibility
- Event tap is the only reliable input method
- Force reset must always work independently
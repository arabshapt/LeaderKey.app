# Approaches to Fix Key Pass-Through During Fast Typing

## Context & Problem Description

### The Issue
When typing very fast, some keys pass through to applications instead of being consumed by Leader Key. This happens because of a **timing gap** between when the callback makes consumption decisions and when the async processing updates the application state.

### Root Cause
```
Timeline:
1. Leader key arrives → Callback: quickShouldConsumeEvent() → Checks current state
2. State check: isInActiveSequence = false (not updated yet)
3. Callback returns: "Don't consume" → Key passes to app ❌
4. Async processing completes → Updates state to active sequence (too late!)
5. Next key arrives → Now sees active sequence → Consumed correctly ✅
```

### Current Architecture Issues
- **Callback decision**: Based on current state (immediate)
- **State updates**: Happen asynchronously (delayed)
- **Race condition**: Fast typing outpaces state updates
- **100ms hack**: Current workaround using time windows (fragile)

---

## Approach 1: Synchronous Activation Processing

### Concept
Process ONLY activation keys synchronously to update state immediately, while keeping other keys async for performance.

### Implementation

```swift
// In eventTapCallback
func eventTapCallback(...) -> Unmanaged<CGEvent>? {
    let shouldConsume = appDelegate.quickShouldConsumeEvent(event)
    
    // Check if this is an activation key
    if appDelegate.isActivationKey(event) {
        // Process activation synchronously to update state immediately
        appDelegate.processActivationKeySynchronously(event)
        
        // Also queue for full async processing (UI updates, etc.)
        appDelegate.enqueueEventForProcessing(event)
    } else {
        // Non-activation keys stay fully async
        appDelegate.enqueueEventForProcessing(event)
    }
    
    return shouldConsume ? nil : Unmanaged.passRetained(event)
}

// New methods in AppDelegate
func isActivationKey(_ event: CGEvent) -> Bool {
    let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
    return cachedActivationKeyCodes.contains(keyCode)
}

func processActivationKeySynchronously(_ event: CGEvent) {
    // Minimal synchronous work: Just update state flags
    guard let nsEvent = NSEvent(cgEvent: event) else { return }
    
    // Quick activation check
    if let activation = checkActivationShortcut(nsEvent) {
        // Update state immediately
        self.currentSequenceGroup = getInitialGroup(for: activation.type)
        self.activeRootGroup = currentSequenceGroup
        self.activeActivationShortcut = activation.shortcut
    }
}
```

### Pros
- ✅ Eliminates timing gap completely
- ✅ Simple state model (no complex tracking)
- ✅ Minimal sync work (just state updates)
- ✅ Keeps heavy processing async

### Cons
- ❌ NSEvent creation in callback (small perf hit)
- ❌ Duplicated activation logic
- ❌ Still some synchronous work in callback

---

## Approach 2: Event Sequence IDs

### Concept
Assign unique sequence IDs to track which events belong together. If activation fails, discard all events with that sequence ID.

### Implementation

```swift
// New structures
struct EventContext {
    let sequenceID: UUID?
    let event: CGEvent
    let timestamp: CFAbsoluteTime
}

// In AppDelegate
private var currentSequenceID: UUID? = nil
private var eventBuffer: [EventContext] = []

func quickShouldConsumeEvent(_ event: CGEvent) -> Bool {
    let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
    
    // If it's an activation key
    if cachedActivationKeyCodes.contains(keyCode) {
        // Start new sequence
        currentSequenceID = UUID()
        return true
    }
    
    // If we have an active sequence ID, consume everything
    if currentSequenceID != nil {
        return true
    }
    
    return isInActiveSequence
}

func enqueueEventForProcessing(_ event: CGEvent) {
    let context = EventContext(
        sequenceID: currentSequenceID,
        event: event.copy()!,
        timestamp: CFAbsoluteTimeGetCurrent()
    )
    
    eventBuffer.append(context)
    
    AppDelegate.eventProcessingQueue.async { [weak self] in
        self?.processEventContext(context)
    }
}

func processEventContext(_ context: EventContext) {
    // If this event's sequence was cancelled, drop it
    if let seqID = context.sequenceID, !isValidSequence(seqID) {
        print("Dropping event from cancelled sequence: \(seqID)")
        return
    }
    
    // Process normally
    processEvent(context.event)
    
    // If activation failed, mark sequence as invalid
    if wasActivationEvent(context.event) && !isInActiveSequence {
        invalidateSequence(context.sequenceID)
    }
}

func invalidateSequence(_ sequenceID: UUID?) {
    guard let seqID = sequenceID else { return }
    
    // Mark sequence as invalid
    invalidSequences.insert(seqID)
    
    // Clean up old invalid sequences
    cleanupOldSequences()
}
```

### Pros
- ✅ Perfect event tracking
- ✅ Can recover from failed activations
- ✅ Explicit sequence lifecycle management
- ✅ Debuggable event flow

### Cons
- ❌ Complex state management
- ❌ Memory overhead for buffers
- ❌ Cleanup complexity
- ❌ More failure modes

---

## Approach 3: State Machine Pattern

### Concept
Replace boolean flags with explicit state machine that tracks all possible callback states.

### Implementation

```swift
// State machine definition
enum CallbackState {
    case idle
    case activationPending(id: UUID, since: CFAbsoluteTime)
    case inSequence(id: UUID)
    case activationFailed(until: CFAbsoluteTime)
    case resetting
}

// In AppDelegate
private var callbackState: CallbackState = .idle

func quickShouldConsumeEvent(_ event: CGEvent) -> Bool {
    let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
    let isActivation = cachedActivationKeyCodes.contains(keyCode)
    
    switch callbackState {
    case .idle:
        if isActivation {
            let id = UUID()
            callbackState = .activationPending(id: id, since: CFAbsoluteTimeGetCurrent())
            return true
        }
        return false
        
    case .activationPending(let id, let since):
        // Consume everything while activation is pending
        return true
        
    case .inSequence(let id):
        // Consume everything while in sequence
        return true
        
    case .activationFailed(let until):
        // Don't consume until timeout expires
        if CFAbsoluteTimeGetCurrent() > until {
            callbackState = .idle
            return quickShouldConsumeEvent(event) // Retry
        }
        return false
        
    case .resetting:
        // Consume nothing while resetting
        return false
    }
}

func updateStateAfterProcessing(success: Bool, isActivation: Bool) {
    switch callbackState {
    case .activationPending(let id, _):
        if isActivation {
            if success {
                callbackState = .inSequence(id: id)
            } else {
                let timeout = CFAbsoluteTimeGetCurrent() + 0.05 // 50ms timeout
                callbackState = .activationFailed(until: timeout)
            }
        }
        
    case .inSequence(let id):
        if !isInActiveSequence {
            callbackState = .idle
        }
        
    default:
        break
    }
}
```

### Pros
- ✅ Explicit, debuggable states
- ✅ Clear state transitions
- ✅ Handles all edge cases
- ✅ Easy to extend with new states

### Cons
- ❌ Complex implementation
- ❌ More code to maintain
- ❌ Potential for state bugs
- ❌ Overkill for simple problem

---

## Approach 4: Optimistic Consumption with Replay

### Concept
Consume everything optimistically during uncertain periods, then replay events as synthetic if we were wrong.

### Implementation

```swift
// Event buffer for replay
private var replayBuffer: [CGEvent] = []
private var bufferingMode: Bool = false

func quickShouldConsumeEvent(_ event: CGEvent) -> Bool {
    let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
    
    // If activation key, start buffering
    if cachedActivationKeyCodes.contains(keyCode) {
        bufferingMode = true
        replayBuffer.removeAll()
        return true
    }
    
    // If in buffering mode, consume optimistically
    if bufferingMode {
        if let eventCopy = event.copy() {
            replayBuffer.append(eventCopy)
        }
        return true
    }
    
    return isInActiveSequence
}

func finishActivationProcessing(success: Bool) {
    defer {
        bufferingMode = false
        replayBuffer.removeAll()
    }
    
    if success {
        // Activation succeeded, we correctly consumed events
        return
    }
    
    // Activation failed, replay buffered events
    print("Activation failed, replaying \(replayBuffer.count) events")
    
    for event in replayBuffer {
        // Inject as synthetic event to let it pass through
        let syntheticEvent = createSyntheticEvent(from: event)
        CGEvent.post(tap: .cghidEventTap, event: syntheticEvent)
    }
}

func createSyntheticEvent(from originalEvent: CGEvent) -> CGEvent {
    guard let synthetic = originalEvent.copy() else { return originalEvent }
    
    // Mark as synthetic to avoid re-processing
    synthetic.setIntegerValueField(.eventSourceUserData, value: leaderKeySyntheticEventTag)
    
    return synthetic
}
```

### Pros
- ✅ Never drops events
- ✅ Self-correcting
- ✅ Simple decision logic
- ✅ Recovers from any failure

### Cons
- ❌ Complex replay mechanism
- ❌ Potential for event loops
- ❌ Timing issues with synthetic events
- ❌ Hard to debug replay scenarios

---

## Approach 5: Deferred Decision Pattern

### Concept
Callback makes provisional decisions, background processor makes final decisions and can inject corrections.

### Implementation

```swift
enum ConsumptionDecision {
    case consume
    case passThrough
    case provisional(reason: String)
}

// In callback
func quickShouldConsumeEvent(_ event: CGEvent) -> ConsumptionDecision {
    let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
    
    if cachedActivationKeyCodes.contains(keyCode) {
        return .consume
    }
    
    if isInActiveSequence {
        return .consume
    }
    
    if hasPendingActivation {
        return .provisional(reason: "activation pending")
    }
    
    return .passThrough
}

// Modified callback logic
func eventTapCallback(...) -> Unmanaged<CGEvent>? {
    let decision = appDelegate.quickShouldConsumeEvent(event)
    
    switch decision {
    case .consume:
        appDelegate.enqueueEventForProcessing(event)
        return nil // Consume
        
    case .passThrough:
        return Unmanaged.passRetained(event) // Pass through
        
    case .provisional(let reason):
        // Store event for potential correction
        appDelegate.storeProvisionalEvent(event, reason: reason)
        appDelegate.enqueueEventForProcessing(event)
        return nil // Consume provisionally
    }
}

// In background processor
func processProvisionalEvents() {
    for provisionalEvent in storedProvisionalEvents {
        if shouldHaveBeenPassedThrough(provisionalEvent) {
            // Inject synthetic event to correct the mistake
            injectCorrectionEvent(provisionalEvent)
        }
    }
    
    storedProvisionalEvents.removeAll()
}
```

### Pros
- ✅ Explicit uncertainty handling
- ✅ Can correct mistakes
- ✅ Clear decision audit trail
- ✅ Minimal callback complexity

### Cons
- ❌ Complex correction mechanism
- ❌ Potential timing issues
- ❌ Hard to guarantee correction delivery
- ❌ Event ordering problems

---

## Approach 6: Double-Check Pattern

### Concept
Quick synchronous validation followed by full async processing.

### Implementation

```swift
func quickShouldConsumeEvent(_ event: CGEvent) -> Bool {
    let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
    
    // Fast activation check
    if cachedActivationKeyCodes.contains(keyCode) {
        // Quick sync check: Would this activation succeed?
        if quickValidateActivation(event) {
            // Pre-update state immediately
            preActivationState = true
            preActivationTime = CFAbsoluteTimeGetCurrent()
            return true
        }
    }
    
    // Check current sequence state
    if isInActiveSequence {
        return true
    }
    
    // Check pre-activation window
    if preActivationState {
        let elapsed = CFAbsoluteTimeGetCurrent() - preActivationTime
        if elapsed < 0.1 { // 100ms window
            return true
        } else {
            preActivationState = false
        }
    }
    
    return false
}

func quickValidateActivation(_ event: CGEvent) -> Bool {
    // Fast checks only - no UI work
    guard isMonitoring else { return false }
    
    // Check if correct app is frontmost (if needed)
    if config.requiresSpecificApp {
        guard isCorrectAppActive() else { return false }
    }
    
    // Check if not in conflicting mode
    guard !isInConflictingMode() else { return false }
    
    return true
}

func processEventAsync(_ event: CGEvent) {
    // Full processing happens here
    let result = processKeyEvent(event)
    
    // Update pre-activation state based on actual result
    if wasActivationEvent(event) {
        if result {
            // Activation succeeded, we're now in sequence
            preActivationState = false // Not needed anymore
        } else {
            // Activation failed, clear pre-activation
            preActivationState = false
        }
    }
}
```

### Pros
- ✅ Fast synchronous validation
- ✅ Immediate state updates
- ✅ Async for heavy work
- ✅ Predictable behavior

### Cons
- ❌ Duplicated validation logic
- ❌ Still some sync work in callback
- ❌ Complex state management
- ❌ Validation might be wrong

---

## Approach 7: Event Buffering During Transition

### Concept
Buffer ALL events during uncertain transition periods, then process the buffer when state is clear.

### Implementation

```swift
enum BufferState {
    case normal
    case buffering(since: CFAbsoluteTime, reason: String)
}

private var bufferState: BufferState = .normal
private var eventBuffer: [CGEvent] = []

func quickShouldConsumeEvent(_ event: CGEvent) -> Bool {
    let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
    
    switch bufferState {
    case .normal:
        // Check for activation
        if cachedActivationKeyCodes.contains(keyCode) {
            startBuffering(reason: "activation detected")
            return true
        }
        
        return isInActiveSequence
        
    case .buffering(let since, let reason):
        // Consume everything while buffering
        if let eventCopy = event.copy() {
            eventBuffer.append(eventCopy)
        }
        
        // Check for timeout
        let elapsed = CFAbsoluteTimeGetCurrent() - since
        if elapsed > 0.1 { // 100ms timeout
            flushBuffer(success: false)
        }
        
        return true
    }
}

func startBuffering(reason: String) {
    bufferState = .buffering(since: CFAbsoluteTimeGetCurrent(), reason: reason)
    eventBuffer.removeAll()
}

func finishTransition(success: Bool) {
    switch bufferState {
    case .buffering:
        flushBuffer(success: success)
    case .normal:
        break
    }
}

func flushBuffer(success: Bool) {
    defer {
        bufferState = .normal
        eventBuffer.removeAll()
    }
    
    if success {
        // Process all buffered events normally
        for event in eventBuffer {
            processEventNormally(event)
        }
    } else {
        // Inject all buffered events as pass-through
        for event in eventBuffer {
            let synthetic = createPassThroughEvent(from: event)
            CGEvent.post(tap: .cghidEventTap, event: synthetic)
        }
    }
}
```

### Pros
- ✅ No events lost
- ✅ Clear transition handling
- ✅ Simple state model
- ✅ Timeout protection

### Cons
- ❌ Delays all events during transition
- ❌ Complex buffer management
- ❌ Memory usage for buffers
- ❌ Timing sensitive

---

## Recommendation & Testing Strategy

### Recommended Order to Try:

1. **Start with Approach 1 (Synchronous Activation)**
   - Simplest to implement
   - Highest chance of success
   - Minimal performance impact

2. **Try Approach 6 (Double-Check)** if #1 has issues
   - Good balance of sync/async
   - Predictable behavior

3. **Consider Approach 3 (State Machine)** for complex cases
   - Most robust long-term
   - Handle all edge cases

### Testing Each Approach:

```bash
# For each approach:
1. Implement the changes
2. Build and test basic functionality
3. Test fast typing: "leader o o leader o i leader o o a"
4. Monitor performance stats
5. Test edge cases: failed activations, wrong apps, etc.
6. Measure callback performance impact
```

### Success Criteria:
- ✅ No keys pass through during fast typing
- ✅ Callback time stays <0.5ms average
- ✅ All sequences work correctly
- ✅ No new race conditions introduced

### Debugging Tips:
- Add logging for each approach's decision points
- Track state transitions explicitly
- Monitor event timing and ordering
- Test with different typing speeds
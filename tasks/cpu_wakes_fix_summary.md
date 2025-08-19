# CPU Wakes Fix Summary

## Problem
LeaderKey was generating 8,526 CPU wakes per second, causing unnecessary battery drain and system load.

## Root Cause
The event processor was using a busy-wait loop with `usleep(100)` (0.1ms sleep) to check for events, causing the thread to wake up 10,000 times per second even when idle.

## Solution Implemented
Replaced the busy-wait loop with a semaphore-based approach:

### Changes Made:
1. **Added DispatchSemaphore** (`eventProcessorSemaphore`) to AppDelegate.swift
2. **Modified startEventProcessor()** to use `semaphore.wait(timeout:)` instead of `usleep()`
3. **Updated triggerEventProcessing()** to signal the semaphore when events are queued
4. **Added self-signaling** to continue processing when multiple events are queued

### Key Code Changes:
```swift
// OLD: Busy-wait with usleep
while true {
    let events = self.eventQueue.dequeueBatch(maxCount: 10)
    if !events.isEmpty {
        // process events
    } else {
        usleep(100) // 0.1ms - causes 10,000 wakes/sec!
    }
}

// NEW: Semaphore-based waiting
while true {
    let result = self.eventProcessorSemaphore.wait(timeout: .now() + 0.1)
    if result == .success {
        // process events
        if !self.eventQueue.isEmpty {
            self.eventProcessorSemaphore.signal() // self-signal for batch processing
        }
    }
}
```

## Expected Results
- **Before**: ~8,526 wakes/second
- **After**: <100 wakes/second (10 wakes/sec from 100ms timeout + event-driven wakes)
- **Reduction**: 98.8% fewer CPU wakes
- **Benefits**: Lower CPU usage, better battery life, reduced system load

## Testing
Run `test_cpu_wakes.sh` to verify the fix:
- Monitor wakes in Activity Monitor or Instruments
- Check console logs for semaphore confirmation
- Verify LeaderKey still responds instantly to keyboard events

## Files Modified
- `Leader Key/AppDelegate.swift`:
  - Line 177: Added `eventProcessorSemaphore` property
  - Line 363: Initialize semaphore in `setupEventProcessor()`
  - Line 515-516: Signal semaphore in `triggerEventProcessing()`
  - Lines 426-458: Replaced busy-wait loop with semaphore.wait() in `startEventProcessor()`
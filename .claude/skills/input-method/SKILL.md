---
name: input-method
description: Use when working on Karabiner communication, command routing, activation/deactivation, state ID handling, or the input method layer
allowed-tools: Read, Grep, Glob, Bash
paths:
  - "Leader Key/Karabiner2InputMethod.swift"
  - "Leader Key/UnixSocketServer.swift"
  - "Leader Key/KarabinerUserCommandReceiver.swift"
  - "Leader Key/KarabinerCommandRouter.swift"
  - "Leader Key/InputMethod.swift"
---

# Input Method Layer

## Architecture
Only one input method exists: `Karabiner2InputMethod`. CGEventTap and Karabiner v1 were removed.

### Communication Channels
1. **UnixSocketServer** — receives text commands (`activate`, `deactivate`, `stateid`, `shake`)
2. **KarabinerUserCommandReceiver** — receives `send_user_command` payloads from Karabiner via Unix datagram socket

## Command Flow

### `activate {bundleId}`
```
UnixSocketServer receives "activate com.raycast.macos"
  → Karabiner2InputMethod parses command
    → delegate.inputMethodDidReceiveActivation(bundleId: "com.raycast.macos")
      → AppDelegate determines activationType (.appSpecificWithFallback)
        → Controller.show(type:bundleId:) loads config using bundleId
          → startSequence() preprocesses config for key lookups
```

**CRITICAL**: `bundleId` comes from Karabiner — it is the single source of truth for app detection. Never use `NSWorkspace.shared.frontmostApplication?.bundleIdentifier` for config loading. Karabiner can detect overlay apps (Raycast, Alfred) that macOS doesn't report as frontmost.

### `stateid {id}` (with optional `sticky` flag)
```
UnixSocketServer receives "stateid 999901894"
  → delegate.inputMethodDidReceiveStateId(stateId, sticky: false)
    → AppDelegate.executeActionByStateId()
      → Looks up StateMapping by stateId
      → Self-contained: if window not visible, shows it with correct bundleId config
      → For groups: navigates by simulating key presses along mapping.path
      → For actions: executes via actionCache[stateId]
```

### `deactivate`
Resets sequence state, hides window.

### `shake`
Triggers "not found" animation when undefined key is pressed.

## Key Files

| File | Role |
|------|------|
| `InputMethod.swift` | Protocol definition: `start()`, `stop()`, `checkHealth()` |
| `Karabiner2InputMethod.swift` | Implementation — manages socket server + command receiver, health checks |
| `UnixSocketServer.swift` | Listens on Unix socket, parses text commands |
| `KarabinerUserCommandReceiver.swift` | Receives `send_user_command` payloads via datagram socket |
| `KarabinerCommandRouter.swift` | Routes parsed commands to appropriate handlers |

## InputMethodDelegate Protocol
AppDelegate implements this. Key callbacks:
- `inputMethodDidReceiveActivation(bundleId:)` — show overlay with app config
- `inputMethodDidReceiveStateId(_:sticky:)` — execute action by state ID
- `inputMethodDidReceiveKey(_:modifiers:)` — handle individual key press
- `inputMethodDidReceiveDeactivation()` — hide overlay
- `inputMethodDidReceiveShake()` — "not found" animation

## Health Monitoring
`inputMethodHealthTimer` runs every 0.5s calling `checkHealth()` which verifies:
- Karabiner Elements is running
- Socket server is active
- User command receiver is operational

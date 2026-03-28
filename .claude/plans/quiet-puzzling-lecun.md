# Plan: Add background flag to v1 open payload

## Context
Raycast window management commands (window left/right) broke — "cannot get focused window". `NSWorkspace.shared.open(url)` brings Raycast to foreground before the command runs, stealing focus. The snaps pattern includes `background: true` in the v1 payload for custom URL schemes so Raycast processes the deep link without stealing focus.

`shouldUseBackgroundExecution()` already exists in `Karabiner2Exporter.swift` and returns `true` for custom schemes like `raycast://`. It just isn't wired through the v1 payload yet.

## Changes

### 1. `Leader Key/Karabiner2Exporter.swift` — restore background flag in helpers + call sites

- **`gokuOpen`** (~line 884): Add `background: Bool = false` param, include `:background` in EDN payload
- **`karOpen`** (~line 894): Add `background: Bool = false` param, include `"background"` in JSON payload
- **3 call sites**: Restore `let background = shouldUseBackgroundExecution(for: action)` and pass to helpers:
  - `generateKarTerminalActionMapping` URL case (~line 732)
  - `generateTerminalAction` URL case (~line 1900)
  - `generateUnifiedTerminalAction` URL case (~line 2376)

### 2. `Leader Key/KarabinerUserCommandReceiver.swift` — read background flag, open with `activates = false`

In `handleV1Payload` "open" case (~line 149):
```swift
let background = dict["background"] as? Bool ?? false
DispatchQueue.main.async {
  if background {
    let config = NSWorkspace.OpenConfiguration()
    config.activates = false
    NSWorkspace.shared.open(url, configuration: config)
  } else {
    NSWorkspace.shared.open(url)
  }
}
```

## Files to modify
- `Leader Key/Karabiner2Exporter.swift`
- `Leader Key/KarabinerUserCommandReceiver.swift`

## Verification
1. Build: `xcodebuild -scheme "Leader Key" -configuration Debug build`
2. Launch from terminal, test background:
```bash
python3 -c "
import socket
sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
sock.sendto(b'{\"v\":1,\"type\":\"open\",\"background\":true,\"target\":\"raycast://extensions/raycast/system/open-camera\"}', '/Library/Application Support/org.pqrs/tmp/user/501/user_command_receiver.sock')
sock.close()
"
```
3. Verify Raycast command runs without stealing focus
4. Test window left/right through actual keybinding

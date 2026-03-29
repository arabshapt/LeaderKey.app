# Plan: Reimplement useful seq/seqd features natively in Leader Key

## Context

Leader Key currently forwards `open_app`/`open_app_toggle`/`open_with_app` commands to seqd at `/tmp/seqd.sock`. seqd is a powerful daemon (~2700 LOC Obj-C++) but includes heavy features we don't need (ScreenCaptureKit screen recording, OCR, ClickHouse telemetry, Hetzner sync, agent process management). The screen capture pipeline likely drives `replayd` at 78% CPU.

**Goal**: Eliminate the seqd dependency for core features by handling them natively in Leader Key. Keep it simple — only reimplement what Leader Key actually uses.

## What Leader Key currently sends to seqd

| Command | Used by |
|---------|---------|
| `OPEN_APP <path>` | v1 `open_app` payload |
| `OPEN_APP_TOGGLE <path>` | v1 `open_app_toggle` payload |
| `OPEN_WITH_APP <app>:<target>` | v1 `open_with_app` payload |

URLs (`type: "open"`) are already handled natively via `NSWorkspace.shared.open(url)`.

## What Leader Key already has natively

- URL opening with background flag (`NSWorkspace`)
- App opening (`NSWorkspace.shared.openApplication`)
- Shell command execution
- Macro/sequence support with delays
- Two socket servers (stream + datagram)

## Recommended approach: Handle app commands natively in Leader Key

Replace the `sendToSeqd()` calls with native Swift implementations in `KarabinerUserCommandReceiver.swift`. No new files, no new daemon — just ~40 lines of Swift.

### Feature implementation

#### 1. `OPEN_APP` → `NSWorkspace.shared.openApplication()`
```swift
// Resolve app path → bundle URL → launch
let url = URL(fileURLWithPath: appPath)
let config = NSWorkspace.OpenConfiguration()
NSWorkspace.shared.openApplication(at: url, configuration: config)
```
- Handles full paths (`/Applications/Safari.app`) and app names (`Safari`) via `NSWorkspace.shared.urlForApplication(withBundleIdentifier:)` or path search

#### 2. `OPEN_APP_TOGGLE` → open if not frontmost, hide if frontmost
```swift
// Check if app is frontmost
if let frontApp = NSWorkspace.shared.frontmostApplication,
   frontApp.bundleURL == appURL {
  frontApp.hide()  // Already focused → hide it
} else {
  NSWorkspace.shared.openApplication(at: appURL, configuration: config)
}
```

#### 3. `OPEN_WITH_APP` → `NSWorkspace.shared.open([url], withApplicationAt:, configuration:)`
```swift
let fileURL = URL(fileURLWithPath: targetPath)
let appURL = URL(fileURLWithPath: appPath)
NSWorkspace.shared.open([fileURL], withApplicationAt: appURL, configuration: config)
```

### Changes

**File: `Leader Key/KarabinerUserCommandReceiver.swift`**

- Replace `sendToSeqd("OPEN_APP ...")` with native `openApp()` method
- Replace `sendToSeqd("OPEN_APP_TOGGLE ...")` with native `openAppToggle()` method
- Replace `sendToSeqd("OPEN_WITH_APP ...")` with native `openWithApp()` method
- Remove `sendToSeqd()` method entirely (no more seqd dependency)
- Remove `seqdSocket` constant

### App name resolution

seqd accepts both full paths (`/Applications/Safari.app`) and app names (`Safari`). We need the same:

```swift
private static func resolveAppURL(_ app: String) -> URL? {
  // Full path
  if app.hasSuffix(".app") {
    let url = URL(fileURLWithPath: app)
    if FileManager.default.fileExists(atPath: app) { return url }
  }
  // Search by name in standard locations
  let searchPaths = ["/Applications", "/System/Applications", "/System/Applications/Utilities"]
  for dir in searchPaths {
    let path = "\(dir)/\(app).app"
    if FileManager.default.fileExists(atPath: path) {
      return URL(fileURLWithPath: path)
    }
  }
  // NSWorkspace spotlight search as fallback
  return NSWorkspace.shared.urlForApplication(withBundleIdentifier: app)
}
```

## What we're NOT reimplementing

- Screen capture / OCR (the CPU hog — not needed)
- Mouse control (click, scroll, drag — not used by Leader Key)
- Macro runner (Leader Key has its own macro system)
- Telemetry / tracing / metrics (not needed)
- Agent process management (not needed)
- AFK detection (not needed)
- Context search (not needed)

## Files to modify

- `Leader Key/KarabinerUserCommandReceiver.swift` — replace seqd forwarding with native implementations (~40 lines of new code, remove ~30 lines of socket code)

## Verification

1. Build: `xcodebuild -scheme "Leader Key" -configuration Debug build`
2. Test app opening:
```bash
python3 -c "
import socket
sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
sock.sendto(b'{\"v\":1,\"type\":\"open_app\",\"app\":\"/System/Applications/Calculator.app\"}', '/Library/Application Support/org.pqrs/tmp/user/501/user_command_receiver.sock')
sock.close()
"
```
3. Test app toggle (run twice — first opens, second hides):
```bash
python3 -c "
import socket
sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
sock.sendto(b'{\"v\":1,\"type\":\"open_app_toggle\",\"app\":\"/Applications/Safari.app\"}', '/Library/Application Support/org.pqrs/tmp/user/501/user_command_receiver.sock')
sock.close()
"
```
4. Test app name resolution (without full path):
```bash
python3 -c "
import socket
sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
sock.sendto(b'{\"v\":1,\"type\":\"open_app\",\"app\":\"Calculator\"}', '/Library/Application Support/org.pqrs/tmp/user/501/user_command_receiver.sock')
sock.close()
"
```
5. Verify seqd can be stopped without breaking Leader Key

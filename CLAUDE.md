# Leader Key Development Guide

## Build & Test Commands
- Build: `xcodebuild -scheme "Leader Key" -configuration Debug build`
- Run all tests: `xcodebuild -scheme "Leader Key" -testPlan "TestPlan" test`
- Run single test: `xcodebuild -scheme "Leader Key" -testPlan "TestPlan" -only-testing:Leader\ KeyTests/UserConfigTests/testInitializesWithDefaults test`
- Bump version: `bin/bump`
- Create release: `bin/release`

## Architecture

Leader Key is a **Karabiner Elements companion app** — a configurator UI, WhichKey/hint overlay, and config exporter. Karabiner Elements is always the foundation for keyboard input.

### Data Flow
```
Karabiner Elements (captures keys, detects frontmost app)
  → UnixSocket / KarabinerUserCommandReceiver
    → Karabiner2InputMethod (only input method)
      → AppDelegate (routes commands: activate, deactivate, stateid, shake)
        → Controller.show() (loads config, shows overlay)
          → startSequence() (preprocesses config for key lookups)
```

### Key Design Decisions
- **Karabiner is single source of truth for app detection** — bundleId always comes from Karabiner's `activate {bundleId}` command. Never use `NSWorkspace.shared.frontmostApplication` for config loading — it can't detect overlay apps like Raycast
- **stateid is self-contained** — `executeActionByStateId()` uses `mapping.bundleId` to show the window with the correct config if not already visible
- **Two export backends** — Goku (EDN format) and kar (TypeScript). Both use `send_user_command` for IPC via `Karabiner2Exporter`
- **v1 payload protocol** — `KarabinerUserCommandReceiver` handles structured `{v:1, type:...}` payloads: `open_app`/`open_app_toggle` → seqd, `open` (URLs) → `NSWorkspace`, `open_with_app` → seqd. String payloads route to `KarabinerCommandRouter` as before
- **Config merging** — app-specific configs are merged with fallback config via `mergeConfigWithFallback()`

### Config Files (in `~/Library/Application Support/Leader Key/`)
- `global-config.json` — default global config (always loaded as `root`)
- `app-fallback-config.json` — fallback config merged into every app config
- `app.{bundleId}.json` — app-specific configs (e.g., `app.com.raycast.macos.json`)

### File Organization
| Area | Key Files |
|------|-----------|
| Core | `AppDelegate.swift`, `Controller.swift`, `Events.swift` |
| Input | `Karabiner2InputMethod.swift`, `UnixSocketServer.swift`, `KarabinerUserCommandReceiver.swift`, `KarabinerCommandRouter.swift` |
| Config | `UserConfig.swift` + 11 extensions (`UserConfig+Loading.swift`, `+Creation`, `+Discovery`, `+Saving`, `+FileManagement`, `+Validation`, `+ErrorHandling`, `+Deletion`, `+Metadata`, `+EditingState`, `+GroupPath`) |
| Export | `Karabiner2Exporter.swift`, `KarCompilerService.swift`, `GokuCompilerService.swift` |
| UI | `MainWindow.swift`, `Cheatsheet.swift`, `Settings/GeneralPane.swift`, `Settings/AdvancedPane.swift` |
| Models | `Defaults.swift`, `UserState.swift`, `ConfigCache.swift`, `KeyLookupCache.swift` |

## Code Style Guidelines
- **Imports**: Group Foundation/AppKit imports first, then third-party libraries (Combine, Defaults)
- **Naming**: Use descriptive camelCase for variables/functions, PascalCase for types
- **Types**: Use explicit type annotations for public properties and parameters
- **Error Handling**: Use do/catch blocks and `alertHandler.showAlert()` for user-facing errors
- **Extensions**: Create extensions for additional functionality (UserConfig is split into 11 focused extensions)
- **State Management**: Use @Published and ObservableObject for reactive UI updates
- **Testing**: Descriptive test names, XCTAssert* methods. Tests in `Leader KeyTests/`
- **Access Control**: Use appropriate access modifiers (private, fileprivate, internal)
- Follow Swift idioms and default formatting (4-space indentation, spaces around operators)

## Manual Testing (v1 payload protocol)

Launch Leader Key from terminal to see stdout logs:
```bash
killall "Leader Key" 2>/dev/null
"/path/to/DerivedData/Leader_Key-.../Build/Products/Debug/Leader Key.app/Contents/MacOS/Leader Key"
```

Send test payloads to the Karabiner user-command receiver (in a second terminal):
```bash
# open_app → seqd
python3 -c "
import socket
sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
sock.sendto(b'{\"v\":1,\"type\":\"open_app\",\"app\":\"/System/Applications/Calculator.app\"}', '/Library/Application Support/org.pqrs/tmp/user/$(id -u)/user_command_receiver.sock')
sock.close()
"

# open_app_toggle → seqd
python3 -c "
import socket
sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
sock.sendto(b'{\"v\":1,\"type\":\"open_app_toggle\",\"app\":\"/Applications/Safari.app\"}', '/Library/Application Support/org.pqrs/tmp/user/$(id -u)/user_command_receiver.sock')
sock.close()
"

# open URL → NSWorkspace
python3 -c "
import socket
sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
sock.sendto(b'{\"v\":1,\"type\":\"open\",\"target\":\"https://google.com\"}', '/Library/Application Support/org.pqrs/tmp/user/$(id -u)/user_command_receiver.sock')
sock.close()
"

# open Raycast deep link → NSWorkspace
python3 -c "
import socket
sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
sock.sendto(b'{\"v\":1,\"type\":\"open\",\"target\":\"raycast://extensions/raycast/system/open-camera\"}', '/Library/Application Support/org.pqrs/tmp/user/$(id -u)/user_command_receiver.sock')
sock.close()
"

# menu item click → AX API
python3 -c "
import socket
sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
sock.sendto(b'{\"v\":1,\"type\":\"menu\",\"app\":\"Finder\",\"path\":\"File > New Finder Window\"}', '/Library/Application Support/org.pqrs/tmp/user/$(id -u)/user_command_receiver.sock')
sock.close()
"

# Leader Key string command (existing protocol)
python3 -c "
import socket
sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
sock.sendto(b'\"activate com.apple.Safari\"', '/Library/Application Support/org.pqrs/tmp/user/$(id -u)/user_command_receiver.sock')
sock.close()
"

# Direct seqd test (bypasses Karabiner)
printf 'OPEN_APP /System/Applications/Calculator.app\n' | nc -U /tmp/seqd.sock
```

## Speed Optimization Patterns
- **`send_user_command` over `shell_command`** — Karabiner's `send_user_command` uses an existing datagram socket (fire-and-forget, ~1ms). `shell_command` spawns a new process each time (~100-200ms). Always prefer `send_user_command` with v1 payloads for app/URL/menu actions
- **`NSRunningApplication.activate()` over `NSWorkspace.openApplication`** — `activate()` is direct IPC to WindowServer (~1ms). `openApplication` goes through LaunchServices (~50ms). Use `activate()` as fast path for running apps, fall back to `openApplication` for cold launches
- **App cache (`appCache`)** — `KarabinerUserCommandReceiver` caches `app string → (url, bundleId)` to avoid repeated FileManager + Bundle lookups. First call resolves, all subsequent are dictionary hits
- **AX menu walking** — Use `AXUIElementPerformAction(kAXPressAction)` directly (non-visual). `AXPick` and `AXShowMenu` are slower alternatives. Descendant search (depth 6) handles inconsistent menu structures across apps
- **`NSWorkspace.OpenConfiguration.activates = false`** — Opens URLs in background without stealing focus. Critical for Raycast deep links / window management commands
- **Macro execution** — macros that use `menu` type go through in-process AX API calls, not shell spawns. Same for `application` (cached NSRunningApplication) and `url` (NSWorkspace)

## Common Gotchas
- **Deleting Swift files** requires removing references from `Leader Key.xcodeproj/project.pbxproj` (use python script to remove lines by line number)
- **Config caching** — `UserConfig.appConfigs` dict caches loaded configs. Call `reloadConfig()` to bust the cache
- **Shell command escaping** in Goku EDN requires two layers: shell escaping (`'\''`) then EDN escaping (`\\`, `\"`)
- **State IDs** in `Karabiner2Exporter` — global starts at 1, fallback at 2, inactive is 0
- **Karabiner key repeat** — Karabiner only allows key repeat for the **last** event in the `to` array. In sticky-mode shortcuts, always put key events (`:escape`, `:!Cz`, etc.) at the end and variable sets (`["leaderkey_sticky" 1]`) before them. Correct: `[["leaderkey_sticky" 1] :!Cz]`, wrong: `[:!Cz ["leaderkey_sticky" 1]]`

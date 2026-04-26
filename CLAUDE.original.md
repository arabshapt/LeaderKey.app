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
- **v1 payload protocol** — `KarabinerUserCommandReceiver` handles structured `{v:1, type:...}` payloads: `open_app`/`open_app_toggle` → seqd, `open` (URLs) → `NSWorkspace`, `open_with_app` → seqd, `menu` → AX API, `intellij` → UDS socket at `/tmp/intellij-leaderkey.sock`. String payloads route to `KarabinerCommandRouter` as before
- **Config merging** — app-specific configs are merged with fallback config via `mergeConfigWithFallback()`
- **Goku is the personal Karabiner source of truth** — `~/.config/karabiner.edn` is canonical for arabshapt's full personal setup. `karabiner.ts/configs/arabshapt/default-profile.ts` and `default-complex-modifications.json` are generated migration snapshots, not hand-edited config. Re-sync through Leader Key via Raycast `Sync Goku Profile` or `printf 'sync-goku-profile\n' | nc -U /tmp/leaderkey.sock`

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

## IntelliJ Integration (v1.3.0+)

The `intellij` action type sends actions directly to IntelliJ via Unix Domain Socket — no HTTP, no shell spawn.

**Socket path**: `/tmp/intellij-leaderkey.sock` (created by the IntelliJ plugin on startup)

**Protocol**: Newline-delimited JSON over `SOCK_STREAM`. Same request format as the HTTP server.

**Single action**: `{"action":"ReformatCode"}`
**Multiple actions**: `{"actions":"SaveAll,ReformatCode","delay":100}` (delay is optional ms between actions)

**Plugin location**: `~/personalProjects/intellijPlugin/`
**Build**: `JAVA_HOME=.../temurin-21.0.7/Contents/Home ./gradlew build` (requires Java 21 — system Java 25 breaks Gradle)
**Install**: Settings → Plugins → ⚙️ → Install Plugin from Disk → `build/distributions/intellij-action-executor-X.Y.Z.zip`

**Config example**:
```json
{"key": "f", "type": "intellij", "value": "ReformatCode,OptimizeImports", "label": "Format"}
```

**Export**: Goku uses `gokuIntelliJ()`, kar uses `karIntelliJ()` — both generate `send_user_command` with `{v:1, type:"intellij", action:"..."}` payload.

**Adding a new v1 payload type** (pattern to follow):
1. Add `case "newtype"` to `handleV1Payload()` in `KarabinerUserCommandReceiver.swift`
2. Add `case newtype` to `Type` enum in `UserConfig.swift` + display name
3. Add `case .newtype` to `Controller.swift` `runAction()`
4. Add `gokuNewtype()`/`karNewtype()` helpers + `.newtype` cases in `Karabiner2Exporter.swift` (2 Goku sections + 1 kar section)
5. Add icon to `ActionIcon.swift`
6. Add to type pickers in `ConfigEditorView.swift` (2 pickers) and `NativeConfigEditorView.swift` (1 picker)

## Raycast Config Editing

The Raycast extension is a separate fast-path editor and discoverability surface. It is intentionally independent from the native settings UI.

**Commands**:
- `Search Shortcuts` — global/effective search across derived shortcut records
- `Browse Configs` — config-first navigation and editing
- `Add/Edit by Path` — character-driven path editor (`ab.c` = `a → b → . → c`)

**Key behaviors**:
- Current-app Raycast deeplinks must be resolved **before** Raycast opens. Use `app:{frontmostBundleId}` in the Raycast deeplink target and let Leader Key expand `{frontmostBundleId}` at execution time.
- Raycast copy/paste uses an internal extension clipboard, not the macOS clipboard.
- Paste is conflict-safe: if the copied key already exists in the target group, open a prefilled create/edit form instead of overwriting.
- Empty groups must still expose create actions (`Add First Action`, `Add First Group`) so they are never dead ends.
- Raycast writes JSON directly, then triggers apply over Leader Key's local socket. Do not rely on URL callbacks.

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

# IntelliJ single action via UDS (requires IntelliJ running with plugin v1.3.0+)
echo '{"action":"SaveAll"}' | nc -U /tmp/intellij-leaderkey.sock

# IntelliJ multiple actions via UDS
echo '{"actions":"SaveAll,ReformatCode","delay":100}' | nc -U /tmp/intellij-leaderkey.sock

# IntelliJ action via v1 payload (via Karabiner)
python3 -c "
import socket
sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
sock.sendto(b'{\"v\":1,\"type\":\"intellij\",\"action\":\"SaveAll\"}', '/Library/Application Support/org.pqrs/tmp/user/$(id -u)/user_command_receiver.sock')
sock.close()
"
```

## Speed Optimization Patterns
- **`send_user_command` over `shell_command`** — Karabiner's `send_user_command` uses an existing datagram socket (fire-and-forget, ~1ms). `shell_command` spawns a new process each time (~100-200ms). Always prefer `send_user_command` with v1 payloads for app/URL/menu actions
- **`NSRunningApplication.activate()` over `NSWorkspace.openApplication`** — `activate()` is direct IPC to WindowServer (~1ms). `openApplication` goes through LaunchServices (~50ms). Use `activate()` as fast path for running apps, but only if the target app already has a usable window
- **Reopen checks only for already-active apps** — some apps (notably Messages) can remain frontmost and keep owning the menu bar after `Cmd+W`, while having no visible window. In that state `activate()` is effectively a no-op. `open_app` now does the more expensive AX/window-state check only when the target app is already active, preserving the seq-style fast path for normal app switches
- **App cache (`appCache`)** — `KarabinerUserCommandReceiver` caches `app string → (url, bundleId)` to avoid repeated FileManager + Bundle lookups. First call resolves, all subsequent are dictionary hits
- **AX menu walking** — Use `AXUIElementPerformAction(kAXPressAction)` directly (non-visual). `AXPick` and `AXShowMenu` are slower alternatives. Descendant search (depth 6) handles inconsistent menu structures across apps
- **`NSWorkspace.OpenConfiguration.activates = false`** — Opens URLs in background without stealing focus. Critical for Raycast deep links / window management commands
- **Macro execution** — macros that use `menu` type go through in-process AX API calls, not shell spawns. Same for `application` (cached NSRunningApplication) and `url` (NSWorkspace)
- **IntelliJ UDS over HTTP** — `intellij` action type connects to `/tmp/intellij-leaderkey.sock` directly (~1ms). Eliminates HTTP handshake overhead of the old `curl localhost:63343` approach (~50ms). Use `SOCK_STREAM` (not `SOCK_DGRAM`) — JVM UDS only supports stream sockets
- **Always-on control socket for external apply** — Raycast and other local tools should send `apply-config` to `/tmp/leaderkey.sock` instead of touching files or using URL schemes. This keeps apply in-process and avoids duplicate reload paths

## Common Gotchas
- **Deleting Swift files** requires removing references from `Leader Key.xcodeproj/project.pbxproj` (use python script to remove lines by line number)
- **Config caching** — `UserConfig.appConfigs` dict caches loaded configs. Call `reloadConfig()` to bust the cache
- **Frontmost app does not guarantee a visible window** — Messages can stay frontmost after `Cmd+W` and still own the menu bar. If app activation logs show `activated ...` but nothing appears, check whether the app is already active with no regular window. The correct behavior is to reopen, not re-activate
- **Shell command escaping** in Goku EDN requires two layers: shell escaping (`'\''`) then EDN escaping (`\\`, `\"`)
- **State IDs** in `Karabiner2Exporter` — global starts at 1, fallback at 2, inactive is 0
- **Karabiner key repeat** — Karabiner only allows key repeat for the **last** event in the `to` array. In sticky-mode shortcuts, always put key events (`:escape`, `:!Cz`, etc.) at the end and variable sets (`["leaderkey_sticky" 1]`) before them. Correct: `[["leaderkey_sticky" 1] :!Cz]`, wrong: `[:!Cz ["leaderkey_sticky" 1]]`
- **IntelliJ plugin build requires Java 21** — System Java may be newer (25.x) which breaks the IntelliJ Gradle plugin. Use `JAVA_HOME=/Users/arabshaptukaev/Library/Java/JavaVirtualMachines/temurin-21.0.7/Contents/Home ./gradlew build`
- **IntelliJ UDS socket not present** = IntelliJ not running or plugin not loaded. `sendToIntelliJSocket()` fails silently (logs a warning) so Leader Key continues normally
- **JVM UDS is stream-only** — Java's `UnixDomainSocketAddress` only supports `SOCK_STREAM`, not `SOCK_DGRAM`. Protocol must be newline-delimited (connect → write → read response → close). Leader Key uses fire-and-forget (no read)
- **`leaderkey://` is gone** — External config apply should use the local socket (`/tmp/leaderkey.sock`). Do not add new app URL handlers for reload/apply/navigation.
- **Some Goku builds advertise `-c` but crash** — Prefer `GOKU_EDN_CONFIG_FILE=/path/to/karabiner.edn goku` over `goku -c /path/to/karabiner.edn`. Leader Key uses the environment-variable form for compatibility.
- **Do not hand-edit the arabshapt migration snapshot** — `karabiner.ts/configs/arabshapt/default-profile.ts` and `default-complex-modifications.json` must be regenerated from Goku through Leader Key. If `~/.config/karabiner.edn` changes, run Raycast `Sync Goku Profile` or send `sync-goku-profile` to `/tmp/leaderkey.sock`. Leader Key's own export updates `karabiner.ts/configs/leaderkey/leaderkey-generated.json` separately from the migrated Goku snapshot.

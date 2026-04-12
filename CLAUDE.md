# Leader Key Development Guide

## Build & Test Commands
- Build: `xcodebuild -scheme "Leader Key" -configuration Debug build`
- Run all tests: `xcodebuild -scheme "Leader Key" -testPlan "TestPlan" test`
- Run single test: `xcodebuild -scheme "Leader Key" -testPlan "TestPlan" -only-testing:Leader\ KeyTests/UserConfigTests/testInitializesWithDefaults test`
- Bump version: `bin/bump`
- Create release: `bin/release`

## Architecture

Leader Key = **Karabiner Elements companion app** — configurator UI, WhichKey/hint overlay, config exporter. Karabiner always foundation.

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
- **External triggers prefer local sockets** — use `/tmp/leaderkey.sock` commands for reload/apply/migration/navigation-style app control. Do not add `leaderkey://` URL schemes or URL callbacks for new integrations; Raycast and scripts should send socket commands such as `apply-config` or `sync-goku-profile`
- **Karabiner = single source of truth for app detection** — bundleId always from Karabiner's `activate {bundleId}` command. Never use `NSWorkspace.shared.frontmostApplication` for config loading — can't detect overlay apps like Raycast
- **stateid self-contained** — `executeActionByStateId()` uses `mapping.bundleId` to show window with correct config if not visible
- **Two export backends** — Goku (EDN) and kar (TypeScript). Both use `send_user_command` for IPC via `Karabiner2Exporter`
- **v1 payload protocol** — `KarabinerUserCommandReceiver` handles `{v:1, type:...}` payloads: `open_app`/`open_app_toggle` → seqd, `open` (URLs) → `NSWorkspace`, `open_with_app` → seqd, `menu` → AX API, `intellij` → UDS at `/tmp/intellij-leaderkey.sock`. String payloads → `KarabinerCommandRouter`
- **Config merging** — app-specific configs merged with fallback via `mergeConfigWithFallback()`
- **Goku = personal Karabiner source of truth** — `~/.config/karabiner.edn` canonical for arabshapt's setup. `karabiner.ts/configs/arabshapt/default-profile.ts` = generated migration snapshot, not hand-edited. Re-sync: `cd karabiner.ts && npm run sync:arabshapt`

### Config Files (in `~/Library/Application Support/Leader Key/`)
- `global-config.json` — default global config (always loaded as `root`)
- `app-fallback-config.json` — fallback merged into every app config
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
- **Imports**: Foundation/AppKit first, then third-party (Combine, Defaults)
- **Naming**: camelCase vars/funcs, PascalCase types
- **Types**: Explicit annotations for public properties/params
- **Error Handling**: do/catch + `alertHandler.showAlert()` for user-facing errors
- **Extensions**: Extend for added functionality (UserConfig = 11 focused extensions)
- **State Management**: @Published + ObservableObject for reactive UI
- **Testing**: Descriptive names, XCTAssert* methods. Tests in `Leader KeyTests/`
- **Access Control**: Appropriate modifiers (private, fileprivate, internal)
- Swift idioms, 4-space indent, spaces around operators

## IntelliJ Integration (v1.3.0+)

`intellij` action type sends directly to IntelliJ via Unix Domain Socket — no HTTP, no shell spawn.

**Socket path**: `/tmp/intellij-leaderkey.sock` (IntelliJ plugin creates on startup)

**Protocol**: Newline-delimited JSON over `SOCK_STREAM`. Same request format as HTTP server.

**Single action**: `{"action":"ReformatCode"}`
**Multiple actions**: `{"actions":"SaveAll,ReformatCode","delay":100}` (delay = optional ms between actions)

**Plugin location**: `~/personalProjects/intellijPlugin/`
**Build**: `JAVA_HOME=.../temurin-21.0.7/Contents/Home ./gradlew build` (requires Java 21 — system Java 25 breaks Gradle)
**Install**: Settings → Plugins → ⚙️ → Install Plugin from Disk → `build/distributions/intellij-action-executor-X.Y.Z.zip`

**Config example**:
```json
{"key": "f", "type": "intellij", "value": "ReformatCode,OptimizeImports", "label": "Format"}
```

**Export**: Goku uses `gokuIntelliJ()`, kar uses `karIntelliJ()` — both generate `send_user_command` with `{v:1, type:"intellij", action:"..."}`.

**Adding new v1 payload type** (pattern):
1. Add `case "newtype"` to `handleV1Payload()` in `KarabinerUserCommandReceiver.swift`
2. Add `case newtype` to `Type` enum in `UserConfig.swift` + display name
3. Add `case .newtype` to `Controller.swift` `runAction()`
4. Add `gokuNewtype()`/`karNewtype()` helpers + `.newtype` cases in `Karabiner2Exporter.swift` (2 Goku sections + 1 kar section)
5. Add icon to `ActionIcon.swift`
6. Add to type pickers in `ConfigEditorView.swift` (2 pickers) and `NativeConfigEditorView.swift` (1 picker)

## Raycast Config Editing

Raycast extension = separate fast-path editor + discoverability surface. Intentionally independent from native settings UI.

**Commands**:
- `Search Shortcuts` — global/effective search across derived shortcut records
- `Browse Configs` — config-first navigation/editing
- `Add/Edit by Path` — character-driven path editor (`ab.c` = `a → b → . → c`)

**Key behaviors**:
- Current-app Raycast deeplinks must resolve **before** Raycast opens. Use `app:{frontmostBundleId}` in deeplink target; Leader Key expands `{frontmostBundleId}` at execution.
- Raycast copy/paste uses internal extension clipboard, not macOS clipboard.
- Paste conflict-safe: if copied key exists in target group, open prefilled create/edit form instead of overwriting.
- Empty groups must expose create actions (`Add First Action`, `Add First Group`) — never dead ends.
- Raycast writes JSON directly, then triggers apply over Leader Key's local socket. Don't rely on URL callbacks.

## Manual Testing (v1 payload protocol)

Launch Leader Key from terminal to see stdout logs:
```bash
killall "Leader Key" 2>/dev/null
"/path/to/DerivedData/Leader_Key-.../Build/Products/Debug/Leader Key.app/Contents/MacOS/Leader Key"
```

Send test payloads to Karabiner user-command receiver (second terminal):
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
- **`send_user_command` over `shell_command`** — `send_user_command` uses existing datagram socket (~1ms). `shell_command` spawns process each time (~100-200ms). Always prefer `send_user_command` with v1 payloads
- **`NSRunningApplication.activate()` over `NSWorkspace.openApplication`** — `activate()` = direct IPC to WindowServer (~1ms). `openApplication` through LaunchServices (~50ms). Use `activate()` as fast path for running apps with usable window
- **Reopen checks only for already-active apps** — apps like Messages can stay frontmost after `Cmd+W` with no visible window; `activate()` = no-op. `open_app` does expensive AX/window-state check only when target already active
- **App cache (`appCache`)** — `KarabinerUserCommandReceiver` caches `app string → (url, bundleId)`. First call resolves, subsequent = dict hits
- **AX menu walking** — Use `AXUIElementPerformAction(kAXPressAction)` directly (non-visual). `AXPick`/`AXShowMenu` slower. Depth-6 descendant search handles inconsistent menu structures
- **`NSWorkspace.OpenConfiguration.activates = false`** — Opens URLs in background without stealing focus. Critical for Raycast deep links / window management
- **Macro execution** — `menu` type → in-process AX API, not shell. Same for `application` (cached NSRunningApplication) and `url` (NSWorkspace)
- **IntelliJ UDS over HTTP** — `intellij` connects to `/tmp/intellij-leaderkey.sock` (~1ms). Eliminates HTTP handshake (~50ms). Use `SOCK_STREAM` — JVM UDS only supports stream
- **Always-on control socket** — Raycast/local tools send `apply-config` to `/tmp/leaderkey.sock`. Keeps apply in-process, avoids duplicate reload paths

## Common Gotchas
- **Deleting Swift files** — remove references from `Leader Key.xcodeproj/project.pbxproj` (python script to remove lines by number)
- **Config caching** — `UserConfig.appConfigs` dict caches loaded configs. Call `reloadConfig()` to bust
- **Frontmost app ≠ visible window** — Messages stays frontmost after `Cmd+W`, owns menu bar. If activation logs show `activated ...` but nothing appears, check if app active with no regular window. Correct behavior: reopen, not re-activate
- **Shell command escaping** in Goku EDN: two layers — shell (`'\''`) then EDN (`\\`, `\"`)
- **State IDs** in `Karabiner2Exporter` — global starts at 1, fallback at 2, inactive = 0
- **Karabiner key repeat** — only for **last** event in `to` array. In sticky-mode shortcuts, key events (`:escape`, `:!Cz`) at end, variable sets (`["leaderkey_sticky" 1]`) before. Correct: `[["leaderkey_sticky" 1] :!Cz]`, wrong: `[:!Cz ["leaderkey_sticky" 1]]`
- **IntelliJ plugin build requires Java 21** — System Java may be newer (25.x), breaks Gradle. Use `JAVA_HOME=/Users/arabshaptukaev/Library/Java/JavaVirtualMachines/temurin-21.0.7/Contents/Home ./gradlew build`
- **IntelliJ UDS socket missing** = IntelliJ not running or plugin not loaded. `sendToIntelliJSocket()` fails silently (logs warning), Leader Key continues
- **JVM UDS stream-only** — Java's `UnixDomainSocketAddress` only supports `SOCK_STREAM`. Protocol: newline-delimited (connect → write → read response → close). Leader Key uses fire-and-forget (no read)
- **`leaderkey://` gone** — external config apply → local socket (`/tmp/leaderkey.sock`). Don't add new URL handlers for reload/apply/navigation
- **Some Goku builds advertise `-c` but crash** — prefer `GOKU_EDN_CONFIG_FILE=/path/to/karabiner.edn goku` over `goku -c /path/to/karabiner.edn`. Leader Key uses env-var form
- **Don't hand-edit arabshapt migration snapshot** — `karabiner.ts/configs/arabshapt/default-profile.ts` must regenerate from Goku. If `~/.config/karabiner.edn` changes: `cd /Users/arabshaptukaev/personalProjects/LeaderKeyapp/karabiner.ts && npm run sync:arabshapt`. Leader Key export only updates `karabiner.ts/configs/leaderkey/leaderkey-generated.ts`

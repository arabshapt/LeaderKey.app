# Consolidate export output paths to Leader Key directory

## Tasks
- [x] Update `KarCompilerService.swift` — computed property using `Defaults[.configDir]/export/`
- [x] Update `Karabiner2InputMethod.swift` — both Goku and kar outputDir paths
- [x] Update `AppDelegate.swift` — state mappings path
- [x] Update `AlternativeMappingsView.swift` — state mappings path
- [x] Update `AdvancedPane.swift` — "Open Export Folder" button
- [x] Build and verify

## Review

### Summary
Consolidated all generated export files from scattered locations (`~/.config/karabiner.edn.d/`, `~/.config/leaderkey/kar/`) into a single `{configDir}/export/` directory under the Leader Key config folder.

### Changes Made
- **`KarCompilerService.swift`** — Changed `generatedConfigPath` to computed property using `Defaults[.configDir]/export/leaderkey-generated.config.ts`
- **`Karabiner2InputMethod.swift`** — Updated both Goku EDN and kar TypeScript output dirs to `Defaults[.configDir]/export/`
- **`AppDelegate.swift`** — State mappings load path updated to `Defaults[.configDir]/export/leaderkey-state-mappings.json`
- **`AlternativeMappingsView.swift`** — Same state mappings path update
- **`AdvancedPane.swift`** — Renamed button to "Open Export Folder", pointing to the export directory

---

# IntelliJ Plugin: Add Unix Domain Socket (UDS) Server

Two-part project: (1) Add UDS listener to IntelliJ plugin, (2) Add `intellij` action type to Leader Key.

## Part 1: IntelliJ Plugin — UDS Server

### Tasks
- [x] 1. Create `UnixSocketServer.kt` — UDS listener at `/tmp/intellij-leaderkey.sock`
- [x] 2. Add `UnixSocketServerService` to `PluginStartup.kt`
- [x] 3. Update `PluginStartup.kt` — start UDS server alongside HTTP server
- [x] 4. Register service in `plugin.xml`
- [x] 5. Build succeeds (requires Java 21: `JAVA_HOME=.../temurin-21.0.7 ./gradlew build`)

## Part 2: Leader Key — `intellij` v1 payload type

### Tasks
- [x] 6. Add `case "intellij"` to `handleV1Payload` in `KarabinerUserCommandReceiver.swift`
- [x] 7. Add `case intellij` to `Type` enum in `UserConfig.swift` (display name, icon)
- [x] 8. Add `intellij` to `Controller.swift` action execution
- [x] 9. Add `intellij` to `Karabiner2Exporter.swift` (Goku + kar export)
- [x] 10. Add `intellij` to type pickers in ConfigEditorView + NativeConfigEditorView
- [x] 11. Add `intellij` icon (hammer) to ActionIcon.swift
- [x] 12. Build Leader Key — BUILD SUCCEEDED

## Design Notes

- **Socket path**: `/tmp/intellij-leaderkey.sock` — simple, predictable, no user-id complexity
- **Protocol**: Newline-delimited JSON over stream socket (not datagram — JVM doesn't support `SOCK_DGRAM` UDS)
- **Payload format**: `{"action":"ReformatCode"}` or `{"actions":"SaveAll,ReformatCode","delay":100}`
- **Same as HTTP**: Reuses exact same request format the CustomHttpServer already parses
- **HTTP stays**: UDS is an addition, not a replacement. CLI/scripts still use HTTP
- **Fire-and-forget from Leader Key**: Connect → write JSON + newline → close. Don't wait for response

## Review

### Part 1: IntelliJ Plugin (3 files)
- **`UnixSocketServer.kt`** (new) — UDS listener using `java.nio.channels.ServerSocketChannel` + `UnixDomainSocketAddress`. Accepts newline-delimited JSON, routes to `ActionExecutorService`, returns JSON response. 4-thread pool, daemon acceptor thread, cleans up `.sock` file on shutdown.
- **`PluginStartup.kt`** — Added `UnixSocketServerService` (app-level service wrapper) and starts it alongside HTTP server.
- **`plugin.xml`** — Registered `UnixSocketServerService`.

### Part 2: Leader Key (7 files)
- **`KarabinerUserCommandReceiver.swift`** — Added `case "intellij"` to v1 handler + `sendToIntelliJSocket()` static method (fire-and-forget via `SOCK_STREAM` unix socket).
- **`UserConfig.swift`** — Added `case intellij` to `Type` enum + display name "IntelliJ: {value}".
- **`Controller.swift`** — Added `.intellij` case calling `sendToIntelliJSocket()`.
- **`Karabiner2Exporter.swift`** — Added `gokuIntelliJ()`/`karIntelliJ()` helpers + `.intellij` case in kar mapping + both Goku export functions.
- **`ActionIcon.swift`** — `hammer` SF Symbol for intellij actions.
- **`ConfigEditorView.swift`** — Added "IntelliJ" to 2 type pickers (action row + macro step).
- **`NativeConfigEditorView.swift`** — Added "IntelliJ" to type picker.

### Data flow
```
Karabiner send_user_command → Leader Key socket → handleV1Payload("intellij")
  → sendToIntelliJSocket() → /tmp/intellij-leaderkey.sock → UnixSocketServer
    → ActionExecutorService.executeAction() → IntelliJ action runs
```

### Testing
```bash
# Test IntelliJ UDS server directly (requires IntelliJ running with plugin)
echo '{"action":"SaveAll"}' | nc -U /tmp/intellij-leaderkey.sock

# Test via Leader Key v1 payload
python3 -c "
import socket
sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
sock.sendto(b'{\"v\":1,\"type\":\"intellij\",\"action\":\"SaveAll\"}', '/Library/Application Support/org.pqrs/tmp/user/$(id -u)/user_command_receiver.sock')
sock.close()
"

# Example config entry
# {"key": "s", "type": "intellij", "value": "SaveAll", "label": "Save All"}
# {"key": "f", "type": "intellij", "value": "ReformatCode", "label": "Reformat"}
```

### Build notes
- IntelliJ plugin requires Java 21: `JAVA_HOME=.../temurin-21.0.7 ./gradlew build`
- Leader Key builds normally with Xcode

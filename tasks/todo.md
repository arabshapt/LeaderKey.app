# Cleanup — Karabiner-only architecture

## Tasks
- [x] Delete CGEventTap input method (files + references)
- [x] Delete Karabiner v1 input method (file + references)
- [x] Remove global shortcut registration
- [x] Simplify to Karabiner 2.0 only
- [x] Make stateid self-contained in AppDelegate
- [x] Build and verify

## Review

### Summary
Refactored Leader Key to be a Karabiner Elements companion app by removing dead input methods, global shortcut registration, and making `stateid` the self-contained entry point for actions.

### Changes Made

**Deleted files:**
- `Leader Key/CGEventTapInputMethod.swift` — CGEventTap input method (~69 lines)
- `Leader Key/DualEventTapManager.swift` — Dual event tap manager with failover (~353 lines)
- `Leader Key/KarabinerInputMethod.swift` — Karabiner v1 integration (~149 lines)

**AppDelegate.swift (~500+ lines removed):**
- Removed `eventTapCallback` global function
- Removed `globalCallbackStats`, `dualTapManager` properties
- Removed CPU monitoring (`startCPUMonitoring`, `stopCPUMonitoring`, `checkCPULoad`, etc.)
- Removed performance stats methods (`getCallbackPerformanceStats`, etc.)
- Removed `KeyboardShortcutsView` struct and Shortcuts settings pane
- Removed `cacheActivationShortcuts()` method (~48 lines)
- Removed force reset shortcut check in `processKeyEvent`
- Simplified `startEventTapMonitoring()` to directly create `Karabiner2InputMethod`
- Simplified `stopEventTapMonitoring()` and health timer
- Made `executeActionByStateId()` self-contained: uses `mapping.bundleId` to show window with correct app config before navigating groups or executing sticky actions

**Defaults.swift:**
- Reduced `InputMethodPreference` to single `.karabiner2` case

**Settings/AdvancedPane.swift:**
- Renamed section to "Karabiner Integration"
- Removed input method picker and Karabiner v1 UI

**Controller.swift:**
- Removed Karabiner v1 `leader_mode` reset block

**Other:**
- Created `tasks/future-plans.md` for planned features (bidirectional converter, search keymaps, CLI extraction)
- Updated `project.pbxproj` to remove deleted file references

### Key Design Decisions
- `stateid` is now self-contained: if the window isn't visible, it shows it with the right config before navigating groups or executing sticky-mode actions
- Normal-mode actions execute directly without needing the window visible
- `KeyboardShortcuts.Name` extension kept in Defaults.swift — the exporter's `resolveActivationShortcut()` still reads these values to generate Karabiner configs
- Goku continues using `:shell` since it doesn't natively support `send_user_command`

---

# Eliminate seqd dependency + v1 payload protocol

## Tasks
- [x] Add v1 structured payload handling to `KarabinerUserCommandReceiver`
- [x] Replace shell commands in Goku exporter with `send_user_command` v1 payloads
- [x] Handle `open_app`, `open_app_toggle`, `open`, `open_with_app` natively in Leader Key
- [x] Remove all seqd socket forwarding code
- [x] Add `background` flag support for URL opens (Raycast deep links)
- [x] Fix sticky mode: add `["leaderkey_sticky" 0]` to activation rules
- [x] Fix sticky-mode key ordering for Karabiner key repeat
- [x] Optimize app activation with `NSRunningApplication.activate()` fast path
- [x] Update CLAUDE.md with v1 protocol docs, testing commands, key repeat gotcha
- [x] Build and verify

## Review

### Summary
Eliminated the seqd daemon dependency by implementing native app management in Leader Key. Replaced all `shell_command` and `socket_command` based app/URL opening with Karabiner's `send_user_command` using structured v1 JSON payloads. This removes the need for seqd (which was causing 78% CPU via ScreenCaptureKit screen recording).

### Changes Made

**`KarabinerUserCommandReceiver.swift`** — Native app management (~100 lines added, seqd code removed):
- Added v1 payload routing (`handleV1Payload`) for `open_app`, `open_app_toggle`, `open`, `open_with_app`
- `resolveAppURL()` — resolves app names/paths to URLs (searches /Applications, /System/Applications, ~/Applications)
- `findRunningApp()` — finds running app by bundle ID or localized name
- `openApp()` — fast path via `NSRunningApplication.activate()`, fallback to `NSWorkspace.openApplication`
- `openAppToggle()` — toggle hide/activate for running apps, launch if not running
- `openWithApp()` — opens files/URLs with specific app
- Background URL opening via `NSWorkspace.OpenConfiguration.activates = false`
- Removed `sendToSeqd()`, `seqdSocket` constant

**`Karabiner2Exporter.swift`** — v1 payload helpers:
- Replaced `gokuSocketCommand`/`karSocketCommand` with `gokuOpenApp`/`gokuOpen`/`karOpenApp`/`karOpen`
- All app/URL actions now use `send_user_command` with v1 JSON payloads
- Added `["leaderkey_sticky" 0]` to all activation manipulators
- Fixed sticky-mode key ordering (key events last for Karabiner key repeat)

**`CLAUDE.md`** — Documentation:
- v1 payload protocol in Key Design Decisions
- Manual testing commands for all v1 payload types
- Key repeat gotcha: last event in `to` array gets repeat

---

# Native menu item clicking (v1 payload)

## Tasks
- [x] Add `menu` case to `handleV1Payload` in `KarabinerUserCommandReceiver.swift`
- [x] Implement `selectMenuItem` using AX APIs with seq's improvements (descendant search depth 6, description fallback, debug logging)
- [x] Add `gokuMenu`/`karMenu` helpers to `Karabiner2Exporter.swift`
- [x] Add `menu` action type to `Type` enum, Controller, exporter (Goku + kar), icon, display name
- [x] Build and verify
- [x] Update CLAUDE.md with menu testing command

## Review

Added native menu item clicking as a first-class action type in Leader Key.

**Value format**: `"AppName > Menu > Submenu > Item"` — first component is the app name, rest is the menu path.

**Example config**: `{"key": "b", "type": "menu", "value": "IntelliJ IDEA > Git > Branches...", "label": "Git Branches"}`

### Files changed:
- **`UserConfig.swift`** — Added `case menu` to `Type` enum + display name (shows menu path without app name)
- **`Controller.swift`** — Parses value, calls `KarabinerUserCommandReceiver.selectMenuItemDirectly()`
- **`KarabinerUserCommandReceiver.swift`** — Added `selectMenuItemDirectly()` static entry point, v1 `menu` payload handling
- **`Karabiner2Exporter.swift`** — Added `.menu` to both Goku and kar terminal action generators + kar mapping generator
- **`ActionIcon.swift`** — `filemenu.and.selection` SF Symbol for menu actions

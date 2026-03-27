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

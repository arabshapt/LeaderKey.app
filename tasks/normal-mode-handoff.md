# Normal Mode Handoff

Last updated: 2026-04-25

This document captures the normal-mode plan and implementation state so a new Codex session can continue without needing the original conversation.

## Goal

Add a Vim/Doom Emacs/Spacemacs/LazyVim style normal mode to Leader Key.

Normal mode is a persistent shortcut mode:

- It is enabled by a Leader Key action.
- It stays active until the user enters input mode or disables normal mode.
- It is app-specific: the same key can do different things in Chrome, IntelliJ, etc.
- It supports a shared fallback keymap.
- Unspecified base-state keys pass through to the frontmost app.
- It must not interfere with existing Leader Key, sticky mode, app fallback, layers, activation rules, or Karabiner behavior.

## Design Decisions

- The normal-mode state machine lives in Karabiner, matching existing `leader_state` and sticky-mode patterns.
- Normal configs are separate from existing configs:
  - `normal-fallback-config.json`
  - `normal-app.<bundleId>.json`
- Normal mode has isolated Karabiner variables:
  - `leaderkey_normal_enabled`
  - `leaderkey_normal_input`
  - `leaderkey_normal_state`
- Normal rules are active only when:
  - `leaderkey_normal_enabled == 1`
  - `leaderkey_normal_input != 1`
  - `leader_state == 0`
- App-specific normal mappings emit before normal fallback mappings.
- Base-state unbound keys pass through because there is no base catch-all.
- Pending-state invalid keys are consumed and reset `leaderkey_normal_state` to base.
- Escape and Caps Lock are reserved built-in normal-mode control keys in v1:
  - Pending normal sequence: reset to base normal.
  - Base normal: disable normal mode and emit `normal_off`.
  - Input mode: pass through to the frontmost app.
- Normal-mode group transitions only set `leaderkey_normal_state`; they do not emit `stateid` and do not show the overlay.
- Normal-mode terminal actions emit `stateid <id>` and resolve through `leaderkey-state-mappings.json`.
- Swift suppresses overlay behavior for normal-mode state mappings so normal actions run silently.
- Status item normal-mode state is driven by Karabiner string commands:
  - `normal_on`
  - `normal_off`
- Raycast support is deferred. It is in-repo work, not an external package-release blocker:
  - `packages/leaderkey-config-core`
  - `raycast-leader-key`

## User-Facing Config Shape

New action types:

```json
{
  "type": "normalModeEnable"
}
```

```json
{
  "type": "normalModeInput"
}
```

```json
{
  "type": "normalModeDisable"
}
```

Optional action field for normal terminal actions:

```json
{
  "type": "command",
  "value": "open -a Safari",
  "normalModeAfter": "normal"
}
```

Allowed values:

- `"normal"`: reset to base normal mode after the action.
- `"input"`: enter input mode after the action.
- `"disabled"`: disable normal mode after the action.

Default is `"normal"`.

## Implementation Summary

### Config Model And Loading

Implemented normal-mode config discovery and merge behavior.

Touched files:

- `Leader Key/UserConfig.swift`
- `Leader Key/UserConfig+Creation.swift`
- `Leader Key/UserConfig+Deletion.swift`
- `Leader Key/UserConfig+Discovery.swift`
- `Leader Key/UserConfig+EditingState.swift`
- `Leader Key/UserConfig+FileManagement.swift`
- `Leader Key/UserConfig+LoadingDecoding.swift`
- `Leader Key/UserConfig+Saving.swift`

Main changes:

- Added normal config constants and display naming.
- Added `UserConfigFileKind` helpers for regular app, normal app, global, fallback, and normal fallback configs.
- Added `Type.normalModeEnable`, `Type.normalModeInput`, and `Type.normalModeDisable`.
- Added `Type.isModeControlAction`.
- Added `NormalModeAfter` and `Action.normalModeAfter`.
- Updated Codable, equality, duplicate handling, best-guess names, and empty-value decoding.
- Added `ensureNormalFallbackConfigExists()`.
- Added `getNormalFallbackConfig()`, `getNormalConfig(for:)`, and `mergeNormalConfigWithFallback()`.
- Normal app configs merge with normal fallback for editing.
- Saving strips fallback entries for both regular app configs and normal app configs.
- Normal fallback is protected from deletion.
- App icon extraction works for both regular and normal app config names.
- Command Scout is restricted to regular app configs.

### Settings UI

Touched files:

- `Leader Key/Settings/GeneralPane.swift`
- `Leader Key/Views/ConfigEditorView.swift`
- `Leader Key/Views/NativeConfigEditorView.swift`
- `Leader Key/CommandScoutModels.swift`

Main changes:

- Sidebar supports normal configs.
- Add Config sheet can create `normal-app.<bundleId>.json`.
- Normal mode configs are excluded from Command Scout.
- Type pickers include the three normal-mode control actions.
- Normal-mode control actions are rendered as no-value actions.
- Sticky-mode toggles are hidden for mode-control actions.
- Editors expose the `normalModeAfter` picker for applicable actions.

### Karabiner Export

Touched file:

- `Leader Key/Karabiner2Exporter.swift`

Main changes:

- Added `StateMapping.Scope.normalShared`, `.normalOverride`, and `.normalSuppress`.
- Added normal variable names:
  - `leaderkey_normal_enabled`
  - `leaderkey_normal_input`
  - `leaderkey_normal_state`
- Export entrypoints now accept `normalAppConfigs`.
- App aliases are built from both regular app configs and normal app configs, without duplicate aliases.
- State ID namespace includes normal scopes to avoid collisions.
- Normal terminal actions are written to `leaderkey-state-mappings.json`.
- Normal group transitions stay entirely in Karabiner and are not added to state mappings.
- Normal app rules emit before normal fallback rules.
- Added normal-mode built-in control rules for Escape and Caps Lock.
- Added pending-state invalid-key catch-all for normal sequences.
- Reserved Escape and Caps Lock are skipped from normal configs.
- Normal terminal actions apply `normalModeAfter`.
- `.normalModeEnable`, `.normalModeInput`, and `.normalModeDisable` export as direct Karabiner variable transitions.
- Regular Leader Key terminal mappings special-case these actions so a Leader Key action can enable/input/disable normal mode directly.
- Sticky-mode shortcut key-event-last behavior was not changed.

Generated Karabiner rule groups:

- `LeaderKeyManaged/NormalAppMode/<alias>`
- `LeaderKeyManaged/NormalFallbackMode`
- `LeaderKeyManaged/NormalControls`
- `LeaderKeyManaged/NormalCatchAll`

### Runtime Dispatch

Touched files:

- `Leader Key/AppDelegate.swift`
- `Leader Key/Controller.swift`
- `Leader Key/Karabiner2InputMethod.swift`
- `Leader Key/KarabinerCommandRouter.swift`
- `Leader Key/StatusItem.swift`
- `Leader Key/UnixSocketServer.swift`

Main changes:

- `Karabiner2InputMethod.exportCurrentConfiguration()` discovers and loads normal app configs.
- Added normal config metadata loading.
- Added `loadAndMergeNormalAppConfig`.
- `KarabinerCommandRouter` handles `normal_on` and `normal_off`.
- `UnixSocketServerDelegate` now has `unixSocketServerDidReceiveNormalModeStatus(active:)`.
- `AppDelegate` updates status-item normal mode state.
- `StatusItem` has `normalModeActive` and shows a blue filled variant when normal mode is active and the overlay is not active.
- `Controller.runAction` handles:
  - `.normalModeEnable`
  - `.normalModeInput`
  - `.normalModeDisable`
- `executeActionByStateId` detects normal mapping scopes and runs normal terminal actions silently, without showing or focusing the overlay.
- Normal shared mappings resolve against the frontmost app normal config when possible.
- Normal override mappings resolve against the mapped bundle ID.
- Normal group state IDs are ignored in Swift because group transitions are Karabiner-only.

## Tests Added Or Updated

Touched files:

- `Leader KeyTests/Karabiner2ExporterKarConfigTests.swift`
- `Leader KeyTests/KarabinerCommandRouterTests.swift`
- `Leader KeyTests/UserConfigTests.swift`

Coverage added:

- Normal config creation/discovery.
- Normal app config plus normal fallback merge behavior.
- Normal variables and guards in exported Karabiner config.
- App override before fallback.
- `normalModeAfter`.
- Escape/Caps Lock cascade.
- Router handling for `normal_on` and `normal_off`.
- Normal state scopes and collision-free namespace behavior.

Regression coverage preserved:

- Existing Leader Key mappings.
- Sticky mode.
- Sticky shortcut direct key-event export behavior.
- App fallback.
- Activation rules.

## Verification

The regular signed test command is blocked on this machine by a missing local signing certificate:

```sh
xcodebuild -scheme "Leader Key" -testPlan "TestPlan" test
```

Error observed:

```text
No signing certificate "Mac Development" found ... team ID "DDB8SQMXS9"
```

The signing-disabled test run passed:

```sh
xcodebuild -scheme "Leader Key" -testPlan "TestPlan" test CODE_SIGNING_ALLOWED=NO
```

Result:

```text
153 tests, 1 skipped, 0 failures
```

There are existing swift-format warnings in the project, but the build and tests passed with signing disabled.

## Current Worktree State After Implementation

Expected modified files from this feature:

```text
Leader Key/AppDelegate.swift
Leader Key/CommandScoutModels.swift
Leader Key/Controller.swift
Leader Key/Karabiner2Exporter.swift
Leader Key/Karabiner2InputMethod.swift
Leader Key/KarabinerCommandRouter.swift
Leader Key/Settings/GeneralPane.swift
Leader Key/StatusItem.swift
Leader Key/UnixSocketServer.swift
Leader Key/UserConfig+Creation.swift
Leader Key/UserConfig+Deletion.swift
Leader Key/UserConfig+Discovery.swift
Leader Key/UserConfig+EditingState.swift
Leader Key/UserConfig+FileManagement.swift
Leader Key/UserConfig+LoadingDecoding.swift
Leader Key/UserConfig+Saving.swift
Leader Key/UserConfig.swift
Leader Key/Views/ConfigEditorView.swift
Leader Key/Views/NativeConfigEditorView.swift
Leader KeyTests/Karabiner2ExporterKarConfigTests.swift
Leader KeyTests/KarabinerCommandRouterTests.swift
Leader KeyTests/UserConfigTests.swift
tasks/normal-mode-handoff.md
```

Pre-existing dirty files that were already modified before this feature work and should not be reverted unless the user asks:

```text
kar
karabiner.ts/configs/leaderkey/leaderkey-generated.json
```

## Manual Test Plan

Use these checks before shipping:

1. Create a Leader Key binding for `normalModeEnable`.
2. Create `normal-fallback-config.json` with at least one normal-mode shortcut.
3. Create two app-specific configs, for example:
   - `normal-app.com.google.Chrome.json`
   - `normal-app.com.jetbrains.intellij.json`
4. Bind the same key differently in Chrome and IntelliJ.
5. Apply/export config.
6. Confirm:
   - Normal mode is inactive by default.
   - Leader Key overlay still works normally.
   - Triggering `normalModeEnable` activates normal mode.
   - Status item shows normal-mode state.
   - In Chrome, the test key fires Chrome-specific action.
   - In IntelliJ, the same key fires IntelliJ-specific action.
   - In an app without a normal app config, fallback normal bindings work.
   - Unbound base-state keys pass through.
   - Nested normal sequences work.
   - Invalid key during a pending sequence is consumed and resets to base normal mode.
   - Escape and Caps Lock reset pending normal sequence.
   - Escape and Caps Lock at base normal disable normal mode.
   - Escape and Caps Lock pass through in input mode.
   - `normalModeInput` suppresses all normal bindings.
   - `normalModeDisable` disables normal mode.
   - Normal terminal actions run silently without flashing the overlay.
   - Existing sticky mode behavior still works.
   - Sticky-mode shortcut key repeat still works for direct shortcut exports.

## Deferred Work

### Raycast

Raycast support is deferred. The work is in this repo:

- `packages/leaderkey-config-core`
- `raycast-leader-key`

Needed later:

- Add discovery patterns for:
  - `normal-fallback-config.json`
  - `normal-app.<bundleId>.json`
- Update Browse Configs and Search Shortcuts to surface normal scopes.
- Ensure Raycast writes JSON directly and notifies Leader Key over `/tmp/leaderkey.sock`.

### UX Polish

Possible follow-ups:

- Add a user setting for status-item normal-mode indicator style.
- Add visual feedback for pending-state invalid-key reset.
- Add validation warnings if a user tries to bind Escape or Caps Lock in normal configs.
- Add help text or examples for normal mode configs in docs.
- Add a small sample normal fallback config.

## Useful Commands For A New Session

Inspect current changes:

```sh
git status --short
```

Run tests with signing disabled:

```sh
xcodebuild -scheme "Leader Key" -testPlan "TestPlan" test CODE_SIGNING_ALLOWED=NO
```

Run the signed test command if local signing is configured:

```sh
xcodebuild -scheme "Leader Key" -testPlan "TestPlan" test
```

Search normal-mode implementation points:

```sh
rg "normalMode|normal_mode|leaderkey_normal|normalShared|normalOverride|normalSuppress|normal_on|normal_off"
```

Inspect Karabiner export output after applying config:

```sh
rg "NormalAppMode|NormalFallbackMode|NormalControls|NormalCatchAll|leaderkey_normal" karabiner.ts/configs/leaderkey/leaderkey-generated.json
```

## Suggested Prompt For Future Codex Session

```text
We are continuing the Leader Key normal-mode implementation.
Read tasks/normal-mode-handoff.md first.
The feature adds Vim-like persistent normal mode using normal-fallback-config.json and normal-app.<bundleId>.json, Karabiner variables leaderkey_normal_enabled/input/state, state-mapped terminal actions, Karabiner-only group transitions, Escape/Caps Lock cascade, and overlay suppression for normal scopes.
Please inspect the current worktree, do not revert pre-existing dirty kar or karabiner.ts/configs/leaderkey/leaderkey-generated.json changes, run tests with CODE_SIGNING_ALLOWED=NO, then continue with the next requested task.
```


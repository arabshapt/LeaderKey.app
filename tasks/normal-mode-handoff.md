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
  - `leaderkey_normal_active`
  - `leaderkey_normal_input`
  - `leaderkey_normal_state`
- `leaderkey_normal_active == 1` is the external integration flag for "normal mode capture is active
  right now". It is `0` in input mode and when the feature is disabled.
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
  - `normal_input`
  - `normal_off`
- Raycast support is in-repo and implemented for Browse Configs, Search Shortcuts, Add/Edit by Path, and config creation:
  - `packages/leaderkey-config-core`
  - `raycast-leader-key`
- Command Scout remains restricted to regular app configs.

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

Normal-mode hold layers use `type: "layer"` in normal configs. Layers are hold-only, matching Goku
`layer`: the layer is active while the trigger key is physically held and exits on key-up. They are
not simlayers, tap-toggle layers, or sticky layers.

```json
{
  "key": "f",
  "type": "layer",
  "label": "Find",
  "tapAction": {
    "type": "shortcut",
    "value": "Cf",
    "normalModeAfter": "normal"
  },
  "actions": [
    { "key": "b", "type": "shortcut", "value": "Cb" },
    {
      "key": "g",
      "type": "group",
      "actions": [
        { "key": "x", "type": "command", "value": "echo nested" }
      ]
    }
  ]
}
```

Layer constraints in v1:

- Layers are normal-mode only. Regular Leader Key configs can decode them, but the Karabiner exporter
  ignores layer bindings outside normal scopes. Native Settings and Raycast only offer new layer
  creation in normal fallback or normal app config scopes.
- `tapAction` is optional. If it is omitted, a short tap passes the original trigger key through.
- Holding past Karabiner's tap timeout without pressing a child key does nothing.
- `tapAction` must be a terminal action. It cannot be `group` or `layer`.
- Nested layers and modifier-key layer triggers are rejected by validation.
- Sibling key collisions are rejected across actions, groups, and layers.

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
  - `leaderkey_normal_active`
  - `leaderkey_normal_input`
  - `leaderkey_normal_state`
  - External Goku/manual Karabiner integrations should key off `leaderkey_normal_active`, not
    `leaderkey_normal_state` or `leaderkey_normal_input`, when they need to know whether Leader Key
    normal mode is currently active.
- Export entrypoints now accept `normalAppConfigs`.
- App aliases are built from both regular app configs and normal app configs, without duplicate aliases.
- State ID namespace includes normal scopes to avoid collisions.
- Normal terminal actions are written to `leaderkey-state-mappings.json`.
- Simple normal-mode `.shortcut` terminal actions are also emitted directly as Karabiner key events
  instead of going through `stateid`. This applies to base normal actions, layer tap actions, and layer
  child actions. Keep normal-mode reset/status variable events before the shortcut key events so the
  final `to` event remains the shortcut key event for Karabiner repeat. Complex shortcut sequences stay
  on the `stateid` path.
- Normal-mode `.keystroke` actions are emitted directly as v1 Karabiner `keystroke` payloads instead
  of going through `stateid`, including layer child keystrokes.
- Normal group transitions stay entirely in Karabiner and are not added to state mappings.
- Normal app rules emit before normal fallback rules.
- Added normal-mode built-in control rules for Escape and Caps Lock.
- Added pending-state invalid-key catch-all for normal sequences.
- Reserved Escape and Caps Lock are skipped from normal configs.
- Normal terminal actions apply `normalModeAfter`.
- `.normalModeEnable`, `.normalModeInput`, and `.normalModeDisable` export as direct Karabiner variable transitions.
- Regular Leader Key terminal mappings special-case these actions so a Leader Key action can enable/input/disable normal mode directly.
- Sticky-mode shortcut key-event-last behavior was not changed.
- Added normal-mode hold-layer export:
  - `leaderkey_normal_layer_state`
  - `leaderkey_normal_layer_sequence_state`
  - Layer trigger `to` sets layer state and resets layer sequence state.
  - Layer trigger `to_if_alone` runs `tapAction` or passes the original key through.
  - Layer trigger `to_after_key_up` resets both layer variables.
- Layer children dispatch through normal-mode state mappings unless they are simple `.shortcut`
  actions that can be emitted directly for key repeat; overlay suppression is reused for the state-id path.
  - Layer child groups use `leaderkey_normal_layer_sequence_state`, not `leaderkey_normal_state`.
  - Invalid keys while a layer group is pending consume/reset only layer sequence state.
  - Escape/Caps while a layer group is pending reset only layer sequence state; base held layer Escape/Caps pass through.

Generated Karabiner rule groups:

- `LeaderKeyManaged/NormalAppMode/<alias>`
- `LeaderKeyManaged/NormalFallbackMode`
- `LeaderKeyManaged/NormalControls`
- `LeaderKeyManaged/NormalCatchAll`
- `LeaderKeyManaged/NormalLayerCatchAll`

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
- `KarabinerCommandRouter` handles `normal_on`, `normal_input`, and `normal_off`.
- `UnixSocketServerDelegate` now has `unixSocketServerDidReceiveNormalModeStatus(_:)`.
- `AppDelegate` updates status-item normal mode state.
- `StatusItem` has distinct menu-bar states for idle, Leader overlay, sticky mode, normal mode,
  normal input mode, and reload success.
- Status item mode indicators are drawn as non-template colored badges instead of tinting the filled
  template asset. This avoids the black cutout rendering issue in the menu bar.
- `Controller.runAction` handles:
  - `.normalModeEnable`
  - `.normalModeInput`
  - `.normalModeDisable`
- `executeActionByStateId` detects normal mapping scopes and runs normal terminal actions silently, without showing or focusing the overlay.
- Normal-mode state-id action resolution descends through both groups and layers. Layer child mappings
  use paths like `["f", "j"]`, and layer tap-action mappings resolve through the layer key itself.
- Normal shared mappings resolve against the frontmost app normal config when possible.
- Normal override mappings resolve against the mapped bundle ID.
- Normal group state IDs are ignored in Swift because group transitions are Karabiner-only.

### Raycast And Config Core

Touched files:

- `packages/leaderkey-config-core/src/app-configs.ts`
- `packages/leaderkey-config-core/src/constants.ts`
- `packages/leaderkey-config-core/src/discovery.ts`
- `packages/leaderkey-config-core/src/index.ts`
- `packages/leaderkey-config-core/src/indexing.ts`
- `packages/leaderkey-config-core/src/labels.ts`
- `packages/leaderkey-config-core/src/mutations.ts`
- `packages/leaderkey-config-core/src/types.ts`
- `raycast-leader-key/src/action-form.ts`
- `raycast-leader-key/src/add-edit-by-path.tsx`
- `raycast-leader-key/src/browse-configs.tsx`
- `raycast-leader-key/src/create-app-config-form.tsx`
- `raycast-leader-key/src/deeplinks.ts`
- `raycast-leader-key/src/detail-presentation.ts`
- `raycast-leader-key/src/editor-form.tsx`
- `raycast-leader-key/src/form-utils.ts`
- `raycast-leader-key/src/macro-editor.tsx`
- `raycast-leader-key/src/presentation.ts`
- `raycast-leader-key/src/search-shortcuts.tsx`
- `raycast-leader-key/src/typed-path-create-picker.tsx`

Main changes:

- Config-core discovers `normal-fallback-config.json` and `normal-app.<bundleId>.json`.
- Normal app configs inherit from the normal fallback config in the generated cache payload.
- Config-core can create empty or templated normal app configs.
- Flat index records preserve `normalModeAfter`.
- Labels, previews, and mutation cloning understand the three normal-mode control actions.
- Raycast Browse Configs and Add/Edit by Path can target normal fallback and normal app scopes.
- Raycast Search Shortcuts surfaces normal records through the shared cache and labels inherited
  normal fallback overrides as normal app overrides.
- Raycast exposes current-app normal config deeplink templates.
- Raycast can create missing normal app configs from a normal app target.
- Raycast action forms include the three normal-mode control actions.
- Raycast action forms expose `normalModeAfter` for non-mode-control terminal actions.
- Macro editor options include normal-mode control actions.
- Config-core now treats `LayerNode` as a group-like container for indexing, search, path navigation,
  validation, and mutations.
- Normal app configs can inherit fallback layer children when layer metadata and `tapAction` match.
- Existing layers can be edited as path containers; missing intermediate typed-path segments are still
  auto-created as groups, not layers.
- Raycast Browse Configs, Search Shortcuts, Add/Edit by Path, typed-path creation, copy/paste, detail
  views, and editor forms understand layers.
- Raycast layer editing includes a nested tap-action editor that reuses the existing terminal action
  fields, macro step editor, and `normalModeAfter` picker.
- Raycast and Native Settings hide layer creation outside normal-mode configs. Raycast typed-path
  layer creation filters the config picker to normal fallback and normal app scopes.

## Tests Added Or Updated

Touched files:

- `Leader KeyTests/Karabiner2ExporterKarConfigTests.swift`
- `Leader KeyTests/KarabinerCommandRouterTests.swift`
- `Leader KeyTests/UserConfigTests.swift`
- `Leader KeyTests/KarCompilerServiceTests.swift`
- `packages/leaderkey-config-core/test/app-configs.test.ts`
- `packages/leaderkey-config-core/test/discovery-indexing.test.ts`
- `packages/leaderkey-config-core/test/labels.test.ts`
- `raycast-leader-key/test/action-form.test.ts`
- `raycast-leader-key/test/deeplinks.test.ts`
- `raycast-leader-key/test/form-utils.test.ts`

Coverage added:

- Normal config creation/discovery.
- Normal app config plus normal fallback merge behavior.
- Normal variables and guards in exported Karabiner config.
- App override before fallback.
- `normalModeAfter`.
- Escape/Caps Lock cascade.
- Router handling for `normal_on`, `normal_input`, and `normal_off`.
- Normal state scopes and collision-free namespace behavior.
- Status item mode badges use non-template images and no tint.
- Config-core discovery/indexing of normal fallback and normal app configs.
- Raycast deep links for normal fallback and normal app scopes.
- Raycast serialization for `normalModeAfter` and normal-mode control actions.
- Layer config validation for nested layers, modifier triggers, invalid tap actions, and sibling key
  collisions.
- Karabiner export of layer hold variables, `to_if_alone`, original-key tap passthrough, child actions,
  direct simple shortcut events, child groups, state mappings, and layer Escape reset.
- Runtime resolution of normal-mode layer child state IDs and layer tap-action state IDs.
- Config-core indexing, path navigation, and mutation behavior for layers.
- Raycast layer form/detail handling.

Regression coverage preserved:

- Existing Leader Key mappings.
- Sticky mode.
- Sticky shortcut direct key-event export behavior.
- App fallback.
- Activation rules.

## Verification

The signing-disabled debug build passed:

```sh
xcodebuild -scheme "Leader Key" -configuration Debug build CODE_SIGNING_ALLOWED=NO
```

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
159 tests, 1 skipped, 0 failures
```

TypeScript tests and typechecks passed:

```sh
npm run typecheck
npm test
```

Results:

```text
config-core: 36 tests, 0 failures
raycast-leader-key: 43 tests, 0 failures
both typechecks passed
root workspace typecheck passed
```

There are existing swift-format warnings in the project, but the build and tests passed with signing disabled.

## Current Worktree State After Implementation

Expected modified files from this feature:

```text
Leader Key/AppDelegate.swift
Leader Key/Cheatsheet.swift
Leader Key/CommandScoutService.swift
Leader Key/ConfigCache.swift
Leader Key/ConfigValidator.swift
Leader Key/Controller.swift
Leader Key/Karabiner2Exporter.swift
Leader Key/KarabinerExporter.swift
Leader Key/UserConfig+LoadingDecoding.swift
Leader Key/UserConfig+Saving.swift
Leader Key/UserConfig.swift
Leader Key/Views/ActionIcon.swift
Leader Key/Views/CommandScoutView.swift
Leader Key/Views/ConfigEditorView.swift
Leader Key/Views/NativeConfigEditorView.swift
Leader KeyTests/ConfigValidatorTests.swift
Leader KeyTests/Karabiner2ExporterKarConfigTests.swift
packages/leaderkey-config-core/src/index.ts
packages/leaderkey-config-core/src/indexing.ts
packages/leaderkey-config-core/src/labels.ts
packages/leaderkey-config-core/src/mutations.ts
packages/leaderkey-config-core/src/normalize.ts
packages/leaderkey-config-core/src/path-navigation.ts
packages/leaderkey-config-core/src/path-validation.ts
packages/leaderkey-config-core/src/types.ts
packages/leaderkey-config-core/src/utils.ts
packages/leaderkey-config-core/test/discovery-indexing.test.ts
packages/leaderkey-config-core/test/mutations.test.ts
packages/leaderkey-config-core/test/path-navigation.test.ts
raycast-leader-key/src/action-form.ts
raycast-leader-key/src/add-edit-by-path.tsx
raycast-leader-key/src/browse-configs.tsx
raycast-leader-key/src/browser.tsx
raycast-leader-key/src/clipboard.ts
raycast-leader-key/src/detail-presentation.ts
raycast-leader-key/src/editor-form.tsx
raycast-leader-key/src/form-utils.ts
raycast-leader-key/src/path-editor-view.tsx
raycast-leader-key/src/presentation.ts
raycast-leader-key/src/search-shortcuts.tsx
raycast-leader-key/src/scope-utils.ts
raycast-leader-key/src/typed-path-create-picker.tsx
raycast-leader-key/test/detail-presentation.test.ts
raycast-leader-key/test/form-utils.test.ts
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

### UX Polish

Possible follow-ups:

- Add a user setting for status-item normal-mode indicator style.
- Add visual feedback for pending-state invalid-key reset.
- Add validation warnings if a user tries to bind Escape or Caps Lock in normal configs.
- Add help text or examples for normal mode configs in docs.
- Add a small sample normal fallback config.
- Run a manual Raycast session to confirm Browse Configs and Add/Edit by Path workflows after
  installing the extension locally.

## Useful Commands For A New Session

Inspect current changes:

```sh
git status --short
```

Run tests with signing disabled:

```sh
xcodebuild -scheme "Leader Key" -testPlan "TestPlan" test CODE_SIGNING_ALLOWED=NO
```

Run TypeScript package checks:

```sh
npm install
npm --prefix packages/leaderkey-config-core test
npm --prefix packages/leaderkey-config-core run typecheck
npm --prefix raycast-leader-key test
npm --prefix raycast-leader-key run typecheck
```

Run the signed test command if local signing is configured:

```sh
xcodebuild -scheme "Leader Key" -testPlan "TestPlan" test
```

Search normal-mode implementation points:

```sh
rg "normalMode|normal_mode|leaderkey_normal|normalShared|normalOverride|normalSuppress|normal_on|normal_input|normal_off"
```

Inspect Karabiner export output after applying config:

```sh
rg "NormalAppMode|NormalFallbackMode|NormalControls|NormalCatchAll|leaderkey_normal" karabiner.ts/configs/leaderkey/leaderkey-generated.json
```

## Suggested Prompt For Future Codex Session

```text
We are continuing the Leader Key normal-mode implementation.
Read tasks/normal-mode-handoff.md first.
The feature adds Vim-like persistent normal mode using normal-fallback-config.json and normal-app.<bundleId>.json, Karabiner variables leaderkey_normal_enabled/active/input/state, state-mapped terminal actions, Karabiner-only group transitions, Escape/Caps Lock cascade, and overlay suppression for normal scopes.
Please inspect the current worktree, do not revert pre-existing dirty kar or karabiner.ts/configs/leaderkey/leaderkey-generated.json changes, run tests with CODE_SIGNING_ALLOWED=NO, then continue with the next requested task.
```

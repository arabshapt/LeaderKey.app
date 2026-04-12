# Plan: Command Scout and Leader Key UI Performance

## Context

Leader Key needs a feature that can help populate a new or existing app config with useful commands. The feature name is **Command Scout**.

The intended workflow is:

1. Pick an app config, or create a new app config and immediately open Command Scout.
2. Collect live menu items from the app when it is running.
3. Optionally use AI with a user-provided API key to research useful commands and shortcuts that are not exposed in menus.
4. Show reviewable suggestions with title, description, action type, value, source, confidence, and Leader Key sequence.
5. Let the user select suggestions and insert them into the editor session.
6. Do not write JSON directly. The normal Leader Key "Save Changes" path remains the only persistence path.

Important repo facts:

- Native config editor lives in `Leader Key/Views/NativeConfigEditorView.swift`.
- Settings/config selection UI lives in `Leader Key/Settings/GeneralPane.swift`.
- App config creation lives in `Leader Key/UserConfig+Creation.swift` and `AddConfigSheet` inside `GeneralPane.swift`.
- Live menu search already exists:
  - Swift socket command routing: `Leader Key/KarabinerCommandRouter.swift`
  - AX menu inventory implementation: `Leader Key/KarabinerUserCommandReceiver.swift`
  - TypeScript socket wrapper: `packages/leaderkey-config-core/src/leaderkey.ts`
  - Raycast picker: `raycast-leader-key/src/menu-picker.tsx`
- AI provider/API-key infrastructure does not exist yet.
- Do not add `leaderkey://` deeplinks. Prefer `/tmp/leaderkey.sock` socket triggers.
- Current workspace note: `Leader Key/CommandScoutModels.swift` may exist as an initial Codex sketch. Treat it as a starting point only; validate it before wiring it into the Xcode project.

## Product Goals

- Command Scout should make a new app config useful quickly, especially for large apps like Chrome.
- Menu inventory is the primary trusted source. AI/web research is an optional supplement.
- Suggestions must be review-first. No auto-write and no invisible config mutation.
- The native app is the first complete surface. Raycast support is required in a later stage, not optional.
- Leader Key UI should feel fast: quick to open, quick to navigate, no heavy scans or JSON work on the hot path.

## Success Criteria

- A user can create a new app config and choose **Create and Scout...** to open Command Scout immediately.
- A user can open **Command Scout...** from an existing app config.
- Menu-only scan works without an API key.
- AI scan works with Keychain-stored API keys for provider adapters.
- Suggestions show conflicts before apply.
- Applying selected suggestions mutates only `ConfigEditorSession` / in-memory editor state.
- Raycast has a Command Scout entry point and uses socket-based triggers, not deeplinks.
- No API key is written to config JSON, metadata JSON, Defaults, logs, Raycast local storage, or prompt debug bundles.
- Native Leader Key activation and command execution paths do not become slower.
- Tests do not call real AI providers.

## Stage 0: Cleanup and Guardrails

- Decide whether to keep or replace the current partial `Leader Key/CommandScoutModels.swift` sketch.
- If keeping it, add it to `Leader Key.xcodeproj/project.pbxproj` only after it compiles with the final model/service/UI split.
- Do not touch unrelated dirty files:
  - `kar`
  - `karabiner.ts/configs/leaderkey/leaderkey-generated.json`
- Keep socket preference visible in any new external trigger docs.
- Add a short note to `tasks/future-plans.md` linking to this plan if desired.

## Stage 1: Shared Command Scout Core

Add small, focused Swift files rather than growing the existing large editor view:

- `Leader Key/CommandScoutModels.swift`
- `Leader Key/CommandScoutService.swift`
- `Leader Key/Views/CommandScoutView.swift`
- `Leader KeyTests/CommandScoutTests.swift`

Core model:

- `CommandScoutSuggestion`
  - `id`
  - `title`
  - `category`
  - `source`
  - `actionType`
  - `actionValue`
  - `menuFallbackPaths`
  - `description`
  - `aiDescription`
  - `suggestedSequence`
  - `alternatives`
  - `confidence`
  - `conflictStatus`
  - `reviewNotes`

Accepted direct-apply action types:

- `menu`
- `shortcut`
- `keystroke`
- `url`

High-risk draft types:

- `command`
- `macro`
- `application`

High-risk drafts should be visible but not selected by "Select High Confidence". Require explicit manual selection and confirmation before apply. If macro support is not safe in v1, leave macro suggestions visible but not applyable.

Validation:

- Reject empty sequences.
- Reject duplicate sequence paths against current config and visible fallback items.
- Reject duplicate action signatures such as same action type plus same value.
- Reject malformed menu values. Required menu format is `App > Menu > Item`.
- Reject unsupported action types.
- For shortcut actions, accept only known Leader Key shortcut format or safely normalized known symbols. Do not silently invent shortcuts.
- If AI output is malformed, show an error and keep any menu-only suggestions.

Default categories:

- Tabs
- Windows
- Navigation
- Editing
- View
- Developer Tools
- Bookmarks
- Search
- History
- Misc

Default sequence strategy:

- Use 1 to 2 keys by default.
- Use 3 keys only when conflicts require it.
- Prefer category prefixes:
  - Tabs: `t`
  - Windows: `w`
  - Navigation: `n`
  - Editing: `e`
  - View: `v`
  - Developer Tools: `d`
  - Bookmarks: `b`
  - Search: `s`
  - History: `h`
  - Misc: `m`
- Never overwrite existing sequences.
- If a category prefix is already an action, choose a non-conflicting alternative and record the reason in `reviewNotes`.

## Stage 2: Local Menu Inventory Suggestions

Use existing AX menu inventory first:

- Use the existing `menu-items` socket route or the same underlying Swift implementation.
- Decode response shape compatible with current Raycast menu picker:
  - `appName`
  - `enabled`
  - `path`
  - `title`
- Convert enabled leaf menu items into `menu` suggestions:
  - `actionType = menu`
  - `actionValue = "<App Name> > <Menu Path>"`
  - `source = liveMenu`
  - `confidence = 0.8` or higher for enabled menu items
- Skip noisy or generally unhelpful menu paths by default:
  - About
  - Services
  - Hide
  - Hide Others
  - Show All
  - Quit
  - Help search entries
- Keep the raw inventory available in a debug bundle, but do not include API keys.
- Cache menu scan results per bundle ID for a short TTL, for example 5 minutes, to avoid repeated AX traversal while iterating.

Optional improvement:

- If AX exposes shortcut attributes reliably, add optional shortcut fields to menu inventory as backward-compatible optional JSON fields. Keep Raycast compatible with missing fields.

## Stage 3: AI Providers and Keychain

Add provider settings:

- Provider kind in Defaults.
- Model name in Defaults.
- Optional base URL in Defaults for OpenAI-compatible providers.
- Web research enabled flag in Defaults.
- API keys in Keychain only.

Provider kinds:

- Gemini
- OpenAI
- Anthropic
- OpenAI-compatible custom endpoint

Provider architecture:

- `AIProviderClient` protocol with a non-streaming JSON generation method.
- Provider capabilities include `supportsWebResearch`.
- If web research is requested but the selected provider/model cannot do it, show a clear warning and run non-web AI generation instead.
- Provider-specific request shapes must be checked against official docs during implementation. Do not guess API details from memory.
- Tests use mock clients only.

Security requirements:

- Do not log API keys.
- Do not include API keys in prompt debug bundles.
- Do not save API keys in Defaults.
- Do not store API keys in Raycast preferences for v1 if native app owns the provider settings.
- Redact Authorization headers and provider key query parameters in errors.

Prompt pack:

System prompt:

```text
You are Command Scout for Leader Key. Return strict JSON only. Suggest useful app commands for a keyboard-driven launcher. Prefer menu actions when the menu inventory contains the command. Use shortcuts or keystrokes only when the command is not available in the menu and the shortcut is reliable. Do not invent shortcuts. Mark uncertain data as low confidence. Do not suggest shell commands unless explicitly requested. Use short mnemonic Leader Key sequences, avoid collisions with existing sequences, and explain each sequence choice.
```

Inventory prompt:

```text
App: {{appName}}
Bundle ID: {{bundleId}}
Existing Leader Key config: {{existingConfigSummary}}
Fallback config summary: {{fallbackSummary}}
Live menu inventory: {{menuItemsJson}}
Allowed action types: menu, shortcut, keystroke, url
Web research enabled: {{webResearchEnabled}}

Find useful commands missing from the current Leader Key config. Include common menu commands, important shortcuts not exposed in the menu, and app-specific high-value workflows. Return JSON with:
suggestions: [{title, category, source, actionType, actionValue, description, aiDescription, confidence, sourceNotes}]
For menu actions, actionValue must be "{{appName}} > <menu path>". For shortcuts, include the exact shortcut string and source.
```

Sequence prompt:

```text
Given these suggestions and this existing sequence tree, assign Leader Key sequences.
Rules: prefer 1-2 keys, allow 3 keys for conflicts, use mnemonic category prefixes, never overwrite existing sequences, avoid reserved keys, keep related commands near each other, and provide 2 alternatives for each conflict.
Return JSON with:
[{suggestionId, suggestedSequence, alternatives, collisionReason, mnemonicReason}]
Existing sequence tree: {{sequenceTree}}
Reserved keys: {{reservedKeys}}
Suggestions: {{suggestions}}
```

Local post-processing rule:

```text
Treat AI output as untrusted draft data. The app validates JSON, repairs only safe sequence formatting, rejects conflicts, and requires user confirmation before inserting anything.
```

## Stage 4: Native UI

Add entry points:

- In existing app configs: **Command Scout...** button near editor actions in `GeneralPane`.
- In `AddConfigSheet`: **Create and Scout...** button that creates an empty config, selects it, loads the native editor session, then opens Command Scout.
- Disable or explain Command Scout for Global Default and Fallback App Config, because the feature needs an app bundle ID.

Command Scout UI layout:

- Left controls:
  - Source status: menu scan, AI enabled, web enabled.
  - Provider picker.
  - Model text field.
  - API key secure field with Save/Clear.
  - Optional base URL field for OpenAI-compatible provider.
  - Scan button.
  - Category filter.
- Main table:
  - Checkbox.
  - Suggested sequence.
  - Title.
  - Category.
  - Action type.
  - Confidence.
  - Conflict badge.
  - Source.
- Detail pane:
  - Description.
  - AI description.
  - Action value.
  - Menu fallback paths.
  - Alternatives.
  - Source notes / web notes.
  - Editable sequence.
  - Editable action value.
- Footer actions:
  - Select High Confidence.
  - Regenerate Sequences.
  - Apply Selected.
  - Copy Prompt Debug Bundle.
  - Close.

Apply behavior:

- Applying selected suggestions inserts into `ConfigEditorSession`.
- It must not write config JSON directly.
- Insert by sequence path:
  - Single key: insert action at root if clear.
  - Multi-key: create or reuse groups for intermediate keys.
  - First intermediate group may use the suggestion category as its label.
- Re-run validation after insertion.
- The normal Save Changes button persists the config.

## Stage 5: Socket Contract for External Triggers

Add socket commands only after native UI is usable:

Recommended command:

```text
command-scout open {"bundleId":"com.google.Chrome","source":"raycast"}
```

Optional later commands:

```text
command-scout status
command-scout open-current
```

Rules:

- Do not add `leaderkey://`.
- Do not expose API keys over the socket.
- The socket command opens/focuses the native Command Scout UI; native app owns AI provider settings and Keychain.
- If the app config does not exist, show a native prompt to create it or return a clear error to Raycast.

## Stage 6: Raycast Side

Add Raycast support after the native socket command exists.

Config core additions:

- In `packages/leaderkey-config-core/src/leaderkey.ts`, add a socket helper:
  - `openLeaderKeyCommandScout(payload: { bundleId?: string; appName?: string; configKey?: string; source?: "raycast" })`
- Keep timeout/error handling consistent with existing `apply-config`, `menu-items`, and `sync-goku-profile`.
- Export it from `packages/leaderkey-config-core/src/index.ts`.

Raycast commands:

- Add `raycast-leader-key/src/command-scout.tsx`.
- Add a command entry in `raycast-leader-key/package.json`.
- UI flow:
  - Let user choose from running apps and/or app configs.
  - Action: **Open Command Scout in Leader Key**.
  - Optional action: **Create App Config and Open Command Scout** if no app config exists.
  - Show clear error if Leader Key socket is unavailable.

Raycast should not own API keys in v1:

- Native app owns provider settings and Keychain.
- Raycast only triggers the native UI through socket.
- Later, if Raycast needs a full suggestion browser, add socket APIs for suggestion sessions rather than duplicating AI provider/key storage.

Raycast tests:

- Socket command payload is encoded correctly.
- Errors from unavailable socket are surfaced.
- Existing menu picker still works.
- Existing config mutation commands are unaffected.

## Stage 7: Make Leader Key UI Feel Fast

Treat this as a parallel performance track, not just Command Scout polish.

Performance targets:

- Leader Key overlay warm open should feel instant and avoid disk/network work.
- App activation and state-id action execution should stay on cached data paths.
- Settings config editor should not block on all-app discovery, AI work, menu scanning, or expensive tree rebuilds.
- Command Scout scans must never block the main thread.

Instrumentation first:

- Add `os_signpost` or existing debug signpost style around:
  - activation received
  - overlay window first shown
  - state ID received
  - action lookup
  - action execution start/end
  - config reload start/end
  - native outline `rebuildIndex`
  - Command Scout menu scan
  - Command Scout AI request
- Use these signposts before making speculative optimizations.

Likely native UI optimizations:

- Keep Leader Key overlay window/controller warm instead of recreating heavy view state on open.
- Avoid JSON decode, config merge, fallback merge, or icon lookup on the activation hot path.
- Ensure `actionCache` and `KeyLookupCache` are the source of truth during key execution.
- Defer nonessential UI updates until after the overlay is visible.
- Cache app icons aggressively and avoid repeated `NSWorkspace.shared.runningApplications` scans in tight UI loops.
- Make menu inventory scans async and cached by bundle ID.
- In settings, avoid rebinding/rebuilding `ConfigEditorSession` unless the selected config or fallback visibility actually changes.
- Keep native outline rendering incremental where possible. Avoid full tree rebuilds on action-only edits.
- Keep verbose logging off the hot path in release builds.
- Make prompt debug bundle generation lazy, only when the user clicks copy.

Raycast performance:

- Reuse existing flat config index in `@leaderkey/config-core`.
- Avoid re-reading all config files for every list render when cached data is valid.
- Socket trigger should be one short request and return quickly.

Command Scout performance:

- Menu-only scan should show partial results quickly.
- AI results can append later or replace suggestions after validation.
- Use cancellation when the sheet closes or a new scan starts.
- Cap prompt input size by summarizing huge menu inventories and existing configs.
- Do not send full config JSON if a compact summary is enough.

## Stage 8: Tests and Verification

Swift tests:

- API keys do not appear in config JSON, metadata JSON, Defaults, logs, or debug bundles.
- Suggestion parser handles:
  - valid JSON
  - fenced JSON
  - malformed JSON
  - missing fields
  - unsupported action types
  - duplicate IDs
- Sequence validation catches:
  - duplicate sequence
  - duplicate action signature
  - empty sequence
  - invalid shortcut value
  - malformed menu value
- Menu suggestions produce `App > Menu > Item`.
- Applying suggestions updates `ConfigEditorSession` only and does not write config files.
- Mock provider clients are used. No test should call real provider APIs.

Raycast tests:

- New Command Scout command renders.
- Socket payload is correct.
- Socket errors are displayed.
- Typecheck passes.
- Existing menu picker and sync-goku-profile commands continue to pass tests.

Manual verification:

- Run Leader Key.
- Create a new Chrome config with **Create and Scout...**.
- Scan with Chrome running and accessibility permissions enabled.
- Select a few menu suggestions and apply them.
- Confirm they appear in the editor but are not persisted until Save Changes.
- Save, reload Karabiner integration, and trigger the new sequences.
- Run Raycast Command Scout and confirm it opens the native sheet for the selected app.
- Profile warm overlay open before and after performance changes.

Suggested commands:

```bash
xcodebuild -scheme "Leader Key" -configuration Debug test
npm run typecheck -w @leaderkey/config-core
npm run typecheck -w leader-key-raycast
npm run test -w @leaderkey/config-core
npm run test -w leader-key-raycast
git diff --check
```

## Done Definition

- Native Command Scout works menu-only and AI-assisted.
- API keys are stored only in Keychain.
- Suggestions are validated and reviewable.
- Apply mutates only the editor session until normal save.
- Raycast has a socket-based Command Scout command.
- No `leaderkey://` scheme is added.
- UI performance has measurable signposts and no new hot-path regressions.
- Tests pass without real AI provider calls.

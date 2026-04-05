# Refactor Raw JSON Rules to Idiomatic karabiner.ts Builder API

## Tasks
- [x] Batch 1: Refactor 5 tiny rules (1 manipulator each)
- [x] Batch 2: Refactor ~12 small rules (2-6 manipulators)
- [x] Batch 3: Refactor ~15 medium rules (7-30 manipulators)
- [x] Batch 4: Refactor large mode/device rules (escape-mode, tilde-mode, arc/dia/zen/intellij-kinesis, global-kinesis-shortcuts, appswitcher-kinesis, tab-mode, backslash-mode)
- [x] Batch 5: Refactor LeaderKey infrastructure (modifier-passthrough, activation)
- [x] Run final full parity test — all 7 tests pass

## Kept as raw JSON (intentional)
- `quote-mode.ts`, `d-mode.ts`, `o-mode.ts`, `a-mode.ts`, `f-mode.ts`, `slash-mode.ts`, `spacebar-mode.ts` — use `simultaneous` from events not supported by `map()` builder
- `global-all-keyboards.ts` — uses `pointing_button`, `consumer_key_code`, `parameters`
- `global-mode.ts`, `fallback-mode.ts` — generated state machines (148/193 manipulators), no hand-editing benefit

## Review

**What changed**: Converted ~30 rule files from raw `JSON.parse(String.raw\`...\`)` blocks to idiomatic karabiner.ts builder API (`map()`, `.to()`, `.condition()`, `.build()`). Total ~600+ manipulators refactored.

**Files refactored** (all in `karabiner.ts/configs/arabshapt/src/`):
- `modes/`: escape-mode.ts (39), tilde-mode.ts (34), tab-mode.ts (21), backslash-mode.ts (18)
- `app-rules/`: safari.ts (7), chrome.ts (8), emacs.ts (9), codecursor.ts (13), code.ts (20), chrome-kinesis.ts (22), warp-apple.ts (5), warp-kinesis.ts (6), arc-apple.ts (6), arc-kinesis.ts (41), dia-kinesis.ts (41), zen-kinesis.ts (41), intellij-kinesis.ts (86), appswitcher-kinesis.ts (12)
- `device-rules/`: terminal-rcmd.ts, kinesis.ts, global-kinesis-end.ts (6), global-end-apple.ts (2), global-apple-shortcuts.ts (26), global-kinesis-shortcuts.ts (124)
- `leaderkey/`: modifier-passthrough.ts (8), activation.ts (56), leader-local-to-apps.ts
- Infrastructure: auto-layers.ts, global-start.ts, caps-layer.ts, test-rule.ts

**Key patterns used**:
- `...map(key, mandatory, optional).to(key, mods).condition(cond).build()` — spread into array
- `ifVar(name, value)` / `ifVar(name, value).unless()` for variable conditions
- `ifApp(bundleId)` for app conditions
- `ifDevice([...])` for device conditions (shared `kinesis`, `apple_built_in` from devices.ts)
- `.toVar()`, `.toSendUserCommand()`, `.toConsumerKey()`, `.toNotificationMessage()` for complex to events
- `mapPointingButton()` for pointing_button from events
- Exact modifier string preservation (e.g., `'command'` vs `'left_command'`)

**Parity verification**: SHA-256 hash comparison of canonicalized JSON output. All 76 rules match the snapshot exactly.

---

# Fix Raycast commands showing "No Results" during async data load

## Tasks
- [x] Add `List.EmptyView` to `search-shortcuts.tsx` — shows "Loading shortcuts…" while payload loads
- [x] Add `List.EmptyView` to `add-edit-by-path.tsx` — shows "Loading configs…" while payload loads
- [x] Add `List.EmptyView` to `browse-configs.tsx` — shows "Loading configs…" while payload loads

## Review

**Root cause**: All three Raycast commands load config data asynchronously via `loadIndex()`. During this async gap, `payload` is `undefined`, so the list renders with zero items. Raycast displays "No Results" for empty lists even when `isLoading={true}`.

**Why it's inconsistent**: When the cache file is valid and the fingerprint matches, `loadIndex()` returns fast enough that the UI never paints the empty state. When the cache is stale or missing, `buildCachePayload()` runs (heavier I/O), creating a visible gap where "No Results" appears.

**Fix**: Added `<List.EmptyView title="Loading …" />` conditionally rendered when data is still loading and no payload exists yet. This replaces the default "No Results" empty state with an appropriate loading message. Once `payload` is set, the `EmptyView` is no longer rendered and normal list items appear.

**Files changed**:
- `raycast-leader-key/src/search-shortcuts.tsx` — 3 lines added
- `raycast-leader-key/src/add-edit-by-path.tsx` — 3 lines added
- `raycast-leader-key/src/browse-configs.tsx` — 3 lines added

# Todo — Perf/Stability + Shortcut Viz + Command Scout + Rock-Solid STT

Plan: `/Users/arabshaptukaev/.claude/plans/analyze-the-code-and-cheerful-planet.md`

## Stage 0 — Baseline
- [x] Snapshot-commit pre-existing dirty voice files + untracked LKExceptionCatcher shim (NOT kar / karabiner.ts generated files)

## Stage A — Safety nets
- [x] T1.0 Fix ControllerTests init + add to test target; run it green
- [x] T1.0 Add missing signposts (Controller.runAction, cheatsheet show)
- [x] T4.0 VoiceAudioCapturing + SpeechTranscribing protocol seams, injected via init defaults
- [x] T4.0 VoiceCoordinatorTests with mocks (happy path, toggle, stuck-recording race repro as XCTExpectFailure)

## Stage B — Voice correctness (T4.1)
- [x] Race fix: keyUp latched while mic-permission arming; late grant finishes immediately
- [x] Watchdog timer on .transcribing (35s) / .planning (90s)
- [x] processingTask retained + cancelled (watchdog/stop); cancellation-aware catches
- [x] Device-change onRecordingInterrupted surfacing + clean capture abort

## Stage C — appConfigs race fix (T1.1)
- [x] Locked accessors for appConfigs; routed all accesses (LoadingDecoding + Metadata)
- [x] threadSafeRoot lock-guarded snapshot for off-main root reads
- [x] Concurrency hammer test green under TSan
- [x] BONUS: fixed ConfigCache pool-exhaustion deadlock (barrier queue → NSLock), found by hammer test

## Stage D — Voice latency/delivery/streaming
- [x] T4.2 Voice signposts (Voice.processing / Voice.transcribe / Voice.prepareAudio)
- [x] T4.2 Trailing delay 0.3s → 0 (holdReleaseTrailingCapture tunable)
- [x] T4.2 afconvert → in-process AVAudioConverter (+ fixture WAV test)
- [x] T4.2 Cache mic auth; stop per-press updateAudioWarmState
- [x] T4.3 Clipboard save/restore around paste (changeCount guard, all item types)
- [x] T4.3 Focus check before paste (copy-only when Leader Key frontmost)
- [x] T4.3 Optional trailing-period strip toggle (default off)
- [x] T4.4A Chunked pre-transcription + live partial transcript in status menu (Parakeet only, default on)

## Stage E — Main-thread & hot-path (T1.2/T1.3)
- [x] T1.2 `.menu` AX execution was already dispatched off-main in `selectMenuItemImpl`; no code change needed
- [x] T1.3 Associated objects → stored properties

## Stage F — Shortcut visualization (T2)
- [x] T2.1 ShortcutsOverviewModel + tests
- [x] T2.2 ShortcutsOverviewView (keyboard grid + flattened list)
- [x] T2.3a Settings pane (.shortcuts)
- [x] T2.3b Standalone window + socket command `shortcut-map open`
- [x] T2.3c HTML export

## Stage G — Command Scout (T3)
- [x] T3.1 AX key-equivalents on menu scan + UI chip + merge normalization
- [x] T3.2 Widen sequence namespace (uppercase, punctuation last resort)
- [x] T3.3 Free-slot integration + embedded compact grid
- [x] T3.4 AI-only mode for non-running apps
- [x] T3.5 UsageStats (default-off) + Scout/viz consumers
  - [x] Opt-in local store, persistence, directory switching, and Clear History
  - [x] Regular shortcut invocation telemetry
  - [x] Heat, ranking, and pruning evidence consumers
- [x] T3.6 Global/fallback scouting

## Stage H — Cheatsheet + low cleanups (T1.4/T1.5)
- [x] T1.4 Cheatsheet window reuse for .always
- [x] T1.5 Delete dead CGEvent-tap machinery
- [x] T1.5 Delete ThreadOptimization.debounce
- [x] T1.5 Karabiner2InputMethod.isActive returns bool directly
- [x] T1.5 Cheatsheet sort hoist + stable ForEach ids
- [x] T1.5 Theme-change: close old window
- [x] T1.5 Document/fix main.sync on socket queue
- [ ] T1.5 (optional, deferred) FileMonitor watches config dir

## Review

### Outcome

- Completed the performance/stability, shortcut visualization, Command Scout, and local usage work without changing the completed STT behavior, normal-mode contracts, socket-only control, or Karabiner key-event-last ordering.
- Kept regular-map visualization, Scout, and usage scoped to Global/Fallback/App configs; normal mode, voice dispatch, and macro substeps remain outside v1.
- Intentionally deferred the optional directory watcher. Socket-driven `apply-config`/reload remains authoritative; directory watching needs a separate fingerprint/filter design so app-config edits are detected without loops from generated export files.

### Landed commits

| Commit | Delivery |
| --- | --- |
| `0d2a0cc` | Snapshot pre-existing voice dictation work. |
| `1f8eef7` | Add Controller/voice safety seams, tests, and signposts. |
| `d121153` | Fix voice arming races, watchdogs, cancellation, and device-change recovery. |
| `f73983b` | Lock UserConfig/ConfigCache access and add concurrency coverage. |
| `5ef4296` | Improve voice latency, delivery safety, conversion, and local partials. |
| `975b31e` | Move AppDelegate event state from associated objects to stored properties. |
| `9af9c44` | Remove dead legacy CGEvent processing. |
| `549670b` | Add shortcut-overview model, physical shift mapping, conflicts, traversal, and tests. |
| `ecdb13d` | Add the keyboard grid and grouped sequence-list overview. |
| `93e1aec` | Register the Shortcuts settings pane. |
| `b7701aa` | Add the reusable shortcut-map window and socket command. |
| `1ea97cd` | Add deterministic, self-contained shortcut-map HTML export. |
| `1a1214b` | Surface native AX menu shortcuts and lock the inventory cache. |
| `0df71b3` | Make Scout sequences exact and case-sensitive with literal punctuation. |
| `ed1a5fd` | Add trie feasibility, batch-safe assignment, and projected grid preview. |
| `7c88d20` | Add explicit AI-only scans for stopped apps. |
| `45418a1` | Add the default-off local usage store and Clear History. |
| `b602919` | Record regular shortcut invocation attempts with ordered telemetry. |
| `91bc932` | Add heat, history-aware ranking, and evidence-gated pruning hints. |
| `c4e2498` | Add Global and Fallback Scout targets. |
| `6fdeb05` | Reuse the cheatsheet only in `.always` mode and rebuild it on reload/theme changes. |
| `1ebd34c` | Remove the unused broken debounce helper. |
| `cc43f6d` | Add synchronized direct socket running/statistics snapshots. |
| `cfb06bf` | Pre-sort cheatsheet rows with stable model identity. |
| `bd9e6cb` | Close replaced theme windows while preserving active panel presentation. |
| `3cbeca2` | Document and test the synchronous dispatch socket-response contract. |

### Verification

- macOS unskipped suite: 265 total, 262 passed, 1 skipped, and only the two documented exporter failures below.
- macOS gated suite with those two identifiers skipped: exits successfully.
- TSan: `UserConfigTests`, `UsageStatsTests.testConcurrentRecordingIsLossless`, and `CommandScoutTests.testMenuCacheSupportsConcurrentReadsWritesAndClears` pass.
- TypeScript workspace: root `npm run typecheck` passes; root `npm test` reports 117 tests, 116 passed, 1 intentional live-socket integration skip.
- App build succeeds. No new unused/unreachable warnings were introduced.

Known exporter failures:

- `Karabiner2ExporterKarabinerTSExportTests.testGenerateKarabinerTSExportCompactsAppSpecificModeRules`
- `Karabiner2ExporterKarabinerTSExportTests.testGenerateKarabinerTSExportIncludesModeGuards`

### Manual handback checklist

Voice:

- [ ] Hold-dictate into TextEdit, Chrome, and a terminal; text appears immediately and the clipboard contents are restored afterward.
- [ ] Rapid-tap the hold key 20 times; recording never remains stuck.
- [ ] Disconnect or change the microphone mid-recording; a visible error appears and the next recording succeeds.
- [ ] With local Parakeet selected, confirm live partial transcripts update in the status menu.

Visualization:

- [ ] Open Settings → Shortcuts, select Chrome, drill through groups/layers, and confirm base/shift occupancy and free keys match the live config.
- [ ] Open the standalone map from the status menu and confirm it preserves the current selection.
- [ ] Run `printf 'shortcut-map open {"bundleId":"com.google.Chrome"}\n' | nc -U /tmp/leaderkey.sock` and confirm Chrome is preselected (or Fallback when no app config exists).
- [ ] Export HTML, open it in a browser, and verify grid drill-down, breadcrumbs, search, list grouping, and provenance work offline.

Command Scout:

- [ ] Scan running Chrome; native menu shortcuts appear as muted chips.
- [ ] Select several suggestions and confirm they occupy structurally free slots in the projected compact grid, including uppercase/punctuation fallback when needed.
- [ ] Scan a stopped app with AI enabled; informational AI-only mode appears and unverified menu paths require review.
- [ ] Scout and apply suggestions to Global and Fallback; confirm shared targets remain AI-only and Create/Create-and-Scout stay app-only.

Usage:

- [ ] Confirm tracking is off by default: exports contain no usage telemetry and the overview shows no heat.
- [ ] Enable usage tracking in Advanced, invoke regular Global/Fallback/App shortcuts, and confirm relative heat updates and Scout history ranking changes only after mnemonic/free-slot tiers.
- [ ] Confirm “Not observed during tracking” stays hidden until both seven days of observation and 50 executions in that config are satisfied; nothing is auto-deleted.
- [ ] Disable tracking and re-enable it; retained history reappears.
- [ ] Use Clear History; counts, heat, ranking evidence, and pruning hints reset and the persisted store is empty.

Performance/stability:

- [ ] Activate and execute shortcuts across several apps while saving/reloading configs; confirm no crashes, stale panels, or normal-mode regressions.
- [ ] With cheatsheet mode `.always`, reopen repeatedly to confirm reuse; reload config and change theme to confirm teardown/recreation and preserved active panel state.
- [ ] Inspect Instruments “Points of Interest” and confirm the Controller/voice/Scout signpost intervals appear.

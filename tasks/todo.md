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
- [ ] T2.3a Settings pane (.shortcuts)
- [ ] T2.3b Standalone window + socket command `shortcut-map open`
- [ ] T2.3c HTML export

## Stage G — Command Scout (T3)
- [ ] T3.1 AX key-equivalents on menu scan + UI chip + merge normalization
- [ ] T3.2 Widen sequence namespace (uppercase, punctuation last resort)
- [ ] T3.3 Free-slot integration + embedded compact grid
- [ ] T3.4 AI-only mode for non-running apps
- [ ] T3.5 UsageStats (default-off) + Scout/viz consumers
- [ ] T3.6 Global/fallback scouting

## Stage H — Cheatsheet + low cleanups (T1.4/T1.5)
- [ ] T1.4 Cheatsheet window reuse for .always
- [x] T1.5 Delete dead CGEvent-tap machinery
- [ ] T1.5 Delete ThreadOptimization.debounce
- [ ] T1.5 Karabiner2InputMethod.isActive returns bool directly
- [ ] T1.5 Cheatsheet sort hoist + stable ForEach ids
- [ ] T1.5 Theme-change: close old window
- [ ] T1.5 Document/fix main.sync on socket queue
- [ ] T1.5 (optional) FileMonitor watches config dir

## Review
(filled in at the end)

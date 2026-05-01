# LeaderKey Voice Feature Handoff

Last updated: 2026-05-01

## Status

Where we are: voice dispatch end-to-end pipeline complete / done: STT, settings, hotkeys, dispatch bridge, confirmation UI, planner fallback, audio polish / next: production packaging (bundle JS runtime or go native), advanced floating-panel confirmation, live voice transcript benchmarks.

## Done

- Dispatcher MVP exists in TypeScript:
  - `packages/leaderkey-dispatcher-core`
  - `packages/leaderkey-dispatcher-cli`
  - fixtures, bench, docs
  - validator blocks invented IDs, low confidence, command actions, unsafe actions
- Swift socket execution route exists:
  - `dispatch execute <json>` over `/tmp/leaderkey.sock`
  - Swift re-resolves scope/path/type against current catalog before `Controller.runAction`
  - command actions are blocked again in Swift
- Native Voice pane exists:
  - enable voice dispatcher
  - prewarm microphone toggle
  - toggle record shortcut
  - hold-to-talk shortcut
  - Groq API key in Keychain
  - STT model setting
  - dry-run/execute setting
  - fast-only/tiered planner setting
- Audio capture exists:
  - `VoiceAudioCapture`
  - optional prewarm
  - 0.75s pre-roll
  - WAV temp file capture
- Groq STT exists:
  - `VoiceTranscriber`
  - `language=en`
  - `temperature=0`
  - prompt is disabled by default
- Transcript-to-dispatch bridge now exists:
  - `VoiceDispatchBridge`
  - `VoiceCoordinator` goes `transcribing -> planning -> ready/error`
  - app invokes local `leaderkey-dispatcher execute`
  - dry-run remains default
  - real execution only if Voice setting is `execute`
- Confirmation UI exists:
  - `NSAlert`-based confirm/cancel dialog for `needs_confirmation` actions
  - 10-second auto-cancel timeout prevents stalled voice state
  - saves/restores frontmost app so user doesn't get stranded in Leader Key
  - confirmation body shows action labels with reasons
- Planner fallback exists:
  - `planDispatch` wraps planner call in try/catch
  - on planner failure, fast-match plan preserved with `planner_error` field
  - Swift decodes `plannerError` from dispatch result
  - status message surfaces planner error when `voiceNotifyTierUnavailable` is true
- App-side reporting improved:
  - single-step display shows action label directly
  - multi-step chains get 3s display time (vs 1.5s for single)
  - full dispatch JSON logged at debug level
- Audio polish exists:
  - trailing silence trimming (RMS < -40dB, last 0.5s)
  - `cleanupTempFiles()` sweeps leftover `/tmp/leaderkey-voice-*` files
  - `stopCompletely()` deletes active and last capture files
- Dispatcher tests expanded:
  - 10 tests total (was 8)
  - planner error fallback test
  - multi-clause unresolved array test

## Current Implementation

`Leader Key/VoiceCoordinator.swift`

- Captures audio on toggle or hold release.
- Sends audio to Groq.
- Logs:
  - `[VoiceCoordinator] Groq prompt disabled`
  - `[VoiceCoordinator] Groq transcript ...`
  - `[VoiceCoordinator] Dispatch ...`
- After transcript:
  - builds `VoiceDispatchOptions` from `Defaults`
  - captures frontmost bundle ID
  - calls `VoiceDispatchBridge.dispatch(...)`
  - displays short status message:
    - `Voice dry run: ...`
    - `Voice executed: ...`
    - `Voice blocked`
    - `Voice needs confirmation`

`Leader Key/VoiceDispatchBridge.swift`

- Resolves dispatcher CLI in this order:
  - `LEADERKEY_DISPATCHER_CLI`
  - `LEADERKEY_REPO_ROOT/packages/leaderkey-dispatcher-cli/dist/index.js`
  - compile-time repo root from `#filePath`
  - current working directory
  - app bundle ancestor
  - `leaderkey-dispatcher` on PATH
- Resolves Node from:
  - `/opt/homebrew/bin`
  - `/usr/local/bin`
  - `/usr/bin`
  - existing PATH
- Runs CLI without a shell.
- Uses `execute`, not `plan`, because `execute --dry-run` returns plan + validation + execution report.
- Timeout is 6 seconds.

CLI shape called by Swift:

```sh
node packages/leaderkey-dispatcher-cli/dist/index.js execute \
  --config-dir "$HOME/Library/Application Support/Leader Key" \
  --scope frontmost \
  --bundle-id <frontmost bundle id> \
  --planner none \
  --dry-run \
  "open new tab"
```

With Voice planner mode set to tiered:

```sh
--planner llama --llama-url "$VOICE_LLAMA_URL" --model "$VOICE_TIER_2_MODEL"
```

## Critical STT Lesson

Do not prime Groq/Whisper with catalog terms.

Catalog-derived prompts caused severe short-clip hallucinations:

- `Raycast. Raycast. Raycast.`
- `Cmdx. Cmdx.`
- `open your tab and copy everything over there`

`VoicePromptBuilder.build(...)` intentionally returns `nil`. Keep it that way unless there is a measured reason to change it. Vocabulary correction belongs in dispatcher alias/fuzzy matching, not in Whisper prompt context.

## Safety Invariants

- Dry-run must remain default.
- Real execution must require Voice setting `execute`.
- No `leaderkey://` URL schemes or callbacks.
- Real execution must remain socket-only through `/tmp/leaderkey.sock`.
- Model/CLI raw values must never be executed.
- `command` actions must remain blocked for voice.
- Confirmation/block actions must not auto-run.
- Do not route around `Controller.runAction`; it preserves existing action semantics.

## Recent Matcher Update

`packages/leaderkey-dispatcher-core/src/matcher.ts`

Added new-tab aliases for STT drift:

- `open a new tab`
- `open your tab`
- `open in your tab`

Test added in `packages/leaderkey-dispatcher-core/test/dispatcher.test.ts`:

- `I want you to open new tab`
- `open your tab`
- `open in your tab`

All map to `tab_new` in fixture catalog.

## Validation Commands

Run these before handing back:

```sh
npm run test -w @leaderkey/dispatcher-core
npm run build -w @leaderkey/dispatcher-cli
node packages/leaderkey-dispatcher-cli/dist/index.js execute --catalog fixtures/actions.json --dry-run --pretty "open your tab"
node packages/leaderkey-dispatcher-cli/dist/index.js execute --config-dir "$HOME/Library/Application Support/Leader Key" --bundle-id com.openai.codex --scope frontmost --planner none --dry-run --pretty "I want you to open new tab"
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift format lint 'Leader Key/VoiceDispatchBridge.swift' 'Leader Key/VoiceCoordinator.swift'
xcodebuild -scheme "Leader Key" -project "Leader Key.xcodeproj" -configuration Debug build
```

Known noise:

- `xcodebuild` emits many pre-existing SwiftFormat warnings in unrelated files.
- `kar` may be dirty as a nested worktree/submodule. Do not touch it unless explicitly asked.

## User Test Flow

1. Run the rebuilt app.
2. Settings -> Voice:
   - Enable voice dispatcher.
   - Keep prewarm enabled.
   - Keep dispatch mode on dry-run first.
3. Hold-to-talk and say: `I want you to open new tab`.
4. Expected log:

```text
[VoiceCoordinator] Groq prompt disabled
[VoiceCoordinator] State: Planning
[VoiceCoordinator] Dispatch mode=fast_match confidence=0.95 valid=true blocked=false dryRun=true executed=false steps=... reason="valid"
```

5. Expected menu/status text:

```text
Voice dry run: Shortcut: Cmd+T
```

6. Only after dry-run looks right, switch Voice dispatch mode to execute and retest with a safe action.

## Remaining Milestones

1. Production packaging:
   - Current bridge relies on local Node + repo CLI.
   - Decide whether to bundle a JS runtime, ship a helper binary, or move hot path native later.
2. Advanced confirmation UI:
   - Replace NSAlert with a floating panel (similar to hint overlay) for a more integrated look.
3. Benchmark live voice transcripts:
   - Record actual Groq mishears into bench rows.
   - Prefer matcher aliases over STT prompt priming.
4. Llama-server lifecycle management:
   - Optionally start/stop llama-server from Leader Key.
   - Add clear UI/logging when llama-server is not reachable.
5. Optional audio refinements:
   - VAD/silence detection at recording start (skip empty recordings earlier).
   - Check prewarm CPU/power with Activity Monitor.

## If Taking Over

Start with:

```sh
git status --short
```

Ignore unrelated `kar` dirtiness. Read:

- `AGENTS.md`
- `CLAUDE.md`
- `tasks/normal-mode-handoff.md` before normal-mode/Karabiner changes
- this file

Then continue from the remaining milestones above. Keep socket-based integration and dry-run safety intact.

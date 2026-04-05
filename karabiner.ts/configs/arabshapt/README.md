# arabshapt — Personal Karabiner Config

Personal Karabiner-Elements config for arabshapt, managed via karabiner.ts.

## Source of truth

**Goku** (`~/.config/karabiner.edn`) is the current source of truth. The modular
karabiner.ts files in `src/` are extracted from Goku's output and will gradually
replace it as the primary source.

## File layout

```
configs/arabshapt/
  default-profile.ts          # Generated snapshot from goku --dry-run (parity reference)
  default-profile.test.ts     # Snapshot parity test
  src/
    index.ts                  # Entrypoint: assembles all 76 rules in order
    index.test.ts             # Modular config parity test against snapshot
    profile.ts                # Timing parameters
    devices.ts                # Device conditions (kinesis, apple, etc.)
    conditions.ts             # App conditions + leader key state variables
    send-user-command.ts      # Leader key command helpers
    helpers.ts                # Shell command helpers (km, alfred, open, etc.)
    auto-layers.ts            # Auto-generated layer/simlayer conditions
    caps-layer.ts             # Caps lock layer rules
    global-start.ts           # Global start rules
    test-rule.ts              # Test rule
    leaderkey/                # Leader Key infrastructure
      activation.ts           # Activation shortcuts (56 manipulators)
      modifier-passthrough.ts # Modifier pass-through (8 manipulators)
      global-mode.ts          # Global mode shortcuts
      fallback-mode.ts        # Fallback mode shortcuts
      leader-local-to-apps.ts # Leader local app routing
    apps/                     # Per-app Leader Key configs (28 apps)
      intellij.ts, arc.ts, ghostty.ts, vscode.ts, ...
    modes/                    # Layer/simlayer mode rules
      tab-mode.ts, slash-mode.ts, tilde-mode.ts, o-mode.ts, ...
    device-rules/             # Device-specific rules
      kinesis.ts, apple.ts, global-kinesis-shortcuts.ts, ...
    app-rules/                # App-specific non-Leader-Key rules
      chrome.ts, arc-kinesis.ts, intellij-kinesis.ts, ...
```

## Commands

```bash
cd karabiner.ts

# Run parity test (modular config vs snapshot)
npm run parity

# Regenerate snapshot from goku --dry-run
npm run sync:arabshapt

# Re-extract modular files from snapshot
npm run extract:arabshapt

# Run all tests
npm test
```

## How to add a new app config

1. Add the app's bundle ID to `src/conditions.ts`
2. Create `src/apps/<app-name>.ts` with the Leader Key manipulators
3. Import and add the rule to `src/index.ts` (maintain rule ordering)
4. Run `npm run parity` to verify

## How to add a new mode

1. Create `src/modes/<mode-name>.ts`
2. Import and add to `src/index.ts`
3. Run `npm run parity`

## How to regenerate after editing karabiner.edn

```bash
# 1. Edit ~/.config/karabiner.edn
# 2. Regenerate snapshot
npm run sync:arabshapt
# 3. Re-extract modular files
npm run extract:arabshapt
# 4. Verify parity
npm run parity
```

## Parity testing

The modular config is tested against the Goku snapshot via SHA-256 hash
comparison of canonicalized JSON. Tests check:

- Same number of rules (76)
- Rule descriptions match in order
- Parameters match
- Per-rule manipulator counts match
- Full SHA-256 hash match
- send_user_command payload shape counts match

## Architecture notes

- Each rule file exports `description` (string) and `manipulators` (Manipulator[])
- `index.ts` assembles them into `allRules: Rule[]` in exact Goku order
- Rule ordering matters — Karabiner-Elements evaluates rules top-to-bottom
- The `default-profile.ts` snapshot is the parity oracle, not the primary config
- Leader Key generated rules (`configs/leaderkey/`) are separate and untouched
- Shared definitions (`devices.ts`, `conditions.ts`, etc.) are ready for use
  when refactoring rules from raw JSON to idiomatic karabiner.ts

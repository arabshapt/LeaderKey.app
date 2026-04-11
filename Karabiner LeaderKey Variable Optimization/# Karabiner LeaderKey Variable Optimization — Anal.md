<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# \# Karabiner LeaderKey Variable Optimization — Analysis \& Prompt

## Current Implementation Analysis

### Architecture Overview

The LeaderKey app implements a **Vim-style leader key state machine** inside Karabiner Elements. A trigger key (e.g., `right_command` or `semicolon`) enters "leader mode," then subsequent keypresses navigate a tree of groups/actions. The state machine is fully materialized in Karabiner's `karabiner.json` as flat manipulator rules.

### The Numbers (Current State)

| Metric | Value |
| :-- | :-- |
| Total Karabiner rules | 76 |
| LeaderKey-managed rules | 32 |
| LeaderKey manipulators | **6,741** |
| `set_variable` operations | **20,852** |
| `variable_if` checks | **13,365** |
| `variable_unless` checks | **7,472** |
| **Total variable operations** | **41,689** |
| Unique `leader_state` values | 853 |
| `karabiner.json` file size | **4.4 MB** |
| App-specific configs | 28 apps |
| Manipulators with full deactivation pattern | **4,908** |

### Variables Used (8 total)

| Variable | Checked (conditions) | Set (to events) | Purpose |
| :-- | :-- | :-- | :-- |
| `leader_state` | 6,669× | 5,797× | Current node in state tree (853 unique values) |
| `leaderkey_global` | 6,669× | 4,968× | Binary flag: global mode active |
| `leaderkey_appspecific` | 6,517× | 4,968× | Binary flag: app-specific mode active |
| `leaderkey_active` | 12× | 4,968× | Binary flag: any leader mode active |
| `leaderkey_sticky` | 859× | 151× | Binary flag: sticky mode (don't deactivate after action) |
| `caps_lock-mode` | 44× | 0× | External: avoid conflicts with other modes |
| `f-mode` | 32× | 0× | External: avoid conflicts with other modes |
| `tilde-mode` | 35× | 0× | External: avoid conflicts with other modes |

### Key Inefficiency: Redundant Deactivation Blocks

Every terminal action (action that runs a command/opens an app) that is NOT in sticky mode repeats this 5-variable deactivation block:

```json
{
  "to": [
    { "send_user_command": { "payload": "..." } },
    { "send_user_command": { "payload": "deactivate" } },
    { "set_variable": { "name": "leaderkey_active", "value": 0 } },
    { "set_variable": { "name": "leaderkey_global", "value": 0 } },
    { "set_variable": { "name": "leaderkey_appspecific", "value": 0 } },
    { "set_variable": { "name": "leader_state", "value": 0 } }
  ]
}
```

This pattern appears **4,908 times** — that's ~24,500 `set_variable` entries just for deactivation.

### Key Inefficiency: Per-State Mode Separation

Each unique `leader_state` value (853 of them) gets its rules duplicated across modes:

- **App-specific mode**: `variable_unless(leaderkey_global, 1)` + `variable_if(leaderkey_appspecific, 1)` + `frontmost_application_if(bundleId)`
- **Global mode**: `variable_if(leaderkey_global, 1)`
- **Fallback mode**: `variable_unless(leaderkey_global, 1)` + `variable_if(leaderkey_appspecific, 1)`

The same tree structure (e.g., "press `o` then `a` → open Safari") is repeated **for each app** that shares the same fallback config.

### State Machine Model

```
[Inactive] → (trigger key) → [Active, leader_state=initialId]
  → (key press matches group) → [Active, leader_state=groupId]  + send "stateid X"
  → (key press matches action) → execute action + [Inactive]     + send "deactivate"
  → (key press matches nothing) → send "shake" + vk_none (swallow key)
  → (escape) → [Inactive] + send "deactivate"
```

The state tree is generated at export time from JSON configs and materialized into flat Karabiner rules.

---

## Ready-to-Use Prompt

> **Copy everything below this line and paste it to another AI:**

---

I have a macOS **leader key** implementation running inside **Karabiner Elements** that uses variables to build a state machine. It works perfectly — I want to keep all functionality — but the generated `karabiner.json` is bloated (**4.4 MB**, **6,741 manipulators**, **41,689 variable operations**) and I want a more elegant approach with fewer config lines.

### How it works now

The system has a companion Swift app ("Leader Key") that:

1. **Reads JSON config files** defining a tree of key→action/key→group bindings (like Vim's which-key)
2. **Exports/materializes the entire state tree** as flat Karabiner complex modification rules into `karabiner.json`
3. **Receives IPC** from Karabiner via `send_user_command` over a Unix datagram socket

The state machine in Karabiner uses these variables:

- `leader_state` (integer, 853 unique values) — tracks which node in the tree we're at
- `leaderkey_active` (0/1) — whether any leader mode is on
- `leaderkey_global` (0/1) — whether we're in global mode
- `leaderkey_appspecific` (0/1) — whether we're in app-specific mode
- `leaderkey_sticky` (0/1) — sticky mode (don't deactivate after executing an action)

There are also 3 external variables (`caps_lock-mode`, `f-mode`, `tilde-mode`) used only as `variable_unless` conditions on activation shortcuts to prevent conflicts.

### Three activation modes

1. **Global mode**: Same key tree regardless of which app is frontmost. Sets `leaderkey_global=1`.
2. **App-specific mode**: Different key tree per frontmost app (28 apps currently). Sets `leaderkey_appspecific=1`. Uses `frontmost_application_if` condition.
3. **Fallback mode**: Used when no app-specific config exists for the current app.

### The bloat problem

**Problem 1: Deactivation repetition**
Every terminal action (not in sticky mode) repeats a 5-variable reset block:

```json
"to": [
  <action payload>,
  {"send_user_command": {"payload": "deactivate"}},
  {"set_variable": {"name": "leaderkey_active", "value": 0}},
  {"set_variable": {"name": "leaderkey_global", "value": 0}},
  {"set_variable": {"name": "leaderkey_appspecific", "value": 0}},
  {"set_variable": {"name": "leader_state", "value": 0}}
]
```

This appears **4,908 times**.

**Problem 2: Full state tree per app**
Each of the 28 app-specific configs materializes its *entire* key tree as separate manipulators, even though most apps share 90%+ of the tree (via fallback config merging). A global config with ~20 bindings × 28 apps = ~560 near-identical manipulators.

**Problem 3: Mode discrimination via separate variables**
Using `leaderkey_global` + `leaderkey_appspecific` as separate booleans means every manipulator needs 2-3 condition checks to determine its mode. A single `leaderkey_mode` variable with values like `0=inactive, 1=global, 2=appspecific` could cut conditions.

**Problem 4: Catch-all per state**
Every unique `leader_state` value gets a catch-all rule (`{"any": "key_code"}` → `send "shake"` + `vk_none`) to swallow unrecognized keys. With 853 states, that's 853 catch-all manipulators.

### What I want to keep

- All functionality (global, app-specific, fallback, sticky mode)
- Variables-based approach (Karabiner's `set_variable` / `variable_if`)
- `send_user_command` for IPC with the Swift companion app (for UI overlay, state display)
- The `leader_state` concept for tracking tree position
- Per-action Karabiner-native execution (`send_user_command` with v1 payloads for open_app, open, menu, intellij, keystroke) — these run at ~1ms vs ~100ms for shell_command
- Device-specific activation (Kinesis keyboard vs built-in MacBook keyboard have different trigger keys)
- Compatibility with external modes (`caps_lock-mode`, `f-mode`, `tilde-mode`) via `variable_unless`


### What I'm open to changing

- How variables are structured (consolidating booleans, using encoded values)
- How the state tree is materialized into rules (maybe fewer, smarter rules?)
- Whether catch-all rules can be shared across states
- Whether deactivation can be done differently (e.g., a single deactivation rule triggered by the action itself rather than inline `set_variable`)
- The overall rule organization strategy


### Constraints

- Must work with **Karabiner Elements' existing complex modifications** system — no custom Karabiner plugins or external daemons for key interception (the companion app only handles IPC, not key events)
- Karabiner evaluates rules **top-to-bottom, first match wins** — rule ordering matters
- Cannot use Karabiner's `layer` feature for this because layers are tied to a held key, not a toggled state
- Variables are global and persist until explicitly changed
- Each manipulator needs its own `conditions` array — no "shared conditions" concept in Karabiner


### What I'd like from you

1. **Analyze** the variable structure and identify specific optimizations
2. **Propose** a concrete alternative variable/rule architecture that reduces config size while maintaining all functionality
3. **Estimate** the reduction in manipulators and variable operations
4. **Show examples** of what the new rules would look like in Karabiner JSON format
5. **Identify risks** or trade-offs of each proposed change

Focus on the Karabiner config structure — the Swift export code can be adapted to generate whatever structure you propose.

---

> [!TIP]
> **End of prompt.** Copy everything above the line to another AI to get a second opinion.

This is a solid optimization target. There are four distinct, implementable changes that together should cut your config by roughly **60–70%** in both manipulators and variable operations. Here's a precise analysis of each.

***

## Optimization 1: Collapse Three Booleans → One Mode Integer

**The problem**: Every manipulator pays 2–3 condition checks for `leaderkey_global` + `leaderkey_appspecific` + `leaderkey_active`. Every deactivation block sets 3 variables.

**The fix**: Replace all three with a single `leaderkey_mode`:


| Value | Meaning |
| :-- | :-- |
| `0` | Inactive |
| `1` | Global mode active |
| `2` | App-specific / fallback mode active |

**Before (activation — global mode):**

```json
"to": [
  {"set_variable": {"name": "leaderkey_active", "value": 1}},
  {"set_variable": {"name": "leaderkey_global", "value": 1}},
  {"set_variable": {"name": "leaderkey_appspecific", "value": 0}},
  {"set_variable": {"name": "leader_state", "value": 100}}
]
```

**After:**

```json
"to": [
  {"set_variable": {"name": "leaderkey_mode", "value": 1}},
  {"set_variable": {"name": "leader_state", "value": 100}}
]
```

**Before (terminal action deactivation):**

```json
"to": [
  {"send_user_command": {"payload": "open_app com.google.Chrome"}},
  {"send_user_command": {"payload": "deactivate"}},
  {"set_variable": {"name": "leaderkey_active", "value": 0}},
  {"set_variable": {"name": "leaderkey_global", "value": 0}},
  {"set_variable": {"name": "leaderkey_appspecific", "value": 0}},
  {"set_variable": {"name": "leader_state", "value": 0}}
]
```

**After (also dropping the `leader_state` reset — see Opt 2):**

```json
"to": [
  {"send_user_command": {"payload": "open_app com.google.Chrome"}},
  {"send_user_command": {"payload": "deactivate"}},
  {"set_variable": {"name": "leaderkey_mode", "value": 0}}
]
```

Every manipulator that previously checked two conditions now checks one. Conditions drop from ~13,000 `variable_if` checks to ~6,700. Deactivation drops from 4 `set_variable` ops to 1.

***

## Optimization 2: Stop Resetting `leader_state` on Deactivation

**The problem**: Every terminal action sets `leader_state=0` as part of deactivation, accounting for ~4,908 set_variable ops. This reset is unnecessary.

**Why it's safe**: The very next activation manipulator always writes `leader_state` to `initialId` before any sub-tree rule can match. The stale leftover value is never observed because all sub-tree rules also check `leaderkey_mode != 0` — once mode is `0`, no rule matches regardless of `leader_state`'s value.[^1]

Drop `{"set_variable": {"name": "leader_state", "value": 0}}` from every deactivation block. Pure savings, zero risk.

***

## Optimization 3: One Shared Catch-All Rule

**The problem**: Each of 853 unique `leader_state` values has a dedicated catch-all `{"any": "key_code"}` manipulator to swallow unrecognized keys — 853 manipulators for identical behavior.

**The fix**: One catch-all at the **bottom** of all LeaderKey rules, checking only that any mode is active:

```json
{
  "type": "basic",
  "from": {"any": "key_code", "modifiers": {"optional": ["any"]}},
  "conditions": [
    {"type": "variable_unless", "name": "leaderkey_mode", "value": 0}
  ],
  "to": [
    {"send_user_command": {"payload": "shake"}},
    {"key_code": "vk_none"}
  ]
}
```

This works because Karabiner evaluates top-to-bottom, first-match wins. By the time this rule is reached, every specific key handler for every active state has already been checked and failed to match. The catch-all fires correctly regardless of which `leader_state` value is current.[^1]

This is valid as long as your rule groups are structured so all specific LeaderKey manipulators precede this single catch-all.

***

## Optimization 4: Shared Tree for App-Specific Mode (Biggest Win)

**The problem**: If 28 apps share 90%+ of bindings via the fallback config, the same ~20-binding tree is materialized 28× as separate rule sets. A flat `o → a → open Safari` path appears in every app's block.

**The fix**: Leverage first-match ordering to separate *shared bindings* from *per-app overrides*. Since `frontmost_application_if` is just another condition checked in order, you can structure rules as:

```
Block A: App-specific overrides (frontmost_application_if + leaderkey_mode=2 + leader_state=X)
Block B: Shared fallback bindings (leaderkey_mode=2 + leader_state=X, no frontmost condition)
```

Karabiner's first-match rule means Block A overrides Block B for specific apps, and Block B handles everything else — including all 28 apps that share the same binding.

**Before (duplicated for each app):**

```json
// Repeated 28× for each app's tree
{
  "conditions": [
    {"type": "variable_if", "name": "leaderkey_mode", "value": 2},
    {"type": "variable_if", "name": "leader_state", "value": 300},
    {"type": "frontmost_application_if",
     "bundle_identifiers": ["^com\\.apple\\.Terminal$"]}
  ],
  "from": {"key_code": "s"},
  "to": [{"send_user_command": {"payload": "open_app com.apple.Safari"}}]
}
```

**After (shared binding appears once; only VSCode override is app-specific):**

```json
// Only UNIQUE overrides get per-app rules
{
  "conditions": [
    {"type": "variable_if", "name": "leaderkey_mode", "value": 2},
    {"type": "variable_if", "name": "leader_state", "value": 300},
    {"type": "frontmost_application_if",
     "bundle_identifiers": ["^com\\.microsoft\\.VSCode$"]}
  ],
  "from": {"key_code": "g"},
  "to": [{"send_user_command": {"payload": "intellij go_to_declaration"}}]
},
// Shared rule — fires for all 28+ apps unless overridden above
{
  "conditions": [
    {"type": "variable_if", "name": "leaderkey_mode", "value": 2},
    {"type": "variable_if", "name": "leader_state", "value": 300}
  ],
  "from": {"key_code": "s"},
  "to": [{"send_user_command": {"payload": "open_app com.apple.Safari"}}]
}
```

If 90% of bindings are shared across 28 apps, you go from 28× the shared tree to 1× shared tree + 28 × (10% unique overrides). At ~20 bindings per shared node, that's ~560 near-identical rules → ~56 override rules + ~20 shared rules = ~76.

***

## Bonus: `to.conditions` for Sticky Unification (KE 15.3.7+)

Karabiner supports `conditions` inside individual `to` events, evaluated at the start of the `to` block . This lets you unify sticky and non-sticky terminal actions into a single manipulator type:

```json
"to": [
  {"send_user_command": {"payload": "keystroke cmd+t"}},
  {
    "send_user_command": {"payload": "deactivate"},
    "conditions": [{"type": "variable_unless", "name": "leaderkey_sticky", "value": 1}]
  },
  {
    "set_variable": {"name": "leaderkey_mode", "value": 0},
    "conditions": [{"type": "variable_unless", "name": "leaderkey_sticky", "value": 1}]
  }
]
```

This doesn't save `set_variable` count per-se, but eliminates the need to generate two separate manipulator variants at export time.

***

## Estimated Impact

| Optimization | Manipulator Δ | Variable Op Δ | Notes |
| :-- | :-- | :-- | :-- |
| Mode consolidation (3→1 var) | 0 | **−~10,000** | Each deactivation: 4 ops → 1; conditions: 2-3 → 1 per manipulator |
| Skip `leader_state` reset | 0 | **−4,908** | Pure removal, zero risk |
| Single shared catch-all | **−852** | −~2,500 | 853 → 1 catch-all manipulator |
| Shared app tree | **−3,000 to −4,500** | **−~18,000** | Assumes 90% shared bindings |
| **Total** | **~−4,000** (59% ↓) | **~−35,000** (84% ↓) |  |

**Projected new totals**: ~2,700 manipulators, ~7,000 variable ops, file size roughly **0.8–1.2 MB** vs current 4.4 MB.

***

## Risks and Trade-offs

**Shared catch-all ordering (critical)**: All app-specific overrides MUST be ordered before shared fallback rules, which must be ordered before the catch-all. A mis-ordered rule will silently shadow bindings with no error. Your Swift exporter must enforce this order deterministically.

**App tree cannot suppress bindings**: With the shared tree model, an app can override a binding but cannot *remove* it. If app X should have no binding at state 300 for key `s`, you need to emit a "null action" override (`to: [{"key_code": "vk_none"}]`) for that app. The exporter needs an explicit `null` binding type.

**IPC mode reporting**: The Swift companion app currently likely reads `leaderkey_global` and `leaderkey_appspecific` separately for its UI overlay. With the single `leaderkey_mode` variable, it needs to interpret `1=global, 2=appspecific` instead of two boolean reads. Minor change but needs updating.

**`variable_unless` for escape deactivation**: The escape key deactivation rule likely checks `leaderkey_active=1`. With mode consolidation, change to `variable_unless(leaderkey_mode, 0)` — fires when mode is any non-zero value (1 or 2).[^1]

**`expression_if` as an alternative**: Karabiner 15.5.19+ supports arithmetic expressions in conditions. You could further encode the full state as `leaderkey_mode * 10000 + leader_state_id` in a single variable, then use `expression_if: "leaderkey_combined % 10000 == 300"` — but this replaces clear semantics with math, adds CPU overhead per evaluation, and is harder to debug. Not recommended unless you hit Karabiner's variable count limits.[^2]
<span style="display:none">[^10][^11][^12][^13][^14][^15][^3][^4][^5][^6][^7][^8][^9]</span>

<div align="center">⁂</div>

[^1]: https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-evaluation-priority/

[^2]: https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/to/set-variable/

[^3]: https://karabiner-elements.pqrs.org/docs/manual/configuration/configure-complex-modifications/

[^4]: https://github.com/pqrs-org/Karabiner-Elements/issues/2774

[^5]: https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/

[^6]: https://github.com/pqrs-org/Karabiner-Elements/issues/3068

[^7]: https://stackoverflow.com/questions/60329520/how-to-enable-rules-only-for-specific-keyboard-layout-karabiner

[^8]: https://karabiner-elements.pqrs.org/docs/json/typical-complex-modifications-examples/

[^9]: https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/to/to-conditions/

[^10]: https://karabiner-elements.pqrs.org/docs/help/advanced-topics/set-environment-variables/

[^11]: https://www.reddit.com/r/Karabiner/comments/1j36eo2/completely_lost_on_how_to_make_this_complex/

[^12]: https://github.com/pqrs-org/Karabiner-Elements/issues/4307

[^13]: https://karabiner-elements.pqrs.org/docs/releasenotes/

[^14]: https://www.reddit.com/r/Karabiner/comments/1je7m9v/help_with_dynamic_caps_lock_hyper_key_setup_for/

[^15]: https://karabiner-elements.pqrs.org/docs/json/expert-complex-modifications-examples/


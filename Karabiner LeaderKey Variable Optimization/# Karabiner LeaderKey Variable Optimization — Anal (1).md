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

This is a well-characterized optimization problem. Four concrete changes can reduce your config by **~70% in manipulators** and **~50% in variable ops**. Here's the full analysis:

***

## Critical Unlock: `expression_if`

Before anything else — Karabiner 15.5.19+ added `expression_if` / `expression_unless` with full arithmetic expressions. This changes what's possible:[^1]

```json
{ "type": "expression_if", "expression": "leader_state > 0" }
```

This lets you check **ranges and inequalities**, not just equality. It directly enables several optimizations that were previously impossible with `variable_if` alone.

***

## Opt 1: Collapse 3 Boolean Flags → 1 Mode Variable

**Current**: `leaderkey_active` + `leaderkey_global` + `leaderkey_appspecific` = 3 variables, requiring 2-3 conditions per manipulator and 4 set_variables per deactivation.

**Proposed**: Single `leaderkey_mode` with integer values:


| Value | Meaning |
| :-- | :-- |
| `0` | Inactive |
| `1` | Global mode |
| `2` | Non-global mode (app-specific + fallback handled by rule ordering) |

**Deactivation shrinks from 4 → 2 set_variables:**

```json
"to": [
  { "send_user_command": { "payload": "deactivate" } },
  { "set_variable": { "name": "leader_state",   "value": 0 } },
  { "set_variable": { "name": "leaderkey_mode", "value": 0 } }
]
```

**Activation examples:**

```json
// Global activation
"to": [
  { "send_user_command": { "payload": "activate:global" } },
  { "set_variable": { "name": "leaderkey_mode", "value": 1 } },
  { "set_variable": { "name": "leader_state",   "value": 1 } }
]

// App-specific or fallback activation (mode=2 always; IPC payload tells companion which)
"to": [
  { "send_user_command": { "payload": "activate:appspecific:com.apple.Safari" } },
  { "set_variable": { "name": "leaderkey_mode", "value": 2 } },
  { "set_variable": { "name": "leader_state",   "value": 1 } }
]
```

The companion Swift app already receives the mode info via `send_user_command` — it doesn't need Karabiner variables to track it. The `leaderkey_global` / `leaderkey_appspecific` distinction moves entirely to IPC payloads.[^2]

**Savings from Opt 1:**

- **−4,968** `set_variable` ops (eliminating `leaderkey_active` sets)
- **−9,816** `set_variable` ops (deactivation: 4×4,908 → 2×4,908)
- **~−3,250** condition checks (2 mode conditions per manipulator → 1)

***

## Opt 2: Single Global Catch-All (853 Rules → 1)

**Current**: Every state gets its own `{"any": "key_code"}` catch-all rule checking `variable_if(leader_state, X)`.

**Proposed**: One catch-all at the bottom of the rule set, using `expression_if`:

```json
{
  "type": "basic",
  "from": {
    "any": "key_code",
    "modifiers": { "optional": ["any"] }
  },
  "conditions": [
    { "type": "expression_if", "expression": "leaderkey_mode > 0" }
  ],
  "to": [
    { "send_user_command": { "payload": "shake" } }
  ],
  "to_if_alone": [
    { "key_code": "vk_none" }
  ]
}
```

This works because Karabiner evaluates **top-to-bottom, first-match-wins**. All specific state rules come earlier in the file and match their keys first. This catch-all only fires when no specific rule matched — which is exactly the per-state catch-all behavior, but without needing to know which state.[^3]

**Savings from Opt 2:**

- **−852 manipulators** outright
- **~−1,700 condition checks**

***

## Opt 3: App Inheritance via Rule Ordering (Biggest Win)

**Current**: Each of 28 app configs materializes its *entire* tree as separate manipulators — the full fallback tree is copied into every app. Apps that share 90%+ of bindings repeat 90% of their rules.

**Proposed architecture using Karabiner's natural rule ordering:**

```
Rule block A (priority): App-specific DELTA rules only
  → Each app: only the rules that DIFFER from fallback
  → frontmost_application_if([bundleId]) on each rule
  → All use leaderkey_mode = 2

Rule block B (fallback): Shared fallback tree
  → No frontmost_application_if at all
  → Fires for leaderkey_mode = 2 when block A didn't match
```

**Example — current (duplicated per app):**

```json
// Repeated ~28 times, once per app that inherits this binding
{
  "conditions": [
    { "type": "variable_unless", "name": "leaderkey_global", "value": 1 },
    { "type": "variable_if",     "name": "leaderkey_appspecific", "value": 1 },
    { "type": "frontmost_application_if", "bundle_identifiers": ["^com\\.apple\\.Safari$"] },
    { "type": "variable_if",     "name": "leader_state", "value": 42 }
  ],
  "from": { "key_code": "b" },
  "to": [
    { "send_user_command": { "payload": "open:https://..." } },
    // ... 4 deactivation set_variables
  ]
}
```

**Example — new (shared fallback rule, fires for all non-global apps):**

```json
{
  "conditions": [
    { "type": "variable_if", "name": "leaderkey_mode",  "value": 2 },
    { "type": "variable_if", "name": "leader_state",    "value": 42 }
  ],
  "from": { "key_code": "b" },
  "to": [
    { "send_user_command": { "payload": "open:https://..." } },
    { "set_variable": { "name": "leader_state",   "value": 0 } },
    { "set_variable": { "name": "leaderkey_mode", "value": 0 } }
  ]
}

// App-specific OVERRIDE (only for Safari's different binding at state 42)
{
  "conditions": [
    { "type": "variable_if", "name": "leaderkey_mode", "value": 2 },
    { "type": "variable_if", "name": "leader_state",   "value": 42 },
    { "type": "frontmost_application_if", "bundle_identifiers": ["^com\\.apple\\.Safari$"] }
  ],
  "from": { "key_code": "b" },
  "to": [
    { "send_user_command": { "payload": "open:safari-specific-url" } },
    { "set_variable": { "name": "leader_state",   "value": 0 } },
    { "set_variable": { "name": "leaderkey_mode", "value": 0 } }
  ]
}
```

The override block comes **before** the shared block in `karabiner.json`. Safari's override fires first; all other apps fall through to the shared rule.[^4]

Additionally, apps that share the **same** set of overrides can be grouped with multiple `bundle_identifiers` in one `frontmost_application_if`.[^4]

**Savings from Opt 3:**
If 90% of non-global rules are currently duplicated across 28 apps, and there are ~4,000 app-specific manipulators total:

- From ~4,000 → ~600 = **−3,400 manipulators** (conservative)

***

## Opt 4: `expression_if` Enables Bonus Unlock — Eliminate `leaderkey_mode` Entirely

Since `expression_if` supports `> 0` checks, you can encode mode directly into state ID ranges:[^1]


| State ID range | Meaning |
| :-- | :-- |
| `0` | Inactive |
| `1 – 999` | Global mode states |
| `1000 – 1999` | Non-global mode states |

The catch-all becomes:

```json
{ "type": "expression_if", "expression": "leader_state > 0" }
```

Deactivation is now a **single** `set_variable`:

```json
{ "set_variable": { "name": "leader_state", "value": 0 } }
```

Global vs. non-global discrimination is implicit — a rule with `variable_if(leader_state, 500)` is by definition global (500 is in the global range), no mode flag needed. This eliminates `leaderkey_mode` entirely from all conditions, shrinking every manipulator by one condition.

> **Caveat**: This requires the Swift exporter to assign state IDs in non-overlapping ranges per mode, which is a trivial change since IDs are generated at export time. The companion app decodes mode from the state ID range.

***

## Estimated Impact

| Metric | Current | Optimized (conservative) | Reduction |
| :-- | :-- | :-- | :-- |
| Total manipulators | 6,741 | ~1,700 | **~75%** |
| `set_variable` ops | 20,852 | ~8,000 | **~62%** |
| Total variable ops | 41,689 | ~18,000 | **~57%** |
| `karabiner.json` size | 4.4 MB | ~1.0–1.5 MB | **~70%** |
| Distinct variable names | 5 core + 3 ext | 2 core + 3 ext | **−3** |
| Catch-all rules | 853 | 1 | **−852** |

The app-inheritance change (Opt 3) dominates — the actual savings hinge on how many bindings are truly unique per app vs. shared with fallback. At 90% shared (as you estimate), the reduction will be near the high end.

***

## Risks \& Trade-offs

**Opt 1 (mode consolidation):** Low risk. The only behavioral change is moving app-specific vs. fallback mode tracking from Karabiner variables to IPC message payloads. If any Karabiner rule currently branches on `leaderkey_appspecific` vs `leaderkey_global` independently (not just as a pair), that logic needs restructuring. Check your 12 `leaderkey_active` condition usages — they could be replaced with `expression_if("leader_state > 0")` directly.

**Opt 2 (single catch-all):** Low risk with correct rule ordering. Critical requirement: the catch-all rule must be in its own rule block, sorted **after** all specific state rules in `karabiner.json`. If the exporter places rule blocks in a non-deterministic order, this could silently swallow keypresses. Add an ordering guarantee to the exporter.

**Opt 3 (app inheritance):** Medium complexity. Requires the Swift exporter to compute the delta between each app config and the fallback, and only export the non-shared rules as app-specific overrides. If your config format already tracks this (app-specific config merges with fallback), the exporter change is straightforward. Edge case: apps where the "same" key at the "same" state has different navigation depth (group vs. terminal action) need careful delta logic — it's not purely additive.

**Opt 4 (state ID encoding):** Low risk with one caveat — `expression_if` was added in **KE 15.5.19**. Verify your users (or you yourself) are on that version. The range-encoding approach also requires state IDs to be stable across exports for the companion app's overlay display — ensure the exporter's ID assignment is deterministic.[^1]
<span style="display:none">[^10][^11][^12][^13][^14][^15][^16][^17][^18][^19][^20][^21][^22][^23][^24][^25][^5][^6][^7][^8][^9]</span>

<div align="center">⁂</div>

[^1]: https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/conditions/expression/

[^2]: https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/conditions/variable/

[^3]: https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-evaluation-priority/

[^4]: https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/conditions/frontmost-application/

[^5]: https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/

[^6]: https://karabiner-elements.pqrs.org/docs/manual/configuration/configure-complex-modifications/

[^7]: https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/conditions/

[^8]: https://karabiner-elements.pqrs.org/docs/json/typical-complex-modifications-examples/

[^9]: https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/to/to-conditions/

[^10]: https://github.com/tekezo/Karabiner-Elements/issues/1396

[^11]: https://github.com/pqrs-org/Karabiner-Elements/issues/2774

[^12]: https://github.com/pqrs-org/Karabiner-Elements/issues/3841

[^13]: https://www.reddit.com/r/Karabiner/comments/1hbyqh7/introducing_complex_modifiers_ready_for_your/

[^14]: https://stackoverflow.com/questions/76090698/how-can-i-disable-karabiner-elements-for-emacs-app-and-emacsclient-app

[^15]: https://lobehub.com/skills/ajbcoding-claude-skill-eval-creating-karabiner-modifications

[^16]: https://github.com/pqrs-org/Karabiner-Elements/issues/3475

[^17]: https://github.com/pqrs-org/Karabiner-Elements/issues/3068

[^18]: https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/conditions/input-source/

[^19]: https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/to/set-variable/

[^20]: https://github.com/pqrs-org/Karabiner-Elements/issues/4160

[^21]: https://www.reddit.com/r/Karabiner/comments/1hb5lir/recipe_for_using_onetap_modifier_keys/

[^22]: https://www.reddit.com/r/Karabiner/comments/1i7hw1z/my_version_of_layered_shortcuts_with_karabiner/

[^23]: https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/conditions/keyboard-type/

[^24]: https://github.com/pqrs-org/Karabiner-Elements/issues/1365

[^25]: https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/from/modifiers/


# Karabiner LeaderKey Optimization — Consolidated Analysis

All four research documents propose the same core optimizations with slight variations. I've cross-referenced everything against the actual Karabiner docs and your codebase. Here's what fits us, what doesn't, and the recommended implementation order.

---

## Summary: All Sources Agree on 4 Core Optimizations

| # | Optimization | All 4 agree? | Fits us? | Risk | Impact |
|---|---|---|---|---|---|
| 1 | Collapse 3 booleans → 1 mode variable | ✅ Yes | ✅ **Yes** | Low | −14,800 var ops |
| 2 | Single shared catch-all | ✅ Yes | ✅ **Yes** | Low | −852 manipulators |
| 3 | Shared fallback tree via rule ordering | ✅ Yes | ✅ **Yes** | Medium | −3,000+ manipulators |
| 4 | Skip `leader_state` reset on deactivation | 2 of 4 | ⚠️ **Risky** | Medium | −4,908 set_variable ops |

Two sources also propose more aggressive ideas:

| # | Extra Optimization | Fits us? | Risk |
|---|---|---|---|
| 5 | Encode mode into state ID ranges + `expression_if` | ⚠️ **Deferred** | Low risk, but adds complexity |
| 6 | State ID bitmasking / `expression_if` modulo math | ❌ **No** — over-engineered | High complexity, minimal gain |
| 7 | `to.conditions` for sticky unification | ✅ **Nice to have** | Low |
| 8 | `frontmost_application_unless` for shared fallback | ⚠️ **Fragile** | Medium — must track bundle IDs |

---

## Optimization 1: Collapse 3 Booleans → `leaderkey_mode`

> [!IMPORTANT]
> **Unanimous recommendation.** Every source proposes this. Low risk, high reward.

### What changes

| Current | Proposed |
|---|---|
| `leaderkey_active` (0/1) | ❌ **Eliminated** |
| `leaderkey_global` (0/1) | ❌ **Eliminated** |
| `leaderkey_appspecific` (0/1) | ❌ **Eliminated** |
| — | `leaderkey_mode` (0=inactive, 1=global, 2=app-specific) |

### Why it fits us

- The Swift app **does NOT read** `leaderkey_global` or `leaderkey_appspecific` from Karabiner variables — it receives mode info via `send_user_command` IPC payloads (`"activate com.apple.Safari"`, `"activate"`, etc.). Confirmed: zero references to these variable names in the Swift app code outside of the exporter.
- The exporter's `modeRuleConditions()` function (line 1432) currently returns 2-3 conditions per mode. With a single `leaderkey_mode` variable, it returns exactly 1.
- Deactivation shrinks from 4 `set_variable` ops → 1.

### Impact

- **Conditions**: Every manipulator loses 1-2 condition checks. With ~6,700 manipulators × ~2 conditions each = **−~10,000 condition checks**
- **Deactivation**: 4,908 terminal actions × 3 fewer `set_variable` = **−14,724 set_variable ops**
- **Activation**: ~64 activation manipulators × 2 fewer `set_variable` = **−128 set_variable ops**

### Code changes needed

| File | Change |
|---|---|
| [Karabiner2Exporter.swift](file:///Users/arabshaptukaev/personalProjects/LeaderKeyapp/Leader%20Key/Karabiner2Exporter.swift) | Replace all `karSetVariable(name: "leaderkey_active/global/appspecific", ...)` blocks with single `karSetVariable(name: "leaderkey_mode", value: N)` |
| `modeRuleConditions()` (L1432) | Return `[variableCondition(name: "leaderkey_mode", value: X)]` instead of 2-3 conditions |
| `generateKarActivationMapping()` (L982) | Set `leaderkey_mode=1` (global) or `leaderkey_mode=2` (app-specific) |
| `generateKarEscapeMapping()` (L1021) | Reset `leaderkey_mode=0` instead of 3 separate resets |
| `generateKarTerminalActionMapping()` (L1102) | Replace 3-variable reset with `leaderkey_mode=0` |
| `generateKarModifierPassThroughMappings()` (L1062) | Condition: `variable_unless(leaderkey_mode, 0)` instead of `variable_if(leaderkey_active, 1)` |
| Goku EDN generation (L195+) | Same changes for the Goku backend |

---

## Optimization 2: Single Shared Catch-All

> [!IMPORTANT]
> **Unanimous recommendation.** Trivial to implement, massive win.

### What changes

Currently: 853 catch-all manipulators (one per unique `leader_state` value), each checking `variable_if(leader_state, X)` + mode conditions.

Proposed: **One** catch-all at the bottom of all LeaderKey rules.

```json
{
  "type": "basic",
  "from": {"any": "key_code", "modifiers": {"optional": ["any"]}},
  "conditions": [
    {"type": "variable_unless", "name": "leaderkey_mode", "value": 0},
    {"type": "variable_unless", "name": "leaderkey_sticky", "value": 1}
  ],
  "to": [
    {"send_user_command": {"payload": "shake"}},
    {"key_code": "vk_none"}
  ]
}
```

### Why it fits us

- Karabiner's top-to-bottom, first-match-wins evaluation guarantees correctness: all specific state rules fire first, and only unmatched keys reach the catch-all.
- Our exporter already controls rule ordering via `compactCompiledRules()` and the `generateKarModeRules()` output order.
- The `variable_unless(leaderkey_sticky, 1)` condition **preserves current behavior**: in sticky mode, unrecognized keys are swallowed without the shake animation.
- Using `variable_unless(leaderkey_mode, 0)` works on all Karabiner versions — no need for `expression_if` here.

### Why NOT `expression_if` for the catch-all

Two sources suggest `expression_if("leader_state > 0")` or `expression_if("leaderkey_mode > 0")`. While elegant, `variable_unless(leaderkey_mode, 0)` achieves the identical result without requiring KE 15.5.19+. Since we need `leaderkey_mode` anyway (from Opt 1), the `variable_unless` approach is strictly better for compatibility.

### Impact

- **−852 manipulators** (853 → 1)
- **−~2,500 variable operations** (all the associated conditions)

### Code changes needed

| File | Change |
|---|---|
| `generateKarModeRules()` (L586) | Remove the per-state `generateKarCatchAllMappings()` loop |
| `generateKarConfig()` (L328) | Append one catch-all rule at the very end of the `rules` array |

---

## Optimization 3: Shared Fallback Tree via Rule Ordering

> [!IMPORTANT]
> **Biggest win. All sources agree. Requires the most careful implementation.**

### What changes

Current: Each of 28 apps materializes its **entire** key tree (fallback + app-specific). A binding like `o → a → open Safari` that comes from the fallback config is repeated 28 times.

Proposed: Three-layer rule ordering:

```
Layer 1: Activation / Escape / Settings / Modifier pass-through (unchanged)
Layer 2: App-specific DELTA rules only (bindings that differ from fallback)
         → Each has frontmost_application_if + leaderkey_mode=2 + leader_state=X
Layer 3: Shared fallback tree (no frontmost_application_if)
         → Just leaderkey_mode=2 + leader_state=X
Layer 4: Global tree (leaderkey_mode=1 + leader_state=X)
Layer 5: Universal catch-all (from Opt 2)
```

### Why it fits us

- The config system already has the concept of **fallback merging** (`mergeConfigWithFallback()` in UserConfig). The exporter can diff app configs against fallback to extract only the delta.
- Karabiner's first-match-wins ensures app-specific overrides in Layer 2 take priority.
- The SharedFallbackTree in Layer 3 fires for **all** apps in `leaderkey_mode=2`, whether they have a config or not.

### Why NOT `frontmost_application_unless`

The deep-research document suggests using `frontmost_application_unless` with a list of all app bundle IDs. This is **fragile** — every time a new app config is added, the `unless` list must be updated across all shared rules. The rule-ordering approach is strictly superior because the `unless` condition is implicit via ordering: if an app-specific rule exists in Layer 2, it fires first; if not, Layer 3 handles it.

### Impact estimate

Current app-specific manipulators: ~6,500 (across 28 apps). If 90% of bindings are shared via fallback:
- App-specific delta rules: 28 × ~10 unique bindings = **~280 manipulators**
- Shared fallback tree: **~150 manipulators** (one copy)
- **Savings: −~4,000 to −5,000 manipulators**

### Edge case: binding suppression

> [!WARNING]
> If an app needs to **remove** a binding that exists in the fallback (not override, but suppress), the exporter must emit a "null action" override in Layer 2. E.g., `"to": [{"key_code": "vk_none"}]` to swallow the key silently for that app.

### Code changes needed

| File | Change |
|---|---|
| `Karabiner2Exporter.swift` | New function: `computeAppDelta(appConfig, fallbackConfig) → deltaRules` to diff per-app configs against the shared fallback |
| `generateKarConfig()` | Restructured output: Layer 2 (app deltas) → Layer 3 (shared fallback) → Layer 4 (global) |
| `buildStateTree()` | May need to build separate trees for fallback and per-app delta |

---

## Optimization 4: Skip `leader_state` Reset

> [!WARNING]
> **Two of four sources recommend this. It's safe but has a subtle implication.**

### The argument

When deactivating, the current code sets `leader_state=0`. But the next activation always sets `leader_state=initialId` before any sub-tree rule can match. Since all sub-tree rules require `leaderkey_mode != 0`, and we set `leaderkey_mode=0` on deactivation, the stale `leader_state` value is never observed.

### Why I'd still keep it

1. **Defensive programming**: If a race condition or edge case leaves `leaderkey_mode` in a non-zero state, a stale `leader_state` could cause incorrect matching.
2. **The cost is now tiny**: With Opt 1, deactivation is already just 2 ops (`leaderkey_mode=0` + `leader_state=0`). Dropping `leader_state=0` saves one `set_variable` per terminal action. With ~4,908 terminal actions, that's 4,908 saved set_variable ops, but each is a single JSON object — the size/performance impact is minimal after Opts 1-3.

### Recommendation

**Implement Opts 1-3 first.** Then benchmark. If further reduction is needed, drop `leader_state=0` from deactivation as a secondary optimization.

---

## Bonus: `to.conditions` for Sticky Mode Unification (KE 15.3.7+)

> [!TIP]
> Nice quality-of-life improvement for the exporter. Doesn't reduce manipulator count but simplifies code generation.

Currently the exporter has branching logic (`if hasStickyMode { ... } else { ... }`) that generates two different `to` arrays per terminal action. With `to.conditions` (available since KE 15.3.7), a single manipulator handles both:

```json
"to": [
  {"send_user_command": {"payload": "open_app /Applications/Safari.app"}},
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

This simplifies `generateKarTerminalActionMapping()` from ~170 lines of branching to ~30 lines of uniform generation.

---

## What NOT to Implement

### ❌ State ID range encoding + `expression_if`

Two sources propose encoding mode into state ID ranges (1-999=global, 1000+=app-specific) and using `expression_if("leader_state > 0")`. While technically sound, this:
- Adds complexity to state ID generation
- Makes debugging harder (IDs aren't just hashes anymore)
- Isn't needed — `leaderkey_mode` achieves the same mode discrimination more clearly
- Can be done later if we want to drop `leaderkey_mode` entirely

### ❌ Bitmasking / modulo math in `expression_if`

One source mentions this as a future-proofing idea. It's clearly over-engineered for our scale.

### ❌ `frontmost_application_unless` for shared rules

Fragile — requires maintaining an exclusion list. Rule ordering achieves the same result implicitly.

---

## Projected Final Numbers

| Metric | Current | After Opts 1-3 | Reduction |
|---|---|---|---|
| Total manipulators | 6,741 | **~1,700–2,000** | **~70-75%** |
| `set_variable` ops | 20,852 | **~5,500** | **~74%** |
| Condition checks | 20,837 | **~4,500** | **~78%** |
| Total variable ops | 41,689 | **~10,000** | **~76%** |
| `karabiner.json` size | 4.4 MB | **~1.0–1.2 MB** | **~75%** |
| Catch-all rules | 853 | 1 | **−852** |
| Core variables | 5 | 3 (`leaderkey_mode`, `leader_state`, `leaderkey_sticky`) | **−2** |

## Recommended Implementation Order

1. **Opt 1** (mode consolidation) — Simplest, most self-contained change. Affects only `Karabiner2Exporter.swift`. Can be tested immediately.
2. **Opt 2** (single catch-all) — Trivial once Opt 1 is in place. Just remove the per-state catch-all loop and add one universal rule at the end.
3. **Opt 3** (shared fallback tree) — Biggest change, requires new delta-computation logic in the exporter. Biggest payoff.
4. **Bonus: `to.conditions` for sticky** — Code cleanup, can be done anytime.

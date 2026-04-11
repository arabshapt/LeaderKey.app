# Analysis of Current Configuration

The existing setup uses **five Karabiner variables** (`leader_state`, `leaderkey_active`, `leaderkey_global`, `leaderkey_appspecific`, `leaderkey_sticky`) plus a few external flags. Every “leader” action must explicitly check or reset these variables, leading to **extreme redundancy**. For example, **4,908** different manipulators repeat a 5-step deactivation sequence (clearing 4 variables) after each action. Likewise, each of 853 possible `leader_state` values has its own “catch-all” rule that sends the “shake” feedback and swallows the key. Every app-specific binding tree is duplicated 28 times (one per app) even when 90% of the shortcuts overlap. In effect, the same key‐sequence mappings and state transitions are re‐encoded in dozens of rules with only different bundle-ID conditions. 

Karabiner applies rules **top-to-bottom, first match wins**【52†L149-L154】, so ordering is crucial and many conditions are effectively the same in all those copies. The net result is ~6,700 manipulators and ~41,700 variable operations, most of which are redundant checks or resets of the mode flags. In short, the current design trades maintainability and compactness for brute‐force completeness.

# Proposed Optimizations

1. **Merge mode flags into one variable:** Instead of three booleans (`leaderkey_global`, `leaderkey_appspecific`, `leaderkey_active`), use a single `leader_mode` variable (integer or string) to encode the mode. E.g.  
   - `leader_mode = 0` means inactive,  
   - `= 1` means global leader mode,  
   - `= 2` means app-specific mode (with frontmost app conditions).  
   Karabiner supports integers or strings for variable values【10†L235-L240】, so you could even use `"global"`/`"app"` for clarity. Now each manipulator needs just one condition (`leader_mode = 1` *or* `= 2`) instead of two boolean checks. In practice this removes **one condition check per rule** (and one `set_variable` on deactivation) and lets us drop the separate `leaderkey_active` flag entirely. For example, a global-rule condition becomes `{"type":"variable_if","name":"leader_mode","value":1}` rather than checking two booleans. 

2. **Single catch-all rule:** Replace the 853 state-specific catch-all manipulators with one (or two) generic manipulators. For example, use a manipulator with `"from": {"any": "key_code"}` and condition `{"type":"variable_unless","name":"leader_mode","value":0}` (i.e. “if `leader_mode` is not 0”) to catch any key pressed while in leader mode. This single rule (placed at the **bottom** of the rule list) will fire only if no earlier (more specific) rule matched【52†L149-L154】. Its “to” can send the shake and `vk_none` to swallow the input. This eliminates hundreds of duplicate rules. 

3. **Shared fallback vs. per-app rules:** Instead of duplicating the entire shortcut tree for each app, use one set of manipulators for the common bindings with a *bundle‑identifier* condition that excludes all app-specific cases. Karabiner allows listing multiple bundle IDs in one condition【25†L215-L222】. For example, put all common mappings in a rule group with  
   ```json
   "conditions": [
     {"type": "variable_if", "name": "leader_mode", "value": 2},
     {"type": "frontmost_application_unless", "bundle_identifiers": [
         "^com\\.apple\\.App1$", "^com\\.apple\\.App2$", … ]}
   ]
   ``` 
   This single “fallback” rule applies in apps *not* in the list. Specific-app rules then only need to define the few shortcuts unique to that app, using `frontmost_application_if` for that bundle ID. This collapses ~28 copies of the same bindings into one with an “unless” condition, cutting thousands of manipulators. (Karabiner supports **OR logic** on `bundle_identifiers` in a single condition【25†L219-L226】.) 

4. **Simplify deactivation steps:** In each action mapping that ends the leader sequence, reduce the reset logic. With `leader_mode`, you only need to set `leader_mode=0` and `leader_state=0` (and maybe clear `leader_sticky` if used). For example, instead of five separate `"set_variable"` steps, do just:  
   ```json
   {"set_variable": {"name": "leader_mode", "value": 0}},
   {"set_variable": {"name": "leader_state", "value": 0}}
   ```  
   (Sticky mode logic can skip these resets when active.) This trims the per-action variable writes from 4→2. The `send_user_command "deactivate"` can remain as-is for the Swift app. While Karabiner still requires the resets be in the rule’s `"to"` array, halving them is a big win.

5. **Keep sticky as a flag:** Continue using `leaderkey_sticky` (or a renamed `sticky_mode`) to indicate whether to auto-reset after an action. This can remain a separate boolean since it only triggers a minor condition. Optionally, one could encode “sticky” into an expanded mode value (e.g. `3=global-sticky`), but clarity favors a dedicated flag (859 checks ⇒ minor overhead).

# Estimated Reductions

Applying these changes yields dramatic cuts. Rough estimates: 

- **Catch-all manipulators:** 853 → *1*, saving ~852 rules.  
- **App-specific duplication:** The ~560 duplicated fallback rules (≈20 common mappings × 28 apps) collapse into ~20 rules with a single “unless” condition, saving ~540 rules.  
- **Variable conditions:** Merging `leaderkey_global` and `leaderkey_appspecific` into one `leader_mode` removes one condition per manipulator. If ~6,000 rules originally had two checks, that’s ~6,000 fewer `variable_if/variable_unless` evaluations.  
- **Deactivation writes:** Reducing 4 resets to 2 per action saves 2×4,908 ≈9,816 `set_variable` operations. We also drop the ~4,968 sets of the now-obsolete `leaderkey_active` and `leaderkey_appspecific` (or global) per action. Altogether, variable-ops could easily fall by **15–20K** or more.  
- **Manipulators total:** 6,741 down by a few thousand. Even a conservative reduction of ~2,000 rules (catch-all + app-duplication) would roughly halve the complex modification size.

These estimates assume full preservation of functionality. The new config might end up on the order of ~2–3 MB (instead of 4.4 MB) and only a couple thousand manipulators, greatly improving readability and Karabiner’s processing load.

# Example New Rules

Below are representative snippets of the proposed JSON (using `"leader_mode"` and unified logic). In practice a Swift exporter would fill in the actual key codes and state IDs.

1. **Trigger (activation) mapping:** E.g. pressing the leader key sets mode and initial state.  
   ```json
   {
     "type": "basic",
     "from": {"key_code": "semicolon"},
     "to": [
       {"set_variable": {"name": "leader_mode", "value": 2}},
       {"set_variable": {"name": "leader_state", "value": 1}}
     ],
     "conditions": [
       {"type": "variable_unless", "name": "caps_lock-mode", "value": 1},
       {"type": "variable_unless", "name": "f-mode", "value": 1}
     ]
   }
   ```
   (Here `leader_mode=2` means “app-specific leader” and state 1 is the root. A similar rule with `leader_mode=1` would be used for the global leader trigger.)

2. **State transition (group node):** When in global mode state 10, pressing “o” moves to state 20.  
   ```json
   {
     "type": "basic",
     "from": {"key_code": "o"},
     "conditions": [
       {"type": "variable_if", "name": "leader_mode", "value": 1},
       {"type": "variable_if", "name": "leader_state", "value": 10}
     ],
     "to": [
       {"set_variable": {"name": "leader_state", "value": 20}},
       {"send_user_command": {"payload": "stateid 20"}}
     ]
   }
   ```
   (The Swift app receives `"stateid 20"` for UI feedback.)

3. **Action (leaf node) and deactivation:** In app mode state 20, pressing “b” opens an app and ends leader mode.  
   ```json
   {
     "type": "basic",
     "from": {"key_code": "b"},
     "conditions": [
       {"type": "variable_if", "name": "leader_mode", "value": 2},
       {"type": "variable_if", "name": "leader_state", "value": 20}
     ],
     "to": [
       {"send_user_command": {"payload": "open_app com.apple.Safari"}},
       {"send_user_command": {"payload": "deactivate"}},
       {"set_variable": {"name": "leader_mode", "value": 0}},
       {"set_variable": {"name": "leader_state", "value": 0}}
     ]
   }
   ```
   (Sticky mode would skip the last two sets if active. This example assumes no sticky.)

4. **Catch-all rule:** At the end, catch any key while leader is active and give feedback.  
   ```json
   {
     "type": "basic",
     "from": {"any": "key_code"},
     "conditions": [
       {"type": "variable_unless", "name": "leader_mode", "value": 0}
     ],
     "to": [
       {"send_user_command": {"payload": "shake"}},
       {"key_code": "vk_none"}
     ]
   }
   ```
   This single rule replaces the many per-state fallback rules. It must come *after* all specific manipulators so that valid shortcuts match first【52†L149-L154】.

These examples illustrate the pattern: one mode variable, streamlined conditions, and shared catch-all. Note the use of `send_user_command "deactivate"` is preserved for the Swift app to close the overlay.

# Risks and Trade-Offs

- **Ordering matters more:** A single catch-all or shared fallback rule must be placed below all more-specific mappings, or it will preempt them. Careful rule ordering is required since Karabiner uses first-match priority【52†L149-L154】. 
- **Complex `frontmost_application` logic:** Combining apps with `frontmost_application_unless` is powerful, but forgetting an app ID could lead to fallback rules triggering incorrectly. Each app-specific sequence must still be guarded so it doesn’t collide with the fallback “unless” rule. (Thorough testing of bundle-ID conditions is needed.)
- **Sticky mode complexity:** Encoding sticky into `leader_mode` values could eliminate one variable, but would complicate mode logic (and risk more conditions). Keeping `sticky` as a boolean is simpler but leaves an extra check. (Given sticky’s rare usage, this overhead is minor.)
- **No built-in “timeout” or global reset:** Karabiner cannot auto-reset a variable after a timer except via `to_delayed_action` on a held key (not usable here). Thus we still need explicit resets in each action as shown. We cannot delegate deactivation to a separate global rule because Karabiner has no rule type that triggers *on user_command payload*. 
- **Compatibility:** All solutions stick to Karabiner’s JSON features, so they should work on macOS without plugins. One must ensure the Karabiner version supports any used features (e.g. multi-bundle `frontmost_application_unless`, string variable values).

Overall, this redesign trades verbose duplication for a bit more complexity in each rule’s conditions. The result should be a far leaner `karabiner.json` that is easier to maintain. By collapsing repeated patterns, we preserve all functionality (leader modes, sticky, etc.) while **drastically reducing** the number of manipulators and variable operations. 

**Sources:** Karabiner’s documentation notes that conditions can combine multiple bundle IDs【25†L215-L222】 and that manipulators are tried top-to-bottom, stopping at the first match【52†L149-L154】. The `layer().leaderMode()` feature in Evan Liu’s karabiner.ts illustrates a similar “leader stays active” behavior【18†L57-L63】. These facts guided the above optimizations.
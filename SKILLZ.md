# Skillz

Practical implementation notes and pitfalls worth remembering.

## Raycast `menu` / `intellij` editor work

### What was implemented

- `intellij` in Raycast now has a structured editor:
  - searchable action picker
  - append-oriented action list editing
  - separate delay field
  - same persisted format as before: `ActionA,ActionB|100`
- `menu` in Raycast now has a structured editor:
  - app picker
  - primary menu path field
  - live menu-item search through Leader Key IPC
  - ordered fallback menu paths
- Leader Key runtime now understands menu fallback paths in both:
  - direct controller execution
  - exported Karabiner `send_user_command` payloads

### What we learned

- In Raycast, controlled text fields must support intermediate states, not just final valid states.
  - Example: `Codex > ` is a real in-progress editing state.
  - If parsing treats that as a completed path instead of `app = Codex, path = ""`, the field starts fighting user input.

- Menu value parsing has to stay backward-compatible.
  - Older values may effectively behave like path-only menu strings.
  - Newer values are app-prefixed: `App > Menu > Item`.
  - Any parser/editor change has to be careful not to blindly assume the first segment is always the app.

- Menu fallbacks have to be threaded through every execution path.
  - It is not enough to store `menuFallbackPaths` in config and support them in `Controller.runAction(...)`.
  - They also must be included in exported Karabiner `send_user_command` payloads, or direct exported usage silently loses the fallback behavior.

- Raycast config display names are not a safe runtime app identity.
  - App config display names may be custom names or default strings like `App: com.bundle.id`.
  - Live menu search and runtime execution should prefer a real app name/bundle mapping, not just the config display name.
  - This remains a watch-out area for future cleanup.

- The IntelliJ side was already in good shape.
  - Raycast could add useful search/append UX without changing the IntelliJ plugin itself.
  - The existing custom server contract was enough for the first pass.

### Current watch-outs

- If menu editing/search acts strangely for app configs with custom names or default `App: bundle.id` names, the next place to fix is app-name inference in the Raycast editor.
- For any future editor/parser changes, test all three menu states explicitly:
  - empty
  - `App > `
  - `App > Menu > Item`

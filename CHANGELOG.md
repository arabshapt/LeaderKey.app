# Changelog

All notable changes to this fork are documented here.

## Unreleased

### Added
- Added IntelliJ integration as a first-class `intellij` action type, using a Unix domain socket at `/tmp/intellij-leaderkey.sock` and optional multi-action delay syntax such as `SaveAll,ReformatCode|100`.
- Added searchable Raycast editors for `intellij` and `menu` actions:
  - `intellij` now supports action search/append and a separate delay field while preserving the existing stored `ActionA,ActionB|100` format
  - `menu` now supports app selection, live menu-item search through Leader Key IPC, and ordered fallback menu paths
- Added a first-class `keystroke` action type with compact shortcut syntax (`Ct`, `COt`, etc.), PID-targeted `CGEvent.postToPid(_:)` delivery, optional app targeting, and optional post-send app focus.
- Added a local-first Raycast extension for config discovery and editing with:
  - `Search Shortcuts`
  - `Browse Configs`
  - `Add/Edit by Path`
  - current-app Raycast deeplinks via `app:{frontmostBundleId}`
  - config creation for missing app configs
  - recursive browse search
  - glanceable detail previews
  - internal copy/paste clipboard for actions and groups
- Added moveable full-path editing with live path validation in the Raycast record editor, including same-config relocation, missing-parent auto-creation, and inline collision checks.
- Added dedicated action `description` and `aiDescription` metadata so action labels can stay automatic while user notes remain editable and searchable.
- Added managed nested `LEADERKEY_SPECIFIC_CONFIGS_START/END` support for `karabiner.edn`, so app-specific activation shortcuts can be regenerated inside the existing activation section without replacing the surrounding manual content.
- Added a subtle menubar reload-success pulse that acknowledges completed config reloads without flashing the Leader Key hint window.
- Added a selectable reload-success sound setting with curated built-in macOS sounds (`Glass`, `Hero`, `Ping`, `Pop`, `Funk`) and silent mode.

### Changed
- Raycast config writes now trigger Leader Key apply/export over the always-on local control socket at `/tmp/leaderkey.sock`, instead of using app URL callbacks.
- External config apply now follows the same reload/export refresh path as native saves, including hint/state refreshes after Raycast edits.
- Export refreshes are coalesced to avoid overlapping Goku runs after a single external apply.
- Raycast `intellij` and `menu` editing now use structured form controls instead of raw single-string editing, while still saving back to the existing underlying action formats.
- `application` actions now use the stronger seq-style activation path for running apps and a more reliable launch fallback for cold launches.
- `application` actions now preserve the fast `activate()` path for normal running-app switches, and only perform window-state reopen checks when the target app is already active.
- `Browse Configs` search now searches recursively inside the current subtree and ranks relative path matches before absolute path matches.
- Raycast list/detail presentation was tightened for small screens: denser rows, consistent path rendering, always-on detail previews, and better empty-group create flows.
- Raycast editing now treats action labels as generated display text and uses separate editable description fields instead.
- Raycast search now indexes action descriptions and AI descriptions in addition to generated labels, values, and key paths.
- Raycast editor field order now prioritizes the fields most likely to be changed:
  - actions: `Type`, value, description, AI description, `Full Path`
  - groups: description, `Full Path`
- The redundant Raycast `Path Preview` summary block was removed; path-specific guidance now appears inline on the `Full Path` field only when relevant.
- `LEADERKEY_SPECIFIC_CONFIGS` generation is now canonical and independent from the current keyboard shortcut settings, preserving fixed `:semicolon` / `:right_command` activation forms for the managed nested block.
- Successful config reload feedback is now routed through the menubar item instead of briefly reopening the main Leader Key HUD.

### Fixed
- Fixed Raycast-driven config changes not always making it into Leader Key hints, exported state mappings, or `karabiner.edn`.
- Fixed multiple redundant Goku/export runs after one external apply.
- Fixed blank Goku failure logs by capturing exit code, stdout, and stderr.
- Fixed menu fallback paths being saved in config but not included in exported/direct Karabiner menu execution payloads.
- Fixed the Raycast `Primary Menu Path` field fighting user input when the value was in the intermediate `App > ` state.
- Fixed compatibility with Homebrew-installed Goku builds that advertise `-c` but fail at runtime; Leader Key now uses `GOKU_EDN_CONFIG_FILE` instead of `goku -c`.
- Fixed `open_app` for apps like Messages that remain frontmost after `Cmd+W` but no longer have a visible window; these now reopen instead of silently re-activating.
- Fixed stale Raycast list refresh after add/edit/delete operations.
- Fixed split detail panes in Raycast only rendering for the first selected row.
- Fixed app saves/export refreshes so managed `LEADERKEY_SPECIFIC_CONFIGS` content in `karabiner.edn` stays in sync when new app configs are created.
- Fixed Goku execution from the app/Xcode environment by resolving Homebrew-installed `goku` binaries through an enriched `PATH`, matching terminal behavior more reliably.
- Fixed the save/reload success acknowledgement flicker that briefly showed Leader Key hints after saving configs.
- Fixed Raycast command startup regressions where `Browse Configs` and `Add/Edit by Path` could visually stick in an empty list until the user typed.
- Fixed literal-vs-alias ambiguity by keeping alias-aware matches while still offering explicit literal typed-path create actions across search, browse, and path-editor flows.
- Fixed runaway selection in Raycast detail lists by removing over-controlled list selection updates during native key-repeat.
- Fixed saved user text like `Go to history` being hidden behind generated shortcut labels by storing it as action description metadata instead of overloading `label`.

### Removed
- Removed the `leaderkey://` URL scheme and the URL-based reload/apply fallback. Local IPC is now the only supported external control path for config apply.

# Changelog

All notable changes to this fork are documented here.

## Unreleased

### Added
- Added IntelliJ integration as a first-class `intellij` action type, using a Unix domain socket at `/tmp/intellij-leaderkey.sock` and optional multi-action delay syntax such as `SaveAll,ReformatCode|100`.
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
- Added managed nested `LEADERKEY_SPECIFIC_CONFIGS_START/END` support for `karabiner.edn`, so app-specific activation shortcuts can be regenerated inside the existing activation section without replacing the surrounding manual content.
- Added a subtle menubar reload-success pulse that acknowledges completed config reloads without flashing the Leader Key hint window.
- Added a selectable reload-success sound setting with curated built-in macOS sounds (`Glass`, `Hero`, `Ping`, `Pop`, `Funk`) and silent mode.

### Changed
- Raycast config writes now trigger Leader Key apply/export over the always-on local control socket at `/tmp/leaderkey.sock`, instead of using app URL callbacks.
- External config apply now follows the same reload/export refresh path as native saves, including hint/state refreshes after Raycast edits.
- Export refreshes are coalesced to avoid overlapping Goku runs after a single external apply.
- `application` actions now use the stronger seq-style activation path for running apps and a more reliable launch fallback for cold launches.
- `Browse Configs` search now searches recursively inside the current subtree and ranks relative path matches before absolute path matches.
- Raycast list/detail presentation was tightened for small screens: denser rows, consistent path rendering, always-on detail previews, and better empty-group create flows.
- `LEADERKEY_SPECIFIC_CONFIGS` generation is now canonical and independent from the current keyboard shortcut settings, preserving fixed `:semicolon` / `:right_command` activation forms for the managed nested block.
- Successful config reload feedback is now routed through the menubar item instead of briefly reopening the main Leader Key HUD.

### Fixed
- Fixed Raycast-driven config changes not always making it into Leader Key hints, exported state mappings, or `karabiner.edn`.
- Fixed multiple redundant Goku/export runs after one external apply.
- Fixed blank Goku failure logs by capturing exit code, stdout, and stderr.
- Fixed compatibility with Homebrew-installed Goku builds that advertise `-c` but fail at runtime; Leader Key now uses `GOKU_EDN_CONFIG_FILE` instead of `goku -c`.
- Fixed stale Raycast list refresh after add/edit/delete operations.
- Fixed split detail panes in Raycast only rendering for the first selected row.
- Fixed app saves/export refreshes so managed `LEADERKEY_SPECIFIC_CONFIGS` content in `karabiner.edn` stays in sync when new app configs are created.
- Fixed Goku execution from the app/Xcode environment by resolving Homebrew-installed `goku` binaries through an enriched `PATH`, matching terminal behavior more reliably.
- Fixed the save/reload success acknowledgement flicker that briefly showed Leader Key hints after saving configs.

### Removed
- Removed the `leaderkey://` URL scheme and the URL-based reload/apply fallback. Local IPC is now the only supported external control path for config apply.

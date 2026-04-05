# Leader Key Raycast Extension

This extension is the fast discovery and config-editing surface for Leader Key.

## Commands

### `Search Shortcuts`

- Searches across the effective flattened index.
- Supports direct edit, delete, override, browse-in-config, and path-editor actions.
- Supports literal typed-path creation rows:
  - `Create Action at ...`
  - `Create Group at ...`

### `Browse Configs`

- Opens the effective config list and then drills into a config browser.
- Also exposes direct path-editor entry for each config.
- Supports top-level literal typed-path creation rows for ambiguous queries.

### `Add/Edit by Path`

- Opens a config picker or a direct config-target path editor.
- Uses path analysis to resolve existing records and offer create/edit flows quickly.
- Also exposes literal typed-path creation rows when alias-aware matching would otherwise hide the user's intended raw sequence.

### `Rebuild Index`

- Forces a rebuild of the cached flattened index.

## Current Search Rules

There are two parallel interpretations of typed input:

- Alias-aware search:
  - `left`, `left arrow`, `left_arrow`, `leftarrow` -> `←`
  - `right`, `right arrow`, `right_arrow`, `rightarrow` -> `→`
  - `up`, `up arrow`, `up_arrow`, `uparrow` -> `↑`
  - `down`, `down arrow`, `down_arrow`, `downarrow` -> `↓`
  - `space`, `space bar`, `space_bar`, `spacebar` -> `" "`
- Literal typed path:
  - `left` can also mean `l -> e -> f -> t`
  - `space` can also mean `s -> p -> a -> c -> e`

The extension intentionally supports both. When alias-aware matching finds existing records, the UI should still offer explicit literal-path creation actions so the user can create the raw sequence instead.

## Current Loading Strategy

Raycast has a rendering quirk here:

- if some commands mount an empty/loading `List` first
- and only later swap to the real rows after async cache I/O
- the UI can visually stick in an empty state even though data is already in memory

Because of that, command startup is intentionally split:

- `Search Shortcuts`
  - can tolerate the normal shared loader path
  - renders from the flattened index and has been stable on first open
- `Browse Configs`
  - intentionally seeds from the on-disk cache on first render
  - keeps background refresh quiet during initial open
- `Add/Edit by Path`
  - intentionally seeds from the on-disk cache on first render
  - keeps background refresh quiet during initial open

That tradeoff exists on purpose. A small synchronous cache read is currently better than letting Raycast mount an empty native list first.

## Index Recovery Behavior

The shared loader in [`src/use-index-payload.ts`](./src/use-index-payload.ts):

- reads memory cache first
- optionally seeds from disk synchronously on first render
- reads disk cache asynchronously when needed
- refreshes the index in the background
- automatically retries index rebuilds when there is no usable payload
- exposes a manual retry action if automatic recovery still fails

The expected behavior is:

- warm cache: commands open immediately with rows
- cold cache: commands recover by rebuilding the index automatically
- unrecoverable failure: commands show an explicit retry row instead of staying in a fake loading state forever

## Config Editing Behavior

Current edit/create coverage:

- groups can be edited from the form UI
- group description is edited through the existing `label` field
- local groups and local actions can be deleted from the editor form
- `Add/Edit by Path` can edit groups directly from child-group rows
- `Search Shortcuts` exposes add/edit actions similar to the config browser
- `Browse Configs` exposes direct path-editor actions per config

## Important Constraints

- `{frontmostBundleId}` is a template placeholder, not something Raycast expands by itself.
- Leader Key must expand that placeholder before opening a `raycast://` deeplink.
- The first-render seeded payload behavior for `Browse Configs` and `Add/Edit by Path` is deliberate. Do not remove it unless Raycast's list-mount behavior changes and the empty-list regression is re-tested.

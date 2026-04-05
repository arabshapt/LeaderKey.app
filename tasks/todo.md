# Fix Raycast commands showing "No Results" during async data load

## Tasks
- [x] Add `List.EmptyView` to `search-shortcuts.tsx` — shows "Loading shortcuts…" while payload loads
- [x] Add `List.EmptyView` to `add-edit-by-path.tsx` — shows "Loading configs…" while payload loads
- [x] Add `List.EmptyView` to `browse-configs.tsx` — shows "Loading configs…" while payload loads

## Review

**Root cause**: All three Raycast commands load config data asynchronously via `loadIndex()`. During this async gap, `payload` is `undefined`, so the list renders with zero items. Raycast displays "No Results" for empty lists even when `isLoading={true}`.

**Why it's inconsistent**: When the cache file is valid and the fingerprint matches, `loadIndex()` returns fast enough that the UI never paints the empty state. When the cache is stale or missing, `buildCachePayload()` runs (heavier I/O), creating a visible gap where "No Results" appears.

**Fix**: Added `<List.EmptyView title="Loading …" />` conditionally rendered when data is still loading and no payload exists yet. This replaces the default "No Results" empty state with an appropriate loading message. Once `payload` is set, the `EmptyView` is no longer rendered and normal list items appear.

**Files changed**:
- `raycast-leader-key/src/search-shortcuts.tsx` — 3 lines added
- `raycast-leader-key/src/add-edit-by-path.tsx` — 3 lines added
- `raycast-leader-key/src/browse-configs.tsx` — 3 lines added

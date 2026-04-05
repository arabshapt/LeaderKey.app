# karabiner.ts Migration

This project now has two related pieces of karabiner.ts work:

1. The forked `karabiner.ts` repo in `karabiner.ts/` was patched to support `send_user_command`.
2. Leader Key's `kar` backend now means `karabiner.ts` repo export, not an external `kar` compiler binary.

## What Was Implemented In The Fork

The forked `karabiner.ts` repo now supports `send_user_command` for both payload styles used by Leader Key:

- string payloads such as `"deactivate"`
- structured payloads such as `{ v: 1, type: "open_app", ... }`

The fork also contains a parity snapshot of the current Goku-generated `Default` profile:

- snapshot path: `karabiner.ts/configs/arabshapt/default-profile.ts`
- parity test path: `karabiner.ts/configs/arabshapt/default-profile.test.ts`
- generator path: `karabiner.ts/scripts/generate-arabshapt-profile.mjs`
- canonical hash: `4a34cd1933d5008f73b3e8fb81609edae7ec7d4ce45bd22753cf70dc5487610c`

That snapshot is a migration baseline and regression reference. It is not the file Leader Key rewrites during normal exports.

## Source Of Truth And Re-Migration

For personal Karabiner rules, Goku remains the source of truth.

- canonical personal config: `~/.config/karabiner.edn`
- generated full-profile migration snapshot: `karabiner.ts/configs/arabshapt/default-profile.ts`
- app-managed Leader Key export: `karabiner.ts/configs/leaderkey/leaderkey-generated.ts`

These are different things:

- Edit `karabiner.edn` when you add or change personal shortcuts outside Leader Key.
- Let Leader Key regenerate `configs/leaderkey/leaderkey-generated.ts` when app-managed shortcuts change.
- Do not hand-edit `configs/arabshapt/default-profile.ts`; regenerate it from Goku.

If `karabiner.edn` changes and you want the forked `karabiner.ts` repo to match it again, rerun the migration snapshot:

```bash
cd /Users/arabshaptukaev/personalProjects/LeaderKeyapp/karabiner.ts
npm run sync:arabshapt
```

That command regenerates:

- `configs/arabshapt/default-profile.ts`
- `configs/arabshapt/default-profile.test.ts`
- `configs/arabshapt/apply-default-profile.ts`

and then reruns the parity test for that snapshot.

If you want to apply the regenerated full-profile snapshot to live Karabiner:

```bash
cd /Users/arabshaptukaev/personalProjects/LeaderKeyapp/karabiner.ts
deno run --allow-env --allow-read --allow-write configs/arabshapt/apply-default-profile.ts
```

If you only want Leader Key app-managed rules refreshed, use the app export path instead. That does not regenerate the full `arabshapt` migration snapshot.

## Leader Key Export Model

Leader Key now exports `karabiner.ts` content into a configurable repo/workspace path and writes only app-managed files under:

- `configs/leaderkey/leaderkey-generated.ts`
- `configs/leaderkey/index.ts` (created once if missing, then preserved)

Manual repo edits should live outside `configs/leaderkey/`, or in the bootstrap `index.ts` after it has been created.

Leader Key still writes `leaderkey-state-mappings.json` into its existing app export directory under `~/Library/Application Support/Leader Key/export/`, because the app runtime already loads mappings from there.

## Live Apply Behavior

The `karabiner.ts` backend no longer depends on an external `kar` binary.

Instead, Leader Key now:

1. builds managed Karabiner rules in Swift
2. writes the generated repo module
3. patches the selected profile in `~/.config/karabiner/karabiner.json` directly

If repo export fails in `karabiner.ts` mode, live apply is skipped.

If backend mode is `both`, the repo export runs first and Goku still runs afterward. A repo export failure is logged and surfaced as an unhealthy karabiner.ts backend state, but Goku continues.

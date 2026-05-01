# LeaderKey Voice Dispatcher Safety

## Defaults

Voice dispatch is dry-run by default. `leaderkey-dispatcher execute` returns JSON describing intended steps unless `--execute` is passed.

Real execution goes through `/tmp/leaderkey.sock` using `dispatch execute <json>`. No `leaderkey://` URL scheme or deeplink control path is added.

## Validation

The validator rejects:

- invented action IDs
- action IDs outside retrieved candidates, unless explicitly allowed by code
- confidence below `0.85`
- model-supplied raw paths or command values
- `command` actions for real voice execution
- dangerous shell patterns such as `rm -rf`, `sudo`, `curl | sh`, `DROP TABLE`, `diskutil erase`, `chmod -R 777`, `launchctl unload`, and AppleScript file deletion

The executor always uses catalog data selected by `action_id`; model output cannot provide executable shell.

## Safety Metadata

Actions may include:

```json
{
  "voiceSafety": "safe",
  "voiceAliases": ["copy current url", "copy link"]
}
```

`voiceSafety` values:

- `safe`: eligible for real execution when validation passes
- `confirm`: plan can be returned, but automatic execution is blocked
- `block`: never execute from voice dispatch

`command` remains blocked even if metadata says `safe`.

## Swift Socket Guard

The Swift route revalidates every step before calling `Controller.runAction`:

- scope/path must resolve in current LeaderKey config
- action type must match the catalog reference
- `command`, `confirm`, and `block` actions do not run
- dry-run never performs a system action

This means the TypeScript planner and CLI are not trusted as the only safety boundary.

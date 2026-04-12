# Agent Notes

- Prefer socket-based triggers for Leader Key integrations. Use `/tmp/leaderkey.sock` commands like `apply-config` and `sync-goku-profile`.
- Do not add or revive `leaderkey://` URL schemes, URL callbacks, or deeplink-based app-control paths for reload/apply/migration/navigation-style triggers.
- Raycast should write JSON directly when editing config, then notify Leader Key over the local socket.

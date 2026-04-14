# Agent Notes

- Prefer socket-based triggers for Leader Key integrations. Use `/tmp/leaderkey.sock` commands like `apply-config` and `sync-goku-profile`.
- Do not add or revive `leaderkey://` URL schemes, URL callbacks, or deeplink-based app-control paths for reload/apply/migration/navigation-style triggers.
- Raycast should write JSON directly when editing config, then notify Leader Key over the local socket.
- Karabiner key repeat only works for the last event in a manipulator `to` array. For sticky-mode shortcut exports, keep `set_variable leaderkey_sticky=1` before the shortcut key event, and keep the shortcut key event last (for example `[set sticky, Cmd+T]`, not `[Cmd+T, set sticky]`). Export simple `.shortcut` actions as direct Karabiner key events in sticky mode; leave complex shortcut sequences on the socket/state-id path.

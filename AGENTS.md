# Agent Notes

- Prefer socket-based triggers for Leader Key integrations. Use `/tmp/leaderkey.sock` commands like `apply-config` and `sync-goku-profile`.
- Do not add or revive `leaderkey://` URL schemes, URL callbacks, or deeplink-based app-control paths for reload/apply/migration/navigation-style triggers.
- Raycast should write JSON directly when editing config, then notify Leader Key over the local socket.
- Karabiner key repeat only works for the last event in a manipulator `to` array. For sticky-mode shortcut exports, keep `set_variable leaderkey_sticky=1` before the shortcut key event, and keep the shortcut key event last (for example `[set sticky, Cmd+T]`, not `[Cmd+T, set sticky]`). Export simple `.shortcut` actions as direct Karabiner key events in sticky mode and normal mode, including normal-mode layer children; put any mode-reset variables before the final shortcut key event. Export normal-mode `.keystroke` actions as direct v1 Karabiner `keystroke` payloads. Leave complex shortcut sequences on the socket/state-id path.
- External Goku/manual Karabiner integrations that need "Leader Key normal mode is currently active" should key off `leaderkey_normal_active`, not `leaderkey_normal_state`, `leaderkey_normal_input`, or `leaderkey_normal_enabled` alone.
- Active normal-mode implementation handoff: `tasks/normal-mode-handoff.md`. Read it before changing normal-mode config, Karabiner export, state mappings, or status-item behavior.

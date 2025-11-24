# Learnings: Karabiner Export & Direct Execution

## Karabiner Export Flow
- **Trigger**: The "Save" button in the LeaderKey app triggers `config.saveAndFinalize()`.
- **Chain**: `saveAndFinalize()` -> `reloadConfig()` -> `.didSaveConfig` event -> `AppDelegate` listener -> `refreshStateMappingsIfNeeded()`.
- **Condition**: The export only happens if `Defaults[.inputMethodPreference]` is set to `.karabiner2`.
- **Execution**: `Karabiner2InputMethod.exportCurrentConfiguration()` generates the EDN, writes it to `~/.config/karabiner.edn.d/leaderkey-unified.edn`, injects it into `~/.config/karabiner.edn` (using markers), and runs `goku`.

## Direct Execution Logic
- **Goal**: Execute actions directly from Karabiner (via `shell_command`) to reduce latency and dependency on the running app.
- **Implementation**:
    - **URL Actions**: Handled in `Karabiner2Exporter.swift`.
    - **Background vs Foreground**:
        - `http`/`https` URLs default to **Foreground** (`open 'url'`).
        - Custom schemes (e.g., `raycast://`) default to **Background** (`open -g 'url'`).
        - Explicit `activates: true` forces Foreground.
        - Explicit `activates: false` forces Background.
    - **State Management**: Even with direct execution, we must call `leaderkey-cli deactivate` (or similar) to reset the LeaderKey state machine. This is done in parallel: `open ... & leaderkey-cli deactivate ...`.

## Key Files
- `Leader Key/Karabiner2Exporter.swift`: Core logic for EDN generation.
- `Leader Key/Karabiner2InputMethod.swift`: Handles the export and injection process.
- `Leader Key/AppDelegate.swift`: Orchestrates the save-reload-export cycle.

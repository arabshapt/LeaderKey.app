# Leader Key Development Guide

## Build & Test Commands
- Build: `xcodebuild -scheme "Leader Key" -configuration Debug build`
- Run all tests: `xcodebuild -scheme "Leader Key" -testPlan "TestPlan" test`
- Run single test: `xcodebuild -scheme "Leader Key" -testPlan "TestPlan" -only-testing:Leader\ KeyTests/UserConfigTests/testInitializesWithDefaults test`
- Bump version: `bin/bump`
- Create release: `bin/release`

## Architecture

Leader Key is a **Karabiner Elements companion app** — a configurator UI, WhichKey/hint overlay, and config exporter. Karabiner Elements is always the foundation for keyboard input.

### Data Flow
```
Karabiner Elements (captures keys, detects frontmost app)
  → UnixSocket / KarabinerUserCommandReceiver
    → Karabiner2InputMethod (only input method)
      → AppDelegate (routes commands: activate, deactivate, stateid, shake)
        → Controller.show() (loads config, shows overlay)
          → startSequence() (preprocesses config for key lookups)
```

### Key Design Decisions
- **Karabiner is single source of truth for app detection** — bundleId always comes from Karabiner's `activate {bundleId}` command. Never use `NSWorkspace.shared.frontmostApplication` for config loading — it can't detect overlay apps like Raycast
- **stateid is self-contained** — `executeActionByStateId()` uses `mapping.bundleId` to show the window with the correct config if not already visible
- **Two export backends** — Goku (EDN format, uses `:shell`) and kar (JSON, uses `send_user_command`). Both are supported via `Karabiner2Exporter`
- **Config merging** — app-specific configs are merged with fallback config via `mergeConfigWithFallback()`

### Config Files (in `~/Library/Application Support/Leader Key/`)
- `global-config.json` — default global config (always loaded as `root`)
- `app-fallback-config.json` — fallback config merged into every app config
- `app.{bundleId}.json` — app-specific configs (e.g., `app.com.raycast.macos.json`)

### File Organization
| Area | Key Files |
|------|-----------|
| Core | `AppDelegate.swift`, `Controller.swift`, `Events.swift` |
| Input | `Karabiner2InputMethod.swift`, `UnixSocketServer.swift`, `KarabinerUserCommandReceiver.swift`, `KarabinerCommandRouter.swift` |
| Config | `UserConfig.swift` + 11 extensions (`UserConfig+Loading.swift`, `+Creation`, `+Discovery`, `+Saving`, `+FileManagement`, `+Validation`, `+ErrorHandling`, `+Deletion`, `+Metadata`, `+EditingState`, `+GroupPath`) |
| Export | `Karabiner2Exporter.swift`, `KarCompilerService.swift`, `GokuCompilerService.swift` |
| UI | `MainWindow.swift`, `Cheatsheet.swift`, `Settings/GeneralPane.swift`, `Settings/AdvancedPane.swift` |
| Models | `Defaults.swift`, `UserState.swift`, `ConfigCache.swift`, `KeyLookupCache.swift` |

## Code Style Guidelines
- **Imports**: Group Foundation/AppKit imports first, then third-party libraries (Combine, Defaults)
- **Naming**: Use descriptive camelCase for variables/functions, PascalCase for types
- **Types**: Use explicit type annotations for public properties and parameters
- **Error Handling**: Use do/catch blocks and `alertHandler.showAlert()` for user-facing errors
- **Extensions**: Create extensions for additional functionality (UserConfig is split into 11 focused extensions)
- **State Management**: Use @Published and ObservableObject for reactive UI updates
- **Testing**: Descriptive test names, XCTAssert* methods. Tests in `Leader KeyTests/`
- **Access Control**: Use appropriate access modifiers (private, fileprivate, internal)
- Follow Swift idioms and default formatting (4-space indentation, spaces around operators)

## Common Gotchas
- **Deleting Swift files** requires removing references from `Leader Key.xcodeproj/project.pbxproj` (use python script to remove lines by line number)
- **Config caching** — `UserConfig.appConfigs` dict caches loaded configs. Call `reloadConfig()` to bust the cache
- **Shell command escaping** in Goku EDN requires two layers: shell escaping (`'\''`) then EDN escaping (`\\`, `\"`)
- **State IDs** in `Karabiner2Exporter` — global starts at 1, fallback at 2, inactive is 0

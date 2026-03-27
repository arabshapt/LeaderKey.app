---
name: config-system
description: Use when working on config loading, saving, creation, deletion, discovery, merging, validation, or the UserConfig class and its extensions
allowed-tools: Read, Grep, Glob, Bash
paths:
  - "Leader Key/UserConfig*.swift"
  - "Leader Key/ConfigCache.swift"
  - "Leader Key/ConfigPreprocessor.swift"
  - "Leader Key/ConfigValidator.swift"
---

# Configuration System

## Config Files (in `~/Library/Application Support/Leader Key/`)
- `global-config.json` — default global config, loaded into `UserConfig.root`
- `app-fallback-config.json` — merged into every app-specific config
- `app.{bundleId}.json` — app-specific (e.g., `app.com.raycast.macos.json`)
- `*.meta.json` — metadata files (custom names, timestamps)

## UserConfig Extensions (11 files)

| Extension | Purpose |
|-----------|---------|
| `+LoadingDecoding` | `getConfig(for:)`, `decodeConfig(from:)`, JSON parsing |
| `+Creation` | `createConfigForApp(bundleId:templateKey:customName:)` |
| `+Discovery` | Scan config directory, populate `discoveredConfigFiles` |
| `+Saving` | Persist config changes to disk |
| `+FileManagement` | File I/O, `defaultDirectory()`, directory validation |
| `+Validation` | Validate config structure |
| `+ErrorHandling` | Error reporting via `alertHandler` |
| `+Deletion` | Remove config files |
| `+Metadata` | Read/write `.meta.json` files |
| `+EditingState` | Track which config is being edited in Settings |
| `+GroupPath` | Navigate config hierarchy by path |

## Config Loading Flow (`getConfig(for:)` in `+LoadingDecoding`)
1. Check `appConfigs[bundleId]` cache — return if hit
2. Look for `app.{bundleId}.json` on disk
3. If found: decode JSON → `mergeConfigWithFallback()` → `sortGroupRecursively()` → cache and return
4. If not found: cache nil → fall through to fallback
5. Try `app-fallback-config.json` (cached as `appConfigs["app.default"]`)
6. Last resort: return `root` (global config)

## Config Merging
`mergeConfigWithFallback(appSpecificConfig:bundleId:)` merges app-specific actions with fallback config items, marking fallback items with `isFromFallback = true`. Result is sorted for consistent display.

## Key Properties
- `root: Group` — global default config (always loaded)
- `discoveredConfigFiles: [String: String]` — display name → file path mapping
- `appConfigs: [String: Group?]` — cache for loaded app configs (nil = tried and failed)
- `configCache: ConfigCache` — parsed config cache
- `appBundleIconCache: NSCache<NSString, NSImage>` — app icon cache

## Gotchas
- `appConfigs` caches nil for missing configs — call `reloadConfig()` to bust cache
- `extractBundleId(from:)` extracts bundleId from display name like "App: com.example.app"
- Config discovery happens in `discoverConfigFiles()` — called on init and file changes
- `FileMonitor` watches the config directory for changes and triggers reloads

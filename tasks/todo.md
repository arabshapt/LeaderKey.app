# Configuration Management Analysis

## Research Plan

### 1. Global Config Creation/Initialization ✓
- [x] Read main UserConfig.swift file
- [x] Understand the initialization flow in `ensureAndLoad()`
- [x] Review UserConfig+FileManagement.swift for directory and file creation

### 2. Default App Config Creation/Initialization ✓
- [x] Examine UserConfig+Creation.swift for app-specific config creation
- [x] Understand the `createConfigForApp()` method
- [x] Review app config naming conventions (app.<bundleId>.json)

### 3. Config Discovery and Loading Logic ✓
- [x] Analyze UserConfig+Discovery.swift for file discovery
- [x] Review UserConfig+LoadingDecoding.swift for loading logic
- [x] Understand the fallback hierarchy: specific app → app.default.json → config.json

### 4. Default Config When None Exist ✓
- [x] Examine the `bootstrapConfig()` method
- [x] Review the `defaultConfig` constant for default JSON structure
- [x] Understand how empty configurations are handled

### 5. Differences Between Global and App-Specific Config Handling ✓
- [x] Compare initialization patterns
- [x] Review caching mechanisms
- [x] Analyze error handling differences

## Key Findings

### Global Config (config.json)
- **Location**: `~/Library/Application Support/Leader Key/config.json`
- **Initialization**: Automatic via `ensureAndLoad()` → `ensureConfigFileExists()` → `bootstrapConfig()`
- **Default Content**: Hard-coded JSON with Terminal, Safari, Mail, Music, Messages, and Raycast actions
- **Validation**: Full validation with alerts for critical errors
- **Caching**: Main config stored in `root` property

### App-Specific Configs
- **Location**: `~/Library/Application Support/Leader Key/app.<bundleId>.json`
- **Creation**: Manual via `createConfigForApp()` method
- **Templates**: Can duplicate from existing config (global default or another app config)
- **Validation**: Validation performed but with suppressed alerts
- **Caching**: Stored in `appConfigs` dictionary with bundle ID as key

### Default App Config (app.default.json)
- **Purpose**: Fallback for all apps when no specific config exists
- **Priority**: Higher than global config.json but lower than app-specific configs
- **Creation**: Manual creation like other app configs
- **Usage**: Automatically used by `getConfig(for:)` method

### Config Discovery Process
1. **Directory Check**: Ensures config directory exists
2. **File Discovery**: Scans directory for config files
3. **Naming Resolution**: Handles custom display names
4. **Sorting**: Global → Default App → App-specific (alphabetical)

### Loading Hierarchy (getConfig method)
1. **App-specific**: `app.<bundleId>.json`
2. **Default app**: `app.default.json`
3. **Global fallback**: `config.json`

### Configuration States
- **Empty Root**: `emptyRoot` - Used when configs fail to load
- **Validation**: Real-time validation with different alert levels
- **Editing State**: Separate `currentlyEditingGroup` for UI modifications

## Implementation Details

### File Management
- Default directory: `~/Library/Application Support/Leader Key/`
- Automatic directory creation if missing
- File existence checks before operations
- Atomic file operations for safety

### Error Handling
- **Critical**: Config.json failures (app won't work)
- **Warning**: App-specific config failures (falls back to defaults)
- **Validation**: Structure validation with user-friendly messages

### Caching Strategy
- Global config: Always loaded in `root`
- App configs: Lazy-loaded and cached in `appConfigs`
- Cache invalidation: On config reload/discovery

## Review

The Leader Key app has a sophisticated configuration management system with:

1. **Three-tier hierarchy**: App-specific → Default app → Global
2. **Automatic bootstrapping**: Creates default config if none exists
3. **Robust error handling**: Different alert levels for different failure types
4. **Efficient caching**: Lazy-loading with proper cache invalidation
5. **User-friendly discovery**: Custom naming and sorting
6. **Real-time validation**: Immediate feedback on configuration issues

The system is well-designed for extensibility and handles edge cases gracefully while maintaining good performance through caching.
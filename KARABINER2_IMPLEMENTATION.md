# Karabiner 2.0 Mode Implementation

## Current Status (as of December 2024)
✅ **COMPLETED** - Basic implementation functional
✅ **COMPLETED** - Unified config generation with all apps in single file

## What We've Accomplished

### 1. Core Infrastructure
- Added `karabiner2` input method option to Defaults.swift
- Created Karabiner2Exporter.swift with state machine generator
- Created Karabiner2InputMethod.swift implementing InputMethod protocol
- Updated AppDelegate.swift to support new input method
- Modified KarabinerExporter.swift to add karabiner2EDN export format

### 2. State Machine Implementation
- **State ID Generation**: Using djb2 hash algorithm for stable, consistent IDs
  - Range: 2 to 2,147,483,647 (Karabiner variable safe range)
  - Special states: 0 = inactive, 1 = leader active
  - Example: "o.Sa" → State ID 193484265 (always consistent)

### 3. Key Notation Support
- Full modifier support (C=Cmd, S=Shift, O=Option, T=Ctrl)
- Proper conversion to Goku notation:
  - Sa → :!Sa (Shift+a)
  - CSa → :!CSa (Cmd+Shift+a)
  - S1 → :!S1 (Shift+1 = !)
- Special character mapping (-, space, return, etc.)

### 4. Command Execution
- Terminal actions call: `/usr/local/bin/leaderkey-cli sequence [path]`
- Path preserves original key notation: "Sa t" not "shift+a t"
- Examples:
  - leader → Sa → t: `/usr/local/bin/leaderkey-cli sequence Sa t`
  - leader → A → t: `/usr/local/bin/leaderkey-cli sequence A t`

## How It Works

### State Flow Example
1. User presses Cmd+k (leader) → state = 1
2. User presses Shift+a → state = hash("Sa") = 5862747
3. User presses t → executes `/usr/local/bin/leaderkey-cli sequence Sa t` → state = 0

### Generated Goku EDN Structure
```clojure
{:main [
  ;; Activation
  [:!Ck [["leader_state" 1] [:shell "leaderkey-cli activate"]]]
  
  ;; State transitions
  [:!Sa [["leader_state" 5862747]] ["leader_state" 1]]
  
  ;; Terminal actions - preserve original key notation
  [:t [[:shell "/usr/local/bin/leaderkey-cli sequence Sa t"] ["leader_state" 0]] ["leader_state" 5862747]]
  
  ;; Escape resets from any specific state
  ;; Note: Need to generate escape handlers for each active state
  [:escape [["leader_state" 0]] ["leader_state" 1]]
  [:escape [["leader_state" 0]] ["leader_state" 5862747]]
  ;; ... etc for each state
]}
```

## Technical Details

### State ID Generation (djb2 hash)
```swift
var hash: Int64 = 5381
for byte in pathString.utf8 {
    hash = ((hash << 5) &+ hash) &+ Int64(byte)
}
let stateId = Int32(abs(hash) % Int64(maxValue - minValue)) + minValue
```

### Key Conversion Algorithm
```swift
// Parse modifiers from key (C=cmd, S=shift, O=option, T=ctrl)
let prefixes = key.prefix(while: { "CSOT".contains($0) })
if !prefixes.isEmpty {
    modifiers = "!" + prefixes  // Build Goku notation
    baseKey = String(key.dropFirst(prefixes.count))
}
```

### Key Conversion Examples
- "Sa" → ":!Sa" (Shift+a in Goku)
- "COSa" → ":!COSa" (Cmd+Option+Shift+a)
- "-" → "hyphen"
- "space" → "spacebar"

### CLI Command Format
The sequence command preserves Leader Key notation:
- `Sa t` stays as "Sa t" (not converted to "shift+a t")
- This allows the CLI to properly interpret modifier combinations

### App-Specific Conditions (Added December 2024)
The implementation now supports app-specific configurations:

1. **Detection**: When exporting, the system detects if the frontmost app has a specific config file
   - Checks for `app.{bundleId}.json` in Application Support folder
   - If found, adds frontmost_application conditions to all manipulators

2. **EDN Generation**: With bundle ID provided, all manipulators include conditions:
   ```clojure
   [:!Ck 
    [["leader_state" 1] [:shell "/usr/local/bin/leaderkey-cli activate"]]
    {:conditions [:frontmost_application_is ["com.apple.Terminal"]]}]
   
   [:a 
    [["leader_state" 12345]] 
    {:conditions [[:frontmost_application_is ["com.apple.Terminal"]] ["leader_state" 1]]}]
   ```

3. **File Naming**: App-specific EDN files are named `leaderkey-{bundleId}.edn`
   - Example: `leaderkey-com.apple.Terminal.edn` for Terminal-specific config

4. **Usage**: Multiple app-specific configs can coexist in `~/.config/karabiner.edn.d/`
   - Each app gets its own state machine that only activates when that app is frontmost

### Unified Config Generation (Added December 2024)
The implementation now generates a single unified EDN file with all app configs:

1. **Structure**: Single `leaderkey-unified.edn` file containing:
   - `:applications` section with app aliases (e.g., `:vscode`, `:terminal`)
   - Global config section (activated with Cmd+K)
   - App-specific sections (activated with Cmd+Shift+K)

2. **App Alias Generation**: Uses custom names from .meta.json files:
   - Reads `customName` field from `app.{bundleId}.meta.json` files
   - Converts custom names to valid Goku aliases:
     - `"VSCode"` → `:vscode`
     - `"Email Randstad"` → `:email_randstad`
     - `"Terminal & Shell"` → `:terminal_and_shell`
   - Falls back to hardcoded mappings or bundle ID conversion if no meta file

3. **State Isolation**: Each app gets isolated state IDs by prefixing with app alias
   - Prevents conflicts when different apps have same key paths
   - Example: VSCode's "g.s" gets different state ID than Terminal's "g.s"

4. **Cleaner Conditions**: Uses Goku's simpler app alias syntax:
   ```clojure
   ;; Old verbose format:
   {:conditions [[:frontmost_application_is ["com.apple.Terminal"]] ["leader_state" 1]]}
   
   ;; New clean format:
   [:terminal ["leader_state" 1]]
   ```

5. **Auto-Discovery**: Automatically finds all app configs in Application Support
   - Merges each with fallback config
   - Generates unified EDN with all discovered apps

## File Structure
```
Leader Key/
├── Karabiner2Exporter.swift      # State machine generator
├── Karabiner2InputMethod.swift   # Input method implementation
├── KarabinerExporter.swift       # Updated with karabiner2EDN format
├── Defaults.swift                # Added karabiner2 input method option
└── AppDelegate.swift             # Updated to support karabiner2
```

## Next Steps / TODO
- [x] Basic state machine generation
- [x] Modifier key support
- [x] Stable hash function
- [x] Fix escape key handling (generate for each state since {:greater_than} not supported)
- [x] Add app-specific conditions to EDN generation
- [ ] Implement sticky mode support in state machine
- [ ] Add UI for exporting/viewing state machine
- [ ] Create automated tests for complex configurations
- [ ] Add support for macro actions
- [ ] Handle overlay detection in state conditions

## Known Limitations
1. ~~**Escape key handling**: Currently uses `{:greater_than 0}` which is not supported~~
   - ✅ **FIXED**: Now generates individual escape handlers for each state
   - Each state gets its own escape rule that resets to state 0
2. ~~App-specific configs not yet implemented in EDN~~
   - ✅ **FIXED**: App-specific conditions now added using frontmost_application_is
   - Detection of app configs and automatic bundle ID extraction implemented
3. Sticky modes not preserved in state machine
4. No visual debugging of state transitions
5. Manual Goku compilation required after export

## Testing
Run test with:
```bash
swift test_karabiner2.swift
```

Expected output shows:
- Stable state IDs for paths
- Correct modifier notation conversion
- Valid Goku EDN format

## Usage
1. Set input method to "Karabiner 2.0 (State Machine)" in settings
2. Export configuration generates `.edn` file
3. Place in `~/.config/karabiner.edn.d/`
4. Run `goku` to compile to Karabiner JSON
5. Leader Key actions execute via CLI

## Important Notes
- State IDs are deterministic using djb2 hash
- Original key notation preserved in CLI commands (Sa not shift+a)
- Actions can be at any depth level (1, 2, 3, 4, 5+)
- All modifier combinations supported (C/S/O/T)
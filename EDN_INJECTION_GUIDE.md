# EDN Injection Guide for Leader Key

## Overview
Leader Key can automatically inject its configuration into your main `karabiner.edn` file when using Karabiner 2.0 mode. This allows you to maintain a single karabiner.edn file with both your custom rules and Leader Key rules.

## How It Works

### 1. Marker Comments
Add special marker comments to your `karabiner.edn` file where you want Leader Key content to be injected:

#### Applications Section
```clojure
:applications {
  :my_custom_app ["com.my.app"]
  
  ;;; LEADERKEY_APPLICATIONS_START
  ;; Leader Key applications will be injected here
  ;;; LEADERKEY_APPLICATIONS_END
  
  :another_custom_app ["com.another.app"]
}
```

#### Main Rules Section
```clojure
:main [
  {:des "My custom rule"
   :rules [[:a :b]]}
  
  ;;; LEADERKEY_MAIN_START
  ;; Leader Key main rules will be injected here
  ;;; LEADERKEY_MAIN_END
  
  {:des "Another custom rule"
   :rules [[:c :d]]}
]
```

### 2. Automatic Behavior

When you export from Leader Key (Karabiner 2.0 mode):
1. Leader Key reads your `karabiner.edn` file
2. Replaces content between the markers with updated Leader Key configuration
3. Creates a timestamped backup before modification
4. Preserves all your custom rules outside the markers

### 3. Special Features

#### Activation Shortcuts Preservation
- The `"Leader Key - Activation Shortcuts"` section is **always preserved** if it exists
- This allows you to customize activation keys (e.g., use semicolon instead of Cmd+K)
- Your custom activation shortcuts won't be overwritten on subsequent exports

#### Auto-Add Markers
- If markers are missing, they're automatically added at the end of each section
- You can also manually place them where you prefer

## Example Configuration

### Basic Setup
```clojure
{:profiles
 {:Default {:default true}}

 :applications {
   :my_app ["com.my.app"]
   
   ;;; LEADERKEY_APPLICATIONS_START
   ;; Auto-generated Leader Key applications
   :intellij ["com.jetbrains.intellij"]
   :vscode ["com.microsoft.VSCode"]
   ;; ... more Leader Key apps ...
   ;;; LEADERKEY_APPLICATIONS_END
 }

 :main [
   {:des "My custom rules before Leader Key"
    :rules [[:a :b]]}
   
   ;;; LEADERKEY_MAIN_START
   {:des "Leader Key - Activation Shortcuts"
    :rules [
      ;; These are preserved - customize as needed!
      [:semicolon [...]]
      [:right_command [...]]
    ]}
   
   {:des "Leader Key - Intellij"
    :rules [
      ;; App-specific Leader Key rules
    ]}
   ;;; LEADERKEY_MAIN_END
   
   {:des "My custom rules after Leader Key"
    :rules [[:c :d]]}
 ]
}
```

### Custom Activation Example
```clojure
;;; LEADERKEY_MAIN_START
{:des "Leader Key - Activation Shortcuts"
 :rules [
   ;; Custom: Using semicolon for all app activations
   [:semicolon [["leaderkey_active" 1] ["leaderkey_global" 1] [:shell "/usr/local/bin/leaderkey-cli activate"]]]
   
   ;; Custom: Right command for global activation
   [:right_command [["leaderkey_active" 1] ["leaderkey_global" 1] [:shell "/usr/local/bin/leaderkey-cli activate"]]]
   
   ;; Custom: Escape to deactivate
   [:escape [["leaderkey_active" 0] [:shell "/usr/local/bin/leaderkey-cli deactivate"]] :leaderkey_active]
 ]}

;; Other Leader Key sections will be auto-updated here
;;; LEADERKEY_MAIN_END
```

## Tips

1. **First Time**: Markers are added automatically if missing
2. **Preserve Custom Shortcuts**: Edit the activation shortcuts section - it won't be overwritten
3. **Force Reset**: Delete the activation shortcuts section to get defaults back
4. **Backups**: Check `~/.config/karabiner.edn.backup.*` for previous versions
5. **Manual Control**: Place markers exactly where you want Leader Key content

## Troubleshooting

### Markers Not Working
- Ensure markers are exactly as shown (three semicolons, exact text)
- Check that both START and END markers are present for each section

### Activation Shortcuts Overwritten
- This shouldn't happen with the latest version
- Ensure you're using Leader Key version with preservation support

### Content Not Injecting
- Check if `karabiner.edn` exists at `~/.config/karabiner.edn`
- Verify markers are present in the file
- Check Leader Key logs for injection status

## Files

- **Main Config**: `~/.config/karabiner.edn`
- **Backups**: `~/.config/karabiner.edn.backup.<timestamp>`
- **Generated EDN**: `~/.config/karabiner.edn.d/leaderkey-unified.edn`
- **State Mappings**: `~/.config/karabiner.edn.d/leaderkey-state-mappings.json`
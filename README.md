<img src="https://s3.brnbw.com/icon_1024-akc2Ij3q9JOyhQ6Y7Lz6AFkX6nQQFhrQaRPqbV4vor0A62EA0vq4xOGrXpg6PVKi3aUJxOAyItkyktblPtZD4K4oYZ1bJVdh96VE.png" width="256" height="256" alt="Leader Key.app" />

# Leader Key.app - Enhanced

**The \*faster than your launcher\* launcher - with enhanced features**

An enhanced fork of the original [Leader Key.app](https://github.com/mikker/LeaderKey.app) by [@mikker](https://github.com/mikker), featuring improved validation UX, enhanced overlay detection, real-time feedback, and refined UI components.

*Original concept: A riff on [Raycast](https://www.raycast.com), [@mxstbr's multi-key Karabiner setup](https://www.youtube.com/watch?v=m5MDv9qwhU8&t=540s), and Vim's `<leader>` key.*

Watch the original intro videos by [@mikker](https://github.com/mikker):

<div>
<a href="https://www.youtube.com/watch?v=EQYakLsYSAQ"><img src="https://img.youtube.com/vi/EQYakLsYSAQ/maxresdefault.jpg" width=480></a>
<a href="https://www.youtube.com/watch?v=hzzQl5FOL-k"><img src="https://img.youtube.com/vi/hzzQl5FOL-k/maxresdefault.jpg" width=480></a>
</div>

*The original videos showcase the core functionality that this enhanced fork builds upon.*

## Fork Enhancements

This enhanced version includes several improvements over the original:

### 🎯 **Enhanced Validation UX**
- **Rich Error Feedback**: Interactive tooltips with detailed error messages and actionable suggestions
- **Validation Summary Panel**: Comprehensive overview of all configuration issues with one-click navigation
- **Severity-Based Indicators**: Color-coded visual feedback (red for errors, orange for warnings) with appropriate icons
- **Real-time Validation**: Immediate feedback as you edit configurations

### 🔍 **Improved Overlay Detection**
- Enhanced detection algorithms for better app overlay recognition
- Improved reliability and responsiveness

### ⚡ **Real-time Feedback & UI Improvements**
- Instant configuration validation without modal dialogs
- Refined settings interface with better visual hierarchy
- Enhanced keyboard interaction and accessibility
- Improved sorting and organization of configuration elements

### 🛠 **Development Improvements**
- Comprehensive test coverage for validation systems
- Better error handling and resilience
- Clean, maintainable codebase architecture

📦 [Download enhanced version](https://drive.google.com/file/d/1E6BcdelZ6FYXwM4fTGTyyY5_PBEsLOxb/view?usp=sharing)

### Installation

**Option 1: Homebrew (Recommended)**
```sh
brew tap arabshapt/leader-key-enhanced
brew install --cask leader-key-enhanced
```

**Option 2: Direct Download**
Download the enhanced version from [Google Drive](https://drive.google.com/file/d/1E6BcdelZ6FYXwM4fTGTyyY5_PBEsLOxb/view?usp=sharing).

**Option 3: Build from Source**
See the [Building from Source](#building-from-source) section below for detailed instructions.

**Option 4: Original via Homebrew** *(installs the upstream version)*
```sh
brew install --cask leader-key
```

*Note: The original Homebrew formula installs the upstream version. For the enhanced features, use Option 1 above.*

## Building from Source

### Prerequisites

- **macOS**: 13.0 or later
- **Xcode**: 15.0 or later with macOS SDK
- **Command Line Tools**: `xcode-select --install`

### Development Builds

For development and testing:

```bash
# Clone the repository
git clone https://github.com/arabshapt/LeaderKeyapp.git
cd LeaderKeyapp

# Build and run Debug configuration
xcodebuild -scheme "Leader Key" -configuration Debug build

# Or open in Xcode
open "Leader Key.xcodeproj"
```

### Release Builds

#### Quick Release (Recommended)

Use the provided release script:

```bash
# Bump version and create release
bin/bump
bin/release
```

The `bin/release` script will:
1. Archive the app in Release configuration
2. Export it to the `Updates/` directory
3. Create a versioned zip file
4. Generate release metadata

#### Manual Release Build

For manual control over the build process:

```bash
# 1. Build Release configuration
xcodebuild -scheme "Leader Key" -configuration Release build

# 2. Create archive
xcodebuild -scheme "Leader Key" -configuration Release archive \
    -archivePath "build/Leader Key.xcarchive"

# 3. Export app bundle
xcodebuild -exportArchive \
    -archivePath "build/Leader Key.xcarchive" \
    -exportPath "Updates" \
    -exportOptionsPlist exportOptions.plist
```

The exported app will be available at `Updates/Leader Key.app`.

### Build Configuration Notes

#### Code Signing & Hardened Runtime

This project uses **ad-hoc signing** for local distribution. Key configuration details:

- **Release builds**: Hardened Runtime is **disabled** to avoid framework loading conflicts
- **Debug builds**: Hardened Runtime is **enabled** for development security
- **Signing**: Uses manual ad-hoc signing (`CODE_SIGN_IDENTITY = "-"`)

#### Why Hardened Runtime is Disabled for Release

During development, we discovered that enabling Hardened Runtime with ad-hoc signing caused framework loading failures:

```
Library not loaded: @rpath/Sparkle.framework/Versions/B/Sparkle
Reason: mapping process and mapped file (non-platform) have different Team IDs
```

**Root Cause**: Hardened Runtime enforces strict validation between the main app and embedded frameworks. With ad-hoc signing (no Team ID), macOS treats each component as having different signing identities.

**Solution**: Hardened Runtime is disabled for Release builds while maintaining ad-hoc signing for local distribution.

For **App Store distribution**, you would need:
- Valid Apple Developer certificate
- Proper Team ID configuration
- Hardened Runtime enabled
- App Store signing configuration

### Troubleshooting

#### Framework Loading Errors

**Problem**: App fails to launch with Sparkle framework errors
**Solution**: Ensure hardened runtime is disabled for Release configuration

#### Code Signing Issues

**Problem**: "No signing certificate found" errors
**Solution**: The project is configured for ad-hoc signing - no developer certificate required

#### Build Failures

**Problem**: Swift format warnings during build
**Solution**: These are linting warnings and don't prevent building. Fix with:
```bash
# Auto-format Swift files
find "Leader Key" -name "*.swift" -exec swift format --in-place {} \;
```

#### Accessibility Permissions

**Problem**: App doesn't capture key events
**Solution**: Grant accessibility permissions in System Preferences → Privacy & Security → Accessibility

### Testing Your Build

After building, verify the app works correctly:

```bash
# Launch the app
open "Updates/Leader Key.app"

# Check if it's running
ps aux | grep "Leader Key" | grep -v grep
```

The app should appear in your menu bar and respond to your configured leader key.

## Why Leader Key?

### Problems with traditional launchers:

1. Typing the name of the thing can be slow and give unpredictable results.
2. Global shortcuts have limited combinations.
3. Leader Key offers predictable, nested shortcuts -- like combos in a fighting game.

### Example Shortcuts:

- <kbd>leader</kbd><kbd>o</kbd><kbd>m</kbd> → Launch Messages (`open messages`)
- <kbd>leader</kbd><kbd>m</kbd><kbd>m</kbd> → Mute audio (`media mute`)
- <kbd>leader</kbd><kbd>w</kbd><kbd>m</kbd> → Maximize current window (`window maximize`)

## FAQ

#### What do I set as my Leader Key?

Any key can be your leader key, but **only modifiers will not work**.

**Examples:**

- <kbd>F12</kbd>
- <kbd>⌘ + space</kbd>
- <kbd>⌘⌥ + space</kbd>
- <kbd>⌘⌥⌃⇧ + L</kbd> (hyper key)

**Advanced examples:**

Using [Karabiner](https://karabiner-elements.pqrs.org/) you can do more fancy things like:

- <kbd>right ⌘ + left ⌘</kbd> at once (bound to <kbd>F12</kbd>) my personal favorite
- <kbd>caps lock</kbd> (bound to <kbd>hyper</kbd> when held, <kbd>F12</kbd> when pressed)

See [@mikker's config](https://github.com/mikker/LeaderKey.app/wiki/@mikker's-config) in the wiki for akimbo cmds example.

#### I disabled the menubar item, how can I get Leader Key back?

Activate Leader Key, then <kbd>cmd + ,</kbd>.

## Attribution

This project is an enhanced fork of the original [Leader Key.app](https://github.com/mikker/LeaderKey.app) created by [@mikker](https://github.com/mikker). All original concepts, design, and core functionality are credited to the original author.

**Original Project**: https://github.com/mikker/LeaderKey.app  
**Original Author**: [@mikker](https://github.com/mikker)  
**Fork Maintainer**: [@arabshapt](https://github.com/arabshapt)

## License

MIT - Same as the original project

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
Clone this repository and build using Xcode or the command line tools documented in `CLAUDE.md`.

**Option 4: Original via Homebrew** *(installs the upstream version)*
```sh
brew install --cask leader-key
```

*Note: The original Homebrew formula installs the upstream version. For the enhanced features, use Option 1 above.*

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

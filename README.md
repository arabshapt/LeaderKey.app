<img src="https://s3.brnbw.com/icon_1024-akc2Ij3q9JOyhQ6Y7Lz6AFkX6nQQFhrQaRPqbV4vor0A62EA0vq4xOGrXpg6PVKi3aUJxOAyItkyktblPtZD4K4oYZ1bJVdh96VE.png" width="256" height="256" alt="Leader Key.app" />

# Leader Key.app — Enhanced

**The *faster than your launcher* launcher.**

An enhanced fork of the original [Leader Key.app](https://github.com/mikker/LeaderKey.app) by [@mikker](https://github.com/mikker). The fork has grown beyond the original macOS app into a small system: a Karabiner-Elements-driven overlay, a TypeScript Karabiner pipeline, a Raycast extension, and an IntelliJ plugin — all coordinated over local Unix sockets.

*Original concept: a riff on [Raycast](https://www.raycast.com), [@mxstbr's multi-key Karabiner setup](https://www.youtube.com/watch?v=m5MDv9qwhU8&t=540s), and Vim's `<leader>` key.*

Watch the original intro videos by [@mikker](https://github.com/mikker):

<div>
<a href="https://www.youtube.com/watch?v=EQYakLsYSAQ"><img src="https://img.youtube.com/vi/EQYakLsYSAQ/maxresdefault.jpg" width=480></a>
<a href="https://www.youtube.com/watch?v=hzzQl5FOL-k"><img src="https://img.youtube.com/vi/hzzQl5FOL-k/maxresdefault.jpg" width=480></a>
</div>

Further reading:
- [CHANGELOG.md](CHANGELOG.md) — recent releases and unreleased work
- [SKILLZ.md](SKILLZ.md) — implementation notes and accumulated lessons
- [CLAUDE.md](CLAUDE.md) — developer architecture guide

---

## What's New

- **IntelliJ integration** — first-class `intellij` action type, delivered over a Unix domain socket (`/tmp/intellij-leaderkey.sock`). Multi-action syntax like `SaveAll,ReformatCode|100` (trailing `|ms` = inter-action delay).
- **`keystroke` action type** — compact shortcut syntax (`Ct` = Ctrl+T, `COt` = Ctrl+Opt+T), PID-targeted delivery via `CGEvent.postToPid(_:)`, optional app targeting + post-send focus.
- **Rewritten Raycast extension** — local-first `Search Shortcuts`, `Browse Configs`, `Add/Edit by Path`, internal copy/paste clipboard, current-app deeplinks, recursive browse search, glanceable detail previews.
- **Structured editors for `intellij` and `menu`** — action search/append, separate delay field, app selection + live menu-item search, ordered fallback menu paths.
- **Moveable full-path editing** — live validation, same-config relocation, missing-parent auto-creation, inline collision checks.
- **Action description metadata** — dedicated `description` and `aiDescription` fields so generated labels stay automatic while notes remain editable and searchable.
- **Local-socket control** — `/tmp/leaderkey.sock` is now the only supported external control path. The `leaderkey://` URL scheme has been removed.
- **Menubar reload feedback** — subtle menubar pulse on successful reload (no more HUD flash), plus a selectable reload sound (`Glass`, `Hero`, `Ping`, `Pop`, `Funk`, or silent).
- **Managed nested `LEADERKEY_SPECIFIC_CONFIGS`** — app-specific activation rules regenerate inside the existing `karabiner.edn` block without clobbering surrounding manual content.

See [CHANGELOG.md](CHANGELOG.md) for the full list.

---

## Installation

Leader Key is a companion to **Karabiner-Elements** and uses **Goku** (or the in-tree `karabiner.ts`) to compile Karabiner configs. Follow the steps in order.

### 1. Install Karabiner-Elements (required)

```sh
brew install --cask karabiner-elements
```

Open it once and grant the requested permissions (Accessibility, Input Monitoring). See [karabiner-elements.pqrs.org](https://karabiner-elements.pqrs.org) for details.

### 2. Install Goku (required for config export)

```sh
brew install yqrashawn/goku/goku
```

Leader Key invokes Goku to compile `~/.config/karabiner.edn` into `~/.config/karabiner/karabiner.json`. Any Homebrew Goku build works; Leader Key uses `GOKU_EDN_CONFIG_FILE=...` internally (no reliance on `goku -c`).

### 3. Install Leader Key (the app)

**Option A — Homebrew tap (recommended)**

```sh
brew tap arabshapt/leader-key-enhanced
brew install --cask leader-key-enhanced
```

> ⚠️ The published cask currently pins an older build. A refreshed cask is pending; until then, prefer Option B or C for the latest features listed above.

**Option B — Build from source**

```sh
git clone https://github.com/arabshapt/LeaderKey.app.git
cd LeaderKey.app
xcodebuild -scheme "Leader Key" -configuration Release build
```

The built app lands in the derived-data `Build/Products/Release/` directory. Copy `Leader Key.app` into `/Applications`.

**Option C — Direct download**

Fallback pre-built zip: [Google Drive](https://drive.google.com/file/d/1E6BcdelZ6FYXwM4fTGTyyY5_PBEsLOxb/view?usp=sharing) (v1.16.0-enhanced — same build as the current Homebrew cask).

### 4. First-run setup

1. Launch Leader Key. It creates `~/Library/Application Support/Leader Key/` with `global-config.json` and `app-fallback-config.json`.
2. Make sure `~/.config/karabiner.edn` exists before your first export. Leader Key injects into and updates an existing Goku config, but it does not bootstrap a complete `karabiner.edn` from scratch. If you are starting fresh, create a minimal Goku config first, then follow [EDN_INJECTION_GUIDE.md](EDN_INJECTION_GUIDE.md).
3. Bind a leader key in **Settings → General** (e.g. F12, Hyper, `Cmd+Space`). Karabiner-Elements is what actually captures the key — Leader Key exports the rule for you.
4. Click **Apply config** (or save any edit). Leader Key injects its managed sections into `~/.config/karabiner.edn`, runs Goku, writes `karabiner.json`, and Karabiner-Elements reloads automatically.
5. Press your leader key — the overlay appears.

### 5. Optional: Raycast extension

Fast-path config editor and shortcut search. See [raycast-leader-key/README.md](raycast-leader-key/README.md) for install instructions (the extension runs locally against Leader Key over `/tmp/leaderkey.sock`).

### 6. Optional: IntelliJ plugin

Enables the `intellij` action type. Plugin repo: [arabshapt/intellij-action-executor](https://github.com/arabshapt/intellij-action-executor).

1. Download the latest `intellij-action-executor-*.zip` from the [Releases page](https://github.com/arabshapt/intellij-action-executor/releases).
2. In IntelliJ: **Settings → Plugins → ⚙️ → Install Plugin from Disk** → pick the zip → restart IDE.
3. On startup the plugin opens `/tmp/intellij-leaderkey.sock`; Leader Key `intellij` actions then route through it.

Building from source requires **Java 21** (system Java 25 breaks Gradle) — see [CLAUDE.md](CLAUDE.md#intellij-integration-v130) for details.

---

## Architecture & Tools

Leader Key is **not** a standalone keyboard remapper. Karabiner-Elements is the source of truth for key capture and frontmost-app detection; Leader Key is the overlay, configurator, and IPC hub that sits on top of it.

### Data flow

**Input (keystroke → action):**

```
Karabiner-Elements (captures keys + detects frontmost app)
  → user_command_receiver.sock (v1 JSON payload)
    → Leader Key InputMethod → Controller
      → overlay renders hints → user presses next key
        → action executes:
            application → NSRunningApplication.activate()
            menu        → AX API (in-process)
            keystroke   → CGEvent.postToPid()
            intellij    → /tmp/intellij-leaderkey.sock (UDS)
            open (URL)  → NSWorkspace
```

**Config edit → Karabiner:**

```
Native UI or Raycast edit
  → ~/Library/Application Support/Leader Key/*.json
    → Karabiner2Exporter
      → Goku (EDN)  OR  karabiner.ts (TypeScript DSL)
        → ~/.config/karabiner/karabiner.json → Karabiner reloads
```

### Components

| Component | Language | Role | Location |
|-----------|----------|------|----------|
| Leader Key app | Swift (AppKit) | Overlay, configurator, IPC hub, exporter | [Leader Key/](Leader%20Key/) |
| Karabiner-Elements | External (C++) | Keyboard event capture + frontmost-app detection | [karabiner-elements.pqrs.org](https://karabiner-elements.pqrs.org) |
| Goku | External (Clojure) | EDN → `karabiner.json` compiler | [yqrashawn/GokuRakuJoudo](https://github.com/yqrashawn/GokuRakuJoudo) |
| karabiner.ts | TypeScript | Type-safe Karabiner DSL + builder (alternative to Goku EDN for personal profiles) | [karabiner.ts/README.md](karabiner.ts/README.md) |
| Raycast extension | TypeScript / React | Fast config editor, shortcut search, path editing | [raycast-leader-key/README.md](raycast-leader-key/README.md) |
| IntelliJ plugin | Kotlin / Java | UDS action executor for `intellij` action type | [arabshapt/intellij-action-executor](https://github.com/arabshapt/intellij-action-executor) |

### IPC sockets

| Socket | Direction | Purpose |
|--------|-----------|---------|
| `/Library/Application Support/org.pqrs/tmp/user/$UID/user_command_receiver.sock` | Karabiner → Leader Key | Inbound key-triggered commands (v1 JSON payloads) |
| `/tmp/leaderkey.sock` | External tools → Leader Key | `apply-config`, `sync-goku-profile`, navigation commands (replaces the retired `leaderkey://` scheme) |
| `/tmp/intellij-leaderkey.sock` | Leader Key → IntelliJ | Newline-delimited JSON, stream socket (`SOCK_STREAM`) |

See [CLAUDE.md](CLAUDE.md) for the full architecture guide, file layout, and manual test harness.

---

## Why Leader Key?

### Problems with traditional launchers

1. Typing the name of the thing can be slow and give unpredictable results.
2. Global shortcuts have limited combinations.
3. Leader Key offers predictable, nested shortcuts — like combos in a fighting game.

### Example shortcuts

- <kbd>leader</kbd><kbd>o</kbd><kbd>m</kbd> → Launch Messages (`open messages`)
- <kbd>leader</kbd><kbd>m</kbd><kbd>m</kbd> → Mute audio (`media mute`)
- <kbd>leader</kbd><kbd>w</kbd><kbd>m</kbd> → Maximize current window (`window maximize`)

---

## FAQ

#### What do I set as my Leader Key?

Any key can be your leader key, but **modifiers alone will not work**.

Examples:

- <kbd>F12</kbd>
- <kbd>⌘ + space</kbd>
- <kbd>⌘⌥ + space</kbd>
- <kbd>⌘⌥⌃⇧ + L</kbd> (hyper key)

Advanced examples (via Karabiner-Elements):

- <kbd>right ⌘ + left ⌘</kbd> at once, bound to <kbd>F12</kbd>
- <kbd>caps lock</kbd> bound to <kbd>hyper</kbd> when held, <kbd>F12</kbd> when pressed

See [@mikker's config](https://github.com/mikker/LeaderKey.app/wiki/@mikker's-config) in the wiki for an akimbo-cmds example.

#### I disabled the menubar item, how can I get Leader Key back?

Activate Leader Key, then <kbd>cmd + ,</kbd>.

---

## Attribution

This project is an enhanced fork of the original [Leader Key.app](https://github.com/mikker/LeaderKey.app) created by [@mikker](https://github.com/mikker). All original concepts, design, and core functionality are credited to the original author.

- **Original project**: https://github.com/mikker/LeaderKey.app
- **Original author**: [@mikker](https://github.com/mikker)
- **Fork maintainer**: [@arabshapt](https://github.com/arabshapt)

## License

MIT — same as the original project.

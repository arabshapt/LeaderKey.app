---
name: export-karabiner
description: Use when working on Karabiner config export, Goku EDN generation, kar JSON generation, state machine, or state ID mapping
allowed-tools: Read, Grep, Glob, Bash
paths:
  - "Leader Key/Karabiner2Exporter.swift"
  - "Leader Key/KarCompilerService.swift"
  - "Leader Key/GokuCompilerService.swift"
  - "Leader Key/KarabinerExporter.swift"
---

# Karabiner Export System

## Core File
`Leader Key/Karabiner2Exporter.swift` — generates both Goku EDN and kar JSON configs from Leader Key's config model.

## State Machine Architecture
- **State tree**: Built from config `Group` hierarchy. Each group and action gets a unique `stateId` (Int32)
- **Initial state IDs**: Global = 1, Fallback = 2, Inactive = 0
- **StateMapping**: Maps stateId → (path, bundleId, actionType, actionValue, actionLabel)
- State mappings are written to `state_mappings.json` and loaded by AppDelegate for `stateid` command handling

## Two Export Backends

### Goku (EDN format)
- `generateGokuEDN()` / `generateUnifiedGokuEDNHierarchical()`
- Output: EDN format for GokuRakuJoudo compiler
- Uses `:shell` for commands (Goku doesn't support `send_user_command`)
- Compiled via `GokuCompilerService` which calls `goku` binary
- **Shell escaping**: Two layers required — shell escaping (`'\''`) then EDN escaping (`\\`, `\"`)
- Helper: `buildShellCommand()` respects user's shell settings (zsh/bash/custom, RC file loading)

### kar (JSON format)
- Generates Karabiner JSON directly
- Uses `send_user_command` for Leader Key communication
- Compiled via `KarCompilerService` which patches `karabiner.json`

## Key Methods
- `buildStateTree(from:appAlias:bundleId:)` — recursively builds state tree from Group hierarchy
- `generateManipulators(from:bundleId:)` — converts state tree to Karabiner manipulators
- `resolveActivationShortcut()` — reads KeyboardShortcuts to determine activation key
- `formatGokuEDN(manipulators:bundleId:)` — formats manipulators as EDN

## Testing
- `Karabiner2ExporterKarConfigTests.swift` — kar backend tests
- `KarCompilerServiceTests.swift` — compiler service tests
- `KarabinerExporterTests.swift` — general exporter tests

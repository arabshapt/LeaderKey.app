# Karabiner JSON Optimization + Benchmarking

## Completed
- [x] Analyze karabiner.json for strippable defaults
- [x] Add benchmark timing to export pipeline
- [x] Add postProcessKarabinerJSON to strip defaults + write compact
- [x] Fix kar backend to use compact JSON instead of prettyPrinted
- [x] Build and verify

## Review

### Changes Made

**`Leader Key/Karabiner2InputMethod.swift`** — Added `[Benchmark]` timing logs at each phase:
- Config discovery, EDN generation, File I/O + injection, Goku compilation, Total pipeline

**`Leader Key/GokuCompilerService.swift`** — Added post-processing after Goku compile:
- `postProcessKarabinerJSON()` reads karabiner.json, strips defaults, writes compact JSON
- `stripKarabinerDefaults()` recursive helper (reused by kar backend)

**`Leader Key/KarCompilerService.swift`** — Changed `.prettyPrinted` → `.sortedKeys` (compact) + default stripping

### Key Finding
The real bloat (3.2 MB / 53% of rules) is Leader Key's **state machine conditions** repeated on 7,561 manipulators — not Karabiner defaults (only 105 `key_up_when=any`). Significant size reduction needs architectural changes.

### How to Test
1. Launch from terminal → look for `[Benchmark]` lines
2. Check karabiner.json size before/after export
3. Verify Karabiner Elements still applies the config correctly

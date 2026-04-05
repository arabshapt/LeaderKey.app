# Refactor activation.ts from raw JSON to builder API

## Plan

The file has 56 manipulators in 5 groups:

1. **Kinesis app-specific activations** (manipulators 1-21): `keypad_4` + hyper + `ifApp(bundleId)` + `kinesis` device. App-specific activation with `leaderkey_appspecific=1, leaderkey_global=0`.
2. **Kinesis global activation** (manipulator 22): `keypad_7` + hyper + `kinesis`. Global activation with `leaderkey_global=1, leaderkey_appspecific=0`.
3. **Kinesis fallback activation** (manipulator 23): `keypad_4` + hyper + `kinesis` (no app condition). Fallback activation.
4. **Kinesis escape/settings** (manipulators 24-25): `escape` deactivate + `cmd+comma` settings, with `leaderkey_active=1` variable_if + `kinesis`.
5. **Apple built-in semicolon activations** (manipulators 26-50): `semicolon` + `noModes` + `ifApp(bundleId)` + `apple_built_in`. Same pattern but for built-in keyboard.
6. **Apple built-in global/fallback/deactivate** (manipulators 51-56): `right_command` global, `semicolon` fallback, `escape` deactivate, `cmd+comma` settings -- all with `noModes` + `apple_built_in`.

## Tasks

- [ ] Write the refactored file using builder API
- [ ] Add review section


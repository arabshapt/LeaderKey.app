# Add Key Naming Reference to Shortcut Action Popup

## Problem
Users need a way to check possible key namings (like `left_arrow`, `escape`, etc.) when creating shortcuts in the popup, but there's currently no reference available.

## Plan

### Todo Items
- [x] Extract key names from `karabinerToKeyCodeMap` in Controller.swift
- [x] Create a helper function to categorize key names by type (arrows, function keys, etc.)
- [x] Add a "Key Reference" button/disclosure in the shortcut editor popup
- [x] Implement a scrollable list view showing available key names organized by category
- [x] Test the implementation to ensure it works correctly

### Implementation Details
The current shortcut editor popup is in `ConfigEditorView.swift` (lines 385-412). It shows:
- A TextEditor for shortcut input
- Help text about modifier notation
- Cancel/Save buttons

We'll add a collapsible section showing all available key names from the `karabinerToKeyCodeMap` dictionary, organized by categories like:
- Letters (a-z)
- Numbers (0-9) 
- Arrows (left_arrow, right_arrow, etc.)
- Function Keys (f1-f20)
- Special Keys (escape, spacebar, etc.)
- Keypad Keys (keypad_0, keypad_enter, etc.)
- Modifiers (left_shift, right_command, etc.)

This will help users discover the correct key names when creating shortcuts.

## Review

### Changes Made
1. **Added KeyReference struct** in `ConfigEditorView.swift` (lines 5-18) - Contains categorized key names from the karabinerToKeyCodeMap
2. **Added state variable** `showingKeyReference` in ActionRow to track disclosure state
3. **Enhanced shortcut editor popup** with a collapsible "Key Reference" section that displays all available key names organized by categories:
   - Letters (a-z)
   - Numbers (0-9)
   - Arrows (left_arrow, right_arrow, etc.)
   - Function Keys (f1-f20)
   - Special Keys (escape, spacebar, etc.)
   - Keypad Keys (keypad_0, keypad_enter, etc.)
   - Modifiers (left_shift, right_command, etc.)
   - Symbols (comma, semicolon, etc.)
   - Media Keys (volume_increment, mute, etc.)
   - Other Keys (print_screen, japanese_kana, etc.)

### Implementation Details
- The key reference is displayed in a scrollable view with a maximum height of 200 points
- Keys are organized in a 4-column grid layout with monospaced font
- Each key name is displayed in a subtle background to make it easy to read
- The disclosure group can be expanded/collapsed to keep the UI clean
- Build tested successfully - no compilation errors

### Impact
- Simple, focused change that adds value without complexity
- Users can now easily discover available key names when creating shortcuts
- Maintains existing functionality while adding helpful reference information
- Implementation follows the existing code style and patterns
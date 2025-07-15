# Leader Key Macro Actions Implementation Plan

## Overview
This plan outlines the implementation of macro actions that can contain other actions with configurable delays and reordering capabilities.

## Current Action System Analysis

### Existing Action Types (from UserConfig.swift)
- `group`: Container for other actions/groups
- `application`: Opens applications
- `url`: Opens URLs
- `command`: Executes shell commands
- `folder`: Opens folders
- `shortcut`: Executes keyboard shortcuts
- `text`: Types text
- `toggleStickyMode`: Toggles sticky mode

### Current Action Execution (from Controller.swift)
- Actions are executed immediately via `runAction(_:)`
- Groups are executed recursively via `runGroup(_:)` - all actions run sequentially without delays
- No built-in delay mechanism between actions
- No reordering capabilities

### Current Data Models
- `Action`: Individual executable item with `key`, `type`, `value`, `label`, etc.
- `Group`: Container with `actions` array
- `ActionOrGroup`: Enum wrapping both types
- Actions are stored in JSON format

### Current UI Components
- `ActionRow`: Edits individual actions
- `GroupRow`: Edits groups and provides expand/collapse
- `ConfigEditorView`: Main editor interface
- Type-specific editors for shortcut, text, URL, command

## Implementation Plan

### 1. Core Data Model Changes
- [ ] Add new action type: `macro` to the `Type` enum
- [ ] Create `MacroStep` struct to represent individual steps in a macro
- [ ] Extend `Action` struct to support macro-specific properties
- [ ] Update JSON serialization/deserialization

### 2. Macro Data Structure
- [ ] Design `MacroStep` with properties: `action`, `delay`, `enabled`
- [ ] Add `steps` array to `Action` for macro type
- [ ] Implement reordering logic for macro steps
- [ ] Add validation for macro steps

### 3. UI Components for Macro Editor
- [ ] Create `MacroEditorView` for editing macro steps
- [ ] Add drag-and-drop reordering for steps
- [ ] Implement step enable/disable toggles
- [ ] Add delay configuration for each step
- [ ] Create step addition/removal controls

### 4. Macro Execution Engine
- [ ] Implement `runMacro(_:)` method in Controller
- [ ] Add delay mechanism between macro steps
- [ ] Handle step skipping when disabled
- [ ] Add error handling for failed steps
- [ ] Implement cancellation support

### 5. Integration with Existing System
- [ ] Update `ActionRow` to handle macro type
- [ ] Modify `runAction(_:)` to support macro execution
- [ ] Update action icon system for macro type
- [ ] Add macro validation rules

### 6. Advanced Features
- [ ] Add conditional execution based on application state
- [ ] Implement variable delays (random, adaptive)
- [ ] Add macro recording functionality
- [ ] Create macro templates/presets

### 7. Testing
- [ ] Unit tests for macro data models
- [ ] UI tests for macro editor
- [ ] Integration tests for macro execution
- [ ] Performance tests for complex macros

### 8. Documentation
- [ ] Update user documentation
- [ ] Add macro examples
- [ ] Create migration guide

## Technical Decisions

### Delay Implementation
- Use `DispatchQueue.main.asyncAfter` for delays
- Support millisecond precision
- Default delay of 100ms between steps

### Step Storage
- Store steps as array in Action.value as JSON
- Maintain backward compatibility with existing actions
- Use codable protocol for serialization

### UI Design
- Modal sheet for macro editing (similar to existing editors)
- List-based interface with drag handles
- Inline delay editing with number input
- Visual indicators for enabled/disabled steps

### Error Handling
- Continue execution on step failure with logging
- Option to stop macro on first error
- Visual feedback for failed steps

## Files to Modify

### Core Data Models
- `Leader Key/UserConfig.swift` - Add macro type and data structures
- `Leader Key/ConfigValidator.swift` - Add macro validation

### UI Components
- `Leader Key/Views/ConfigEditorView.swift` - Add macro editor support
- `Leader Key/Views/ActionIcon.swift` - Add macro icon

### Execution Engine
- `Leader Key/Controller.swift` - Add macro execution logic

### Tests
- `Leader KeyTests/UserConfigTests.swift` - Add macro tests
- `Leader KeyTests/ConfigValidatorTests.swift` - Add macro validation tests

## Next Steps
1. Start with core data model changes
2. Implement basic macro execution
3. Create UI components
4. Add advanced features
5. Comprehensive testing
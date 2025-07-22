# Todo List: Fix Targeted Override Functionality

## Problem Analysis
The "Override" button in the settings editor is converting all fallback items instead of just the targeted item. This happens because:

1. **For Actions**: The action override works correctly - it only converts the specific action at the given path.

2. **For Groups**: The group override calls `convertNestedFallbacksToAppSpecific()` which recursively converts ALL nested items from fallback to app-specific, not just the targeted group itself.

The issue is in the `convertNestedFallbacksToAppSpecific` function which blindly converts all items in the entire subtree, when it should only convert items that are actually marked as fallbacks.

## Tasks

- [ ] **Task 1**: Modify `convertNestedFallbacksToAppSpecific` function to only convert items that are actually marked as fallbacks (`isFromFallback = true`)
- [ ] **Task 2**: Test the fix to ensure that when overriding a group, only fallback items within that group are converted, while app-specific items remain unchanged
- [ ] **Task 3**: Verify that the action override functionality still works correctly (it should, since it doesn't use this problematic function)

## Implementation Details

The fix should be simple - modify the `convertNestedFallbacksToAppSpecific` function to check `isFromFallback` before converting items:

```swift
func convertNestedFallbacksToAppSpecific(_ items: [ActionOrGroup]) -> [ActionOrGroup] {
    return items.map { item in
        switch item {
        case .action(var action):
            // Only convert if it's actually from fallback
            if action.isFromFallback {
                action.isFromFallback = false
                action.fallbackSource = nil
                // Convert macro steps if any
                if let macroSteps = action.macroSteps {
                    action.macroSteps = macroSteps.map { step in
                        var newStep = step
                        if newStep.action.isFromFallback {
                            newStep.action.isFromFallback = false
                            newStep.action.fallbackSource = nil
                        }
                        return newStep
                    }
                }
            }
            return .action(action)
        case .group(var group):
            // Only convert if it's actually from fallback
            if group.isFromFallback {
                group.isFromFallback = false
                group.fallbackSource = nil
            }
            // Recursively process nested items
            group.actions = convertNestedFallbacksToAppSpecific(group.actions)
            return .group(group)
        }
    }
}
```
# Sticky Mode for Groups

You can now mark groups with sticky mode (SM) similar to actions, so that activating a group automatically turns on sticky mode.

## How to Add Sticky Mode to Groups

Groups can now have a `stickyMode` property set to `true` in your configuration:

```json
{
  "key": null,
  "type": "group",
  "actions": [
    {
      "key": "a",
      "type": "group",
      "label": "Applications",
      "stickyMode": true,
      "actions": [
        {
          "key": "t",
          "type": "application",
          "value": "/Applications/Terminal.app",
          "label": "Terminal"
        },
        {
          "key": "s",
          "type": "application", 
          "value": "/Applications/Safari.app",
          "label": "Safari"
        }
      ]
    }
  ]
}
```

## How It Works

When you enter a group marked with `"stickyMode": true`:

1. **Automatic Activation**: Sticky mode is automatically activated when you press the group's key
2. **Visual Feedback**: The Leader Key window becomes transparent (alpha 0.2) to indicate sticky mode is active
3. **Persistent Navigation**: You can continue navigating through the menu without holding modifier keys
4. **Action Execution**: All actions within the group (and sub-groups) will execute without closing the window

## Benefits

- **Seamless Workflows**: Perfect for groups that contain multiple related actions you want to execute in sequence
- **No Manual Activation**: No need to explicitly toggle sticky mode or hold modifier keys
- **Consistent Behavior**: Works the same way as action-level sticky mode but applies to entire group hierarchies
- **Visual Consistency**: Same transparency feedback as existing sticky mode functionality

## Example Usage

With the configuration above:

1. Press your leader key → `a` to enter the Applications group
2. Sticky mode is automatically activated (window becomes transparent)
3. You can now press `t` to open Terminal, then `s` to open Safari
4. Both applications open without the Leader Key window closing
5. Sticky mode resets when you press Escape or activate the leader key again

## UI Configuration

In the Leader Key settings:

- Each group now has an "SM" checkbox in the configuration editor
- The checkbox tooltip explains: "Sticky Mode: Automatically activate sticky mode when entering this group"
- Works alongside existing action-level sticky mode settings

## Technical Implementation

- Groups now have a `stickyMode: Bool?` property
- Automatic activation occurs in both event tap handling and normal key processing
- Compatible with existing sticky mode toggle actions and modifier key behavior
- Properly serialized in JSON configuration files

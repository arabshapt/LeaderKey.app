# Sticky Mode Toggle Action

You can now toggle sticky mode programmatically using an action within a Leader Key sequence.

## How to Add the Action to Your Config

Add a new action with type `toggleStickyMode` to your configuration:

```json
{
  "key": "s",
  "type": "toggleStickyMode",
  "value": "",
  "label": "Toggle Sticky Mode"
}
```

## Example Usage

With this configuration:

```json
{
  "key": null,
  "type": "group",
  "actions": [
    {
      "key": "a",
      "type": "group",
      "label": "Applications",
      "actions": [
        {
          "key": "s",
          "type": "toggleStickyMode",
          "value": "",
          "label": "Toggle Sticky Mode"
        },
        {
          "key": "t",
          "type": "application",
          "value": "/Applications/Terminal.app",
          "label": "Terminal"
        }
      ]
    }
  ]
}
```

You can:
1. Press your leader key → `a` → `s` to toggle sticky mode on
2. The window will become transparent (alpha 0.2) when sticky mode is active
3. You can now navigate without holding the modifier key
4. Sticky mode automatically resets when you press Escape or activate the leader key again

## How Sticky Mode Works

Sticky mode can be activated in two ways:
1. **Modifier Key**: Hold the Command key (or Control key, depending on your configuration)
2. **Toggle Action**: Use the `toggleStickyMode` action in a sequence

When sticky mode is active:
- The Leader Key window becomes very transparent (alpha 0.2)
- You can continue navigating through the menu without holding modifier keys
- Actions will execute without closing the window

Sticky mode is automatically reset when:
- You press Escape
- You activate the leader key again (starting a new sequence)
- The window is hidden

## Benefits

- No need to hold modifier keys for long sequences
- Visual feedback through window transparency
- Predictable reset behavior
- Works alongside the existing modifier key sticky mode

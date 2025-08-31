#!/bin/bash

echo "=== Testing Action Type Fix for State ID Execution ==="
echo ""

# Check if the state mappings file exists
MAPPING_FILE="$HOME/.config/karabiner.edn.d/leaderkey-state-mappings.json"

if [ -f "$MAPPING_FILE" ]; then
    echo "✅ State mappings file found"
    echo ""
    
    # Check if actionTypeRaw field exists in mappings
    echo "Checking for actionTypeRaw field in mappings..."
    if jq -e '.[0].actionTypeRaw' "$MAPPING_FILE" > /dev/null 2>&1; then
        echo "✅ actionTypeRaw field exists in mappings"
        echo ""
        
        # Show some examples of different action types
        echo "Sample mappings with action types:"
        echo "-----------------------------------"
        
        # Find an application type action
        APP_ACTION=$(jq -r '.[] | select(.actionTypeRaw == "application") | "\(.stateId): \(.actionLabel // "N/A") - Type: \(.actionTypeRaw) - Value: \(.actionValue)" | @text' "$MAPPING_FILE" | head -1)
        if [ -n "$APP_ACTION" ]; then
            echo "Application: $APP_ACTION"
        fi
        
        # Find a command type action
        CMD_ACTION=$(jq -r '.[] | select(.actionTypeRaw == "command") | "\(.stateId): \(.actionLabel // "N/A") - Type: \(.actionTypeRaw) - Value: \(.actionValue)" | @text' "$MAPPING_FILE" | head -1)
        if [ -n "$CMD_ACTION" ]; then
            echo "Command: $CMD_ACTION"
        fi
        
        # Find a URL type action
        URL_ACTION=$(jq -r '.[] | select(.actionTypeRaw == "url") | "\(.stateId): \(.actionLabel // "N/A") - Type: \(.actionTypeRaw) - Value: \(.actionValue)" | @text' "$MAPPING_FILE" | head -1)
        if [ -n "$URL_ACTION" ]; then
            echo "URL: $URL_ACTION"
        fi
        
        echo ""
        echo "Action type distribution:"
        jq -r '.[] | .actionTypeRaw' "$MAPPING_FILE" | sort | uniq -c | sort -rn
        
    else
        echo "❌ actionTypeRaw field NOT found in mappings"
        echo "   You need to re-export the Karabiner configuration"
        echo "   1. Start Leader Key with Karabiner 2.0 mode"
        echo "   2. The export will happen automatically"
        echo "   3. Check the mappings file again"
    fi
else
    echo "❌ State mappings file not found at: $MAPPING_FILE"
    echo "   Make sure Leader Key is running with Karabiner 2.0 mode to generate it"
fi

echo ""
echo "=== Test Complete ==="
echo ""
echo "Expected behavior after fix:"
echo "- Application actions (like Xcode) will open correctly"
echo "- Command actions will execute as shell commands"
echo "- Each action type will be handled appropriately"
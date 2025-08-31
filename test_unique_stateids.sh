#!/bin/bash

echo "=== Testing Unique State IDs for Terminal Actions ==="
echo ""

# Check if the state mappings file exists
MAPPING_FILE="$HOME/.config/karabiner.edn.d/leaderkey-state-mappings.json"
EDN_FILE="$HOME/.config/karabiner.edn.d/leaderkey.edn"

if [ -f "$MAPPING_FILE" ]; then
    echo "✅ State mappings file found"
    echo ""
    
    # Count unique state IDs
    TOTAL_MAPPINGS=$(jq '. | length' "$MAPPING_FILE")
    UNIQUE_STATE_IDS=$(jq '[.[].stateId] | unique | length' "$MAPPING_FILE")
    
    echo "Total mappings: $TOTAL_MAPPINGS"
    echo "Unique state IDs: $UNIQUE_STATE_IDS"
    echo ""
    
    if [ "$TOTAL_MAPPINGS" -eq "$UNIQUE_STATE_IDS" ]; then
        echo "✅ All state IDs are unique!"
    else
        echo "❌ WARNING: Some state IDs are duplicated!"
        echo ""
        echo "Duplicate state IDs:"
        jq -r '[.[].stateId] | group_by(.) | map(select(length > 1)) | map(.[0])[]' "$MAPPING_FILE" 2>/dev/null || \
        jq -r '.[].stateId' "$MAPPING_FILE" | sort | uniq -d
    fi
    
    echo ""
    echo "Sample of first 10 unique state IDs with their actions:"
    echo "---------------------------------------------------"
    jq -r '.[:10] | .[] | "State ID: \(.stateId) → \(.actionLabel // .path | tostring)"' "$MAPPING_FILE"
    
    echo ""
    echo "Checking EDN file for stateid commands..."
    if [ -f "$EDN_FILE" ]; then
        echo "Sample stateid commands from EDN:"
        grep -o 'stateid [0-9-]*' "$EDN_FILE" | sort -u | head -10
        
        echo ""
        UNIQUE_STATEID_CMDS=$(grep -o 'stateid [0-9-]*' "$EDN_FILE" | sort -u | wc -l)
        echo "Total unique stateid commands in EDN: $UNIQUE_STATEID_CMDS"
    else
        echo "❌ EDN file not found at: $EDN_FILE"
    fi
    
else
    echo "❌ State mappings file not found at: $MAPPING_FILE"
    echo "   You need to restart Leader Key with Karabiner 2.0 mode to regenerate it"
fi

echo ""
echo "=== Test Complete ==="
echo ""
echo "Expected behavior:"
echo "- Each action should have a unique state ID"
echo "- No two actions should share the same state ID"
echo "- Each key press should trigger its specific action"
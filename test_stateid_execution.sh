#!/bin/bash

echo "=== Testing State ID Based Action Execution ==="
echo ""

# First, let's check if the state mappings file exists
MAPPING_FILE="$HOME/.config/karabiner.edn.d/leaderkey-state-mappings.json"

if [ -f "$MAPPING_FILE" ]; then
    echo "✅ State mappings file found at: $MAPPING_FILE"
    echo ""
    echo "First 5 state mappings:"
    jq '.[0:5]' "$MAPPING_FILE"
    echo ""
    
    # Get a sample state ID from the mappings
    SAMPLE_STATE_ID=$(jq -r '.[0].stateId' "$MAPPING_FILE")
    echo "Sample state ID: $SAMPLE_STATE_ID"
    echo ""
    
    # Test sending a state ID command
    echo "Testing state ID command with ID: $SAMPLE_STATE_ID"
    echo "Command: echo 'stateid $SAMPLE_STATE_ID' | nc -U /tmp/leaderkey.sock"
    
    # Check if socket exists
    if [ -S "/tmp/leaderkey.sock" ]; then
        echo ""
        echo "Sending state ID to Leader Key..."
        echo "stateid $SAMPLE_STATE_ID" | nc -U /tmp/leaderkey.sock
        echo ""
        echo "✅ State ID command sent successfully"
    else
        echo ""
        echo "⚠️  Unix socket not found. Make sure Leader Key is running with Karabiner 2.0 mode."
    fi
else
    echo "❌ State mappings file not found at: $MAPPING_FILE"
    echo "   Make sure you've exported the Karabiner 2.0 configuration."
fi

echo ""
echo "=== Testing Complete ==="
echo ""
echo "How the new system works:"
echo "1. Karabiner state machine reaches a terminal action"
echo "2. Executes: /usr/local/bin/leaderkey-cli stateid <state_id>"
echo "3. Leader Key receives the state ID"
echo "4. Looks up the action in state mappings"
echo "5. Executes the action directly"
echo ""
echo "Benefits:"
echo "- O(1) lookup instead of tree traversal"
echo "- No ambiguity about which config to use"
echo "- State ID encodes full context (app + path)"
echo "- Faster execution"
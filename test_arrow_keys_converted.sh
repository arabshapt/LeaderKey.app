#!/bin/bash

echo "=== Testing Converted Arrow Keys in Goku EDN ==="
echo ""
echo "This tests the arrow keys after conversion by Leader Key"
echo ""

# Create test EDN with properly converted arrow keys
cat > /tmp/test_arrow_keys_converted.edn << 'EOF'
;; Test EDN with converted arrow keys (as Leader Key would generate)

{
 :main [{:des "Arrow Key Test - Converted"
         :rules [
           ;; These are the keys after Leader Key converts Unicode symbols
           [:up_arrow [["leader_state" 100]] ["leader_state" 1]]
           [:down_arrow [["leader_state" 101]] ["leader_state" 1]]
           [:left_arrow [["leader_state" 102]] ["leader_state" 1]]
           [:right_arrow [["leader_state" 103]] ["leader_state" 1]]
           
           ;; Test terminal actions with arrow keys
           [:up_arrow ["/usr/local/bin/leaderkey-cli stateid 1000" ["leader_state" 0]] ["leader_state" 100]]
           [:down_arrow ["/usr/local/bin/leaderkey-cli stateid 1001" ["leader_state" 0]] ["leader_state" 101]]
         ]}]
}
EOF

echo "Testing converted arrow keys with goku dry-run..."
if GOKU_EDN_CONFIG_FILE=/tmp/test_arrow_keys_converted.edn goku --dry-run > /tmp/arrow_converted_output.json 2>&1; then
    echo "✅ Goku processed converted arrow key EDN successfully!"
    echo ""
    
    # Check for arrow key codes in output
    echo "Generated key codes:"
    jq -r '.complex_modifications.rules[0].manipulators[].from.key_code' /tmp/arrow_converted_output.json 2>/dev/null | sort -u
    echo ""
    
    # Count manipulators
    MANIP_COUNT=$(jq '.complex_modifications.rules[0].manipulators | length' /tmp/arrow_converted_output.json 2>/dev/null || echo "0")
    echo "✅ Generated $MANIP_COUNT manipulators with arrow keys"
    
else
    echo "❌ Goku failed to process converted arrow key EDN"
    echo "Error output:"
    cat /tmp/arrow_converted_output.json 2>/dev/null | head -20
fi

echo ""
echo "========================================="
echo "How the fix works:"
echo "1. User config has arrow keys as Unicode symbols (↑, ↓, ←, →)"
echo "2. Leader Key's convertToKarabinerKey() converts them to Karabiner format"
echo "3. Generated EDN has proper key codes (up_arrow, down_arrow, etc.)"
echo "4. Goku correctly processes the converted key codes"
echo ""
echo "To test with real Leader Key:"
echo "1. Add arrow key bindings to your config"
echo "2. Restart Leader Key with Karabiner 2.0 mode"
echo "3. Check generated EDN has 'up_arrow' instead of '↑'"
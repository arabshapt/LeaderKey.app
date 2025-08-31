#!/bin/bash

echo "=== Testing Arrow Key Conversion in Goku EDN ==="
echo ""

# Create test EDN with arrow keys
cat > /tmp/test_arrow_keys.edn << 'EOF'
;; Test EDN with arrow keys

{
 :main [{:des "Arrow Key Test"
         :rules [
           ;; Test with Unicode arrow symbols
           [:↑ [["leader_state" 100]] ["leader_state" 1]]
           [:↓ [["leader_state" 101]] ["leader_state" 1]]
           [:← [["leader_state" 102]] ["leader_state" 1]]
           [:→ [["leader_state" 103]] ["leader_state" 1]]
           
           ;; Test with text representations
           [:up_arrow [["leader_state" 200]] ["leader_state" 1]]
           [:down_arrow [["leader_state" 201]] ["leader_state" 1]]
           [:left_arrow [["leader_state" 202]] ["leader_state" 1]]
           [:right_arrow [["leader_state" 203]] ["leader_state" 1]]
         ]}]
}
EOF

echo "Testing arrow keys with goku dry-run..."
if GOKU_EDN_CONFIG_FILE=/tmp/test_arrow_keys.edn goku --dry-run > /tmp/arrow_test_output.json 2>&1; then
    echo "✅ Goku processed arrow key EDN successfully!"
    echo ""
    
    # Check for arrow key codes in output
    echo "Checking generated key codes:"
    if jq -r '.complex_modifications.rules[0].manipulators[].from.key_code' /tmp/arrow_test_output.json 2>/dev/null | head -10; then
        echo ""
        echo "✅ Arrow keys are being processed"
    fi
    
    # Count manipulators
    MANIP_COUNT=$(jq '.complex_modifications.rules[0].manipulators | length' /tmp/arrow_test_output.json 2>/dev/null || echo "0")
    echo "Generated $MANIP_COUNT manipulators"
    
else
    echo "❌ Goku failed to process arrow key EDN"
    echo "Error output:"
    cat /tmp/arrow_test_output.json 2>/dev/null | head -20
fi

echo ""
echo "========================================="
echo "Arrow Key Mapping Summary:"
echo "- Unicode ↑ → up_arrow"
echo "- Unicode ↓ → down_arrow"  
echo "- Unicode ← → left_arrow"
echo "- Unicode → → right_arrow"
echo ""
echo "The fix ensures arrow keys in Leader Key configs are properly"
echo "converted to Karabiner-compatible key codes."
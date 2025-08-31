#!/bin/bash

echo "=== Creating Test EDN with Proper Goku Format ==="
echo ""

# Create a simple test EDN with correct format
cat > /tmp/test_leader_key.edn << 'EOF'
;; Test EDN for Leader Key with proper Goku format
;; This demonstrates the correct structure with :des key

{
 :applications {
   :arc ["company.thebrowser.Browser"]
   :vscode ["com.microsoft.VSCode"]
 }

 :main [{:des "Leader Key Test Configuration"
         :rules [
           ;; Activation
           [:!Ck [["leader_state" 1] [:shell "/usr/local/bin/leaderkey-cli activate"]]]
           
           ;; Sample state transitions
           [:a [["leader_state" 177672]] ["leader_state" 1]]
           [:o [["leader_state" 177686]] ["leader_state" 1]]
           
           ;; Sample terminal actions with unique state IDs
           [:x [[:shell "/usr/local/bin/leaderkey-cli stateid 123456"] ["leader_state" 0]] ["leader_state" 177672]]
           [:c [[:shell "/usr/local/bin/leaderkey-cli stateid 789012"] ["leader_state" 0]] ["leader_state" 177686]]
           
           ;; Escape handlers
           [:escape [["leader_state" 0]] ["leader_state" 1]]
           [:escape [["leader_state" 0]] ["leader_state" 177672]]
           [:escape [["leader_state" 0]] ["leader_state" 177686]]
         ]}]
}
EOF

echo "✅ Created test EDN at /tmp/test_leader_key.edn"
echo ""
echo "Testing with goku dry-run..."
echo ""

if GOKU_EDN_CONFIG_FILE=/tmp/test_leader_key.edn goku --dry-run > /tmp/goku_test_output.json 2>&1; then
    echo "✅ Goku processed the test EDN successfully!"
    echo ""
    
    # Validate JSON
    if jq empty /tmp/goku_test_output.json 2>/dev/null; then
        echo "✅ Generated valid JSON"
        
        # Count rules
        RULE_COUNT=$(jq '.profiles[0].complex_modifications.rules | length' /tmp/goku_test_output.json 2>/dev/null || echo "0")
        echo "Generated $RULE_COUNT rule(s)"
        
        # Check for manipulators
        MANIP_COUNT=$(jq '.profiles[0].complex_modifications.rules[0].manipulators | length' /tmp/goku_test_output.json 2>/dev/null || echo "0")
        echo "Generated $MANIP_COUNT manipulator(s)"
    else
        echo "❌ Invalid JSON output"
    fi
else
    echo "❌ Goku failed to process the test EDN"
    echo "Error output:"
    cat /tmp/goku_test_output.json 2>/dev/null
fi

echo ""
echo "----------------------------------------"
echo ""
echo "To regenerate your Leader Key EDN with the correct format:"
echo "1. Restart Leader Key app with Karabiner 2.0 mode"
echo "2. The new EDN will be generated at ~/.config/karabiner.edn.d/leaderkey-unified.edn"
echo "3. Test it with: GOKU_EDN_CONFIG_FILE=~/.config/karabiner.edn.d/leaderkey-unified.edn goku --dry-run"
echo "4. If successful, copy to main location: cp ~/.config/karabiner.edn.d/leaderkey-unified.edn ~/.config/karabiner.edn"
echo "5. Apply with: goku"
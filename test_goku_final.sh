#!/bin/bash

echo "=== Final Goku Dry-Run Test ==="
echo ""
echo "NOTE: You need to restart Leader Key with Karabiner 2.0 mode to regenerate"
echo "the EDN files with the corrected format."
echo ""
echo "Testing with a correct format sample..."
echo ""

# Create test EDN with correct format
cat > /tmp/test_final.edn << 'EOF'
;; Test EDN with corrected format

{
 :applications {
   :arc ["company.thebrowser.Browser"]
   :vscode ["com.microsoft.VSCode"]
 }

 :main [{:des "Leader Key Test - Final Format"
         :rules [
           ;; Activation
           [:!Ck [["leader_state" 1] "/usr/local/bin/leaderkey-cli activate"]]
           
           ;; State transitions
           [:a [["leader_state" 177672]] ["leader_state" 1]]
           [:o [["leader_state" 177686]] ["leader_state" 1]]
           
           ;; Terminal actions with shell commands
           [:x ["/usr/local/bin/leaderkey-cli stateid 123456" ["leader_state" 0]] ["leader_state" 177672]]
           [:c ["/usr/local/bin/leaderkey-cli stateid 789012" ["leader_state" 0]] ["leader_state" 177686]]
           
           ;; Escape handlers
           [:escape [["leader_state" 0] "/usr/local/bin/leaderkey-cli deactivate"] ["leader_state" 1]]
           [:escape [["leader_state" 0]] ["leader_state" 177672]]
           [:escape [["leader_state" 0]] ["leader_state" 177686]]
         ]}]
}
EOF

echo "Running goku dry-run test..."
if GOKU_EDN_CONFIG_FILE=/tmp/test_final.edn goku --dry-run > /tmp/goku_final_output.json 2>&1; then
    echo "✅ Goku processed EDN successfully!"
    echo ""
    
    # Check for shell commands
    if grep -q "shell_command" /tmp/goku_final_output.json; then
        echo "✅ Shell commands are properly generated"
        echo ""
        echo "Sample shell commands:"
        jq -r '.complex_modifications.rules[0].manipulators[] | select(.to[]?.shell_command) | .to[].shell_command // empty' /tmp/goku_final_output.json 2>/dev/null | head -5
    else
        echo "⚠️  No shell commands found in output"
    fi
    
    echo ""
    echo "Manipulator count:"
    jq '.complex_modifications.rules[0].manipulators | length' /tmp/goku_final_output.json 2>/dev/null
    
else
    echo "❌ Goku failed to process EDN"
    cat /tmp/goku_final_output.json 2>/dev/null | head -20
fi

echo ""
echo "========================================="
echo "Next steps to apply the fixes:"
echo "1. Restart Leader Key app with Karabiner 2.0 mode"
echo "2. Wait for EDN to be regenerated at ~/.config/karabiner.edn.d/leaderkey-unified.edn"
echo "3. Test with: GOKU_EDN_CONFIG_FILE=~/.config/karabiner.edn.d/leaderkey-unified.edn goku --dry-run"
echo "4. If successful, copy to main: cp ~/.config/karabiner.edn.d/leaderkey-unified.edn ~/.config/karabiner.edn"
echo "5. Apply configuration: goku"
echo "6. Test in Karabiner Elements"
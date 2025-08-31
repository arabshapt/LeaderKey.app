#!/bin/bash

echo "=== Testing Multi-Section EDN Format ==="
echo ""
echo "This tests the new EDN format with separate sections for:"
echo "  1. Activation (all !Ck and !CSk keys)"
echo "  2. Global rules"
echo "  3. App-specific rules"
echo ""

# Create test EDN with multi-section format
cat > /tmp/test_multi_section.edn << 'EOF'
;; Test Multi-Section EDN Format
;; This mimics what Leader Key 2.0 should generate

{
 :applications {
   :vscode ["com.microsoft.VSCode"]
   :xcode ["com.apple.dt.Xcode"]
 }

 :main [
  ;; Section 1: Activation
  {:des "Leader Key 2.0 - Activation"
   :rules [
     ;; Global activation
     [:!Ck [["leader_state" 1] "/usr/local/bin/leaderkey-cli activate"]]
     ;; App-specific activations
     [:!CSk [["leader_state" 1] "/usr/local/bin/leaderkey-cli activate"] :vscode]
     [:!CSk [["leader_state" 1] "/usr/local/bin/leaderkey-cli activate"] :xcode]
   ]}

  ;; Section 2: Global rules
  {:des "Leader Key 2.0 - Global"
   :rules [
     ;; Global state transitions
     [:a [["leader_state" 100]] ["leader_state" 1]]
     [:b [["leader_state" 101]] ["leader_state" 1]]
     
     ;; Global terminal actions
     [:x ["/usr/local/bin/leaderkey-cli stateid 1000" ["leader_state" 0]] ["leader_state" 100]]
     [:y ["/usr/local/bin/leaderkey-cli stateid 1001" ["leader_state" 0]] ["leader_state" 101]]
     
     ;; Global escape handlers
     [:escape [["leader_state" 0] "/usr/local/bin/leaderkey-cli deactivate"] ["leader_state" 1]]
     [:escape [["leader_state" 0] "/usr/local/bin/leaderkey-cli deactivate"] ["leader_state" 100]]
     [:escape [["leader_state" 0] "/usr/local/bin/leaderkey-cli deactivate"] ["leader_state" 101]]
   ]}

  ;; Section 3: VSCode rules
  {:des "Leader Key 2.0 - vscode"
   :rules [
     ;; VSCode state transitions
     [:c [["leader_state" 200]] [:vscode ["leader_state" 1]]]
     [:d [["leader_state" 201]] [:vscode ["leader_state" 1]]]
     
     ;; VSCode terminal actions
     [:x ["/usr/local/bin/leaderkey-cli stateid 2000" ["leader_state" 0]] [:vscode ["leader_state" 200]]]
     [:y ["/usr/local/bin/leaderkey-cli stateid 2001" ["leader_state" 0]] [:vscode ["leader_state" 201]]]
     
     ;; VSCode escape handlers
     [:escape [["leader_state" 0] "/usr/local/bin/leaderkey-cli deactivate"] [:vscode ["leader_state" 200]]]
     [:escape [["leader_state" 0] "/usr/local/bin/leaderkey-cli deactivate"] [:vscode ["leader_state" 201]]]
   ]}

  ;; Section 4: Xcode rules
  {:des "Leader Key 2.0 - xcode"
   :rules [
     ;; Xcode state transitions
     [:e [["leader_state" 300]] [:xcode ["leader_state" 1]]]
     [:f [["leader_state" 301]] [:xcode ["leader_state" 1]]]
     
     ;; Xcode terminal actions
     [:x ["/usr/local/bin/leaderkey-cli stateid 3000" ["leader_state" 0]] [:xcode ["leader_state" 300]]]
     [:y ["/usr/local/bin/leaderkey-cli stateid 3001" ["leader_state" 0]] [:xcode ["leader_state" 301]]]
     
     ;; Xcode escape handlers
     [:escape [["leader_state" 0] "/usr/local/bin/leaderkey-cli deactivate"] [:xcode ["leader_state" 300]]]
     [:escape [["leader_state" 0] "/usr/local/bin/leaderkey-cli deactivate"] [:xcode ["leader_state" 301]]]
   ]}
 ]
}
EOF

echo "Testing multi-section EDN with goku dry-run..."
if GOKU_EDN_CONFIG_FILE=/tmp/test_multi_section.edn goku --dry-run > /tmp/multi_section_output.json 2>&1; then
    echo "✅ Goku processed multi-section EDN successfully!"
    echo ""
    
    # Check for multiple rule sections
    echo "Checking rule sections..."
    RULE_COUNT=$(jq '.profiles[0].complex_modifications.rules | length' /tmp/multi_section_output.json 2>/dev/null || echo "0")
    echo "✅ Generated $RULE_COUNT rule sections"
    
    # Check each section
    echo ""
    echo "Rule section descriptions:"
    jq -r '.profiles[0].complex_modifications.rules[].description' /tmp/multi_section_output.json 2>/dev/null | while IFS= read -r desc; do
        echo "  - $desc"
    done
    
    # Count manipulators per section
    echo ""
    echo "Manipulators per section:"
    i=0
    while true; do
        MANIP_COUNT=$(jq ".profiles[0].complex_modifications.rules[$i].manipulators | length" /tmp/multi_section_output.json 2>/dev/null)
        if [ $? -ne 0 ] || [ -z "$MANIP_COUNT" ]; then
            break
        fi
        DESC=$(jq -r ".profiles[0].complex_modifications.rules[$i].description" /tmp/multi_section_output.json 2>/dev/null)
        echo "  $DESC: $MANIP_COUNT manipulators"
        ((i++))
    done
    
    # Check for activation keys
    echo ""
    echo "Checking activation keys..."
    ACTIVATION_COUNT=$(jq '[.profiles[0].complex_modifications.rules[] | select(.description | contains("Activation")) | .manipulators | length] | add' /tmp/multi_section_output.json 2>/dev/null || echo "0")
    echo "✅ Found $ACTIVATION_COUNT activation manipulators"
    
    # Verify state IDs
    echo ""
    echo "Sample state IDs found:"
    grep -o 'stateid [0-9]*' /tmp/multi_section_output.json | sed 's/stateid //' | sort -u | head -10 | while read id; do
        echo "  - $id"
    done
    
else
    echo "❌ Goku failed to process multi-section EDN"
    echo "Error output:"
    cat /tmp/multi_section_output.json 2>/dev/null | head -20
fi

echo ""
echo "========================================="
echo ""
echo "To test with real Leader Key EDN:"
echo "1. Run Leader Key app with Karabiner 2.0 mode"
echo "2. Check ~/.config/karabiner.edn.d/leaderkey-unified.edn"
echo "3. Run: GOKU_EDN_CONFIG_FILE=~/.config/karabiner.edn.d/leaderkey-unified.edn goku --dry-run"
echo "4. Verify multiple sections appear in Karabiner Elements"
#!/bin/bash

echo "Testing Preservation of Activation Shortcuts Inside Markers"
echo "==========================================================="
echo ""

# Create test file with activation shortcuts INSIDE markers
cat > /tmp/test_activation_inside.edn << 'EOF'
{:profiles
 {:Default {:default true}}

 :applications {
   :my_app ["com.my.app"]
   ;;; LEADERKEY_APPLICATIONS_START
   ;; Will be replaced
   ;;; LEADERKEY_APPLICATIONS_END
 }

 :main [
   {:des "My Custom Rule Before" 
    :rules [[:a :b]]}
   
   ;;; LEADERKEY_MAIN_START
   {:des "Leader Key - Activation Shortcuts"
    :rules [
      [:condi :!tilde-mode :!caps_lock-mode]
      ;; CUSTOM: Using semicolon for all activations
      [:semicolon [["leaderkey_active" 1] ["leaderkey_global" 1] [:shell "/usr/local/bin/leaderkey-cli activate"]] ]
      [:right_command [["leaderkey_active" 1] ["leaderkey_global" 1] [:shell "/usr/local/bin/leaderkey-cli activate"]] ]
      ;; CUSTOM: Special escape handling
      [:escape [["leaderkey_active" 0] [:shell "/usr/local/bin/leaderkey-cli deactivate"]] :leaderkey_active]
    ]}
   
   {:des "Other Leader Key Section"
    :rules [
      ;; This should be replaced
      [:x :y]
    ]}
   ;;; LEADERKEY_MAIN_END
   
   {:des "My Custom Rule After"
    :rules [[:c :d]]}
 ]
}
EOF

echo "Created test file with CUSTOM activation shortcuts INSIDE markers:"
echo "- Using semicolon for activation"
echo "- Using right_command for activation"
echo "- Custom escape handling"
echo ""
echo "File: /tmp/test_activation_inside.edn"
echo ""
echo "Expected behavior after export:"
echo "✓ Custom activation shortcuts should be PRESERVED"
echo "✓ Other Leader Key sections should be updated"
echo "✓ Applications should be updated"
echo ""
echo "To test:"
echo "1. cp ~/.config/karabiner.edn ~/.config/karabiner.edn.backup"
echo "2. cp /tmp/test_activation_inside.edn ~/.config/karabiner.edn"
echo "3. Trigger export from Leader Key"
echo "4. Check that semicolon/right_command activations are still there:"
echo "   grep -A10 'Leader Key - Activation Shortcuts' ~/.config/karabiner.edn"
echo "5. Restore: cp ~/.config/karabiner.edn.backup ~/.config/karabiner.edn"
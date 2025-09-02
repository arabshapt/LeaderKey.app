#!/bin/bash

echo "Testing Activation Shortcuts Preservation"
echo "=========================================="
echo ""

# Create test karabiner.edn with custom activation shortcuts
cat > /tmp/test_karabiner_custom.edn << 'EOF'
{:profiles
 {:Default {:default true}}

 :applications {
   :my_app ["com.my.app"]
   ;;; LEADERKEY_APPLICATIONS_START
   ;; Leader Key apps will be injected here
   ;;; LEADERKEY_APPLICATIONS_END
 }

 :main [
   {:des "My Custom Rule Before" 
    :rules [[:a :b]]}
   
   ;;; LEADERKEY_MAIN_START
   {:des "Leader Key - Activation Shortcuts"
    :rules [
      ;; CUSTOM ACTIVATION - Using Ctrl+Shift+K instead of Cmd+Shift+K
      [{:key :k :modi [:control :shift]} [["leaderkey_active" 1] ["leaderkey_global" 1] [:shell "/usr/local/bin/leaderkey-cli activate"]] ]
      ;; CUSTOM ACTIVATION - Added custom shortcut for Terminal
      [{:key :t :modi [:command :option]} [["leaderkey_active" 1] [:shell "/usr/local/bin/leaderkey-cli activate com.apple.Terminal"]] ]
    ]}
   ;;; LEADERKEY_MAIN_END
   
   {:des "My Custom Rule After"
    :rules [[:c :d]]}
 ]
}
EOF

echo "Created test file with CUSTOM activation shortcuts:"
echo "- Ctrl+Shift+K for global activation (instead of Cmd+K)"
echo "- Cmd+Option+T for Terminal activation (custom addition)"
echo ""
echo "File saved to: /tmp/test_karabiner_custom.edn"
echo ""
echo "To test preservation:"
echo "1. Backup your current karabiner.edn:"
echo "   cp ~/.config/karabiner.edn ~/.config/karabiner.edn.backup"
echo ""
echo "2. Copy test file:"
echo "   cp /tmp/test_karabiner_custom.edn ~/.config/karabiner.edn"
echo ""
echo "3. Trigger export from Leader Key (Karabiner 2.0 mode)"
echo ""
echo "4. Check if custom activation shortcuts are preserved:"
echo "   grep -A5 'Leader Key - Activation Shortcuts' ~/.config/karabiner.edn"
echo ""
echo "5. The CUSTOM shortcuts should remain, not be replaced with defaults"
echo ""
echo "6. Restore your original when done:"
echo "   cp ~/.config/karabiner.edn.backup ~/.config/karabiner.edn"
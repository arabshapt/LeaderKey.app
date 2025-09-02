#!/bin/bash

echo "Testing EDN Injection Feature"
echo "=============================="

# Create a test karabiner.edn with markers
cat > /tmp/test_karabiner.edn << 'EOF'
{:profiles
 {:Default {:default true
            :alone   260
            :held    50
            :delay   0
            :sim 100}}

 :applications {
   :my_custom_app ["com.my.custom.app"]
   :another_app ["com.another.app"]
   ;;; LEADERKEY_APPLICATIONS_START
   ;; Leader Key applications will be injected here
   ;;; LEADERKEY_APPLICATIONS_END
   :final_app ["com.final.app"]
 }

 :main [
   {:des "My custom rule before"
    :rules [[:a :b]]}
   
   ;;; LEADERKEY_MAIN_START
   ;; Leader Key main rules will be injected here
   ;;; LEADERKEY_MAIN_END
   
   {:des "My custom rule after"
    :rules [[:c :d]]}
 ]
}
EOF

echo "Created test karabiner.edn with markers at /tmp/test_karabiner.edn"
echo ""
echo "Backup your current karabiner.edn and copy test file to test injection:"
echo "  cp ~/.config/karabiner.edn ~/.config/karabiner.edn.original"
echo "  cp /tmp/test_karabiner.edn ~/.config/karabiner.edn"
echo ""
echo "Then trigger export in Leader Key app (Karabiner 2.0 mode) to test injection"
echo ""
echo "After testing, restore your original:"
echo "  cp ~/.config/karabiner.edn.original ~/.config/karabiner.edn"
#!/bin/bash

echo "Add Leader Key Injection Markers"
echo "================================="
echo ""
echo "This script will help you add the injection markers to your karabiner.edn"
echo ""

EDN_FILE="$HOME/.config/karabiner.edn"

if [ ! -f "$EDN_FILE" ]; then
    echo "ERROR: karabiner.edn not found at $EDN_FILE"
    exit 1
fi

# Check if markers already exist
if grep -q ";;; LEADERKEY_APPLICATIONS_START" "$EDN_FILE"; then
    echo "✓ Application markers already exist"
    APP_EXISTS=true
else
    echo "✗ Application markers not found"
    APP_EXISTS=false
fi

if grep -q ";;; LEADERKEY_MAIN_START" "$EDN_FILE"; then
    echo "✓ Main markers already exist"
    MAIN_EXISTS=true
else
    echo "✗ Main markers not found"
    MAIN_EXISTS=false
fi

if [ "$APP_EXISTS" = true ] && [ "$MAIN_EXISTS" = true ]; then
    echo ""
    echo "All markers are already present!"
    exit 0
fi

echo ""
echo "The improved injection system can now automatically add markers"
echo "when you export from Leader Key (with autoAddMarkers enabled)."
echo ""
echo "However, you can also manually add them at specific locations."
echo ""
echo "For manual addition, add these markers to your karabiner.edn:"
echo ""
echo "In the :applications section (before the closing }):"
echo "   ;;; LEADERKEY_APPLICATIONS_START"
echo "   ;; Leader Key applications will be injected here"
echo "   ;;; LEADERKEY_APPLICATIONS_END"
echo ""
echo "In the :main section (before the closing ]):"
echo "   ;;; LEADERKEY_MAIN_START"
echo "   ;; Leader Key main rules will be injected here"
echo "   ;;; LEADERKEY_MAIN_END"
echo ""
echo "Or simply trigger an export from Leader Key and markers will be"
echo "added automatically at the end of each section."
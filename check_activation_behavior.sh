#!/bin/bash

echo "Checking Activation Shortcuts Behavior"
echo "======================================="
echo ""

EDN_FILE="$HOME/.config/karabiner.edn"

if [ ! -f "$EDN_FILE" ]; then
    echo "karabiner.edn not found"
    exit 1
fi

# Check if activation shortcuts exist
if grep -q "\"Leader Key - Activation Shortcuts\"" "$EDN_FILE"; then
    echo "✓ Activation shortcuts section EXISTS in karabiner.edn"
    echo ""
    echo "Current activation rules:"
    echo "------------------------"
    sed -n '/Leader Key - Activation Shortcuts/,/^[[:space:]]*]}/p' "$EDN_FILE" | head -20
    echo ""
    echo "BEHAVIOR: These shortcuts will be PRESERVED on next export"
    echo "You can safely customize them and they won't be overwritten."
else
    echo "✗ Activation shortcuts section NOT FOUND in karabiner.edn"
    echo ""
    echo "BEHAVIOR: Default activation shortcuts will be ADDED on next export"
    echo "After first export, you can customize them and they'll be preserved."
fi

echo ""
echo "To force update activation shortcuts (if needed):"
echo "1. Remove the entire {:des \"Leader Key - Activation Shortcuts\" ...} block"
echo "2. Export again from Leader Key"
echo "3. New defaults will be added"
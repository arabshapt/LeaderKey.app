#!/bin/bash

echo "=== Testing Fallback-Only Activation ===" 
echo ""
echo "This test verifies the new fallbackOnly activation type"
echo ""

# First, export the current configuration
echo "1. Running Leader Key app to export configuration..."
open "/Users/arabshaptukaev/Library/Developer/Xcode/DerivedData/Leader_Key-hdrszguigtidcmfqirtyvoqbgjhv/Build/Products/Debug/Leader Key.app"
sleep 3

echo ""
echo "2. Checking generated EDN for activation keys..."
echo ""

# Check for global activation (Cmd+K)
echo "Global activation (Cmd+K):"
grep '!Ck.*activate"' ~/.config/karabiner.edn.d/leaderkey-unified.edn | head -1

echo ""
echo "Fallback-only activation (Cmd+Option+K):"
grep '!MOk.*activate.*__FALLBACK__' ~/.config/karabiner.edn.d/leaderkey-unified.edn | head -1

echo ""
echo "App-specific activations (Cmd+Shift+K):"
grep '!CSk.*activate' ~/.config/karabiner.edn.d/leaderkey-unified.edn | head -3

echo ""
echo "3. Testing activation commands via Unix socket..."
echo ""

# Test global activation
echo "Testing: leaderkey-cli activate"
echo "activate" | nc -U /tmp/leaderkey.sock 2>/dev/null && echo "✅ Global activation sent" || echo "❌ No socket connection"

echo ""
# Test fallback-only activation
echo "Testing: leaderkey-cli activate __FALLBACK__"
echo "activate __FALLBACK__" | nc -U /tmp/leaderkey.sock 2>/dev/null && echo "✅ Fallback activation sent" || echo "❌ No socket connection"

echo ""
# Test app-specific activation
echo "Testing: leaderkey-cli activate com.microsoft.VSCode"
echo "activate com.microsoft.VSCode" | nc -U /tmp/leaderkey.sock 2>/dev/null && echo "✅ App-specific activation sent" || echo "❌ No socket connection"

echo ""
echo "4. Verifying EDN structure..."
echo ""

# Count activation rules in the Activation section
ACTIVATION_COUNT=$(grep -c '^\s*\[:!' ~/.config/karabiner.edn.d/leaderkey-unified.edn 2>/dev/null || echo "0")
echo "Total activation keys found: $ACTIVATION_COUNT"

# Check for __FALLBACK__ marker
if grep -q '__FALLBACK__' ~/.config/karabiner.edn.d/leaderkey-unified.edn; then
    echo "✅ __FALLBACK__ marker found in EDN"
else
    echo "❌ __FALLBACK__ marker NOT found in EDN"
fi

echo ""
echo "=== Test Complete ===" 
echo ""
echo "Expected behavior:"
echo "- Cmd+K (global): Loads default config only"
echo "- Cmd+Option+K (fallback): Loads fallback config only (app-fallback-config.json)"
echo "- Cmd+Shift+K (app-specific): Loads app config with fallback"
echo ""
echo "To manually test in Karabiner:"
echo "1. Run: goku"
echo "2. Open Karabiner Elements → Complex Modifications"
echo "3. Look for 'Leader Key 2.0 - Activation' section"
echo "4. Verify all three activation types are present"
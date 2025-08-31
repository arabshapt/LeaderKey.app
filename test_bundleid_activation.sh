#!/bin/bash

echo "=== Testing BundleId in Activation Commands ==="
echo ""

# Check global activation (should not have bundleId)
echo "1. Global activation (Cmd+K):"
GLOBAL_CMD=$(grep '!Ck.*activate' ~/.config/karabiner.edn.d/leaderkey-unified.edn | head -1)
echo "$GLOBAL_CMD"
if echo "$GLOBAL_CMD" | grep -q 'activate"'; then
    echo "✅ Global activation has no bundleId (correct)"
else
    echo "❌ Global activation should not have bundleId"
fi

echo ""
echo "2. App-specific activations (Cmd+Shift+K):"
echo ""

# Check a few app-specific activations
APP_CMDS=$(grep '!CSk.*activate' ~/.config/karabiner.edn.d/leaderkey-unified.edn | head -5)

while IFS= read -r line; do
    if echo "$line" | grep -q 'activate [a-z]'; then
        BUNDLE_ID=$(echo "$line" | sed -n 's/.*activate \([^"]*\)".*/\1/p')
        APP_ALIAS=$(echo "$line" | sed -n 's/.* :\([a-z_]*\)]/\1/p')
        echo "✅ $APP_ALIAS: activate $BUNDLE_ID"
    else
        echo "❌ Missing bundleId in: $line"
    fi
done <<< "$APP_CMDS"

echo ""
echo "3. Testing activation commands directly:"
echo ""

# Test global activation
echo "Testing: leaderkey-cli activate"
echo "activate" | nc -U /tmp/leaderkey.sock 2>/dev/null && echo "Response received" || echo "No socket connection"

echo ""
# Test app-specific activation
echo "Testing: leaderkey-cli activate com.microsoft.VSCode"
echo "activate com.microsoft.VSCode" | nc -U /tmp/leaderkey.sock 2>/dev/null && echo "Response received" || echo "No socket connection"

echo ""
echo "=== Test Complete ==="
echo ""
echo "Expected behavior:"
echo "- Global activation (!Ck) → .defaultOnly activation type"
echo "- App-specific activation (!CSk) → .appSpecificWithFallback activation type"
echo ""
echo "Check /tmp/leaderkey_bundleid.log for activation logs with bundleId"
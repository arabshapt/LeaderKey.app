#!/bin/bash

# Test sticky mode with opacity settings
echo "=== Testing Sticky Mode with Opacity Settings ==="
echo ""

# Build the CLI first
echo "Building CLI..."
cd leaderkey-cli
swift build -c release 2>/dev/null
CLI_PATH="$(pwd)/build/leaderkey-cli"
cd ..

echo "CLI path: $CLI_PATH"
echo ""

# Test 1: Normal mode action (should use normalModeOpacity)
echo "Test 1: Normal mode action"
echo "  Sending: stateid 100"
echo "  Expected: Window should close after action, uses normalModeOpacity"
$CLI_PATH stateid 100
sleep 1

echo ""
echo "Test 2: Sticky mode action"
echo "  Sending: stateid 101 sticky"
echo "  Expected: Window stays open, uses stickyModeOpacity"
$CLI_PATH stateid 101 sticky
sleep 1

echo ""
echo "Test 3: Multiple sticky actions in sequence"
echo "  Sending: stateid 102 sticky"
$CLI_PATH stateid 102 sticky
sleep 0.5
echo "  Sending: stateid 103 sticky"
$CLI_PATH stateid 103 sticky
sleep 0.5
echo "  Sending: stateid 104 sticky"
$CLI_PATH stateid 104 sticky

echo ""
echo "Test 4: Deactivation (should reset opacity)"
echo "  Sending: deactivate"
$CLI_PATH deactivate

echo ""
echo "=== Test Complete ==="
echo "Check that:"
echo "1. Normal mode uses normalModeOpacity setting"
echo "2. Sticky mode uses stickyModeOpacity setting"
echo "3. Window stays open in sticky mode"
echo "4. Opacity resets on deactivation"
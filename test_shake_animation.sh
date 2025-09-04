#!/bin/bash

# Test script to verify shake animation functionality
# This script simulates what happens when an undefined key is pressed in Karabiner mode

echo "Testing Leader Key shake animation..."
echo ""
echo "This script will send a 'shake' command to Leader Key"
echo "to simulate what happens when the catch-all rule is triggered."
echo ""

# Check if leaderkey-cli exists
if [ -f "/usr/local/bin/leaderkey-cli" ]; then
    echo "Using leaderkey-cli..."
    /usr/local/bin/leaderkey-cli shake
else
    echo "Using Unix socket directly..."
    echo 'shake' | nc -U /tmp/leaderkey.sock
fi

echo ""
echo "If Leader Key is running and visible, you should see the window shake."
echo "This indicates that an undefined key was pressed."
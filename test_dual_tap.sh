#!/bin/bash

# Test script for dual event tap failover functionality
# This script will help verify that the dual tap manager works correctly

echo "🧪 Testing Dual Event Tap Failover System"
echo "========================================="
echo ""

# Build the app first
echo "📦 Building Leader Key app..."
cd "/Users/arabshaptukaev/personalProjects/LeaderKeyapp"
xcodebuild -scheme "Leader Key" -configuration Debug build > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Build successful"
else
    echo "❌ Build failed"
    exit 1
fi

echo ""
echo "🔧 Test Instructions:"
echo "1. Run the Leader Key app"
echo "2. Open the app menu and select 'Debug > Test Event Tap Recovery'"
echo "3. Check Console.app for dual tap statistics"
echo "4. Try the 'Debug > Test Recovery Under Stress' option"
echo "5. Monitor the logs for instant failover behavior"
echo ""
echo "Expected behavior:"
echo "- Primary tap should be active by default"
echo "- If primary tap fails, instant failover to secondary"
echo "- Automatic recovery attempts in background"
echo "- Statistics showing failover count and recovery success"
echo ""
echo "To view logs in real-time:"
echo "log stream --predicate 'process == \"Leader Key\"' --level debug"
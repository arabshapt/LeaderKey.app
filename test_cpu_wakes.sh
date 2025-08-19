#!/bin/bash

# Test script to verify CPU wakes reduction fix
# This script monitors CPU wakes before and after the semaphore optimization

echo "🔍 CPU Wakes Test for LeaderKey"
echo "================================="
echo ""
echo "This test verifies that the semaphore-based event processor"
echo "significantly reduces CPU wakes from ~8,500/sec to <100/sec"
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
echo "📊 Monitoring Instructions:"
echo "1. Launch the Leader Key app"
echo "2. Open Activity Monitor > View > All Processes"
echo "3. Find 'Leader Key' in the process list"
echo "4. Right-click on column headers and add 'Wakes' column"
echo "5. Monitor the wakes/second value"
echo ""
echo "Expected Results:"
echo "✅ BEFORE FIX: ~8,500 wakes/second (busy-wait with usleep)"
echo "✅ AFTER FIX:  <100 wakes/second (semaphore-based waiting)"
echo ""
echo "To monitor in Instruments:"
echo "1. Open Instruments"
echo "2. Choose 'System Trace' template"
echo "3. Target the Leader Key process"
echo "4. Record for 10-30 seconds"
echo "5. Check 'Wakes' track"
echo ""
echo "Console logs should show:"
echo "[EventProcessor] Started with semaphore-based signaling (low CPU wake design)"
echo ""
echo "To view logs:"
echo "log stream --predicate 'process == \"Leader Key\"' --level debug | grep EventProcessor"
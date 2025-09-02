#!/bin/bash

echo "Verifying EDN Injection Markers"
echo "================================"

EDN_FILE="$HOME/.config/karabiner.edn"

if [ ! -f "$EDN_FILE" ]; then
    echo "ERROR: karabiner.edn not found at $EDN_FILE"
    echo ""
    echo "The injection system will skip if karabiner.edn doesn't exist."
    exit 1
fi

echo "Checking for injection markers in $EDN_FILE..."
echo ""

# Check for application markers
if grep -q ";;; LEADERKEY_APPLICATIONS_START" "$EDN_FILE"; then
    echo "✓ Found LEADERKEY_APPLICATIONS_START marker"
else
    echo "✗ Missing LEADERKEY_APPLICATIONS_START marker"
fi

if grep -q ";;; LEADERKEY_APPLICATIONS_END" "$EDN_FILE"; then
    echo "✓ Found LEADERKEY_APPLICATIONS_END marker"
else
    echo "✗ Missing LEADERKEY_APPLICATIONS_END marker"
fi

# Check for main markers
if grep -q ";;; LEADERKEY_MAIN_START" "$EDN_FILE"; then
    echo "✓ Found LEADERKEY_MAIN_START marker"
else
    echo "✗ Missing LEADERKEY_MAIN_START marker"
fi

if grep -q ";;; LEADERKEY_MAIN_END" "$EDN_FILE"; then
    echo "✓ Found LEADERKEY_MAIN_END marker"
else
    echo "✗ Missing LEADERKEY_MAIN_END marker"
fi

echo ""
echo "Checking for Leader Key injected content..."

# Check if there's content between application markers
APP_CONTENT=$(sed -n '/;;; LEADERKEY_APPLICATIONS_START/,/;;; LEADERKEY_APPLICATIONS_END/p' "$EDN_FILE" | wc -l)
if [ "$APP_CONTENT" -gt 2 ]; then
    echo "✓ Found injected content in applications section ($((APP_CONTENT - 2)) lines)"
else
    echo "✗ No content between application markers"
fi

# Check if there's content between main markers
MAIN_CONTENT=$(sed -n '/;;; LEADERKEY_MAIN_START/,/;;; LEADERKEY_MAIN_END/p' "$EDN_FILE" | wc -l)
if [ "$MAIN_CONTENT" -gt 2 ]; then
    echo "✓ Found injected content in main section ($((MAIN_CONTENT - 2)) lines)"
else
    echo "✗ No content between main markers"
fi

echo ""
echo "Checking for backups..."
BACKUP_COUNT=$(ls -1 "$EDN_FILE.backup."* 2>/dev/null | wc -l)
echo "Found $BACKUP_COUNT backup file(s)"

if [ "$BACKUP_COUNT" -gt 0 ]; then
    echo "Latest backup:"
    ls -lt "$EDN_FILE.backup."* 2>/dev/null | head -1
fi
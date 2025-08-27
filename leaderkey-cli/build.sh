#!/bin/bash

# Build the Leader Key CLI tool

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"

# Create build directory
mkdir -p "$BUILD_DIR"

# Compile the Swift file
echo "Building leaderkey-cli..."
swiftc "$SCRIPT_DIR/leaderkey-cli/leaderkey-cli/main.swift" -o "$BUILD_DIR/leaderkey-cli"

if [ $? -eq 0 ]; then
    echo "Build successful! Binary created at: $BUILD_DIR/leaderkey-cli"
    echo ""
    echo "To install system-wide, run:"
    echo "  sudo cp '$BUILD_DIR/leaderkey-cli' /usr/local/bin/"
    echo ""
    echo "To test the CLI, run:"
    echo "  '$BUILD_DIR/leaderkey-cli' help"
else
    echo "Build failed!"
    exit 1
fi
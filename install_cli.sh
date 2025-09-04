#!/bin/bash

# Install the Leader Key CLI tool

echo "Installing Leader Key CLI tool..."

# Build the CLI if needed
if [ ! -f "leaderkey-cli/build/leaderkey-cli" ]; then
    echo "Building CLI tool..."
    cd leaderkey-cli/leaderkey-cli/leaderkey-cli
    swiftc -O main.swift -o leaderkey-cli
    cd ../../..
    cp leaderkey-cli/leaderkey-cli/leaderkey-cli/leaderkey-cli leaderkey-cli/build/leaderkey-cli
fi

# Copy to /usr/local/bin (requires sudo)
echo "Installing to /usr/local/bin (requires admin password)..."
sudo cp leaderkey-cli/build/leaderkey-cli /usr/local/bin/leaderkey-cli
sudo chmod +x /usr/local/bin/leaderkey-cli

echo "Leader Key CLI installed successfully!"
echo ""
echo "You can now use: leaderkey-cli help"
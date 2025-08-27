#!/bin/bash

# Install Karabiner Elements configuration for Leader Key integration

KARABINER_CONFIG_DIR="$HOME/.config/karabiner/assets/complex_modifications"
CONFIG_FILE="leader_key_integration.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Leader Key - Karabiner Elements Integration Installer"
echo "====================================================="
echo ""

# Check if Karabiner Elements is installed
if [ ! -d "/Applications/Karabiner-Elements.app" ]; then
    echo "❌ Karabiner Elements is not installed."
    echo ""
    echo "Please install Karabiner Elements first:"
    echo "  https://karabiner-elements.pqrs.org"
    exit 1
fi

# Create config directory if it doesn't exist
if [ ! -d "$KARABINER_CONFIG_DIR" ]; then
    echo "Creating Karabiner config directory..."
    mkdir -p "$KARABINER_CONFIG_DIR"
fi

# Copy configuration file
echo "Installing Leader Key configuration..."
cp "$SCRIPT_DIR/$CONFIG_FILE" "$KARABINER_CONFIG_DIR/"

if [ $? -eq 0 ]; then
    echo "✅ Configuration installed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Open Karabiner-Elements Preferences"
    echo "2. Go to the 'Complex Modifications' tab"
    echo "3. Click 'Add rule'"
    echo "4. Find 'Leader Key Integration' and enable the rules"
    echo "5. In Leader Key app, go to Settings > Advanced"
    echo "6. Change Input Method to 'Karabiner Elements'"
    echo ""
    echo "Default activation shortcut: Cmd+K"
else
    echo "❌ Failed to install configuration"
    exit 1
fi
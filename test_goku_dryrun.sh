#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Goku Dry-Run Test for Leader Key Karabiner Configuration ===${NC}"
echo ""

# Function to test an EDN file
test_edn_file() {
    local edn_file="$1"
    local description="$2"
    
    echo -e "${YELLOW}Testing: $description${NC}"
    echo "File: $edn_file"
    echo ""
    
    if [ ! -f "$edn_file" ]; then
        echo -e "${RED}❌ File not found: $edn_file${NC}"
        return 1
    fi
    
    # Create temp file for output
    local temp_output="/tmp/goku_dryrun_output_$$.json"
    local temp_errors="/tmp/goku_dryrun_errors_$$.txt"
    
    # Run goku with dry-run
    echo "Running: goku -c \"$edn_file\" --dry-run"
    if goku -c "$edn_file" --dry-run > "$temp_output" 2> "$temp_errors"; then
        echo -e "${GREEN}✅ Goku processed EDN successfully${NC}"
        
        # Validate JSON output
        if jq empty "$temp_output" 2>/dev/null; then
            echo -e "${GREEN}✅ Generated valid JSON${NC}"
            
            # Count manipulators
            local manipulator_count=$(jq '.profiles[0].complex_modifications.rules | length' "$temp_output" 2>/dev/null || echo "0")
            echo "Generated $manipulator_count rules"
            
            # Check for stateid commands
            echo ""
            echo "Checking for stateid commands..."
            local stateid_count=$(grep -o 'stateid [0-9-]*' "$temp_output" | wc -l | tr -d ' ')
            
            if [ "$stateid_count" -gt 0 ]; then
                echo -e "${GREEN}✅ Found $stateid_count stateid commands${NC}"
                
                # Show unique state IDs
                local unique_stateids=$(grep -o 'stateid [0-9-]*' "$temp_output" | sed 's/stateid //' | sort -u | wc -l | tr -d ' ')
                echo "Unique state IDs: $unique_stateids"
                
                # Show sample state IDs
                echo ""
                echo "Sample state IDs (first 5):"
                grep -o 'stateid [0-9-]*' "$temp_output" | sed 's/stateid //' | sort -u | head -5 | while read id; do
                    echo "  - $id"
                done
            else
                echo -e "${YELLOW}⚠️  No stateid commands found (might be using sequence commands)${NC}"
            fi
            
            # Check for sequence commands (fallback)
            local sequence_count=$(grep -o 'sequence [a-z ]*' "$temp_output" | wc -l | tr -d ' ')
            if [ "$sequence_count" -gt 0 ]; then
                echo "Found $sequence_count sequence commands (legacy mode)"
            fi
            
        else
            echo -e "${RED}❌ Invalid JSON output${NC}"
            echo "JSON validation error:"
            jq empty "$temp_output" 2>&1 | head -10
        fi
    else
        echo -e "${RED}❌ Goku failed to process EDN${NC}"
        if [ -s "$temp_errors" ]; then
            echo "Error output:"
            cat "$temp_errors"
        fi
    fi
    
    # Show any errors/warnings
    if [ -s "$temp_errors" ]; then
        echo ""
        echo -e "${YELLOW}Goku stderr output:${NC}"
        cat "$temp_errors"
    fi
    
    # Cleanup
    rm -f "$temp_output" "$temp_errors"
    
    echo ""
    echo "----------------------------------------"
    echo ""
}

# Test main karabiner.edn
if [ -f ~/.config/karabiner.edn ]; then
    test_edn_file ~/.config/karabiner.edn "Main karabiner.edn"
fi

# Test unified EDN if it exists
if [ -f ~/.config/karabiner.edn.d/leaderkey-unified.edn ]; then
    test_edn_file ~/.config/karabiner.edn.d/leaderkey-unified.edn "Leader Key Unified EDN"
fi

# Option to test a specific file
if [ "$1" ]; then
    echo -e "${BLUE}Testing user-specified file${NC}"
    test_edn_file "$1" "User-specified EDN"
fi

echo -e "${BLUE}=== Test Complete ===${NC}"
echo ""
echo "Tips:"
echo "- Use 'goku --dry-run' to test without modifying karabiner.json"
echo "- Use 'goku -c <file> --dry-run' to test a specific EDN file"
echo "- Use 'goku --dry-run-all' to see the complete config output"
echo "- Check ~/.config/karabiner/automatic_backups/ for config backups"
echo ""
echo "To apply changes for real, run: goku"
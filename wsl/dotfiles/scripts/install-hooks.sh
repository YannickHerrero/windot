#!/bin/bash
#
# install-hooks.sh
# Interactive hook installer script
# Uses fzf to let users select and install git hooks from ~/.local/bin/git-hooks/
#
# Usage:
#   install-hooks
#

set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

HOOKS_DIR="$HOME/.local/bin/git-hooks"

# Check if hooks directory exists
if [[ ! -d "$HOOKS_DIR" ]]; then
    echo -e "${RED}Error: Hooks directory not found at $HOOKS_DIR${NC}"
    exit 1
fi

# Check if there are any hook scripts
if ! ls "$HOOKS_DIR"/*.sh > /dev/null 2>&1; then
    echo -e "${RED}Error: No hook scripts found in $HOOKS_DIR${NC}"
    exit 1
fi

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    echo -e "${RED}Error: fzf is not installed${NC}"
    echo "Please install fzf to use this script"
    exit 1
fi

# Function to extract help text from a script
# Extracts content from shebang to the # --- marker
extract_help() {
    local file="$1"
    local in_help=false
    local help_text=""
    
    while IFS= read -r line; do
        # Skip shebang
        if [[ "$line" == \#\!* ]]; then
            continue
        fi
        
        # Check for the end marker
        if [[ "$line" == \#\ --- ]]; then
            break
        fi
        
        # Collect lines that start with #
        if [[ "$line" == \#* ]]; then
            in_help=true
            # Remove leading # and up to one space, preserve the rest
            cleaned=$(echo "$line" | sed 's/^#\s\{0,1\}//')
            help_text+="$cleaned"
            help_text+=$'\n'
        elif [[ "$in_help" && "$line" == "" ]]; then
            # Keep empty lines within help section
            help_text+=$'\n'
        elif [[ "$in_help" && "$line" != "" ]]; then
            # Non-comment, non-empty line while in help - shouldn't happen with proper scripts
            break
        fi
    done < "$file"
    
    # Return the help text, removing leading/trailing empty lines
    echo "$help_text" | sed -e :a -e '/^\s*$/d;N;ba' -e 's/[[:space:]]*$//'
}

# Build the fzf list with preview
# Using a preview command that extracts help text (lines between shebang and # ---)
selected=$(ls "$HOOKS_DIR"/*.sh | while read script; do
    basename "$script" .sh
done | fzf \
    --preview "bash -c 'file=\"$HOOKS_DIR/{}.sh\"; sed -n \"/^\#!/!{/^#[^#]/p; /^# ---/q}\" \"\$file\" | sed \"s/^# //\" | sed \"/^---\$/d\" | sed -e :a -e \"/^\s*\$/d;N;ba\" -e \"s/[[:space:]]*$//\"'" \
    --preview-label="Help" \
    --preview-window="wrap" \
    --no-multi \
    --exit-0)

# If nothing was selected, exit
if [[ -z "$selected" ]]; then
    echo -e "${YELLOW}No hook selected${NC}"
    exit 0
fi

# Execute the selected hook script
hook_script="$HOOKS_DIR/${selected}.sh"

if [[ ! -f "$hook_script" ]]; then
    echo -e "${RED}Error: Hook script not found: $hook_script${NC}"
    exit 1
fi

"$hook_script" "$@"

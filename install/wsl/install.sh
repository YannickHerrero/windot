#!/bin/bash
# WSL Install Script - select and run install scripts via fzf

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RUN_DIR="$SCRIPT_DIR/run"

# Find all install scripts in run directory
mapfile -t INSTALL_SCRIPTS < <(find "$RUN_DIR" -name "*.sh" -type f | sort)

if [ ${#INSTALL_SCRIPTS[@]} -eq 0 ]; then
    echo "No install scripts found in $RUN_DIR"
    exit 1
fi

# Build list with display names (strip path and number prefix)
OPTIONS=("all")
for script in "${INSTALL_SCRIPTS[@]}"; do
    # Get filename and remove number prefix (e.g., "00-prerequisites.sh" -> "prerequisites")
    filename=$(basename "$script" .sh)
    display_name="${filename#*-}"
    OPTIONS+=("$display_name")
done

# Show fzf menu
SELECTION=$(printf '%s\n' "${OPTIONS[@]}" | fzf --prompt="Select install script: " --height=40% --reverse)

if [ -z "$SELECTION" ]; then
    echo "No selection made."
    exit 0
fi

# Execute based on selection
if [ "$SELECTION" = "all" ]; then
    echo "Running all install scripts..."
    echo ""
    for script in "${INSTALL_SCRIPTS[@]}"; do
        filename=$(basename "$script" .sh)
        display_name="${filename#*-}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Running: $display_name"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        bash "$script"
        echo ""
    done
    echo "All install scripts completed!"
else
    # Find and run the matching script
    for script in "${INSTALL_SCRIPTS[@]}"; do
        filename=$(basename "$script" .sh)
        display_name="${filename#*-}"
        if [ "$display_name" = "$SELECTION" ]; then
            bash "$script"
            exit 0
        fi
    done
    echo "Script not found: $SELECTION"
    exit 1
fi

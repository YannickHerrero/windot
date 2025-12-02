#!/bin/bash
# Root sync script - select and run sync scripts via fzf

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Find all sync.sh scripts in subdirectories (excluding this root script)
mapfile -t SYNC_SCRIPTS < <(find "$SCRIPT_DIR" -mindepth 2 -name "sync.sh" -type f | sort)

if [ ${#SYNC_SCRIPTS[@]} -eq 0 ]; then
    echo "No sync scripts found."
    exit 1
fi

# Build list with relative paths for display
OPTIONS=("all")
for script in "${SYNC_SCRIPTS[@]}"; do
    OPTIONS+=("${script#$SCRIPT_DIR/}")
done

# Show fzf menu
SELECTION=$(printf '%s\n' "${OPTIONS[@]}" | fzf --prompt="Select sync script: " --height=40% --reverse)

if [ -z "$SELECTION" ]; then
    echo "No selection made."
    exit 0
fi

# Execute based on selection
if [ "$SELECTION" = "all" ]; then
    echo "Running all sync scripts..."
    echo ""
    for script in "${SYNC_SCRIPTS[@]}"; do
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Running: ${script#$SCRIPT_DIR/}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        bash "$script"
        echo ""
    done
    echo "All sync scripts completed!"
else
    bash "$SCRIPT_DIR/$SELECTION"
fi

#!/bin/bash
# Syncs scripts from this repo to Windows scripts location

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Auto-detect Windows username
WIN_USER=$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r')
if [ -z "$WIN_USER" ]; then
    echo "Error: Could not detect Windows username"
    exit 1
fi

WIN_SCRIPTS="/mnt/c/Users/$WIN_USER/scripts"

echo "Syncing scripts to $WIN_SCRIPTS..."

# Sync all AHK files
cp "$SCRIPT_DIR"/*.ahk "$WIN_SCRIPTS/"
echo "  - AHK scripts"

# Sync lib folder
mkdir -p "$WIN_SCRIPTS/lib"
cp "$SCRIPT_DIR/lib"/*.ahk "$WIN_SCRIPTS/lib/"
echo "  - lib/*.ahk"

# Sync config folder
mkdir -p "$WIN_SCRIPTS/config"
cp "$SCRIPT_DIR/config"/*.ini "$WIN_SCRIPTS/config/"
echo "  - config/*.ini"

echo ""
echo "Done! Restart master.ahk to apply changes."

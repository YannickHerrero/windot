#!/bin/bash
# Syncs scripts from this repo to Windows scripts location

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WIN_SCRIPTS="/mnt/c/Users/yannick.herrero/scripts"

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

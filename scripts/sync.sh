#!/bin/bash
# Syncs scripts from this repo to Windows scripts location

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WIN_SCRIPTS="/mnt/c/Users/yannick.herrero/scripts"

echo "Syncing scripts to $WIN_SCRIPTS..."

# Sync config files
cp "$SCRIPT_DIR/config.ini" "$WIN_SCRIPTS/config.ini"
cp "$SCRIPT_DIR/folders.ini" "$WIN_SCRIPTS/folders.ini"
cp "$SCRIPT_DIR/websites.ini" "$WIN_SCRIPTS/websites.ini"
echo "  - config files (3 files)"

# Sync AutoHotkey scripts
cp "$SCRIPT_DIR/terminal-launcher.ahk" "$WIN_SCRIPTS/terminal-launcher.ahk"
cp "$SCRIPT_DIR/website-launcher.ahk" "$WIN_SCRIPTS/website-launcher.ahk"
echo "  - AHK scripts (2 files)"

# Sync utility scripts
cp "$SCRIPT_DIR/launch-browser-app.ps1" "$WIN_SCRIPTS/launch-browser-app.ps1"
cp "$SCRIPT_DIR/launch-claude.vbs" "$WIN_SCRIPTS/launch-claude.vbs"
echo "  - utility scripts (2 files)"

echo ""
echo "Done! Restart AutoHotkey scripts to apply changes."

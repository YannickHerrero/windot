#!/bin/bash
# Syncs WezTerm config from this repo to Windows home

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Auto-detect Windows username
WIN_USER=$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r')
if [ -z "$WIN_USER" ]; then
    echo "Error: Could not detect Windows username"
    exit 1
fi

WIN_HOME="/mnt/c/Users/$WIN_USER"

echo "Syncing WezTerm config to $WIN_HOME..."

cp "$SCRIPT_DIR/.wezterm.lua" "$WIN_HOME/.wezterm.lua"
echo "  - .wezterm.lua"

echo ""
echo "Done! Restart WezTerm to apply changes."

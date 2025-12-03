#!/bin/bash
# Syncs WezTerm config from this repo to Windows home

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WIN_HOME="/mnt/c/Users/yannick.herrero"

echo "Syncing WezTerm config to $WIN_HOME..."

cp "$SCRIPT_DIR/.wezterm.lua" "$WIN_HOME/.wezterm.lua"
echo "  - .wezterm.lua"

echo ""
echo "Done! Restart WezTerm to apply changes."

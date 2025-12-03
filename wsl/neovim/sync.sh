#!/bin/bash
# Syncs nvim config from this repo to ~/.config/nvim

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NVIM_DIR="$HOME/.config/nvim"

echo "Syncing nvim config to $NVIM_DIR..."

# Ensure target directory exists
mkdir -p "$NVIM_DIR"

# Sync all config files from nvim/ subfolder
cp "$SCRIPT_DIR/nvim/init.lua" "$NVIM_DIR/"
cp "$SCRIPT_DIR/nvim/lazy-lock.json" "$NVIM_DIR/"
cp "$SCRIPT_DIR/nvim/lazyvim.json" "$NVIM_DIR/"
cp "$SCRIPT_DIR/nvim/stylua.toml" "$NVIM_DIR/"
cp -r "$SCRIPT_DIR/nvim/lua" "$NVIM_DIR/"
echo "  - init.lua, config files, lua/"

echo ""
echo "Done! Restart nvim to apply changes."

#!/bin/bash
# Syncs dotfiles from this repo to WSL home

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOME_DIR="$HOME"

echo "Syncing dotfiles to $HOME_DIR..."

cp "$SCRIPT_DIR/.zshrc" "$HOME_DIR/.zshrc"
echo "  - .zshrc"

cp "$SCRIPT_DIR/.gitconfig" "$HOME_DIR/.gitconfig"
echo "  - .gitconfig"

mkdir -p "$HOME_DIR/.config/ohmyposh"
cp "$SCRIPT_DIR/ohmyposh/"* "$HOME_DIR/.config/ohmyposh/"
echo "  - ohmyposh config"

echo ""
echo "Done! Run 'source ~/.zshrc' to apply changes."

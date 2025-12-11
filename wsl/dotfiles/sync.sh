#!/bin/bash
# Syncs dotfiles from this repo to WSL home

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOME_DIR="$HOME"

# Auto-detect Windows username for placeholder replacement
WIN_USER=$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r')
if [ -z "$WIN_USER" ]; then
    echo "Warning: Could not detect Windows username, using WSL username"
    WIN_USER="$USER"
fi

echo "Syncing dotfiles to $HOME_DIR..."

cp "$SCRIPT_DIR/.zshrc" "$HOME_DIR/.zshrc"
echo "  - .zshrc"

cp "$SCRIPT_DIR/.gitconfig" "$HOME_DIR/.gitconfig"
echo "  - .gitconfig"

mkdir -p "$HOME_DIR/.config/ohmyposh"
cp "$SCRIPT_DIR/ohmyposh/"* "$HOME_DIR/.config/ohmyposh/"
echo "  - ohmyposh config"

# Theme switcher script (with placeholder replacement)
mkdir -p "$HOME_DIR/.local/bin"
sed "s/%WIN_USER%/$WIN_USER/g" "$SCRIPT_DIR/set-theme.sh" > "$HOME_DIR/.local/bin/set-theme.sh"
chmod +x "$HOME_DIR/.local/bin/set-theme.sh"
echo "  - set-theme.sh"

# Theme definitions (TOML files for set-theme.sh)
THEME_DIR="$HOME_DIR/.config/themes"
mkdir -p "$THEME_DIR"
cp "$SCRIPT_DIR/../../theme/themes/"*.toml "$THEME_DIR/"
echo "  - theme definitions ($(ls -1 "$THEME_DIR/"*.toml 2>/dev/null | wc -l) themes)"

echo ""
echo "Done! Run 'source ~/.zshrc' to apply changes."

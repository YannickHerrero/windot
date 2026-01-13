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

cp "$SCRIPT_DIR/.gitconfig" "$HOME_DIR/.gitconfig"
echo "  - .gitconfig"

mkdir -p "$HOME_DIR/.config/ohmyposh"
cp "$SCRIPT_DIR/ohmyposh/"* "$HOME_DIR/.config/ohmyposh/"
echo "  - ohmyposh config"

# Theme helper scripts
DOTFILES_DIR="$HOME_DIR/.config/dotfiles"
mkdir -p "$DOTFILES_DIR/theme-scripts"
cp "$SCRIPT_DIR/theme-scripts/"*.sh "$DOTFILES_DIR/theme-scripts/"
chmod +x "$DOTFILES_DIR/theme-scripts/"*.sh
echo "  - theme-scripts ($(ls -1 "$DOTFILES_DIR/theme-scripts/"*.sh 2>/dev/null | wc -l) scripts)"

# Theme switcher script (with placeholder replacement)
mkdir -p "$HOME_DIR/.local/bin"
sed "s/%WIN_USER%/$WIN_USER/g" "$SCRIPT_DIR/set-theme.sh" > "$HOME_DIR/.local/bin/set-theme.sh"
chmod +x "$HOME_DIR/.local/bin/set-theme.sh"
echo "  - set-theme.sh"

# Hook installer script
cp "$SCRIPT_DIR/scripts/install-hooks.sh" "$HOME_DIR/.local/bin/install-hooks.sh"
chmod +x "$HOME_DIR/.local/bin/install-hooks.sh"
echo "  - install-hooks.sh"

# Notes CLI
NOTES_SRC="$SCRIPT_DIR/../bin"
ln -sf "$NOTES_SRC/notes" "$HOME_DIR/.local/bin/notes"
mkdir -p "$HOME_DIR/.local/bin/notes.d"
for file in "$NOTES_SRC/notes.d/"*.sh; do
    ln -sf "$file" "$HOME_DIR/.local/bin/notes.d/"
done
echo "  - notes CLI"

# Git hooks scripts
mkdir -p "$HOME_DIR/.local/bin/git-hooks"
cp "$SCRIPT_DIR/scripts/git-hooks/"*.sh "$HOME_DIR/.local/bin/git-hooks/"
chmod +x "$HOME_DIR/.local/bin/git-hooks/"*.sh
echo "  - git-hooks ($(ls -1 "$HOME_DIR/.local/bin/git-hooks/"*.sh 2>/dev/null | wc -l) hooks)"

# Theme definitions (TOML files for set-theme.sh)
THEME_DIR="$HOME_DIR/.config/themes"
mkdir -p "$THEME_DIR"
cp "$SCRIPT_DIR/../../theme/themes/"*.toml "$THEME_DIR/"
echo "  - theme definitions ($(ls -1 "$THEME_DIR/"*.toml 2>/dev/null | wc -l) themes)"

echo ""
echo "Done! Run 'source ~/.zshrc' to apply changes."

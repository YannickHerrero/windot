#!/bin/bash
# Theme Switcher - Updates theme across all applications
# Usage: set-theme.sh <mocha|latte>

set -e

THEME="${1:-mocha}"
WIN_USER="%WIN_USER%"

# Theme mappings
case "$THEME" in
    mocha)
        WEZTERM_SCHEME="Catppuccin Mocha"
        NVIM_FLAVOUR="mocha"
        OPENCODE_MODE="dark"
        ;;
    latte)
        WEZTERM_SCHEME="Catppuccin Latte"
        NVIM_FLAVOUR="latte"
        OPENCODE_MODE="light"
        ;;
    *)
        exit 1
        ;;
esac

# Update WezTerm
WEZTERM_CONFIG="/mnt/c/Users/$WIN_USER/.wezterm.lua"
if [[ -f "$WEZTERM_CONFIG" ]]; then
    sed -i "s/color_scheme = \".*\"/color_scheme = \"$WEZTERM_SCHEME\"/" "$WEZTERM_CONFIG"
fi

# Update Neovim
NVIM_CATPPUCCIN="$HOME/.config/nvim/lua/plugins/catppuccin.lua"
if [[ -f "$NVIM_CATPPUCCIN" ]]; then
    sed -i "s/flavour = \".*\"/flavour = \"$NVIM_FLAVOUR\"/" "$NVIM_CATPPUCCIN"
fi

# Update OpenCode
OPENCODE_KV="$HOME/.local/state/opencode/kv.json"
if [[ -d "$(dirname "$OPENCODE_KV")" ]]; then
    cat > "$OPENCODE_KV" << EOF
{
  "theme": "catppuccin",
  "theme_mode": "$OPENCODE_MODE"
}
EOF
fi

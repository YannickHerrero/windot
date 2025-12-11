#!/bin/bash
# Theme Switcher - Updates theme across all applications
# Usage: set-theme.sh <theme-id>

set -e

THEME_ID="${1:-mocha}"
WIN_USER="%WIN_USER%"
THEME_DIR="$HOME/.config/themes"

# Find theme file by ID
find_theme_file() {
    local id="$1"
    for f in "$THEME_DIR"/*.toml; do
        if [[ -f "$f" ]]; then
            local file_id
            file_id=$(python3 -c "import tomllib; print(tomllib.load(open('$f','rb'))['meta']['id'])" 2>/dev/null)
            if [[ "$file_id" == "$id" ]]; then
                echo "$f"
                return 0
            fi
        fi
    done
    return 1
}

# Read value from TOML file
read_toml() {
    local file="$1"
    local section="$2"
    local key="$3"
    python3 -c "import tomllib; print(tomllib.load(open('$file','rb'))['$section']['$key'])"
}

# Find the theme file
THEME_FILE=$(find_theme_file "$THEME_ID")
if [[ -z "$THEME_FILE" ]]; then
    echo "Error: Theme '$THEME_ID' not found in $THEME_DIR"
    exit 1
fi

# Read app-specific values from TOML
WEZTERM_SCHEME=$(read_toml "$THEME_FILE" apps wezterm_scheme)
NVIM_FLAVOUR=$(read_toml "$THEME_FILE" apps nvim_flavour)
OPENCODE_MODE=$(read_toml "$THEME_FILE" apps opencode_mode)

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

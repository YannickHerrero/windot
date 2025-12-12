#!/bin/bash
# Theme Switcher - Updates theme across all applications
# Usage: set-theme.sh <theme-id>

set -e

THEME_ID="${1:-mocha}"
WIN_USER="%WIN_USER%"
THEME_DIR="$HOME/.config/themes"
SCRIPTS_DIR="$HOME/.config/dotfiles/theme-scripts"

# Source helper scripts
source "$SCRIPTS_DIR/common.sh"
source "$SCRIPTS_DIR/wezterm.sh"
source "$SCRIPTS_DIR/neovim.sh"
source "$SCRIPTS_DIR/ohmyposh.sh"
source "$SCRIPTS_DIR/opencode.sh"
source "$SCRIPTS_DIR/glazewm.sh"
source "$SCRIPTS_DIR/zebar.sh"

# Find theme file by ID
find_theme_file() {
    local id="$1"
    for f in "$THEME_DIR"/*.toml; do
        if [[ -f "$f" ]]; then
            local file_id
            file_id=$(read_toml "$f" "meta" "id" 2>/dev/null) || continue
            if [[ "$file_id" == "$id" ]]; then
                echo "$f"
                return 0
            fi
        fi
    done
    return 1
}

# Main execution
main() {
    # Find the theme file
    THEME_FILE=$(find_theme_file "$THEME_ID")
    if [[ -z "$THEME_FILE" ]]; then
        echo "Error: Theme '$THEME_ID' not found in $THEME_DIR"
        exit 1
    fi

    echo "Applying theme: $(read_toml "$THEME_FILE" "meta" "name")"

    # Generate WezTerm colors
    local wezterm_colors="/mnt/c/Users/$WIN_USER/.wezterm-colors.lua"
    generate_wezterm_colors "$THEME_FILE" "$wezterm_colors"
    echo "  ✓ WezTerm colors"

    # Generate Neovim base16 colors
    local nvim_colors="$HOME/.config/nvim/lua/theme-colors.lua"
    generate_neovim_colors "$THEME_FILE" "$nvim_colors"
    echo "  ✓ Neovim colors"

    # Update Oh My Posh palette
    local ohmyposh_config="$HOME/.config/ohmyposh/zen.toml"
    if [[ -f "$ohmyposh_config" ]]; then
        update_ohmyposh_palette "$THEME_FILE" "$ohmyposh_config"
        echo "  ✓ Oh My Posh palette"
    fi

    # Generate OpenCode theme
    local opencode_theme="$HOME/.config/opencode/themes/current.json"
    generate_opencode_theme "$THEME_FILE" "$opencode_theme"
    echo "  ✓ OpenCode theme"

    # Update GlazeWM colors
    local glazewm_config="/mnt/c/Users/$WIN_USER/.glzr/glazewm/config.yaml"
    if [[ -f "$glazewm_config" ]]; then
        update_glazewm_colors "$THEME_FILE" "$glazewm_config"
        echo "  ✓ GlazeWM borders"
    fi

    # Generate Zebar CSS variables
    local zebar_css="/mnt/c/Users/$WIN_USER/AppData/Roaming/zebar/downloads/glzr-io.starter@0.0.0/theme-vars.css"
    if [[ -d "$(dirname "$zebar_css")" ]]; then
        generate_zebar_css "$THEME_FILE" "$zebar_css"
        echo "  ✓ Zebar CSS variables"
    fi

    echo ""
    echo "Theme applied! Some apps may need restart:"
    echo "  - Neovim: Restart or run :lua require('base16-colorscheme').setup(require('theme-colors').base16)"
    echo "  - OpenCode: Restart required"
}

main

#!/bin/bash
# Generate OpenCode theme JSON

generate_opencode_theme() {
    local theme_file="$1"
    local output_file="$2"

    # Read OpenCode colors
    local primary=$(read_toml "$theme_file" "apps.opencode" "primary")
    local secondary=$(read_toml "$theme_file" "apps.opencode" "secondary")
    local accent=$(read_toml "$theme_file" "apps.opencode" "accent")
    local error=$(read_toml "$theme_file" "apps.opencode" "error")
    local warning=$(read_toml "$theme_file" "apps.opencode" "warning")
    local success=$(read_toml "$theme_file" "apps.opencode" "success")
    local info=$(read_toml "$theme_file" "apps.opencode" "info")
    local text=$(read_toml "$theme_file" "apps.opencode" "text")
    local textMuted=$(read_toml "$theme_file" "apps.opencode" "textMuted")
    local background=$(read_toml "$theme_file" "apps.opencode" "background")
    local backgroundPanel=$(read_toml "$theme_file" "apps.opencode" "backgroundPanel")
    local backgroundElement=$(read_toml "$theme_file" "apps.opencode" "backgroundElement")
    local border=$(read_toml "$theme_file" "apps.opencode" "border")
    local borderActive=$(read_toml "$theme_file" "apps.opencode" "borderActive")
    local borderSubtle=$(read_toml "$theme_file" "apps.opencode" "borderSubtle")

    # Create themes directory if needed
    mkdir -p "$(dirname "$output_file")"

    cat > "$output_file" << EOF
{
  "\$schema": "https://opencode.ai/theme.json",
  "theme": {
    "primary": "#$primary",
    "secondary": "#$secondary",
    "accent": "#$accent",
    "error": "#$error",
    "warning": "#$warning",
    "success": "#$success",
    "info": "#$info",
    "text": "#$text",
    "textMuted": "#$textMuted",
    "background": "#$background",
    "backgroundPanel": "#$backgroundPanel",
    "backgroundElement": "#$backgroundElement",
    "border": "#$border",
    "borderActive": "#$borderActive",
    "borderSubtle": "#$borderSubtle"
  }
}
EOF
}

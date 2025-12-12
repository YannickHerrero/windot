#!/bin/bash
# Update GlazeWM border colors

update_glazewm_colors() {
    local theme_file="$1"
    local config_file="$2"

    local focused=$(read_toml "$theme_file" "apps.glazewm" "border_focused")
    local unfocused=$(read_toml "$theme_file" "apps.glazewm" "border_unfocused")

    # Update focused window border color (in focused_window section)
    # The YAML structure is: focused_window: border: color: '#hexval'
    python3 << EOF
import re

with open('$config_file', 'r') as f:
    content = f.read()

# Update focused_window border color
# Match the pattern within focused_window section
content = re.sub(
    r'(focused_window:.*?border:.*?color:\s*["\'])#?[a-fA-F0-9]{6}(["\'])',
    r'\g<1>#$focused\2',
    content,
    count=1,
    flags=re.DOTALL
)

# Update other_windows border color
content = re.sub(
    r'(other_windows:.*?border:.*?color:\s*["\'])#?[a-fA-F0-9]{6}(["\'])',
    r'\g<1>#$unfocused\2',
    content,
    count=1,
    flags=re.DOTALL
)

with open('$config_file', 'w') as f:
    f.write(content)
EOF
}

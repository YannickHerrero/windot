#!/bin/bash
# Update Oh My Posh palette in config

update_ohmyposh_palette() {
    local theme_file="$1"
    local config_file="$2"

    # Read palette colors
    local path=$(read_toml "$theme_file" "apps.ohmyposh" "path")
    local prompt=$(read_toml "$theme_file" "apps.ohmyposh" "prompt")
    local prompt_error=$(read_toml "$theme_file" "apps.ohmyposh" "prompt_error")
    local git_branch=$(read_toml "$theme_file" "apps.ohmyposh" "git_branch")
    local git_status=$(read_toml "$theme_file" "apps.ohmyposh" "git_status")
    local duration=$(read_toml "$theme_file" "apps.ohmyposh" "duration")

    # Update palette section using sed
    sed -i "s/^path = \".*\"/path = \"#$path\"/" "$config_file"
    sed -i "s/^prompt = \".*\"/prompt = \"#$prompt\"/" "$config_file"
    sed -i "s/^prompt_error = \".*\"/prompt_error = \"#$prompt_error\"/" "$config_file"
    sed -i "s/^git_branch = \".*\"/git_branch = \"#$git_branch\"/" "$config_file"
    sed -i "s/^git_status = \".*\"/git_status = \"#$git_status\"/" "$config_file"
    sed -i "s/^duration = \".*\"/duration = \"#$duration\"/" "$config_file"
}

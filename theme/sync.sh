#!/bin/bash
# Syncs themes and wallpapers from this repo to Windows locations

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Auto-detect Windows username
WIN_USER=$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r')
if [ -z "$WIN_USER" ]; then
    echo "Error: Could not detect Windows username"
    exit 1
fi

WIN_WALLPAPERS="/mnt/c/Users/$WIN_USER/Pictures/Wallpapers"
WIN_SCRIPTS="/mnt/c/Users/$WIN_USER/scripts/config/themes"

# Create destination directories if they don't exist
mkdir -p "$WIN_WALLPAPERS"
mkdir -p "$WIN_SCRIPTS"

echo "Syncing themes..."

# Convert TOML to INI for AHK consumption
convert_toml_to_ini() {
    local toml_file="$1"
    local ini_file="$2"
    
    python3 << EOF
import tomllib
import configparser
from pathlib import Path

toml_path = Path("$toml_file")
ini_path = Path("$ini_file")

with open(toml_path, 'rb') as f:
    data = tomllib.load(f)

config = configparser.ConfigParser()
for section, values in data.items():
    config[section] = {k: str(v) for k, v in values.items()}

with open(ini_path, 'w') as f:
    config.write(f)
EOF
}

# Convert each theme TOML to INI
theme_count=0
for toml_file in "$SCRIPT_DIR/themes/"*.toml; do
    if [[ -f "$toml_file" ]]; then
        filename=$(basename "$toml_file" .toml)
        ini_file="$WIN_SCRIPTS/${filename}.ini"
        convert_toml_to_ini "$toml_file" "$ini_file"
        ((theme_count++))
    fi
done
echo "  - theme definitions ($theme_count themes converted to INI)"

# Sync wallpapers
echo "Syncing wallpapers to $WIN_WALLPAPERS..."
cp "$SCRIPT_DIR/walls/"*.{png,jpg,jpeg} "$WIN_WALLPAPERS/" 2>/dev/null || true
wallpaper_count=$(ls -1 "$SCRIPT_DIR/walls/"*.{png,jpg,jpeg} 2>/dev/null | wc -l)
echo "  - wallpapers ($wallpaper_count files)"

echo ""
echo "Done! Themes and wallpapers synced."

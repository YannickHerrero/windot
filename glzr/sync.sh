#!/bin/bash
# Syncs glzr configs from this repo to Windows locations.
# wbar replaced zebar; wbar manages its own config at %APPDATA%\wbar\
# and isn't tracked here.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Auto-detect Windows username
WIN_USER=$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r')
if [ -z "$WIN_USER" ]; then
    echo "Error: Could not detect Windows username"
    exit 1
fi

WIN_GLZR="/mnt/c/Users/$WIN_USER/.glzr"

echo "Syncing glzr configs..."

# Sync glazewm config (substitute %WIN_USER% placeholder)
mkdir -p "$WIN_GLZR/glazewm"
sed "s/%WIN_USER%/$WIN_USER/g" "$SCRIPT_DIR/glazewm/config.yaml" > "$WIN_GLZR/glazewm/config.yaml"
echo "  - glazewm/config.yaml -> $WIN_GLZR/glazewm/"

echo ""
echo "Done! Reload GlazeWM with Alt+Shift+R"

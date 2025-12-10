#!/bin/bash
# Syncs glzr configs from this repo to Windows locations

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Auto-detect Windows username
WIN_USER=$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r')
if [ -z "$WIN_USER" ]; then
    echo "Error: Could not detect Windows username"
    exit 1
fi

WIN_GLZR="/mnt/c/Users/$WIN_USER/.glzr"
ZEBAR_DOWNLOADS="/mnt/c/Users/$WIN_USER/AppData/Roaming/zebar/downloads"

echo "Syncing glzr configs..."

# Sync glazewm config (substitute %WIN_USER% placeholder)
sed "s/%WIN_USER%/$WIN_USER/g" "$SCRIPT_DIR/glazewm/config.yaml" > "$WIN_GLZR/glazewm/config.yaml"
echo "  - glazewm/config.yaml -> $WIN_GLZR/glazewm/"

# Sync zebar settings
cp "$SCRIPT_DIR/zebar/settings.json" "$WIN_GLZR/zebar/settings.json"
echo "  - zebar/settings.json -> $WIN_GLZR/zebar/"

# Sync glzr-io.starter pack to marketplace downloads location
mkdir -p "$ZEBAR_DOWNLOADS/glzr-io.starter@0.0.0"
cp -r "$SCRIPT_DIR/zebar/glzr-io.starter/." "$ZEBAR_DOWNLOADS/glzr-io.starter@0.0.0/"
echo "  - zebar/glzr-io.starter/ -> $ZEBAR_DOWNLOADS/glzr-io.starter@0.0.0/"

echo ""
echo "Done! Reload GlazeWM with Alt+Shift+R"

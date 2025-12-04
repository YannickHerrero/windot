#!/bin/bash
# Syncs glzr configs from this repo to Windows locations

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WIN_GLZR="/mnt/c/Users/yannick.herrero/.glzr"
ZEBAR_DOWNLOADS="/mnt/c/Users/yannick.herrero/AppData/Roaming/zebar/downloads"

echo "Syncing glzr configs..."

# Sync glazewm config
cp "$SCRIPT_DIR/glazewm/config.yaml" "$WIN_GLZR/glazewm/config.yaml"
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

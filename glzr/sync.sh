#!/bin/bash
# Syncs glzr configs from this repo to Windows .glzr location

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WIN_GLZR="/mnt/c/Users/yannick.herrero/.glzr"

echo "Syncing glzr configs to $WIN_GLZR..."

# Sync glazewm config
cp "$SCRIPT_DIR/glazewm/config.yaml" "$WIN_GLZR/glazewm/config.yaml"
echo "  - glazewm/config.yaml"

# Sync zebar settings
cp "$SCRIPT_DIR/zebar/settings.json" "$WIN_GLZR/zebar/settings.json"
echo "  - zebar/settings.json"

# Build and sync zebar-glazewm widget
echo "Building zebar-glazewm widget..."
cd "$SCRIPT_DIR/zebar/zebar-glazewm"
npm install --silent
npm run build --silent
cd "$SCRIPT_DIR"

# Sync built dist folder and config files
cp -r "$SCRIPT_DIR/zebar/zebar-glazewm/dist/." "$WIN_GLZR/zebar/zebar-glazewm/dist/"
cp "$SCRIPT_DIR/zebar/zebar-glazewm/main.zebar.json" "$WIN_GLZR/zebar/zebar-glazewm/main.zebar.json"
cp "$SCRIPT_DIR/zebar/zebar-glazewm/styles.css" "$WIN_GLZR/zebar/zebar-glazewm/styles.css"
echo "  - zebar/zebar-glazewm/ (dist + config)"

echo ""
echo "Done! Reload GlazeWM with Alt+Shift+R"

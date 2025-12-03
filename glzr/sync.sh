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

# Sync zebar-glazewm files
cp "$SCRIPT_DIR/zebar/zebar-glazewm/main.zebar.json" "$WIN_GLZR/zebar/zebar-glazewm/main.zebar.json"
cp "$SCRIPT_DIR/zebar/zebar-glazewm/styles.css" "$WIN_GLZR/zebar/zebar-glazewm/styles.css"
cp "$SCRIPT_DIR/zebar/zebar-glazewm/src/main.jsx" "$WIN_GLZR/zebar/zebar-glazewm/src/main.jsx"
echo "  - zebar/zebar-glazewm/ (3 files)"

echo ""
echo "Done! Reload GlazeWM with Alt+Shift+R"

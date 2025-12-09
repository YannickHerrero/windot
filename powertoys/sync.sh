#!/bin/bash
# Syncs PowerToys config to %LOCALAPPDATA%\Microsoft\PowerToys

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_PATH="/mnt/c/Users/yannick.herrero/AppData/Local/Microsoft/PowerToys"

echo "Syncing PowerToys config..."

# Copy main settings
cp "$SCRIPT_DIR/settings.json" "$TARGET_PATH/settings.json"
echo "  - settings.json -> $TARGET_PATH/settings.json"

# Copy Keyboard Manager config
mkdir -p "$TARGET_PATH/Keyboard Manager"
cp "$SCRIPT_DIR/Keyboard Manager/default.json" "$TARGET_PATH/Keyboard Manager/default.json"
cp "$SCRIPT_DIR/Keyboard Manager/settings.json" "$TARGET_PATH/Keyboard Manager/settings.json"
echo "  - Keyboard Manager/ -> $TARGET_PATH/Keyboard Manager/"

echo ""
echo "Done! Restart PowerToys to apply changes."

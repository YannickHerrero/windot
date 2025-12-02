#!/bin/bash
# Syncs wallpapers from this repo to Windows Pictures location

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WIN_WALLPAPERS="/mnt/c/Users/yannick.herrero/Pictures/Wallpapers"

# Create destination directory if it doesn't exist
mkdir -p "$WIN_WALLPAPERS"

echo "Syncing wallpapers to $WIN_WALLPAPERS..."

# Sync all wallpaper files
cp "$SCRIPT_DIR/walls/"* "$WIN_WALLPAPERS/"
echo "  - wallpapers ($(ls -1 "$SCRIPT_DIR/walls" | wc -l) files)"

echo ""
echo "Done! Wallpapers synced."

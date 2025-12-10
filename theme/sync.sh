#!/bin/bash
# Syncs wallpapers from this repo to Windows Pictures location

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Auto-detect Windows username
WIN_USER=$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r')
if [ -z "$WIN_USER" ]; then
    echo "Error: Could not detect Windows username"
    exit 1
fi

WIN_WALLPAPERS="/mnt/c/Users/$WIN_USER/Pictures/Wallpapers"

# Create destination directory if it doesn't exist
mkdir -p "$WIN_WALLPAPERS"

echo "Syncing wallpapers to $WIN_WALLPAPERS..."

# Sync all wallpaper files
cp "$SCRIPT_DIR/walls/"* "$WIN_WALLPAPERS/"
echo "  - wallpapers ($(ls -1 "$SCRIPT_DIR/walls" | wc -l) files)"

echo ""
echo "Done! Wallpapers synced."

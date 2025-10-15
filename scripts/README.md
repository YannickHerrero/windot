# Launcher Scripts

AutoHotkey v2 scripts for quick terminal and webapp launching.

## Scripts

- **terminal-launcher.ahk** - Quick folder navigation launcher (`Alt+Enter`)
- **website-launcher.ahk** - Quick webapp launcher (`Alt+Space`)

## Configuration

### First Time Setup

1. Copy the example config files and customize them:
   ```bash
   # Keep your personal configs out of version control
   cp folders.ini folders.local.ini
   cp websites.ini websites.local.ini
   ```

2. Edit the `.local.ini` files with your personal paths and websites

3. Update the scripts to load `.local.ini` instead of `.ini` files

### Config Files

- **config.ini** - Theme colors, font settings, and executable paths
- **folders.ini** - Terminal launcher folder list (example/template)
- **websites.ini** - Website launcher shortcuts (example/template)

### folders.ini Format

```ini
[Folder Name]
path=\\wsl.localhost\Ubuntu\home\username\project
displayPath=~/project
```

### websites.ini Format

```ini
[k]  ; Keyboard shortcut key
name=Website Name
url=https://example.com
```

## Hotkeys

- `Alt+Enter` - Open terminal launcher
- `Alt+Space` - Open website launcher
- `ESC` - Close launcher
- `Enter` - Launch selected item
- `↑/↓` - Navigate (terminal launcher)
- Type to filter (terminal launcher)

## Requirements

- AutoHotkey v2.0
- WezTerm (or configure another terminal)
- Chrome/Chromium-based browser

# Windot - Windows Configuration Files

Personal Windows configuration and scripts for a tiling window manager setup.

## 🛠️ Tech Stack

- **Window Manager**: [GlazeWM](https://github.com/glzr-io/glazewm) - Tiling window manager for Windows
- **Status Bar**: [Zebar](https://github.com/glzr-io/zebar) - Customizable status bar
- **Terminal**: [WezTerm](https://wezfurlong.org/wezterm/) - GPU-accelerated terminal emulator
- **Automation**: AutoHotkey v2 + PowerShell scripts

## 📁 Repository Structure

```
windot/
├── glazewm/          # GlazeWM tiling window manager config
│   └── config.yaml   # Main configuration file
├── zebar/            # Zebar status bar config (glzr-io.starter pack)
│   ├── settings.json # Active pack configuration
│   ├── styles.css    # Bar styling and padding
│   ├── zpack.json    # Widget positioning and dimensions
│   └── *.html        # Widget templates
├── scripts/          # Automation scripts
│   ├── website-launcher.ahk      # Quick web app launcher (Alt+Space)
│   ├── launch-browser-app.ps1    # PowerShell helper for Chrome app mode
│   ├── launch-claude.vbs         # Silent launcher for Claude AI
│   └── amphetamine.ahk           # Keep system awake utility
├── wezterm.lua       # WezTerm terminal configuration
└── README.md         # This file
```

## 🚀 Features

### GlazeWM Configuration
- **Gaps**: 12px uniform spacing
- **Window Effects**: Catppuccin-themed borders, transparency
- **Workspaces**: 1-9 with custom keybinds
- **Auto-launch**: Zebar and website launcher on startup

### Website Launcher (Alt+Space)
Quick access launcher for web apps in Chrome app mode:
- **N** - Nicoka
- **J** - Jira
- **B** - Bitbucket
- **K** - Keymap Editor
- **M** - Gmail
- **P** - ProtonMail
- **C** - Claude
- **G** - GitHub
- **O** - Outlook
- **F** - Figma
- **E** - Expo

### Zebar Status Bar
- Fully flush with screen edges (0px padding)
- Uses `dockToEdge` to reserve screen space
- Custom Catppuccin styling
- Integrated with GlazeWM workspaces

## 📦 Installation

### Prerequisites
- Windows 11 (for best compatibility)
- [GlazeWM](https://github.com/glzr-io/glazewm)
- [Zebar](https://github.com/glzr-io/zebar)
- [WezTerm](https://wezfurlong.org/wezterm/)
- [AutoHotkey v2](https://www.autohotkey.com/)
- Google Chrome (for web app launcher)

### Setup

1. **Clone this repository:**
   ```powershell
   git clone <your-repo-url> C:\Users\<username>\windot
   ```

2. **Copy configurations to their active locations:**

   ```powershell
   # GlazeWM config
   Copy-Item -Recurse windot/glazewm/* $env:USERPROFILE/.glzr/glazewm/

   # Zebar config (if using custom, otherwise use marketplace)
   # Active config is in AppData/Roaming/zebar/downloads/glzr-io.starter@0.0.0/

   # WezTerm config
   Copy-Item windot/wezterm.lua $env:USERPROFILE/.wezterm.lua

   # Scripts
   Copy-Item -Recurse windot/scripts/* $env:USERPROFILE/scripts/
   ```

3. **Reload GlazeWM:**
   Press `Alt+Shift+R`

## 🔄 Updating Configs

Since this repo uses manual copies (no symlinks), after making changes:

```powershell
# Update from active locations to repo
Copy-Item $env:USERPROFILE/.glzr/glazewm/config.yaml windot/glazewm/
Copy-Item $env:USERPROFILE/.wezterm.lua windot/wezterm.lua
Copy-Item $env:USERPROFILE/scripts/* windot/scripts/

# Commit changes
cd windot
git add .
git commit -m "Update configs"
git push
```

## 🎨 Customization

### Adding websites to launcher
Edit `scripts/website-launcher.ahk`:
```ahk
global websites := Map(
    "x", {name: "Your Site", url: "https://example.com"}
)
```

### Changing GlazeWM gaps
Edit `glazewm/config.yaml`:
```yaml
gaps:
  inner_gap: '12px'
  outer_gap:
    top: '12px'
    # ...
```

### Customizing Zebar
Edit `zebar/styles.css` for styling and `zebar/zpack.json` for positioning.

## 📝 Notes

- **Active Zebar config** is downloaded from marketplace to `AppData/Roaming/zebar/downloads/`
- **Scripts location** is `C:/Users/<username>/scripts/`
- **GlazeWM config** is in `C:/Users/<username>/.glzr/glazewm/`
- **WezTerm config** is in `C:/Users/<username>/.wezterm.lua`
- This repo contains **manual copies** for version control - changes to active configs must be manually synced

## 🔗 Useful Links

- [GlazeWM Documentation](https://github.com/glzr-io/glazewm)
- [Zebar Documentation](https://github.com/glzr-io/zebar)
- [WezTerm Documentation](https://wezfurlong.org/wezterm/)
- [AutoHotkey v2 Docs](https://www.autohotkey.com/docs/v2/)

## 📄 License

Personal configuration - use as you wish!

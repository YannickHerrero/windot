# Windot - Windows Configuration Files

Personal Windows/WSL configuration files with automated sync scripts for a tiling window manager setup.

## Tech Stack

- **Window Manager**: [GlazeWM](https://github.com/glzr-io/glazewm) - Tiling window manager for Windows
- **Status Bar**: [Zebar](https://github.com/glzr-io/zebar) - Custom React status bar with GlazeWM integration
- **Terminal**: [WezTerm](https://wezfurlong.org/wezterm/) - GPU-accelerated terminal emulator
- **Browser**: Firefox with custom userChrome.css styling
- **Automation**: AutoHotkey v2 scripts for fuzzy-find launchers
- **Editor**: Neovim with LazyVim configuration
- **Shell**: Zsh with modular configuration

## Repository Structure

```
windot/
├── glzr/           # GlazeWM & Zebar configs
├── scripts/        # AutoHotkey launchers
│   ├── config/     # INI configuration files
│   └── lib/        # Shared library functions
├── standalone/     # Manual setup configs (Firefox)
├── theme/          # Wallpapers
├── wezterm/        # Terminal config
└── wsl/            # WSL dotfiles (neovim, zsh)
```

## Features

### Sync System

Run `./sync.sh` from the repo root for an interactive fzf menu to sync configs:

```bash
./sync.sh
# Select "all" to sync everything, or choose individual configs
```

Individual sync scripts:
- `glzr/sync.sh` - GlazeWM + Zebar to `~/.glzr/`
- `wezterm/sync.sh` - WezTerm config to `~/.wezterm.lua`
- `scripts/sync.sh` - AutoHotkey scripts to `~/scripts/`
- `theme/sync.sh` - Wallpapers to `~/Pictures/Wallpapers/`
- `wsl/dotfiles/sync.sh` - .zshrc to `~/`
- `wsl/neovim/sync.sh` - Neovim config to `~/.config/nvim/`
- `wsl/zsh/sync.sh` - Zsh modules to `~/.zsh/`

### Launchers

All launchers are consolidated into a single `master.ahk` script with shared libraries. Uses Catppuccin Mocha theming and fuzzy-find filtering.

**Terminal Launcher (Alt+Enter)**
- Opens WezTerm in selected project folder
- Auto-scans `~/dev/` for projects
- Static entries from `config/folders.ini`

**Website Launcher (Alt+Space)**
- Launches web apps in Chrome app mode
- Supports Chrome, Vivaldi, Brave, and Edge
- Entries configured in `config/websites.ini`

**Wallpaper Selector (Alt+W)**
- Fuzzy-find wallpaper selector with live preview
- Scans `~/Pictures/Wallpapers/`
- Sets desktop wallpaper instantly

**Amphetamine (Ctrl+Alt+A)**
- Prevents screen lock with natural mouse movement
- Toggle on/off with tooltip feedback
- Enabled by default on startup

**Help Window (Alt+?)**
- Shows AutoHotkey and GlazeWM keyboard shortcuts
- Displays amphetamine status (ON/OFF)

### GlazeWM Configuration

- **Gaps**: 12px uniform spacing
- **Window Effects**: Catppuccin-themed borders
- **Workspaces**: 1-9 with Alt+number keybinds
- **Focus**: Alt+hjkl for vim-style navigation
- **Reload**: Alt+Shift+R

### Zebar Status Bar

Custom React-based status bar with:
- GlazeWM workspace buttons
- Active window title
- CPU/Memory monitors (click to open Task Manager)
- Date/time display
- Catppuccin Mocha theme

### Firefox Customization

Located in `standalone/firefox/` (requires manual setup):

**userChrome.css**:
- Auto-hiding navbar (shows on hover)
- Minimal tab design
- Debloated toolbar
- Catppuccin colors

**Installation**:
1. Enable `toolkit.legacyUserProfileCustomizations.stylesheets` in `about:config`
2. Copy `userChrome.css` to `%APPDATA%\Mozilla\Firefox\Profiles\<profile>\chrome\`

### WSL Dotfiles

**Neovim**: Full LazyVim configuration with:
- LSP support
- Catppuccin theme
- Copilot integration
- Custom keybindings

**Zsh**: Modular configuration with:
- Aliases
- Completions
- Custom functions
- History settings
- Tool integrations (fzf, zoxide)

## Installation

### Prerequisites

- Windows 11
- WSL2 with Ubuntu
- [GlazeWM](https://github.com/glzr-io/glazewm)
- [Zebar](https://github.com/glzr-io/zebar)
- [WezTerm](https://wezfurlong.org/wezterm/)
- [AutoHotkey v2](https://www.autohotkey.com/)
- Google Chrome (for web app launcher)

### Setup

1. **Clone the repository (from WSL):**
   ```bash
   git clone <repo-url> ~/dev/windot
   cd ~/dev/windot
   ```

2. **Sync all configurations:**
   ```bash
   ./sync.sh
   # Select "all" or choose specific configs
   ```

3. **Reload GlazeWM:**
   Press `Alt+Shift+R`

4. **Start AutoHotkey scripts:**
   Run `master.ahk` from `C:\Users\<username>\scripts\` (single script handles all launchers)

## Keybindings

### AutoHotkey Launchers

| Hotkey | Action |
|--------|--------|
| Alt+Enter | Terminal launcher |
| Alt+Space | Website launcher |
| Alt+W | Wallpaper selector |
| Ctrl+Alt+A | Toggle amphetamine |
| Alt+? | Help window |

### GlazeWM

| Hotkey | Action |
|--------|--------|
| Alt+hjkl | Focus window |
| Alt+1-9 | Switch workspace |
| Alt+Shift+1-9 | Move window to workspace |
| Alt+Shift+R | Reload GlazeWM |

## Notes

- **Windows configs** sync to `C:\Users\<username>\`
- **WSL configs** sync to the WSL home directory
- **Firefox config** requires manual setup (see `standalone/firefox/`)
- All launchers auto-detect installed applications

## Links

- [GlazeWM Documentation](https://github.com/glzr-io/glazewm)
- [Zebar Documentation](https://github.com/glzr-io/zebar)
- [WezTerm Documentation](https://wezfurlong.org/wezterm/)
- [AutoHotkey v2 Docs](https://www.autohotkey.com/docs/v2/)
- [LazyVim Documentation](https://www.lazyvim.org/)

## License

Personal configuration - use as you wish!

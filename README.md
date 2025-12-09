# Windot - Windows Configuration Files

Personal Windows/WSL configuration files with automated sync scripts for a tiling window manager setup.

## Tech Stack

- **Window Manager**: [GlazeWM](https://github.com/glzr-io/glazewm) - Tiling window manager for Windows
- **Status Bar**: [Zebar](https://github.com/glzr-io/zebar) - Custom React status bar with GlazeWM integration
- **Terminal**: [WezTerm](https://wezfurlong.org/wezterm/) - GPU-accelerated terminal emulator
- **Browser**: Firefox with custom userChrome.css styling
- **Automation**: AutoHotkey v2 scripts for fuzzy-find launchers
- **Utilities**: [PowerToys](https://github.com/microsoft/PowerToys) - Keyboard Manager remappings
- **Customization**: [Windhawk](https://windhawk.net/) - Taskbar and Windows UI mods
- **Editor**: Neovim with LazyVim configuration
- **Shell**: Zsh with modular configuration

## Repository Structure

```
windot/
├── glzr/           # GlazeWM & Zebar configs
├── install/        # Automated install scripts
│   ├── windows/    # Windows apps via winget
│   └── wsl/        # WSL packages via apt/scripts
├── powertoys/      # PowerToys config (Keyboard Manager)
├── scripts/        # AutoHotkey launchers
│   ├── config/     # INI configuration files
│   └── lib/        # Shared library functions
├── standalone/     # Manual setup configs (Firefox, Windhawk)
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
- `powertoys/sync.sh` - PowerToys config to `%LOCALAPPDATA%\Microsoft\PowerToys`
- `theme/sync.sh` - Wallpapers to `~/Pictures/Wallpapers/`
- `wsl/dotfiles/sync.sh` - .zshrc to `~/`
- `wsl/neovim/sync.sh` - Neovim config to `~/.config/nvim/`
- `wsl/zsh/sync.sh` - Zsh modules to `~/.zsh/`

### Launchers

All launchers are consolidated into a single `master.ahk` script with shared libraries. Uses Catppuccin Mocha theming and fuzzy-find filtering.

**Terminal Launcher (Alt+Enter)**
- Opens a new WezTerm terminal in the current directory
- If focused on WezTerm: new terminal opens in same directory
- If focused on other window: new terminal opens in home directory

**Quick Launcher (Alt+Space)**
- Unified launcher for websites, apps, folders, and terminal paths
- Web apps open in Chrome app mode (Chrome, Vivaldi, Brave, Edge)
- Terminal paths open in WezTerm (auto-scans `~/dev/`)
- Obsidian vaults open directly
- Folders open in File Explorer
- Config split into `config/web.ini`, `apps.ini`, `folders.ini`, `terminal.ini`

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

### Install Scripts

Automated installation scripts for setting up a new machine:

**Windows** (`install/windows/install.ps1`):
- Interactive fzf menu (with fallback) to select scripts
- Auto-installs WinGet if not available
- Scripts:
  - `browsers` - Firefox, Chrome, Brave
  - `development` - VS Code, Git, WezTerm
  - `fonts` - JetBrains Mono, Cascadia Code, Nerd Fonts
  - `system-tools` - PowerToys, UniGetUI, Windhawk, AutoHotkey
  - `wsl` - WSL2 + Ubuntu
  - `window-management` - GlazeWM, Zebar
  - `settings` - Windows appearance, taskbar, explorer, privacy tweaks

**WSL** (`install/wsl/install.sh`):
- Interactive fzf menu to select scripts
- Scripts:
  - `prerequisites` - build-essential, curl, git
  - `shell` - zsh, oh-my-zsh, starship
  - `utilities` - fzf, ripgrep, eza, bat, zoxide
  - `dev-core` - neovim, tmux, docker
  - `javascript` - nvm, node, bun, pnpm
  - `lazy-tools` - lazygit, lazydocker
  - `databases` - postgresql client
  - `ai` - Claude Code CLI
  - `misc` - additional tools

### PowerToys

Configuration for Microsoft PowerToys:
- **Keyboard Manager**: Custom key remappings
- Sync with `powertoys/sync.sh`

### Windhawk

Located in `standalone/windhawk/` (requires manual setup):

Custom Windows UI modifications via Windhawk mods:
- **Taskbar Styler**: Rose Pine theme
- **Start Menu Styler**: Down Aero theme
- **Notification Center Styler**: Translucent Shell theme
- **Taskbar Clock Customization**: Custom time format, RSS tooltip
- **Taskbar Icon Size**: Smaller icons (18px)
- **Taskbar Volume Control**: Scroll wheel volume adjustment
- **File Explorer Remove Suffixes**: Hide file extensions

**Installation**: Install mods via Windhawk GUI, then configure settings using `mods.json` as reference. See `standalone/windhawk/README.md` for details.

## Installation

### Option 1: Automated Install (Recommended)

Run the install scripts to set up everything automatically:

```powershell
# From PowerShell (as Administrator for some packages)
.\install\windows\install.ps1
# Select "all" or choose specific categories
```

```bash
# From WSL (after Windows install)
./install/wsl/install.sh
# Select "all" or choose specific categories
```

### Option 2: Manual Prerequisites

If you prefer manual installation:
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

2. **Run install scripts (optional):**
   ```powershell
   # Windows
   .\install\windows\install.ps1
   ```
   ```bash
   # WSL
   ./install/wsl/install.sh
   ```

3. **Sync all configurations:**
   ```bash
   ./sync.sh
   # Select "all" or choose specific configs
   ```

4. **Reload GlazeWM:**
   Press `Alt+Shift+R`

5. **Start AutoHotkey scripts:**
   Run `master.ahk` from `C:\Users\<username>\scripts\` (single script handles all launchers)

### Troubleshooting

**PowerShell scripts won't run**: If you get an error about execution policy, run PowerShell as Administrator and execute:
```powershell
Set-ExecutionPolicy RemoteSigned
```

## Keybindings

### AutoHotkey Launchers

| Hotkey | Action |
|--------|--------|
| Alt+Enter | New terminal in current directory |
| Alt+Space | Quick launcher |
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

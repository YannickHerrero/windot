# Windot

> **For Linux devs who lost the "which OS" argument at work.**

A comprehensive Windows + WSL dotfiles configuration that makes Windows feel less like Windows. Tiling window manager, vim keybindings, fuzzy-find everything, and a theme system that synchronizes colors across your entire setup with a single command.

## Highlights

- **Tiling WM on Windows** — GlazeWM with vim-style navigation (Alt+hjkl), workspaces, and gaps
- **One-click theme switching** — Change themes across Windows, terminal, Neovim, and shell prompt simultaneously
- **Fuzzy-find everything** — AutoHotkey launchers for apps, websites, folders, terminal paths, and system utilities
- **WSL-first workflow** — Zsh, Neovim, and modern CLI tools configured and ready
- **Automated setup** — Install scripts for both Windows and WSL with interactive menus

## Overview

Windot is a collection of configuration files and scripts for setting up a productive development environment on Windows + WSL. It bridges the gap between Windows native applications and a Linux development workflow, providing a cohesive experience across both environments.

The standout feature is the **cross-platform theme system** — a single theme change propagates to WezTerm, Neovim, Oh My Posh, GlazeWM, Zebar, OpenCode, and even sets the Windows dark/light mode and wallpaper. No more manually updating colors in 7 different config files.

### Inspiration

This setup is inspired by [Omarchy](https://github.com/basecamp/omarchy). Windot attempts to recreate that same polished, cohesive developer experience — but for those of us stuck on Windows.

### Author

Created by [Yannick Herrero](https://github.com/YannickHerrero) as a personal configuration backup and reference. Feel free to use anything you find useful.

## Tech Stack

| Component      | Tool                                                      | Description                                 |
| -------------- | --------------------------------------------------------- | ------------------------------------------- |
| Window Manager | [GlazeWM](https://github.com/glzr-io/glazewm)             | Tiling WM for Windows (i3/bspwm-like)       |
| Status Bar     | [Zebar](https://github.com/glzr-io/zebar)                 | React-based bar with GlazeWM integration    |
| Terminal       | [WezTerm](https://wezfurlong.org/wezterm/)                | GPU-accelerated, Lua-configurable           |
| Launchers      | [AutoHotkey v2](https://www.autohotkey.com/)              | Fuzzy-find launchers and utilities          |
| Editor         | [Neovim](https://neovim.io/)                              | Custom config with LSP, Copilot, treesitter |
| Shell          | Zsh + [Zinit](https://github.com/zdharma-continuum/zinit) | Fast, modular configuration                 |
| Prompt         | [Oh My Posh](https://ohmyposh.dev/)                       | Cross-platform prompt theming               |
| Utilities      | [PowerToys](https://github.com/microsoft/PowerToys)       | Keyboard remappings                         |

## Features

### Cross-Platform Theme System

Themes are defined in TOML files with comprehensive color palettes:

```toml
[meta]
name = "Catppuccin Mocha"
id = "mocha"
type = "dark"              # Sets Windows dark/light mode
wallpaper = "catppuccin.png"

[colors]
background = "1e1e2e"
foreground = "cdd6f4"
# ... core UI colors

[colors.terminal]
# ANSI 16-color palette for terminals

[colors.base16]
# Base16 palette for Neovim syntax highlighting

[apps.ohmyposh]
# Semantic colors for shell prompt

[apps.glazewm]
border_focused = "b4befe"
```

**Available themes:** Catppuccin (Mocha/Latte), Nord, Osaka Jade, Milk Matcha, Rose of Dune, Snow

**What gets updated:**

- WezTerm colors (hot-reloads without restart)
- Neovim base16 colorscheme
- Oh My Posh prompt colors
- OpenCode theme
- GlazeWM window borders
- Zebar CSS variables
- Windows dark/light mode
- Desktop wallpaper

### AutoHotkey Launcher Suite

All launchers consolidated into `master.ahk` with shared libraries and Catppuccin theming.

#### Quick Launcher `Alt+Space`

Unified fuzzy-find launcher for:

- **Websites** — Opens in Chrome app mode (supports Chrome, Vivaldi, Brave, Edge)
- **Applications** — With Obsidian vault support
- **Folders** — Opens in File Explorer
- **Terminal paths** — Opens WezTerm in directory (auto-scans `~/dev/`)
- **Firefox Web Apps** — Auto-discovered
- **Clipboard URLs** — Paste and go

Configuration split into `config/web.ini`, `apps.ini`, `folders.ini`, `terminal.ini`.

#### Omakase Launcher `Win+Alt+Space`

Meta-launcher providing access to all utilities:

- Quick Launcher
- Wallpaper Selector (fuzzy-find with live preview)
- Theme Switcher (light themes marked 日, dark themes 月)
- Help Window (shows all keybindings)
- Amphetamine toggle (prevents screen lock, shows ON/OFF status)

#### Terminal `Alt+Enter`

Opens a new WezTerm instance.

### GlazeWM Configuration

- **Gaps**: 12px uniform spacing
- **Window effects**: Themed borders, transparency on unfocused windows
- **Workspaces**: 1-9 with Alt+number keybinds
- **Navigation**: Alt+hjkl for vim-style focus movement
- **Auto-starts**: Zebar and master.ahk on launch
- **Smart rules**: Ignores Zebar, PowerToys, AHK launchers, PiP windows

### Zebar Status Bar

Custom React-based status bar featuring:

- GlazeWM workspace buttons (clickable)
- Tiling direction toggle
- Date/time display
- CPU/Memory usage monitors
- Battery indicator
- Binding mode display
- Pause indicator

### WSL Development Environment

#### Neovim

Custom configuration with:

- LSP support for multiple languages
- GitHub Copilot integration
- Treesitter syntax highlighting
- Telescope fuzzy finder
- Base16 theme integration (syncs with system theme)

#### Zsh

Modular configuration with Zinit plugin manager:

- `aliases.zsh` — Common shortcuts
- `completions.zsh` — Enhanced tab completion
- `functions.zsh` — Custom shell functions
- `history.zsh` — Shared history settings
- `tools.zsh` — Tool integrations (fzf, zoxide, etc.)
- `fuzzy-dir.zsh` — Fuzzy directory navigation

Modern CLI tools configured: `eza` (ls), `bat` (cat), `zoxide` (cd), `fzf`, `ripgrep`

### Firefox Customization

Located in `standalone/firefox/` (requires manual setup):

**userChrome.css:**

- Auto-hiding navbar (shows on hover)
- Minimal tab design
- Debloated toolbar

**Installation:**

1. Enable userchrome in `about:config`:
   - Set `toolkit.legacyUserProfileCustomizations.stylesheets` to `true`

2. Enable compact mode:
   - Set `browser.compactmode.show` to `true` in `about:config`
   - In customize toolbar menu, set density to compact

3. Copy `userChrome.css` to the `chrome` directory in your Firefox profile
   - Find your profile path at `about:profiles`

## Repository Structure

```
windot/
├── glzr/              # GlazeWM & Zebar configs
│   ├── glazewm/       # Window manager config
│   └── zebar/         # Status bar (React + CSS)
├── install/           # Automated install scripts
│   ├── windows/       # PowerShell + WinGet
│   └── wsl/           # Bash + apt/brew/cargo
├── powertoys/         # PowerToys config (Keyboard Manager)
├── scripts/           # AutoHotkey launchers
│   ├── config/        # INI configuration files
│   └── lib/           # Shared library functions
├── standalone/        # Manual setup configs (Firefox)
├── theme/             # Theme definitions & wallpapers
│   ├── themes/        # TOML theme files
│   └── walls/         # Wallpaper images
├── wezterm/           # Terminal configuration
└── wsl/               # WSL dotfiles
    ├── dotfiles/      # Shell configs, theme scripts
    ├── neovim/        # Neovim configuration
    └── zsh/           # Zsh modules
```

## Installation

### Option 1: Automated Install (Recommended)

#### Windows

```powershell
# Run from PowerShell (as Administrator for some packages)
.\install\windows\install.ps1
```

Interactive fzf menu to select:

- `browsers` — Firefox, Chrome, Brave
- `development` — VS Code, Git, WezTerm
- `fonts` — JetBrains Mono, Cascadia Code, Nerd Fonts
- `system-tools` — PowerToys, UniGetUI, AutoHotkey
- `wsl` — WSL2 + Ubuntu
- `window-management` — GlazeWM, Zebar
- `settings` — Windows appearance, taskbar, explorer, privacy tweaks

#### WSL

```bash
# Run from WSL
./install/wsl/install.sh
```

Interactive fzf menu to select:

- `prerequisites` — build-essential, curl, git
- `shell` — zsh, oh-my-zsh, starship
- `utilities` — fzf, ripgrep, eza, bat, zoxide
- `dev-core` — neovim, tmux, docker
- `javascript` — nvm, node, bun, pnpm
- `lazy-tools` — lazygit, lazydocker
- `databases` — postgresql client
- `ai` — Claude Code CLI
- `misc` — additional tools

### Option 2: Manual Prerequisites

If you prefer manual installation:

- Windows 11
- WSL2 with Ubuntu
- [GlazeWM](https://github.com/glzr-io/glazewm)
- [Zebar](https://github.com/glzr-io/zebar)
- [WezTerm](https://wezfurlong.org/wezterm/)
- [AutoHotkey v2](https://www.autohotkey.com/)
- Google Chrome (for web app launcher)

### Syncing Configurations

```bash
# From WSL, in the repo directory
./sync.sh
```

Interactive fzf menu with options:

- `all` — Sync everything
- Individual configs (glzr, wezterm, scripts, etc.)

**Individual sync scripts:**

| Script                 | Destination                              |
| ---------------------- | ---------------------------------------- |
| `glzr/sync.sh`         | `~/.glzr/`                               |
| `wezterm/sync.sh`      | `~/.wezterm.lua`                         |
| `scripts/sync.sh`      | `~/scripts/`                             |
| `powertoys/sync.sh`    | `%LOCALAPPDATA%\Microsoft\PowerToys`     |
| `theme/sync.sh`        | `~/Pictures/Wallpapers/` + theme INI     |
| `wsl/dotfiles/sync.sh` | `~/` (.zshrc, .gitconfig, theme-scripts) |
| `wsl/neovim/sync.sh`   | `~/.config/nvim/`                        |
| `wsl/zsh/sync.sh`      | `~/.zsh/`                                |

### Post-Install Setup

1. **Reload GlazeWM:** `Alt+Shift+R`

2. **Start AutoHotkey scripts:** Run `master.ahk` from `C:\Users\<username>\scripts\`

3. **Set a theme:** Press `Win+Alt+Space` → Select "Theme Switcher"

### Troubleshooting

**PowerShell scripts won't run:**

```powershell
# Run PowerShell as Administrator
Set-ExecutionPolicy RemoteSigned
```

**Theme not applying to all apps:** Ensure `set-theme.sh` is in `~/.local/bin/` and executable.

## Keybindings

### AutoHotkey

| Hotkey          | Action                       |
| --------------- | ---------------------------- |
| `Alt+Enter`     | New terminal                 |
| `Alt+Space`     | Quick launcher               |
| `Win+Alt+Space` | Omakase launcher (utilities) |

### GlazeWM

| Hotkey              | Action                   |
| ------------------- | ------------------------ |
| `Alt+h/j/k/l`       | Focus window (vim-style) |
| `Alt+Shift+h/j/k/l` | Move window              |
| `Alt+1-9`           | Switch workspace         |
| `Alt+Shift+1-9`     | Move window to workspace |
| `Alt+f`             | Toggle floating          |
| `Alt+m`             | Toggle maximize          |
| `Alt+Shift+q`       | Close window             |
| `Alt+Shift+r`       | Reload config            |

## Notes

- **Windows configs** sync to `C:\Users\<username>\`
- **WSL configs** sync to the WSL home directory
- **Firefox config** requires manual setup (see `standalone/firefox/`)
- **Theme system** requires Python 3.11+ (for `tomllib`)
- All launchers auto-detect installed applications

## Links

- [GlazeWM Documentation](https://github.com/glzr-io/glazewm)
- [Zebar Documentation](https://github.com/glzr-io/zebar)
- [WezTerm Documentation](https://wezfurlong.org/wezterm/)
- [AutoHotkey v2 Docs](https://www.autohotkey.com/docs/v2/)
- [Neovim Documentation](https://neovim.io/doc/)
- [Oh My Posh Documentation](https://ohmyposh.dev/)

## Feedback

If you have questions or suggestions, feel free to [open an issue](https://github.com/YannickHerrero/windot/issues).

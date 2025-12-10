# AGENTS.md - Coding Agent Instructions

## Overview
Windows 11 + WSL2 dotfiles repository. No build/test system - configuration files only.

## Commands
- `./sync.sh` - Interactive sync menu (fzf-based)
- Individual syncs: `glzr/sync.sh`, `wezterm/sync.sh`, `scripts/sync.sh`, `wsl/*/sync.sh`
- Install: `install/windows/install.ps1` (Windows), `install/wsl/install.sh` (WSL)

## Code Style by Language
| Language | Indent | Naming | Notes |
|----------|--------|--------|-------|
| Lua | 2 spaces | snake_case vars, hyphenated files | 120 col width, `stylua.toml` |
| Shell/Zsh | 4 spaces | UPPER_CASE constants, lower_case locals | Guard clauses for deps |
| PowerShell | 4 spaces | PascalCase functions/vars | `-ErrorAction SilentlyContinue` |
| AutoHotkey v2 | 4 spaces | camelCase local, PascalCase global | `#Include "lib/file.ahk"` |
| YAML | 2 spaces | kebab-case keys | Inline comments encouraged |

## Conventions
- **Theme**: Catppuccin Mocha everywhere
- **Placeholders**: `%WIN_USER%`, `%WSL_USER%` for dynamic paths
- **Install scripts**: Numbered prefix (00-, 01-) for execution order
- **Imports**: `require("module")` (Lua), `source file.zsh` (shell)

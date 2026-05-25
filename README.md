# windot

Windows-only setup for a tiling, keyboard-driven workflow. No WSL, no
admin, installs in a few minutes from a fresh box.

## Stack

| Layer         | Tool                                                                  |
| ------------- | --------------------------------------------------------------------- |
| Window manager | [GlazeWM](https://github.com/glzr-io/glazewm)                        |
| Status bar    | [wbar](https://github.com/YannickHerrero/wbar)                        |
| Launcher / hotkeys | [wmenu](https://github.com/YannickHerrero/wmenu)                 |
| File manager  | [Explorer](https://github.com/YannickHerrero/Explorer)                |
| Keyboard remap | [kanata](https://github.com/jtroo/kanata) (CapsLock → Ctrl/Esc)      |
| Terminal      | [WezTerm](https://wezfurlong.org/wezterm/)                            |
| Package manager | [Scoop](https://scoop.sh) (user-mode, no admin)                     |

## Install

Open **Windows Terminal** (PowerShell, **not** as admin):

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
scoop install git
git clone https://github.com/YannickHerrero/windot.git
cd windot
.\install.ps1
```

`install.ps1` (a root wrapper around `install\windows\install.ps1`)
bootstraps scoop, adds the `extras`, `nerd-fonts`, and `yannick`
buckets, then shows a numbered menu of steps. Pick `0` for everything.

### What gets installed

| Bucket / Source | App | Step |
| --- | --- | --- |
| `extras` | Google Chrome | 0-browsers |
| `extras` | Firefox | 0-browsers |
| `extras` | WezTerm | 1-development |
| `extras` | Bruno | 1-development |
| `nerd-fonts` | JetBrainsMono-NF | 2-fonts |
| `extras` | kanata | 3-system-tools |
| `yannick` | wmenu | 4-launcher |
| `yannick` | wbar | 4-launcher |
| `yannick` | explorer | 4-launcher |
| `extras` | GlazeWM | 5-window-management |
| — | Registry tweaks | 6-settings (dark mode, taskbar, file explorer, privacy) |

All packages install user-mode under `~\scoop\apps\`. No UAC prompt
should appear at any point.

## Sync

```powershell
.\sync.ps1
```

Numbered menu lists every `<app>/sync.ps1`. Picking `0` copies all
configs into their expected locations:

| App     | Destination                                          |
| ------- | ---------------------------------------------------- |
| GlazeWM | `%USERPROFILE%\.glzr\glazewm\config.yaml`             |
| WezTerm | `%USERPROFILE%\.wezterm.lua`                          |
| wmenu   | `%APPDATA%\wmenu\config\config.toml`                  |
| wbar    | `%APPDATA%\wbar\config.toml`                          |
| Explorer | `%APPDATA%\com.ilios.explorer\config.json`           |
| kanata  | `%APPDATA%\kanata\kanata.kbd`                         |

## Keybinds

| Key                       | Action |
| ------------------------- | ------ |
| `Alt+Space`               | wmenu app launcher |
| `Alt+Super+Space`         | wmenu Omakase (system actions) |
| `Alt+Enter`               | New WezTerm window |
| `Alt+E`                   | Focus / launch Explorer |
| `Alt+h/j/k/l`             | GlazeWM focus left/down/up/right |
| `Alt+Shift+h/j/k/l`       | GlazeWM move window |
| `Alt+1` .. `Alt+9`        | Focus workspace |
| `Alt+Shift+1` .. `Alt+Shift+9` | Move window to workspace |
| `Alt+f`                   | Toggle fullscreen |
| `Alt+t` / `Alt+Shift+t`   | Toggle tiling / floating |
| `Alt+q`                   | Close window |
| `CapsLock` (tap)          | Esc (kanata) |
| `CapsLock` (hold)         | Ctrl (kanata) |

## Notes

- **No admin.** Scoop runs in user mode. GlazeWM's MSI is extracted by
  lessmsi (no Windows Installer service). Kanata uses the WinIOv2
  backend — no interception driver.
- **Autostart.** GlazeWM is the only autostart entry; it starts wbar and
  kanata via its `startup_commands`. wmenu autostarts itself via the
  per-user Run registry (toggle in its settings window).
- **Firefox** customisations (userChrome.css, fx-autoconfig, leader-key
  navigation) live in `standalone/firefox/` and are applied manually —
  see that directory's README.

## Layout

```
windot/
├── glzr/glazewm/        GlazeWM config + sync.ps1
├── wezterm/             WezTerm config + sync.ps1
├── wmenu/               wmenu config + sync.ps1
├── wbar/                wbar config + sync.ps1
├── explorer/            Explorer config + sync.ps1
├── kanata/              kanata.kbd + sync.ps1
├── standalone/firefox/  manual-apply Firefox tweaks
├── install/windows/     install.ps1 + run/*.ps1 steps
└── sync.ps1             top-level sync dispatcher
```

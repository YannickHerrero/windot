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
| Terminal (WSL) | [Windows Terminal](https://aka.ms/terminal) (matches WezTerm look)   |
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
| Wallpapers | `%APPDATA%\wmenu\wallpapers\<theme>.png`           |
| Windows Terminal | `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json` (merged) |

Windows Terminal's `sync.ps1` **merges** rather than overwrites: curated keys
(font, keybindings, default profile, `profiles.defaults`) are overlaid onto the
live file, while WT-generated profiles and the live dynamic color scheme are
preserved.

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

## Theming

`Alt+Super+Space → Theme → <Name>` switches everything at once:

| Target | What changes |
| ------ | ------------ |
| wmenu | own palette (instant) |
| wbar | palette (via 127.0.0.1:17128 IPC, instant) |
| Explorer | `theme` field in config.json — backend file watcher picks it up live |
| GlazeWM | focused / unfocused border colors in your `config.yaml` — orchestrator finds the `# wmenu-theme-focused` / `# wmenu-theme-unfocused` sentinel comments, rewrites just those lines, then triggers `wm-reload-config` |
| WezTerm | writes a complete `config.colors` table to `~/.wezterm-colors.lua` — your main `.wezterm.lua` already adds this path to `add_to_config_reload_watch_list`, so the terminal hot-reloads with no restart |
| Windows Terminal | has no Lua hot-reload; a bridge translates `~/.wezterm-colors.lua` into the `wezterm-omakase` scheme inside `settings.json` (WT live-reloads). wmenu can call `windows-terminal/theme-sync.ps1` natively on Windows; or run `windows-terminal/theme-sync.sh` from WSL (add `--watch` to resync on every theme switch) |
| Wallpaper | calls `SystemParametersInfoW SPI_SETDESKWALLPAPER` on `%APPDATA%\wmenu\wallpapers\<theme>.png` — drop your own image at any of the 5 slots to replace the shipped one |
| Windows | dark/light mode toggle + DWM accent color (Ink = dark, everything else = light), broadcast via `WM_SETTINGCHANGE` so running apps repaint without log-out |

The five themes available are **Paper**, **Stone**, **Sage**, **Clay**, **Ink** — they share names across wmenu, wbar, and Explorer. Each leg fails independently; if (say) wbar isn't running, the rest still update.

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
├── windows-terminal/    Windows Terminal settings.json + sync.ps1 + theme-sync.{ps1,sh}
├── wmenu/               wmenu config + sync.ps1
├── wbar/                wbar config + sync.ps1
├── explorer/            Explorer config + sync.ps1
├── kanata/              kanata.kbd + launch.vbs + sync.ps1
├── wallpapers/          5 per-theme PNGs + sync.ps1
├── standalone/firefox/  manual-apply Firefox tweaks
├── install/windows/     install.ps1 + run/*.ps1 steps
└── sync.ps1             top-level sync dispatcher
```

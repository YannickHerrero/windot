# Wallpapers

Five wallpaper slots, one per theme, used by the wmenu ecosystem theme
switcher. When you pick a theme from Omakase (`Alt+Super+Space → Theme
→ <Name>`), wmenu reads `%APPDATA%\wmenu\wallpapers\<theme>.png` and
calls `SystemParametersInfoW SPI_SETDESKWALLPAPER` on it.

The PNGs shipped here are solid-color placeholders generated from each
theme's `palette.paper` hex — they work out of the box but are
visually plain. Drop in any image you like at the same filename
(`paper.png`, `stone.png`, `sage.png`, `clay.png`, `ink.png`); 16:9
ratio is recommended but Windows will fit/fill per your existing
`HKCU\Control Panel\Desktop\WallpaperStyle` setting.

Re-run `./sync.ps1` (or `..\sync.ps1` and pick `0`) to push your
updates to `%APPDATA%\wmenu\wallpapers\`.

If a `<theme>.png` is missing the orchestrator logs `wallpaper: err:
no wallpaper at …` and skips that leg — every other target (wmenu,
wbar, Explorer, GlazeWM, WezTerm, Windows registry) still updates.

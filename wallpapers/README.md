# Wallpapers

A rotation pool per theme, used by the wmenu ecosystem theme switcher.
When you pick a theme from Omakase (`Alt+Super+Space → Theme → <Name>`),
wmenu picks a random `<theme>-N.png` from `%APPDATA%\wmenu\wallpapers\`
and calls `SystemParametersInfoW SPI_SETDESKWALLPAPER` on it, then
re-randomizes every `wallpaper_rotation_minutes` (wmenu config, default
30; set `0` to disable rotation).

Files are named `<theme>-<n>.png` (`paper-1.png`, `paper-2.png`, …).
The `-1` slot is the original solid-color placeholder generated from
each theme's `palette.paper` hex — it works out of the box but is
visually plain. Every slot is equally in the rotation, so drop in any
images you like at the same naming; 16:9 ratio is recommended but
Windows will fit/fill per your existing
`HKCU\Control Panel\Desktop\WallpaperStyle` setting. The pool size per
theme is whatever `<theme>-*.png` files exist — add or remove freely.

Re-run `./sync.ps1` (or `..\sync.ps1` and pick `0`) to push your
updates to `%APPDATA%\wmenu\wallpapers\`. Note `sync.ps1` copies but
never deletes, so renaming or removing a wallpaper leaves the old file
behind in the dest — clear it there too if you want it out of the pool.

If a theme has no `<theme>-*.png` at all, the orchestrator logs
`wallpaper: err: no wallpaper for <theme> in …` and skips that leg —
every other target (wmenu, wbar, Explorer, GlazeWM, WezTerm, Windows
registry) still updates.

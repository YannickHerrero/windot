# Windhawk Configuration

Manual setup guide for Windhawk mods. The `mods.json` file contains the mod list and settings for reference.

## Installation

1. Install Windhawk (already included in `install/windows/run/03-system-tools.ps1`)
2. Open Windhawk from the Start menu
3. Install each mod from the "Explore" tab by searching for the mod name

## Mods to Install

| Mod Name | Description |
|----------|-------------|
| windows-11-taskbar-styler | Taskbar theme (Rose Pine) |
| windows-11-start-menu-styler | Start menu theme (Down Aero) |
| windows-11-notification-center-styler | Notification center theme (Translucent Shell) |
| taskbar-clock-customization | Custom clock format with RSS tooltip |
| taskbar-icon-size | Smaller taskbar icons (18px) |
| taskbar-volume-control | Scroll wheel volume adjustment |
| file-explorer-remove-suffixes | Hide common file extensions |
| taskbar-vertical | Vertical taskbar (disabled by default) |

## Settings Reference

After installing each mod, configure settings in the Windhawk GUI. Reference values are in `mods.json`.

### Key Settings

**taskbar-clock-customization:**
- Width: 180, Height: 60
- Middle Line: `%weekday%`
- Tooltip: RSS feed from NY Times World
- Date style hidden

**taskbar-icon-size:**
- Taskbar Height: 36
- Icon Size: 18
- Button Width: 36

**taskbar-volume-control:**
- Volume change step: 2
- Middle click to mute: enabled
- Scroll area: taskbar

**Styler mods:**
- Taskbar: Rose Pine theme
- Start Menu: Down Aero theme
- Notification Center: Translucent Shell theme

## Why Manual Setup?

Windhawk stores its configuration in the Windows registry (`HKLM\SOFTWARE\Windhawk`). Automating registry modifications:
- Could cause issues if Windhawk isn't installed or has a different version
- Doesn't handle errors gracefully
- May overwrite user customizations

The GUI installation ensures mods are compiled correctly for your Windows version and avoids registry compatibility issues.

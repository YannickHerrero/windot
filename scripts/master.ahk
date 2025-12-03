; Master Launcher - Single entry point for all AutoHotkey scripts
; Run this script to start all launchers with a single tray icon

#Requires AutoHotkey v2.0
#SingleInstance Force

; Global variables shared by all launchers
global scriptDir := A_ScriptDir
global config := Map()

; Include library functions
#Include "lib/fuzzy-match.ahk"
#Include "lib/center-window.ahk"
#Include "lib/theme-config.ahk"

; Load theme and GUI configuration
LoadThemeConfig()

; Include all launchers
#Include "terminal-launcher.ahk"
#Include "website-launcher.ahk"
#Include "wallpaper-launcher.ahk"
#Include "amphetamine.ahk"

; Keybinds
!Enter::ToggleTerminalLauncher()
!Space::ToggleWebsiteLauncher()
!w::ToggleWallpaperLauncher()
^!a::ToggleAmphetamine()

; Keep script running with tray icon
Persistent

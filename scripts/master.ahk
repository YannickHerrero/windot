; Master Launcher - Single entry point for all AutoHotkey scripts
; Run this script to start all launchers with a single tray icon

#Requires AutoHotkey v2.0
#SingleInstance Force

; Global variables shared by all launchers
global scriptDir := A_ScriptDir
global config := Map()

; Auto-detect usernames for dynamic paths
global WIN_USER := A_UserName
global WSL_USER := GetWSLUser()

; Get WSL username (tries environment variable, falls back to Windows username without domain)
GetWSLUser() {
    ; Try WSL_USER environment variable first
    user := EnvGet("WSL_USER")
    if (user != "")
        return user
    ; Fallback: use Windows username, strip domain suffix if present
    return RegExReplace(A_UserName, "\..*$", "")
}

; Expand path placeholders with actual usernames
ExpandUserPath(path) {
    path := StrReplace(path, "%WIN_USER%", WIN_USER)
    path := StrReplace(path, "%WSL_USER%", WSL_USER)
    return path
}

; Include library functions
#Include "lib/fuzzy-match.ahk"
#Include "lib/center-window.ahk"
#Include "lib/theme-config.ahk"
#Include "lib/help-window.ahk"

; Load theme and GUI configuration
LoadThemeConfig()

; Include all launchers
#Include "quick-launcher.ahk"
#Include "wallpaper-launcher.ahk"
#Include "theme-launcher.ahk"
#Include "amphetamine.ahk"
#Include "terminal-launcher.ahk"

; Keybinds
!Enter::LaunchTerminalInCwd()
!Space::ToggleQuickLauncher()
!w::ToggleWallpaperLauncher()
^!a::ToggleAmphetamine()
!+/::ToggleHelpWindow()

; Keep script running with tray icon
Persistent

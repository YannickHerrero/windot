; Theme Launcher - Quick theme switcher with fuzzy find
; Press Shift+Alt+W to open launcher

; Global variables (unique names to avoid conflicts)
global themes := []
global filteredThemes := []
global themeGui := ""
global themeVisible := false
global themeSearch := ""
global themeList := ""

; Load theme definitions from INI files
LoadThemeDefinitions()

; Register theme change callback to recreate GUI with new colors
RegisterThemeChangeCallback(OnThemeLauncherThemeChange)

OnThemeLauncherThemeChange() {
    global themeGui, themeVisible
    if (themeGui) {
        themeGui.Destroy()
        themeGui := ""
        themeVisible := false
    }
}

; Load available themes from config/themes/*.ini
LoadThemeDefinitions() {
    global themes, scriptDir
    themes := []

    ; Scan all INI files in config/themes/
    themesDir := scriptDir . "\config\themes"

    ; Check if themes directory exists
    if !DirExist(themesDir) {
        MsgBox("Theme configuration not found.`n`nPlease run theme/sync.sh to generate theme files.`n`nExpected location: " . themesDir, "Theme Launcher - Setup Required", "Icon!")
        return
    }

    ; Scan for INI files
    themeCount := 0
    loop files themesDir . "\*.ini" {
        themeFile := A_LoopFileFullPath

        ; Read meta section
        name := IniRead(themeFile, "meta", "name", "")
        id := IniRead(themeFile, "meta", "id", "")
        type := IniRead(themeFile, "meta", "type", "")
        wallpaper := IniRead(themeFile, "meta", "wallpaper", "")

        ; Skip invalid themes
        if (name == "" || id == "") {
            continue
        }

        ; Read colors section
        colors := Map(
            "background", IniRead(themeFile, "colors", "background", ""),
            "primary", IniRead(themeFile, "colors", "primary", ""),
            "accent", IniRead(themeFile, "colors", "accent", ""),
            "text", IniRead(themeFile, "colors", "text", ""),
            "muted", IniRead(themeFile, "colors", "muted", ""),
            "border", IniRead(themeFile, "colors", "border", "")
        )

        themes.Push({
            name: name,
            id: id,
            type: type,
            wallpaper: wallpaper,
            colors: colors
        })
        themeCount++
    }

    ; Show error if no themes found
    if (themeCount == 0) {
        MsgBox("No theme files found.`n`nPlease run theme/sync.sh to generate theme files.`n`nExpected location: " . themesDir . "\*.ini", "Theme Launcher - No Themes", "Icon!")
    }
}

; Function to show/hide launcher
ToggleThemeLauncher() {
    global themeVisible, themes
    
    ; Don't show if no themes loaded
    if (themes.Length == 0) {
        LoadThemeDefinitions()
        if (themes.Length == 0) {
            return
        }
    }
    
    if (themeVisible) {
        HideThemeLauncher()
    } else {
        ShowThemeLauncher()
    }
}

; Show the launcher
ShowThemeLauncher() {
    global themeGui, themeVisible, themeSearch, themeList, themes, config

    ; Create GUI if it doesn't exist
    if (!themeGui) {
        ; Get theme colors from current config
        bg := config["theme"]["background"]
        primary := config["theme"]["primary"]
        accent := config["theme"]["accent"]
        txt := config["theme"]["text"]
        muted := config["theme"]["muted"]
        border := config["theme"]["border"]

        ; Get font settings
        font := config["gui"]["font"]
        fontSize := config["gui"]["fontSize"]
        titleSize := config["gui"]["titleSize"]

        themeGui := Gui("+AlwaysOnTop -Caption +Border +ToolWindow", "Theme Selector")
        themeGui.BackColor := bg
        themeGui.SetFont("s" fontSize " c" txt, font)

        ; Add title
        themeGui.SetFont("s" titleSize " Bold c" primary, font)
        themeGui.Add("Text", "x20 y15 w360 Center", "Theme Selector")

        ; Add instructions
        themeGui.SetFont("s9 c" muted, font)
        themeGui.Add("Text", "x20 y45 w360 Center", "Enter to apply - ESC to close")

        ; Add separator
        themeGui.Add("Text", "x20 y70 w360 h1 Background" accent)

        ; Add search box
        themeGui.SetFont("s" fontSize " c" txt, font)
        themeSearch := themeGui.Add("Edit", "x20 y85 w360 h30 -E0x200 Background" bg " c" txt)
        themeSearch.OnEvent("Change", (*) => FilterThemes())

        ; Add bottom border for search box
        themeGui.Add("Text", "x20 y116 w360 h1 Background" border)

        ; Add list view with custom colors
        themeGui.SetFont("s" fontSize " c" txt, font)
        themeList := themeGui.Add("ListView", "x20 y135 w360 h150 -Hdr -Multi -E0x200 Background" bg " c" txt, ["Name"])
        themeList.OnEvent("DoubleClick", (*) => ApplySelectedTheme())

        ; Populate initial list
        PopulateThemeList()

        ; Handle keyboard shortcuts
        themeGui.OnEvent("Escape", (*) => HideThemeLauncher())

        ; Set column width
        themeList.ModifyCol(1, 340)

        ; Set up context-sensitive hotkeys
        HotIfWinActive("ahk_id " themeGui.Hwnd)
        Hotkey("Enter", (*) => ApplySelectedTheme(), "On")
        Hotkey("Down", (*) => MoveThemeSelection(1), "On")
        Hotkey("Up", (*) => MoveThemeSelection(-1), "On")
        HotIfWinActive()
    }

    ; Reset search and refresh list
    themeSearch.Value := ""
    PopulateThemeList()

    ; Center and show
    CenterWindow(themeGui)
    themeGui.Show()
    themeSearch.Focus()
    themeVisible := true
}

; Hide the launcher
HideThemeLauncher() {
    global themeGui, themeVisible

    if (themeGui) {
        themeGui.Hide()
        themeVisible := false
    }
}

; Populate list with themes
PopulateThemeList(filter := "") {
    global themeList, themes, filteredThemes

    themeList.Delete()
    filteredThemes := []

    for theme in themes {
        ; Fuzzy match filter (name only)
        if (filter == "" || FuzzyMatch(theme.name, filter)) {
            ; Use kanji prefix: 月 (moon) for dark, 日 (sun) for light
            prefix := (theme.type == "light") ? "日 " : "月 "
            themeList.Add("", prefix . theme.name)
            filteredThemes.Push(theme)
        }
    }

    ; Select first item if available
    if (themeList.GetCount() > 0) {
        themeList.Modify(1, "Select Focus")
    }
}

; Filter themes based on search
FilterThemes() {
    global themeSearch
    filter := themeSearch.Value
    PopulateThemeList(filter)
}

; Move selection up or down
MoveThemeSelection(direction) {
    global themeList

    currentRow := themeList.GetNext()

    if (direction > 0) {  ; Down
        if (currentRow == 0) {
            themeList.Modify(1, "Select Focus")
        } else if (currentRow < themeList.GetCount()) {
            themeList.Modify(currentRow + 1, "Select Focus")
        }
    } else {  ; Up
        if (currentRow > 1) {
            themeList.Modify(currentRow - 1, "Select Focus")
        }
    }
}

; Apply selected theme
ApplySelectedTheme() {
    global themeList, filteredThemes, themeGui, scriptDir

    selectedRow := themeList.GetNext()
    if (selectedRow == 0) {
        return
    }

    ; Get the theme from filtered list
    if (selectedRow <= filteredThemes.Length) {
        theme := filteredThemes[selectedRow]

        ; Hide launcher first
        HideThemeLauncher()

        ; Update AHK config.ini with new theme colors
        configFile := scriptDir . "\config\config.ini"
        IniWrite(theme.colors["background"], configFile, "Theme", "background")
        IniWrite(theme.colors["primary"], configFile, "Theme", "primary")
        IniWrite(theme.colors["accent"], configFile, "Theme", "accent")
        IniWrite(theme.colors["text"], configFile, "Theme", "text")
        IniWrite(theme.colors["muted"], configFile, "Theme", "muted")
        IniWrite(theme.colors["border"], configFile, "Theme", "border")

        ; Set wallpaper if specified
        if (theme.wallpaper != "") {
            SetThemeWallpaper(theme.wallpaper)
        }

        ; Set Windows theme mode (dark/light)
        SetWindowsThemeMode(theme.type)

        ; Call WSL script to update other configs (WezTerm, Neovim, OpenCode)
        Run('wsl.exe ~/.local/bin/set-theme.sh "' . theme.id . '"', , "Hide")

        ; Reload theme config and notify all launchers to recreate their GUIs
        ReloadTheme()
    }
}

; Set Windows wallpaper (Fill style)
SetThemeWallpaper(wallpaperName) {
    ; Build wallpaper path
    wallpaperPath := "C:\Users\" . EnvGet("USERNAME") . "\Pictures\Wallpapers\" . wallpaperName

    ; Check if file exists
    if !FileExist(wallpaperPath) {
        return
    }

    ; Set wallpaper style to Fill (WallpaperStyle=10, TileWallpaper=0) via registry
    RegWrite(10, "REG_SZ", "HKCU\Control Panel\Desktop", "WallpaperStyle")
    RegWrite(0, "REG_SZ", "HKCU\Control Panel\Desktop", "TileWallpaper")

    ; Set wallpaper using SystemParametersInfo (same as wallpaper-launcher.ahk)
    ; SPI_SETDESKWALLPAPER = 0x0014
    ; SPIF_UPDATEINIFILE = 0x01
    ; SPIF_SENDCHANGE = 0x02
    DllCall("SystemParametersInfoW"
        , "UInt", 0x0014        ; SPI_SETDESKWALLPAPER
        , "UInt", 0             ; Not used
        , "Str", wallpaperPath  ; Path to wallpaper
        , "UInt", 0x01 | 0x02)  ; SPIF_UPDATEINIFILE | SPIF_SENDCHANGE
}

; Set Windows theme mode (dark/light) for apps and system
SetWindowsThemeMode(themeType) {
    ; 0 = Dark mode, 1 = Light mode
    mode := (themeType == "light") ? 1 : 0

    ; Set app theme (AppsUseLightTheme)
    RegWrite(mode, "REG_DWORD", "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme")

    ; Set system theme (SystemUsesLightTheme) - taskbar, start menu, etc.
    RegWrite(mode, "REG_DWORD", "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize", "SystemUsesLightTheme")

    ; Broadcast WM_SETTINGCHANGE to notify all windows of theme change
    ; This avoids restarting Explorer which breaks GlazeWM window management
    BroadcastThemeChange()
}

; Broadcast WM_SETTINGCHANGE to notify applications of theme change
BroadcastThemeChange() {
    ; WM_SETTINGCHANGE = 0x001A
    ; HWND_BROADCAST = 0xFFFF
    ; Send to all top-level windows with "ImmersiveColorSet" to trigger theme refresh
    DllCall("SendMessageTimeoutW"
        , "Ptr", 0xFFFF              ; HWND_BROADCAST
        , "UInt", 0x001A             ; WM_SETTINGCHANGE
        , "Ptr", 0                   ; wParam
        , "Str", "ImmersiveColorSet" ; lParam - signals theme/color change
        , "UInt", 0x0002             ; SMTO_ABORTIFHUNG
        , "UInt", 5000               ; 5 second timeout
        , "Ptr*", &result := 0)      ; result (unused)
}

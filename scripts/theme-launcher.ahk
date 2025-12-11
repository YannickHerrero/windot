; Theme Launcher - Quick theme switcher with fuzzy find
; Press Shift+Alt+W to open launcher

; Global variables (unique names to avoid conflicts)
global themes := []
global filteredThemes := []
global themeGui := ""
global themeVisible := false
global themeSearch := ""
global themeList := ""

; Load theme definitions
LoadThemeDefinitions()

; Load available themes
LoadThemeDefinitions() {
    global themes

    ; Catppuccin Mocha (Dark)
    mochaColors := Map(
        "background", "1e1e2e",
        "primary", "f5c2e7",
        "accent", "89b4fa",
        "text", "cdd6f4",
        "muted", "6c7086",
        "border", "45475a"
    )
    themes.Push({
        name: "Catppuccin Mocha",
        id: "mocha",
        type: "dark",
        colors: mochaColors
    })

    ; Catppuccin Latte (Light)
    latteColors := Map(
        "background", "eff1f5",
        "primary", "ea76cb",
        "accent", "1e66f5",
        "text", "4c4f69",
        "muted", "9ca0b0",
        "border", "ccd0da"
    )
    themes.Push({
        name: "Catppuccin Latte",
        id: "latte",
        type: "light",
        colors: latteColors
    })
}

; Function to show/hide launcher
ToggleThemeLauncher() {
    global themeVisible
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
            themeList.Add("", theme.name . " (" . theme.type . ")")
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

        ; Call WSL script to update other configs (WezTerm, Neovim, OpenCode)
        Run('wsl.exe ~/.local/bin/set-theme.sh "' . theme.id . '"', , "Hide")

        ; Destroy GUI so it will be recreated with new colors next time
        themeGui.Destroy()
        themeGui := ""

        ; Reload theme config for other AHK scripts
        LoadThemeConfig()
    }
}

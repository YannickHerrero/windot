; Omakase Launcher - Meta-launcher for all AHK utilities
; Press Shift+Alt+Space to open launcher

; Global variables (unique names to avoid conflicts)
global omakaseItems := []
global filteredOmakaseItems := []
global omakaseGui := ""
global omakaseVisible := false
global omakaseSearch := ""
global omakaseList := ""

; Register theme change callback to recreate GUI with new colors
RegisterThemeChangeCallback(OnOmakaseLauncherThemeChange)

OnOmakaseLauncherThemeChange() {
    global omakaseGui, omakaseVisible
    if (omakaseGui) {
        omakaseGui.Destroy()
        omakaseGui := ""
        omakaseVisible := false
    }
}

; Build items array dynamically (for Amphetamine status)
BuildOmakaseItems() {
    global omakaseItems, amphetamineEnabled

    omakaseItems := []

    omakaseItems.Push({
        name: "Quick Launcher",
        displayName: "Quick Launcher",
        action: "quick"
    })

    omakaseItems.Push({
        name: "Wallpaper Selector",
        displayName: "Wallpaper Selector",
        action: "wallpaper"
    })

    omakaseItems.Push({
        name: "Theme Switcher",
        displayName: "Theme Switcher",
        action: "theme"
    })

    omakaseItems.Push({
        name: "Help Window",
        displayName: "Help Window",
        action: "help"
    })

    ; Dynamic Amphetamine label based on current state
    ampLabel := amphetamineEnabled ? "Turn off Amphetamine" : "Turn on Amphetamine"
    omakaseItems.Push({
        name: "Amphetamine",
        displayName: ampLabel,
        action: "amphetamine"
    })
}

; Function to show/hide launcher
ToggleOmakaseLauncher() {
    global omakaseVisible
    if (omakaseVisible) {
        HideOmakaseLauncher()
    } else {
        ShowOmakaseLauncher()
    }
}

; Show the launcher
ShowOmakaseLauncher() {
    global omakaseGui, omakaseVisible, omakaseSearch, omakaseList, omakaseItems, config

    ; Rebuild items to get fresh Amphetamine status
    BuildOmakaseItems()

    ; Create GUI if it doesn't exist
    if (!omakaseGui) {
        ; Get theme colors
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

        omakaseGui := Gui("+AlwaysOnTop -Caption +Border +ToolWindow", "Omakase Launcher")
        omakaseGui.BackColor := bg
        omakaseGui.SetFont("s" fontSize " c" txt, font)

        ; Add title
        omakaseGui.SetFont("s" titleSize " Bold c" primary, font)
        omakaseGui.Add("Text", "x20 y15 w360 Center", "Omakase Launcher")

        ; Add instructions
        omakaseGui.SetFont("s9 c" muted, font)
        omakaseGui.Add("Text", "x20 y45 w360 Center", "Type to filter - Enter to select - ESC to close")

        ; Add separator
        omakaseGui.Add("Text", "x20 y70 w360 h1 Background" accent)

        ; Add search box
        omakaseGui.SetFont("s" fontSize " c" txt, font)
        omakaseSearch := omakaseGui.Add("Edit", "x20 y85 w360 h30 -E0x200 Background" bg " c" txt)
        omakaseSearch.OnEvent("Change", (*) => FilterOmakaseItems())

        ; Add bottom border for search box
        omakaseGui.Add("Text", "x20 y116 w360 h1 Background" border)

        ; Add list view with custom colors
        omakaseGui.SetFont("s" fontSize " c" txt, font)
        omakaseList := omakaseGui.Add("ListView", "x20 y135 w360 h180 -Hdr -Multi -E0x200 Background" bg " c" txt, ["Name"])
        omakaseList.OnEvent("DoubleClick", (*) => LaunchSelectedOmakaseItem())

        ; Populate initial list
        PopulateOmakaseList()

        ; Handle keyboard shortcuts
        omakaseGui.OnEvent("Escape", (*) => HideOmakaseLauncher())

        ; Set column width
        omakaseList.ModifyCol(1, 340)

        ; Set up context-sensitive hotkeys
        HotIfWinActive("ahk_id " omakaseGui.Hwnd)
        Hotkey("Enter", (*) => LaunchSelectedOmakaseItem(), "On")
        Hotkey("Down", (*) => MoveOmakaseSelection(1), "On")
        Hotkey("Up", (*) => MoveOmakaseSelection(-1), "On")
        HotIfWinActive()
    }

    ; Reset search and refresh list
    omakaseSearch.Value := ""
    PopulateOmakaseList()

    ; Center and show
    CenterWindow(omakaseGui)
    omakaseGui.Show()
    omakaseSearch.Focus()
    omakaseVisible := true
}

; Hide the launcher
HideOmakaseLauncher() {
    global omakaseGui, omakaseVisible

    if (omakaseGui) {
        omakaseGui.Hide()
        omakaseVisible := false
    }
}

; Populate list with items
PopulateOmakaseList(filter := "") {
    global omakaseList, omakaseItems, filteredOmakaseItems

    omakaseList.Delete()
    filteredOmakaseItems := []

    for item in omakaseItems {
        ; Fuzzy match filter (name only)
        if (filter == "" || FuzzyMatch(item.name, filter)) {
            omakaseList.Add("", item.displayName)
            filteredOmakaseItems.Push(item)
        }
    }

    ; Select first item if available
    if (omakaseList.GetCount() > 0) {
        omakaseList.Modify(1, "Select Focus")
    }
}

; Filter items based on search
FilterOmakaseItems() {
    global omakaseSearch
    filter := omakaseSearch.Value
    PopulateOmakaseList(filter)
}

; Move selection up or down
MoveOmakaseSelection(direction) {
    global omakaseList

    currentRow := omakaseList.GetNext()

    if (direction > 0) {  ; Down
        if (currentRow == 0) {
            omakaseList.Modify(1, "Select Focus")
        } else if (currentRow < omakaseList.GetCount()) {
            omakaseList.Modify(currentRow + 1, "Select Focus")
        }
    } else {  ; Up
        if (currentRow > 1) {
            omakaseList.Modify(currentRow - 1, "Select Focus")
        }
    }
}

; Launch selected item
LaunchSelectedOmakaseItem() {
    global omakaseList, filteredOmakaseItems, omakaseGui

    selectedRow := omakaseList.GetNext()
    if (selectedRow == 0) {
        return
    }

    ; Get the item from filtered list
    if (selectedRow <= filteredOmakaseItems.Length) {
        item := filteredOmakaseItems[selectedRow]

        ; Hide omakase launcher first
        HideOmakaseLauncher()

        ; Destroy GUI so it rebuilds with fresh Amphetamine status next time
        if (omakaseGui) {
            omakaseGui.Destroy()
            omakaseGui := ""
        }

        switch item.action {
            case "quick":
                ToggleQuickLauncher()
            case "wallpaper":
                ToggleWallpaperLauncher()
            case "theme":
                ToggleThemeLauncher()
            case "help":
                ToggleHelpWindow()
            case "amphetamine":
                ToggleAmphetamine()
        }
    }
}

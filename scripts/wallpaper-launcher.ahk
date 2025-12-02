; Wallpaper Launcher - Quick wallpaper selector with fuzzy find
; Press Alt+W to open launcher

#Requires AutoHotkey v2.0
#SingleInstance Force

; Get script directory for config files
global scriptDir := A_ScriptDir

; Global variables
global wallpapers := []
global filteredWallpapers := []
global config := Map()
global launcherGui := ""
global isVisible := false
global searchBox := ""
global listView := ""
global previewPic := ""

; Wallpaper folder path (synced location)
global wallpaperPath := "C:\Users\yannick.herrero\Pictures\Wallpapers"

; Load configuration
LoadConfig()

; Load configuration from files
LoadConfig() {
    global scriptDir, wallpapers, config, wallpaperPath

    ; Load INI config
    configFile := scriptDir . "\config.ini"
    if (!FileExist(configFile)) {
        MsgBox("Config file not found: " configFile, "Error", "Icon!")
        ExitApp()
    }

    ; Read INI settings
    config["theme"] := Map(
        "background", IniRead(configFile, "Theme", "background", "1e1e2e"),
        "primary", IniRead(configFile, "Theme", "primary", "ff79c6"),
        "accent", IniRead(configFile, "Theme", "accent", "89b4fa"),
        "text", IniRead(configFile, "Theme", "text", "b4befe"),
        "muted", IniRead(configFile, "Theme", "muted", "6c7086"),
        "border", IniRead(configFile, "Theme", "border", "45475a")
    )

    config["gui"] := Map(
        "font", IniRead(configFile, "GUI", "font", "Segoe UI"),
        "fontSize", IniRead(configFile, "GUI", "fontSize", "11"),
        "titleSize", IniRead(configFile, "GUI", "titleSize", "13")
    )

    ; Scan wallpaper folder for images
    if (!DirExist(wallpaperPath)) {
        MsgBox("Wallpaper folder not found: " wallpaperPath "`n`nRun theme/sync.sh first.", "Error", "Icon!")
        ExitApp()
    }

    ; Scan for supported image formats
    imageExtensions := ["*.png", "*.jpg", "*.jpeg", "*.bmp"]
    for ext in imageExtensions {
        Loop Files, wallpaperPath . "\" . ext {
            fileName := A_LoopFileName
            ; Remove extension for display name
            displayName := RegExReplace(fileName, "\.[^.]+$", "")
            ; Replace underscores/hyphens with spaces for readability
            displayName := StrReplace(StrReplace(displayName, "_", " "), "-", " ")

            wallpapers.Push({
                name: displayName,
                fileName: fileName,
                fullPath: A_LoopFilePath
            })
        }
    }
}

; Hotkey to toggle launcher (Alt+W)
!w::ToggleLauncher()

; Function to show/hide launcher
ToggleLauncher() {
    global isVisible
    if (isVisible) {
        HideLauncher()
    } else {
        ShowLauncher()
    }
}

; Show the launcher
ShowLauncher() {
    global launcherGui, isVisible, searchBox, listView, previewPic, wallpapers, config

    ; Create GUI if it doesn't exist
    if (!launcherGui) {
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

        launcherGui := Gui("+AlwaysOnTop -Caption +Border +ToolWindow", "Wallpaper Selector")
        launcherGui.BackColor := bg
        launcherGui.SetFont("s" fontSize " c" txt, font)

        ; Add title
        launcherGui.SetFont("s" titleSize " Bold c" primary, font)
        launcherGui.Add("Text", "x20 y15 w460 Center", "Wallpaper Selector")

        ; Add instructions
        launcherGui.SetFont("s9 c" muted, font)
        launcherGui.Add("Text", "x20 y45 w460 Center", "Type to filter - Enter to set - ESC to close")

        ; Add separator
        launcherGui.Add("Text", "x20 y70 w460 h1 Background" accent)

        ; Add search box
        launcherGui.SetFont("s" fontSize " c" txt, font)
        searchBox := launcherGui.Add("Edit", "x20 y85 w460 h30 -E0x200 Background" bg " c" txt)
        searchBox.OnEvent("Change", (*) => FilterWallpapers())

        ; Add bottom border for search box
        launcherGui.Add("Text", "x20 y116 w460 h1 Background" border)

        ; Add list view with custom colors
        launcherGui.SetFont("s" fontSize " c" txt, font)
        listView := launcherGui.Add("ListView", "x20 y135 w460 h350 -Hdr -Multi -E0x200 Background" bg " c" txt, ["Name"])
        listView.OnEvent("DoubleClick", (*) => SetSelectedWallpaper())
        listView.OnEvent("ItemSelect", UpdatePreview)

        ; Add preview panel on the right
        previewPic := launcherGui.Add("Picture", "x500 y85 w380 h400 +Border Background" bg)

        ; Populate initial list
        PopulateList()

        ; Handle keyboard shortcuts
        launcherGui.OnEvent("Escape", (*) => HideLauncher())

        ; Set column width
        listView.ModifyCol(1, 440)

        ; Set up context-sensitive hotkeys
        HotIfWinActive("ahk_id " launcherGui.Hwnd)
        Hotkey("Enter", (*) => SetSelectedWallpaper(), "On")
        Hotkey("Down", (*) => MoveSelection(1), "On")
        Hotkey("Up", (*) => MoveSelection(-1), "On")
        HotIfWinActive()
    }

    ; Reset search and refresh list
    searchBox.Value := ""
    PopulateList()

    ; Center and show
    CenterWindow(launcherGui)
    launcherGui.Show()
    searchBox.Focus()
    isVisible := true
}

; Hide the launcher
HideLauncher() {
    global launcherGui, isVisible

    if (launcherGui) {
        launcherGui.Hide()
        isVisible := false
    }
}

; Populate list with wallpapers
PopulateList(filter := "") {
    global listView, wallpapers, filteredWallpapers

    listView.Delete()
    filteredWallpapers := []

    for wallpaper in wallpapers {
        ; Fuzzy match filter (name only)
        if (filter == "" || FuzzyMatch(wallpaper.name, filter)) {
            listView.Add("", wallpaper.name)
            filteredWallpapers.Push(wallpaper)
        }
    }

    ; Select first item if available and update preview
    if (listView.GetCount() > 0) {
        listView.Modify(1, "Select Focus")
        ; Manually trigger preview update for initial selection
        UpdatePreview(listView, 1, true)
    }
}

; Simple fuzzy matching
FuzzyMatch(text, pattern) {
    text := StrLower(text)
    pattern := StrLower(pattern)

    textPos := 1
    for charIndex, char in StrSplit(pattern) {
        textPos := InStr(text, char, , textPos)
        if (!textPos) {
            return false
        }
        textPos++
    }
    return true
}

; Filter wallpapers based on search
FilterWallpapers() {
    global searchBox
    filter := searchBox.Value
    PopulateList(filter)
}

; Update preview image when selection changes
UpdatePreview(LV, Item, Selected) {
    global filteredWallpapers, previewPic

    ; Only update on selection, not deselection
    if (!Selected || Item < 1 || Item > filteredWallpapers.Length)
        return

    wallpaper := filteredWallpapers[Item]
    ; Load image with aspect-ratio-preserving resize (width 380, height auto)
    previewPic.Value := "*w380 *h-1 " wallpaper.fullPath
}

; Move selection up or down
MoveSelection(direction) {
    global listView

    currentRow := listView.GetNext()
    newRow := currentRow

    if (direction > 0) {  ; Down
        if (currentRow == 0) {
            newRow := 1
        } else if (currentRow < listView.GetCount()) {
            newRow := currentRow + 1
        }
    } else {  ; Up
        if (currentRow > 1) {
            newRow := currentRow - 1
        }
    }

    if (newRow != currentRow) {
        listView.Modify(newRow, "Select Focus")
        UpdatePreview(listView, newRow, true)
    }
}

; Set selected wallpaper as desktop background
SetSelectedWallpaper() {
    global listView, filteredWallpapers

    selectedRow := listView.GetNext()
    if (selectedRow == 0) {
        return
    }

    ; Get the wallpaper from filtered list
    if (selectedRow <= filteredWallpapers.Length) {
        wallpaper := filteredWallpapers[selectedRow]

        ; Hide launcher first
        HideLauncher()

        ; Set wallpaper using Windows API
        SetWallpaper(wallpaper.fullPath)
    }
}

; Set desktop wallpaper using SystemParametersInfo
SetWallpaper(imagePath) {
    ; SPI_SETDESKWALLPAPER = 0x0014
    ; SPIF_UPDATEINIFILE = 0x01
    ; SPIF_SENDCHANGE = 0x02

    result := DllCall("SystemParametersInfoW"
        , "UInt", 0x0014        ; SPI_SETDESKWALLPAPER
        , "UInt", 0             ; Not used
        , "Str", imagePath      ; Path to wallpaper
        , "UInt", 0x01 | 0x02)  ; SPIF_UPDATEINIFILE | SPIF_SENDCHANGE

    if (!result) {
        MsgBox("Failed to set wallpaper: " imagePath, "Error", "Icon!")
    }
}

; Center window on screen
CenterWindow(guiObj) {
    guiObj.Show("Hide")
    guiObj.GetPos(, , &width, &height)

    ; Get monitor info for the active monitor
    MonitorGet(MonitorGetPrimary(), &mLeft, &mTop, &mRight, &mBottom)

    x := mLeft + (mRight - mLeft - width) // 2
    y := mTop + (mBottom - mTop - height) // 2

    guiObj.Move(x, y)
}

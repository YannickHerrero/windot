; Wallpaper Launcher - Quick wallpaper selector with fuzzy find
; Press Alt+W to open launcher

; Global variables (unique names to avoid conflicts)
global wallpapers := []
global filteredWallpapers := []
global wallpaperGui := ""
global wallpaperVisible := false
global wallpaperSearch := ""
global wallpaperList := ""
global previewPic := ""

; Wallpaper folder path (synced location)
global wallpaperPath := "C:\Users\yannick.herrero\Pictures\Wallpapers"

; Load wallpaper configuration
LoadWallpaperConfig()

; Load wallpapers from folder
LoadWallpaperConfig() {
    global scriptDir, wallpapers, config, wallpaperPath

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
!w::ToggleWallpaperLauncher()

; Function to show/hide launcher
ToggleWallpaperLauncher() {
    global wallpaperVisible
    if (wallpaperVisible) {
        HideWallpaperLauncher()
    } else {
        ShowWallpaperLauncher()
    }
}

; Show the launcher
ShowWallpaperLauncher() {
    global wallpaperGui, wallpaperVisible, wallpaperSearch, wallpaperList, previewPic, wallpapers, config

    ; Create GUI if it doesn't exist
    if (!wallpaperGui) {
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

        wallpaperGui := Gui("+AlwaysOnTop -Caption +Border +ToolWindow", "Wallpaper Selector")
        wallpaperGui.BackColor := bg
        wallpaperGui.SetFont("s" fontSize " c" txt, font)

        ; Add title
        wallpaperGui.SetFont("s" titleSize " Bold c" primary, font)
        wallpaperGui.Add("Text", "x20 y15 w460 Center", "Wallpaper Selector")

        ; Add instructions
        wallpaperGui.SetFont("s9 c" muted, font)
        wallpaperGui.Add("Text", "x20 y45 w460 Center", "Type to filter - Enter to set - ESC to close")

        ; Add separator
        wallpaperGui.Add("Text", "x20 y70 w460 h1 Background" accent)

        ; Add search box
        wallpaperGui.SetFont("s" fontSize " c" txt, font)
        wallpaperSearch := wallpaperGui.Add("Edit", "x20 y85 w460 h30 -E0x200 Background" bg " c" txt)
        wallpaperSearch.OnEvent("Change", (*) => FilterWallpapers())

        ; Add bottom border for search box
        wallpaperGui.Add("Text", "x20 y116 w460 h1 Background" border)

        ; Add list view with custom colors
        wallpaperGui.SetFont("s" fontSize " c" txt, font)
        wallpaperList := wallpaperGui.Add("ListView", "x20 y135 w460 h350 -Hdr -Multi -E0x200 Background" bg " c" txt, ["Name"])
        wallpaperList.OnEvent("DoubleClick", (*) => SetSelectedWallpaper())
        wallpaperList.OnEvent("ItemSelect", UpdateWallpaperPreview)

        ; Add preview panel on the right
        previewPic := wallpaperGui.Add("Picture", "x500 y85 w380 h400 +Border Background" bg)

        ; Populate initial list
        PopulateWallpaperList()

        ; Handle keyboard shortcuts
        wallpaperGui.OnEvent("Escape", (*) => HideWallpaperLauncher())

        ; Set column width
        wallpaperList.ModifyCol(1, 440)

        ; Set up context-sensitive hotkeys
        HotIfWinActive("ahk_id " wallpaperGui.Hwnd)
        Hotkey("Enter", (*) => SetSelectedWallpaper(), "On")
        Hotkey("Down", (*) => MoveWallpaperSelection(1), "On")
        Hotkey("Up", (*) => MoveWallpaperSelection(-1), "On")
        HotIfWinActive()
    }

    ; Reset search and refresh list
    wallpaperSearch.Value := ""
    PopulateWallpaperList()

    ; Center and show
    CenterWindow(wallpaperGui)
    wallpaperGui.Show()
    wallpaperSearch.Focus()
    wallpaperVisible := true
}

; Hide the launcher
HideWallpaperLauncher() {
    global wallpaperGui, wallpaperVisible

    if (wallpaperGui) {
        wallpaperGui.Hide()
        wallpaperVisible := false
    }
}

; Populate list with wallpapers
PopulateWallpaperList(filter := "") {
    global wallpaperList, wallpapers, filteredWallpapers

    wallpaperList.Delete()
    filteredWallpapers := []

    for wallpaper in wallpapers {
        ; Fuzzy match filter (name only)
        if (filter == "" || FuzzyMatch(wallpaper.name, filter)) {
            wallpaperList.Add("", wallpaper.name)
            filteredWallpapers.Push(wallpaper)
        }
    }

    ; Select first item if available and update preview
    if (wallpaperList.GetCount() > 0) {
        wallpaperList.Modify(1, "Select Focus")
        ; Manually trigger preview update for initial selection
        UpdateWallpaperPreview(wallpaperList, 1, true)
    }
}

; Filter wallpapers based on search
FilterWallpapers() {
    global wallpaperSearch
    filter := wallpaperSearch.Value
    PopulateWallpaperList(filter)
}

; Update preview image when selection changes
UpdateWallpaperPreview(LV, Item, Selected) {
    global filteredWallpapers, previewPic

    ; Only update on selection, not deselection
    if (!Selected || Item < 1 || Item > filteredWallpapers.Length)
        return

    wallpaper := filteredWallpapers[Item]
    ; Load image with aspect-ratio-preserving resize (width 380, height auto)
    previewPic.Value := "*w380 *h-1 " wallpaper.fullPath
}

; Move selection up or down
MoveWallpaperSelection(direction) {
    global wallpaperList

    currentRow := wallpaperList.GetNext()
    newRow := currentRow

    if (direction > 0) {  ; Down
        if (currentRow == 0) {
            newRow := 1
        } else if (currentRow < wallpaperList.GetCount()) {
            newRow := currentRow + 1
        }
    } else {  ; Up
        if (currentRow > 1) {
            newRow := currentRow - 1
        }
    }

    if (newRow != currentRow) {
        wallpaperList.Modify(newRow, "Select Focus")
        UpdateWallpaperPreview(wallpaperList, newRow, true)
    }
}

; Set selected wallpaper as desktop background
SetSelectedWallpaper() {
    global wallpaperList, filteredWallpapers

    selectedRow := wallpaperList.GetNext()
    if (selectedRow == 0) {
        return
    }

    ; Get the wallpaper from filtered list
    if (selectedRow <= filteredWallpapers.Length) {
        wallpaper := filteredWallpapers[selectedRow]

        ; Hide launcher first
        HideWallpaperLauncher()

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

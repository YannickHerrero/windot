; Terminal Launcher - Quick access to project folders in WezTerm
; Press Alt+Enter to open launcher

#Requires AutoHotkey v2.0
#SingleInstance Force

; Get script directory for config files
global scriptDir := A_ScriptDir

; Global variables
global folders := []
global config := Map()
global launcherGui := ""
global isVisible := false
global searchBox := ""
global listView := ""
global filteredFolders := []

; Load configuration
LoadConfig()

; Load configuration from files
LoadConfig() {
    global scriptDir, folders, config

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

    config["terminalExe"] := IniRead(configFile, "Terminal", "executable", "")

    ; Load folders from INI
    foldersFile := scriptDir . "\folders.ini"
    if (!FileExist(foldersFile)) {
        MsgBox("Folders config not found: " foldersFile, "Error", "Icon!")
        ExitApp()
    }

    ; Read all sections (folder names) from INI file
    sections := IniRead(foldersFile)
    for section in StrSplit(sections, "`n") {
        section := Trim(section)
        if (section != "") {
            path := IniRead(foldersFile, section, "path", "")
            displayPath := IniRead(foldersFile, section, "displayPath", "")

            if (path != "" && displayPath != "") {
                folders.Push({
                    name: section,
                    path: path,
                    displayPath: displayPath
                })
            }
        }
    }

    ; Dynamically scan dev folder and add all subdirectories
    devPath := "\\wsl.localhost\Ubuntu\home\yannick\dev"
    Loop Files, devPath . "\*", "D" {
        folderName := A_LoopFileName
        folders.Push({
            name: folderName,
            path: devPath . "\" . folderName,
            displayPath: "~/dev/" . folderName
        })
    }
}

; Hotkey to toggle launcher (Alt+Enter)
!Enter::ToggleLauncher()

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
    global launcherGui, isVisible, searchBox, listView, folders, config

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

        launcherGui := Gui("+AlwaysOnTop -Caption +Border +ToolWindow", "Terminal Launcher")
        launcherGui.BackColor := bg
        launcherGui.SetFont("s" fontSize " c" txt, font)

        ; Add title
        launcherGui.SetFont("s" titleSize " Bold c" primary, font)
        launcherGui.Add("Text", "x20 y15 w460 Center", "Terminal Launcher")

        ; Add instructions
        launcherGui.SetFont("s9 c" muted, font)
        launcherGui.Add("Text", "x20 y45 w460 Center", "Type to filter • Enter to open • ESC to close")

        ; Add separator
        launcherGui.Add("Text", "x20 y70 w460 h1 Background" accent)

        ; Add search box
        launcherGui.SetFont("s" fontSize " c" txt, font)
        searchBox := launcherGui.Add("Edit", "x20 y85 w460 h30 -E0x200 Background" bg " c" txt)
        searchBox.OnEvent("Change", (*) => FilterFolders())

        ; Add bottom border for search box
        launcherGui.Add("Text", "x20 y116 w460 h1 Background" border)

        ; Add list view with custom colors
        launcherGui.SetFont("s" fontSize " c" txt, font)
        listView := launcherGui.Add("ListView", "x20 y135 w460 h300 -Hdr -Multi -E0x200 Background" bg " c" txt, ["Name", "Path"])
        listView.OnEvent("DoubleClick", (*) => LaunchTerminal())

        ; Populate initial list
        PopulateList()

        ; Handle keyboard shortcuts
        launcherGui.OnEvent("Escape", (*) => HideLauncher())

        ; Set column widths
        listView.ModifyCol(1, 200)
        listView.ModifyCol(2, 240)

        ; Set up context-sensitive hotkeys
        HotIfWinActive("ahk_id " launcherGui.Hwnd)
        Hotkey("Enter", (*) => LaunchTerminal(), "On")
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

; Populate list with folders
PopulateList(filter := "") {
    global listView, folders, filteredFolders

    listView.Delete()
    filteredFolders := []

    for folder in folders {
        ; Fuzzy match filter (name only)
        if (filter == "" || FuzzyMatch(folder.name, filter)) {
            listView.Add("", folder.name, folder.displayPath)
            filteredFolders.Push(folder)
        }
    }

    ; Select first item if available
    if (listView.GetCount() > 0) {
        listView.Modify(1, "Select Focus")
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

; Filter folders based on search
FilterFolders() {
    global searchBox
    filter := searchBox.Value
    PopulateList(filter)
}

; Move selection up or down
MoveSelection(direction) {
    global listView

    currentRow := listView.GetNext()

    if (direction > 0) {  ; Down
        if (currentRow == 0) {
            listView.Modify(1, "Select Focus")
        } else if (currentRow < listView.GetCount()) {
            listView.Modify(currentRow + 1, "Select Focus")
        }
    } else {  ; Up
        if (currentRow > 1) {
            listView.Modify(currentRow - 1, "Select Focus")
        }
    }
}

; Launch terminal with selected folder
LaunchTerminal() {
    global listView, filteredFolders, config

    selectedRow := listView.GetNext()
    if (selectedRow == 0) {
        return
    }

    ; Get the folder from filtered list
    if (selectedRow <= filteredFolders.Length) {
        folder := filteredFolders[selectedRow]

        ; Get WezTerm executable path
        weztermExe := config["terminalExe"]

        ; If not in config, auto-detect
        if (weztermExe == "" || !FileExist(weztermExe)) {
            weztermPaths := [
                EnvGet("ProgramFiles") . "\WezTerm\wezterm-gui.exe",
                EnvGet("LocalAppData") . "\Programs\WezTerm\wezterm-gui.exe"
            ]

            weztermExe := ""
            for path in weztermPaths {
                if (FileExist(path)) {
                    weztermExe := path
                    break
                }
            }
        }

        if (!weztermExe || !FileExist(weztermExe)) {
            MsgBox("WezTerm not found!", "Error", "Icon!")
            return
        }

        ; Launch WezTerm in the folder
        Run('"' weztermExe '" start --cwd "' folder.path '"')

        ; Hide launcher
        HideLauncher()
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

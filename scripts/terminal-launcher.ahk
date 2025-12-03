; Terminal Launcher - Quick access to project folders in WezTerm
; Press Alt+Enter to open launcher

; Global variables (unique names to avoid conflicts)
global folders := []
global filteredFolders := []
global terminalGui := ""
global terminalVisible := false
global terminalSearch := ""
global terminalList := ""

; Load folder configuration
LoadTerminalConfig()

; Load folders from config files
LoadTerminalConfig() {
    global scriptDir, folders, config

    ; Read terminal executable from config
    configFile := scriptDir . "\config.ini"
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
!Enter::ToggleTerminalLauncher()

; Function to show/hide launcher
ToggleTerminalLauncher() {
    global terminalVisible
    if (terminalVisible) {
        HideTerminalLauncher()
    } else {
        ShowTerminalLauncher()
    }
}

; Show the launcher
ShowTerminalLauncher() {
    global terminalGui, terminalVisible, terminalSearch, terminalList, folders, config

    ; Create GUI if it doesn't exist
    if (!terminalGui) {
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

        terminalGui := Gui("+AlwaysOnTop -Caption +Border +ToolWindow", "Terminal Launcher")
        terminalGui.BackColor := bg
        terminalGui.SetFont("s" fontSize " c" txt, font)

        ; Add title
        terminalGui.SetFont("s" titleSize " Bold c" primary, font)
        terminalGui.Add("Text", "x20 y15 w460 Center", "Terminal Launcher")

        ; Add instructions
        terminalGui.SetFont("s9 c" muted, font)
        terminalGui.Add("Text", "x20 y45 w460 Center", "Type to filter • Enter to open • ESC to close")

        ; Add separator
        terminalGui.Add("Text", "x20 y70 w460 h1 Background" accent)

        ; Add search box
        terminalGui.SetFont("s" fontSize " c" txt, font)
        terminalSearch := terminalGui.Add("Edit", "x20 y85 w460 h30 -E0x200 Background" bg " c" txt)
        terminalSearch.OnEvent("Change", (*) => FilterTerminalFolders())

        ; Add bottom border for search box
        terminalGui.Add("Text", "x20 y116 w460 h1 Background" border)

        ; Add list view with custom colors
        terminalGui.SetFont("s" fontSize " c" txt, font)
        terminalList := terminalGui.Add("ListView", "x20 y135 w460 h300 -Hdr -Multi -E0x200 Background" bg " c" txt, ["Name", "Path"])
        terminalList.OnEvent("DoubleClick", (*) => LaunchTerminal())

        ; Populate initial list
        PopulateTerminalList()

        ; Handle keyboard shortcuts
        terminalGui.OnEvent("Escape", (*) => HideTerminalLauncher())

        ; Set column widths
        terminalList.ModifyCol(1, 200)
        terminalList.ModifyCol(2, 240)

        ; Set up context-sensitive hotkeys
        HotIfWinActive("ahk_id " terminalGui.Hwnd)
        Hotkey("Enter", (*) => LaunchTerminal(), "On")
        Hotkey("Down", (*) => MoveTerminalSelection(1), "On")
        Hotkey("Up", (*) => MoveTerminalSelection(-1), "On")
        HotIfWinActive()
    }

    ; Reset search and refresh list
    terminalSearch.Value := ""
    PopulateTerminalList()

    ; Center and show
    CenterWindow(terminalGui)
    terminalGui.Show()
    terminalSearch.Focus()
    terminalVisible := true
}

; Hide the launcher
HideTerminalLauncher() {
    global terminalGui, terminalVisible

    if (terminalGui) {
        terminalGui.Hide()
        terminalVisible := false
    }
}

; Populate list with folders
PopulateTerminalList(filter := "") {
    global terminalList, folders, filteredFolders

    terminalList.Delete()
    filteredFolders := []

    for folder in folders {
        ; Fuzzy match filter (name only)
        if (filter == "" || FuzzyMatch(folder.name, filter)) {
            terminalList.Add("", folder.name, folder.displayPath)
            filteredFolders.Push(folder)
        }
    }

    ; Select first item if available
    if (terminalList.GetCount() > 0) {
        terminalList.Modify(1, "Select Focus")
    }
}

; Filter folders based on search
FilterTerminalFolders() {
    global terminalSearch
    filter := terminalSearch.Value
    PopulateTerminalList(filter)
}

; Move selection up or down
MoveTerminalSelection(direction) {
    global terminalList

    currentRow := terminalList.GetNext()

    if (direction > 0) {  ; Down
        if (currentRow == 0) {
            terminalList.Modify(1, "Select Focus")
        } else if (currentRow < terminalList.GetCount()) {
            terminalList.Modify(currentRow + 1, "Select Focus")
        }
    } else {  ; Up
        if (currentRow > 1) {
            terminalList.Modify(currentRow - 1, "Select Focus")
        }
    }
}

; Launch terminal with selected folder
LaunchTerminal() {
    global terminalList, filteredFolders, config

    selectedRow := terminalList.GetNext()
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
        HideTerminalLauncher()
    }
}

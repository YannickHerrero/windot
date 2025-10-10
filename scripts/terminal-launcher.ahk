; Terminal Launcher - Quick access to project folders in WezTerm
; Press Alt+Enter to open launcher

#Requires AutoHotkey v2.0
#SingleInstance Force

; Configuration - Add your project folders here (sorted by displayPath length)
global folders := [
    {name: "Home", path: "\\wsl.localhost\Ubuntu\home\yannick", displayPath: "~/"},
    {name: "Notes", path: "\\wsl.localhost\Ubuntu\home\yannick\dev\notes", displayPath: "~/dev/notes"},
    {name: "Dev Environment", path: "\\wsl.localhost\Ubuntu\home\yannick\dev\dev-env", displayPath: "~/dev/dev-env"},
    {name: "Dotfiles", path: "\\wsl.localhost\Ubuntu\home\yannick\dev\dotfiles", displayPath: "~/dev/dotfiles"},
    {name: "Omarchy", path: "\\wsl.localhost\Ubuntu\home\yannick\dev\omarchy", displayPath: "~/dev/omarchy"},
    {name: "Test MSAL", path: "\\wsl.localhost\Ubuntu\home\yannick\dev\test-msal", displayPath: "~/dev/test-msal"},
    {name: "Chocofi ZMK", path: "\\wsl.localhost\Ubuntu\home\yannick\dev\chocofi-zmk", displayPath: "~/dev/chocofi-zmk"},
    {name: "Idisko App", path: "\\wsl.localhost\Ubuntu\home\yannick\dev\idisko-app", displayPath: "~/dev/idisko-app"},
    {name: "Idisko Next", path: "\\wsl.localhost\Ubuntu\home\yannick\dev\idisko_next", displayPath: "~/dev/idisko_next"},
    {name: "Portail GED", path: "\\wsl.localhost\Ubuntu\home\yannick\dev\portail-ged", displayPath: "~/dev/portail-ged"},
    {name: "Idisko Jamendo", path: "\\wsl.localhost\Ubuntu\home\yannick\dev\idisko-jamendo", displayPath: "~/dev/idisko-jamendo"},
    {name: "UXCO Portail Locataire", path: "\\wsl.localhost\Ubuntu\home\yannick\dev\uxco-portail-locataire", displayPath: "~/dev/uxco-portail-locataire"},
    {name: "Windows Home", path: "C:\Users\yannick.herrero", displayPath: "/mnt/c/Users/yannick.herrero"},
    {name: "Domofinance iOS", path: "\\wsl.localhost\Ubuntu\home\yannick\dev\domofinance-domosimu-ios", displayPath: "~/dev/domofinance-domosimu-ios"},
    {name: "UXCO Ansible", path: "\\wsl.localhost\Ubuntu\home\yannick\dev\uxco-portail-locataire-ansible", displayPath: "~/dev/uxco-portail-locataire-ansible"},
    {name: "Windot", path: "C:\Users\yannick.herrero\windot", displayPath: "/mnt/c/Users/yannick.herrero/windot"},
    {name: "Scripts", path: "C:\Users\yannick.herrero\scripts", displayPath: "/mnt/c/Users/yannick.herrero/scripts"},
    {name: "Domofinance RN", path: "\\wsl.localhost\Ubuntu\home\yannick\dev\domofinance-domosimu-react-native", displayPath: "~/dev/domofinance-domosimu-react-native"},
]

; Global variables
global launcherGui := ""
global isVisible := false
global searchBox := ""
global listView := ""
global filteredFolders := []

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
    global launcherGui, isVisible, searchBox, listView, folders

    ; Create GUI if it doesn't exist
    if (!launcherGui) {
        launcherGui := Gui("+AlwaysOnTop -Caption +Border +ToolWindow", "Terminal Launcher")
        launcherGui.BackColor := "1e1e2e"
        launcherGui.SetFont("s11 cb4befe", "Segoe UI")

        ; Add title
        launcherGui.SetFont("s13 Bold cff79c6", "Segoe UI")
        launcherGui.Add("Text", "x20 y15 w460 Center", "Terminal Launcher")

        ; Add instructions
        launcherGui.SetFont("s9 c6c7086", "Segoe UI")
        launcherGui.Add("Text", "x20 y45 w460 Center", "Type to filter • Enter to open • ESC to close")

        ; Add separator
        launcherGui.Add("Text", "x20 y70 w460 h1 Background89b4fa")

        ; Add search box
        launcherGui.SetFont("s11 cb4befe", "Segoe UI")
        searchBox := launcherGui.Add("Edit", "x20 y85 w460 h30 -E0x200 Background1e1e2e cb4befe")
        searchBox.OnEvent("Change", (*) => FilterFolders())

        ; Add bottom border for search box
        launcherGui.Add("Text", "x20 y116 w460 h1 Background45475a")

        ; Add list view with custom colors
        launcherGui.SetFont("s11 cb4befe", "Segoe UI")
        listView := launcherGui.Add("ListView", "x20 y135 w460 h300 -Hdr -Multi -E0x200 Background1e1e2e cb4befe", ["Name", "Path"])
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
    global listView, filteredFolders

    selectedRow := listView.GetNext()
    if (selectedRow == 0) {
        return
    }

    ; Get the folder from filtered list
    if (selectedRow <= filteredFolders.Length) {
        folder := filteredFolders[selectedRow]

        ; Find WezTerm executable
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

        if (!weztermExe) {
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

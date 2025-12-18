; System Launcher - Power options menu with fuzzy find
; Accessed via Omakase Launcher

; Global variables (unique names to avoid conflicts)
global systemActions := []
global filteredSystemActions := []
global systemGui := ""
global systemVisible := false
global systemSearch := ""
global systemList := ""

; Build system actions array
BuildSystemActions() {
    global systemActions

    systemActions := []

    systemActions.Push({
        name: "Shut Down",
        displayName: "Shut Down",
        action: "shutdown"
    })

    systemActions.Push({
        name: "Restart",
        displayName: "Restart",
        action: "restart"
    })

    systemActions.Push({
        name: "Hibernate",
        displayName: "Hibernate",
        action: "hibernate"
    })
}

; Register theme change callback to recreate GUI with new colors
RegisterThemeChangeCallback(OnSystemLauncherThemeChange)

OnSystemLauncherThemeChange() {
    global systemGui, systemVisible
    if (systemGui) {
        systemGui.Destroy()
        systemGui := ""
        systemVisible := false
    }
}

; Function to show/hide launcher
ToggleSystemLauncher() {
    global systemVisible
    if (systemVisible) {
        HideSystemLauncher()
    } else {
        ShowSystemLauncher()
    }
}

; Show the launcher
ShowSystemLauncher() {
    global systemGui, systemVisible, systemSearch, systemList, systemActions, config

    ; Build actions list
    BuildSystemActions()

    ; Create GUI if it doesn't exist
    if (!systemGui) {
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

        systemGui := Gui("+AlwaysOnTop -Caption +Border +ToolWindow", "System")
        systemGui.BackColor := bg
        systemGui.SetFont("s" fontSize " c" txt, font)

        ; Add title
        systemGui.SetFont("s" titleSize " Bold c" primary, font)
        systemGui.Add("Text", "x20 y15 w360 Center", "System")

        ; Add instructions
        systemGui.SetFont("s9 c" muted, font)
        systemGui.Add("Text", "x20 y45 w360 Center", "Enter to select - ESC to close")

        ; Add separator
        systemGui.Add("Text", "x20 y70 w360 h1 Background" accent)

        ; Add search box
        systemGui.SetFont("s" fontSize " c" txt, font)
        systemSearch := systemGui.Add("Edit", "x20 y85 w360 h30 -E0x200 Background" bg " c" txt)
        systemSearch.OnEvent("Change", (*) => FilterSystemActions())

        ; Add bottom border for search box
        systemGui.Add("Text", "x20 y116 w360 h1 Background" border)

        ; Add list view with custom colors
        systemGui.SetFont("s" fontSize " c" txt, font)
        systemList := systemGui.Add("ListView", "x20 y135 w360 h120 -Hdr -Multi -E0x200 Background" bg " c" txt, ["Name"])
        systemList.OnEvent("DoubleClick", (*) => ExecuteSelectedSystemAction())

        ; Populate initial list
        PopulateSystemList()

        ; Handle keyboard shortcuts
        systemGui.OnEvent("Escape", (*) => HideSystemLauncher())

        ; Set column width
        systemList.ModifyCol(1, 340)

        ; Set up context-sensitive hotkeys
        HotIfWinActive("ahk_id " systemGui.Hwnd)
        Hotkey("Enter", (*) => ExecuteSelectedSystemAction(), "On")
        Hotkey("Down", (*) => MoveSystemSelection(1), "On")
        Hotkey("Up", (*) => MoveSystemSelection(-1), "On")
        HotIfWinActive()
    }

    ; Reset search and refresh list
    systemSearch.Value := ""
    PopulateSystemList()

    ; Center and show
    CenterWindow(systemGui)
    systemGui.Show()
    systemSearch.Focus()
    systemVisible := true
}

; Hide the launcher
HideSystemLauncher() {
    global systemGui, systemVisible

    if (systemGui) {
        systemGui.Hide()
        systemVisible := false
    }
}

; Populate list with system actions
PopulateSystemList(filter := "") {
    global systemList, systemActions, filteredSystemActions

    systemList.Delete()
    filteredSystemActions := []

    for item in systemActions {
        ; Fuzzy match filter (name only)
        if (filter == "" || FuzzyMatch(item.name, filter)) {
            systemList.Add("", item.displayName)
            filteredSystemActions.Push(item)
        }
    }

    ; Select first item if available
    if (systemList.GetCount() > 0) {
        systemList.Modify(1, "Select Focus")
    }
}

; Filter actions based on search
FilterSystemActions() {
    global systemSearch
    filter := systemSearch.Value
    PopulateSystemList(filter)
}

; Move selection up or down
MoveSystemSelection(direction) {
    global systemList

    currentRow := systemList.GetNext()

    if (direction > 0) {  ; Down
        if (currentRow == 0) {
            systemList.Modify(1, "Select Focus")
        } else if (currentRow < systemList.GetCount()) {
            systemList.Modify(currentRow + 1, "Select Focus")
        }
    } else {  ; Up
        if (currentRow > 1) {
            systemList.Modify(currentRow - 1, "Select Focus")
        }
    }
}

; Execute selected system action
ExecuteSelectedSystemAction() {
    global systemList, filteredSystemActions, systemGui

    selectedRow := systemList.GetNext()
    if (selectedRow == 0) {
        return
    }

    ; Get the action from filtered list
    if (selectedRow <= filteredSystemActions.Length) {
        item := filteredSystemActions[selectedRow]

        ; Hide launcher first
        HideSystemLauncher()

        ; Destroy GUI so it rebuilds next time
        if (systemGui) {
            systemGui.Destroy()
            systemGui := ""
        }

        switch item.action {
            case "shutdown":
                Run("shutdown /s /t 0", , "Hide")
            case "restart":
                Run("shutdown /r /t 0", , "Hide")
            case "hibernate":
                Run("shutdown /h", , "Hide")
        }
    }
}

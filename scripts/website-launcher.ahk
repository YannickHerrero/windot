; Website Launcher - Quick access to web apps with fuzzy find
; Press Alt+Space to open launcher

#Requires AutoHotkey v2.0
#SingleInstance Force

; Get script directory for config files
global scriptDir := A_ScriptDir

; Global variables
global websites := []
global filteredWebsites := []
global config := Map()
global launcherGui := ""
global isVisible := false
global searchBox := ""
global listView := ""

; Load configuration
LoadConfig()

; Load configuration from files
LoadConfig() {
    global scriptDir, websites, config

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

    config["browserExe"] := IniRead(configFile, "Browser", "executable", "")

    ; Load websites from INI
    websitesFile := scriptDir . "\websites.ini"
    if (!FileExist(websitesFile)) {
        MsgBox("Websites config not found: " websitesFile, "Error", "Icon!")
        ExitApp()
    }

    ; Read all sections (keys) from INI file
    sections := IniRead(websitesFile)
    for section in StrSplit(sections, "`n") {
        section := Trim(section)
        if (section != "") {
            name := IniRead(websitesFile, section, "name", "")
            url := IniRead(websitesFile, section, "url", "")

            if (name != "" && url != "") {
                websites.Push({
                    name: name,
                    displayName: name,
                    url: url,
                    type: "chrome"
                })
            }
        }
    }

    ; Scan Firefox Web Apps folder
    firefoxAppsPath := "C:\Users\yannick.herrero\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Firefox Web Apps"
    if (DirExist(firefoxAppsPath)) {
        Loop Files, firefoxAppsPath . "\*.lnk" {
            appName := RegExReplace(A_LoopFileName, "\.lnk$", "")
            websites.Push({
                name: appName,
                displayName: "[FF] " . appName,
                url: A_LoopFilePath,
                type: "firefox"
            })
        }
    }

    ; Add clipboard entry as searchable item
    websites.Push({
        name: "Paste from Clipboard",
        displayName: "[📋] Paste from Clipboard",
        url: "",
        type: "clipboard"
    })
}

; Hotkey to toggle launcher (Alt+Space)
!Space::ToggleLauncher()

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
    global launcherGui, isVisible, searchBox, listView, websites, config

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

        launcherGui := Gui("+AlwaysOnTop -Caption +Border +ToolWindow", "Website Launcher")
        launcherGui.BackColor := bg
        launcherGui.SetFont("s" fontSize " c" txt, font)

        ; Add title
        launcherGui.SetFont("s" titleSize " Bold c" primary, font)
        launcherGui.Add("Text", "x20 y15 w460 Center", "Quick Launch")

        ; Add instructions
        launcherGui.SetFont("s9 c" muted, font)
        launcherGui.Add("Text", "x20 y45 w460 Center", "Type to filter • Enter to open • ESC to close")

        ; Add separator
        launcherGui.Add("Text", "x20 y70 w460 h1 Background" accent)

        ; Add search box
        launcherGui.SetFont("s" fontSize " c" txt, font)
        searchBox := launcherGui.Add("Edit", "x20 y85 w460 h30 -E0x200 Background" bg " c" txt)
        searchBox.OnEvent("Change", (*) => FilterWebsites())

        ; Add bottom border for search box
        launcherGui.Add("Text", "x20 y116 w460 h1 Background" border)

        ; Add list view with custom colors
        launcherGui.SetFont("s" fontSize " c" txt, font)
        listView := launcherGui.Add("ListView", "x20 y135 w460 h300 -Hdr -Multi -E0x200 Background" bg " c" txt, ["Name"])
        listView.OnEvent("DoubleClick", (*) => LaunchSelected())

        ; Populate initial list
        PopulateList()

        ; Handle keyboard shortcuts
        launcherGui.OnEvent("Escape", (*) => HideLauncher())

        ; Set column width
        listView.ModifyCol(1, 440)

        ; Set up context-sensitive hotkeys
        HotIfWinActive("ahk_id " launcherGui.Hwnd)
        Hotkey("Enter", (*) => LaunchSelected(), "On")
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

; Populate list with websites
PopulateList(filter := "") {
    global listView, websites, filteredWebsites

    listView.Delete()
    filteredWebsites := []

    for site in websites {
        ; Fuzzy match filter (name only)
        if (filter == "" || FuzzyMatch(site.name, filter)) {
            listView.Add("", site.displayName)
            filteredWebsites.Push(site)
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

; Filter websites based on search
FilterWebsites() {
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

; Launch selected website/app
LaunchSelected() {
    global listView, filteredWebsites, config

    selectedRow := listView.GetNext()
    if (selectedRow == 0) {
        return
    }

    ; Get the site from filtered list
    if (selectedRow <= filteredWebsites.Length) {
        site := filteredWebsites[selectedRow]

        ; Hide launcher first
        HideLauncher()

        if (site.type == "clipboard") {
            LaunchFromClipboard()
        } else if (site.type == "firefox") {
            ; Run the .lnk shortcut directly
            Run(site.url)
        } else {
            ; Chrome app mode for websites.ini entries
            LaunchWebsite(site.url)
        }
    }
}

; Launch website in Chrome app mode
LaunchWebsite(url) {
    global config

    ; Get Chrome executable path
    chromeExe := config["browserExe"]

    ; If not in config, auto-detect
    if (chromeExe == "" || !FileExist(chromeExe)) {
        browserPaths := [
            ; Chrome (prioritized)
            EnvGet("ProgramFiles") . "\Google\Chrome\Application\chrome.exe",
            EnvGet("ProgramFiles(x86)") . "\Google\Chrome\Application\chrome.exe",
            EnvGet("LocalAppData") . "\Google\Chrome\Application\chrome.exe",
            ; Vivaldi
            EnvGet("LocalAppData") . "\Vivaldi\Application\vivaldi.exe",
            ; Brave
            EnvGet("ProgramFiles") . "\BraveSoftware\Brave-Browser\Application\brave.exe",
            EnvGet("LocalAppData") . "\BraveSoftware\Brave-Browser\Application\brave.exe",
            ; Edge
            EnvGet("ProgramFiles(x86)") . "\Microsoft\Edge\Application\msedge.exe"
        ]

        chromeExe := ""
        for path in browserPaths {
            if (FileExist(path)) {
                chromeExe := path
                break
            }
        }
    }

    if (!chromeExe || !FileExist(chromeExe)) {
        MsgBox("No Chromium-based browser found! Please set the path in config.ini", "Error", "Icon!")
        return
    }

    ; Launch browser in app mode
    Run('"' chromeExe '" --app="' url '"')
}

; Launch URL from clipboard in app mode
LaunchFromClipboard() {
    ; Get clipboard content
    clipContent := A_Clipboard

    ; Basic URL validation (starts with http:// or https://)
    if (!RegExMatch(clipContent, "^https?://")) {
        MsgBox("Clipboard does not contain a valid URL", "Error", "Icon!")
        return
    }

    ; Launch using existing function
    LaunchWebsite(clipContent)
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

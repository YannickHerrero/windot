; Quick Launcher - Unified launcher for websites, apps, folders, and terminal paths
; Press Alt+Space to open launcher

; Global variables (unique names to avoid conflicts)
global items := []
global filteredItems := []
global launcherGui := ""
global launcherVisible := false
global launcherSearch := ""
global launcherList := ""

; Load launcher configuration
LoadLauncherConfig()

; Load items from config files
LoadLauncherConfig() {
    global scriptDir, items, config

    ; Read executables from config
    configFile := scriptDir . "\config\config.ini"
    config["browserExe"] := IniRead(configFile, "Browser", "executable", "")
    config["terminalExe"] := IniRead(configFile, "Terminal", "executable", "")

    ; Load websites from web.ini
    LoadWebsites()

    ; Load applications from apps.ini
    LoadApps()

    ; Load folders from folders.ini
    LoadFolders()

    ; Load terminal paths from terminal.ini
    LoadTerminalPaths()

    ; Auto-scan ~/dev/ for terminal entries
    ScanDevFolder()

    ; Scan Firefox Web Apps folder
    LoadFirefoxApps()

    ; Add clipboard entry as searchable item
    items.Push({
        name: "Paste from Clipboard",
        displayName: "[Clipboard] Paste from Clipboard",
        url: "",
        type: "clipboard"
    })

    ; Add theme switcher entry
    items.Push({
        name: "Theme Switcher",
        displayName: "[System] Theme Switcher",
        url: "",
        type: "theme"
    })
}

; Load websites from web.ini
LoadWebsites() {
    global scriptDir, items

    webFile := scriptDir . "\config\web.ini"
    if (!FileExist(webFile)) {
        return
    }

    sections := IniRead(webFile)
    for section in StrSplit(sections, "`n") {
        section := Trim(section)
        if (section != "") {
            name := IniRead(webFile, section, "name", "")
            url := IniRead(webFile, section, "url", "")

            if (name != "" && url != "") {
                items.Push({
                    name: name,
                    displayName: "[CHR] " . name,
                    url: url,
                    type: "web"
                })
            }
        }
    }
}

; Load applications from apps.ini
LoadApps() {
    global scriptDir, items

    appsFile := scriptDir . "\config\apps.ini"
    if (!FileExist(appsFile)) {
        return
    }

    sections := IniRead(appsFile)
    for section in StrSplit(sections, "`n") {
        section := Trim(section)
        if (section != "") {
            name := IniRead(appsFile, section, "name", "")
            path := IniRead(appsFile, section, "path", "")
            vault := IniRead(appsFile, section, "vault", "")

            if (name != "") {
                items.Push({
                    name: name,
                    displayName: "[App] " . name,
                    path: path,
                    vault: vault,
                    type: "app"
                })
            }
        }
    }
}

; Load folders from folders.ini
LoadFolders() {
    global scriptDir, items

    foldersFile := scriptDir . "\config\folders.ini"
    if (!FileExist(foldersFile)) {
        return
    }

    sections := IniRead(foldersFile)
    for section in StrSplit(sections, "`n") {
        section := Trim(section)
        if (section != "") {
            name := IniRead(foldersFile, section, "name", "")
            path := IniRead(foldersFile, section, "path", "")

            if (name != "" && path != "") {
                items.Push({
                    name: name,
                    displayName: "[Folder] " . name,
                    path: ExpandUserPath(path),
                    type: "folder"
                })
            }
        }
    }
}

; Load terminal paths from terminal.ini
LoadTerminalPaths() {
    global scriptDir, items

    terminalFile := scriptDir . "\config\terminal.ini"
    if (!FileExist(terminalFile)) {
        return
    }

    sections := IniRead(terminalFile)
    for section in StrSplit(sections, "`n") {
        section := Trim(section)
        if (section != "") {
            name := IniRead(terminalFile, section, "name", "")
            path := IniRead(terminalFile, section, "path", "")
            displayPath := IniRead(terminalFile, section, "displayPath", "")

            if (name != "" && path != "") {
                expandedDisplayPath := displayPath != "" ? ExpandUserPath(displayPath) : ""
                displayName := "[T] " . name
                if (expandedDisplayPath != "") {
                    displayName .= " (" . expandedDisplayPath . ")"
                }
                items.Push({
                    name: name,
                    displayName: displayName,
                    path: ExpandUserPath(path),
                    type: "terminal"
                })
            }
        }
    }
}

; Auto-scan ~/dev/ folder for terminal entries
ScanDevFolder() {
    global items

    devPath := "\\wsl.localhost\Ubuntu\home\" . WSL_USER . "\dev"
    if (!DirExist(devPath)) {
        return
    }

    Loop Files, devPath . "\*", "D" {
        folderName := A_LoopFileName
        items.Push({
            name: folderName,
            displayName: "[T] " . folderName . " (~/dev/" . folderName . ")",
            path: devPath . "\" . folderName,
            type: "terminal"
        })
    }
}

; Load Firefox Web Apps
LoadFirefoxApps() {
    global items

    firefoxAppsPath := "C:\Users\" . WIN_USER . "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Firefox Web Apps"
    if (!DirExist(firefoxAppsPath)) {
        return
    }

    Loop Files, firefoxAppsPath . "\*.lnk" {
        appName := RegExReplace(A_LoopFileName, "\.lnk$", "")
        items.Push({
            name: appName,
            displayName: "[FF] " . appName,
            url: A_LoopFilePath,
            type: "firefox"
        })
    }
}

; Function to show/hide launcher
ToggleQuickLauncher() {
    global launcherVisible
    if (launcherVisible) {
        HideQuickLauncher()
    } else {
        ShowQuickLauncher()
    }
}

; Show the launcher
ShowQuickLauncher() {
    global launcherGui, launcherVisible, launcherSearch, launcherList, items, config

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

        launcherGui := Gui("+AlwaysOnTop -Caption +Border +ToolWindow", "Quick Launcher")
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
        launcherSearch := launcherGui.Add("Edit", "x20 y85 w460 h30 -E0x200 Background" bg " c" txt)
        launcherSearch.OnEvent("Change", (*) => FilterItems())

        ; Add bottom border for search box
        launcherGui.Add("Text", "x20 y116 w460 h1 Background" border)

        ; Add list view with custom colors
        launcherGui.SetFont("s" fontSize " c" txt, font)
        launcherList := launcherGui.Add("ListView", "x20 y135 w460 h300 -Hdr -Multi -E0x200 Background" bg " c" txt, ["Name"])
        launcherList.OnEvent("DoubleClick", (*) => LaunchSelectedItem())

        ; Populate initial list
        PopulateLauncherList()

        ; Handle keyboard shortcuts
        launcherGui.OnEvent("Escape", (*) => HideQuickLauncher())

        ; Set column width
        launcherList.ModifyCol(1, 440)

        ; Set up context-sensitive hotkeys
        HotIfWinActive("ahk_id " launcherGui.Hwnd)
        Hotkey("Enter", (*) => LaunchSelectedItem(), "On")
        Hotkey("Down", (*) => MoveLauncherSelection(1), "On")
        Hotkey("Up", (*) => MoveLauncherSelection(-1), "On")
        HotIfWinActive()
    }

    ; Reset search and refresh list
    launcherSearch.Value := ""
    PopulateLauncherList()

    ; Center and show
    CenterWindow(launcherGui)
    launcherGui.Show()
    launcherSearch.Focus()
    launcherVisible := true
}

; Hide the launcher
HideQuickLauncher() {
    global launcherGui, launcherVisible

    if (launcherGui) {
        launcherGui.Hide()
        launcherVisible := false
    }
}

; Populate list with items
PopulateLauncherList(filter := "") {
    global launcherList, items, filteredItems

    launcherList.Delete()
    filteredItems := []

    for item in items {
        ; Fuzzy match filter (name only)
        if (filter == "" || FuzzyMatch(item.name, filter)) {
            launcherList.Add("", item.displayName)
            filteredItems.Push(item)
        }
    }

    ; Select first item if available
    if (launcherList.GetCount() > 0) {
        launcherList.Modify(1, "Select Focus")
    }
}

; Filter items based on search
FilterItems() {
    global launcherSearch
    filter := launcherSearch.Value
    PopulateLauncherList(filter)
}

; Move selection up or down
MoveLauncherSelection(direction) {
    global launcherList

    currentRow := launcherList.GetNext()

    if (direction > 0) {  ; Down
        if (currentRow == 0) {
            launcherList.Modify(1, "Select Focus")
        } else if (currentRow < launcherList.GetCount()) {
            launcherList.Modify(currentRow + 1, "Select Focus")
        }
    } else {  ; Up
        if (currentRow > 1) {
            launcherList.Modify(currentRow - 1, "Select Focus")
        }
    }
}

; Launch selected item
LaunchSelectedItem() {
    global launcherList, filteredItems, config

    selectedRow := launcherList.GetNext()
    if (selectedRow == 0) {
        return
    }

    ; Get the item from filtered list
    if (selectedRow <= filteredItems.Length) {
        item := filteredItems[selectedRow]

        ; Hide launcher first
        HideQuickLauncher()

        switch item.type {
            case "web":
                LaunchWebsite(item.url)
            case "firefox":
                Run(item.url)
            case "clipboard":
                LaunchFromClipboard()
            case "app":
                LaunchApplication(item)
            case "folder":
                LaunchFolder(item.path)
            case "terminal":
                LaunchTerminal(item)
            case "theme":
                ToggleThemeLauncher()
        }
    }
}

; Launch application
LaunchApplication(item) {
    ; Special handling for Obsidian with vault
    if (item.HasProp("vault") && item.vault != "") {
        Run("obsidian://open?vault=" . item.vault)
        return
    }

    ; Generic app launch
    if (item.path != "") {
        Run(item.path)
    }
}

; Launch folder in File Explorer
LaunchFolder(folderPath) {
    Run('explorer.exe "' folderPath '"')
}

; Launch terminal with selected path
LaunchTerminal(item) {
    global config

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
    Run('"' weztermExe '" start --cwd "' item.path '"')
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

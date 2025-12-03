; Website Launcher - Quick access to web apps with fuzzy find
; Press Alt+Space to open launcher

; Global variables (unique names to avoid conflicts)
global websites := []
global filteredWebsites := []
global websiteGui := ""
global websiteVisible := false
global websiteSearch := ""
global websiteList := ""

; Load website configuration
LoadWebsiteConfig()

; Load websites from config files
LoadWebsiteConfig() {
    global scriptDir, websites, config

    ; Read browser executable from config
    configFile := scriptDir . "\config.ini"
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
        displayName: "[clipboard] Paste from Clipboard",
        url: "",
        type: "clipboard"
    })
}

; Hotkey to toggle launcher (Alt+Space)
!Space::ToggleWebsiteLauncher()

; Function to show/hide launcher
ToggleWebsiteLauncher() {
    global websiteVisible
    if (websiteVisible) {
        HideWebsiteLauncher()
    } else {
        ShowWebsiteLauncher()
    }
}

; Show the launcher
ShowWebsiteLauncher() {
    global websiteGui, websiteVisible, websiteSearch, websiteList, websites, config

    ; Create GUI if it doesn't exist
    if (!websiteGui) {
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

        websiteGui := Gui("+AlwaysOnTop -Caption +Border +ToolWindow", "Website Launcher")
        websiteGui.BackColor := bg
        websiteGui.SetFont("s" fontSize " c" txt, font)

        ; Add title
        websiteGui.SetFont("s" titleSize " Bold c" primary, font)
        websiteGui.Add("Text", "x20 y15 w460 Center", "Quick Launch")

        ; Add instructions
        websiteGui.SetFont("s9 c" muted, font)
        websiteGui.Add("Text", "x20 y45 w460 Center", "Type to filter • Enter to open • ESC to close")

        ; Add separator
        websiteGui.Add("Text", "x20 y70 w460 h1 Background" accent)

        ; Add search box
        websiteGui.SetFont("s" fontSize " c" txt, font)
        websiteSearch := websiteGui.Add("Edit", "x20 y85 w460 h30 -E0x200 Background" bg " c" txt)
        websiteSearch.OnEvent("Change", (*) => FilterWebsites())

        ; Add bottom border for search box
        websiteGui.Add("Text", "x20 y116 w460 h1 Background" border)

        ; Add list view with custom colors
        websiteGui.SetFont("s" fontSize " c" txt, font)
        websiteList := websiteGui.Add("ListView", "x20 y135 w460 h300 -Hdr -Multi -E0x200 Background" bg " c" txt, ["Name"])
        websiteList.OnEvent("DoubleClick", (*) => LaunchSelectedWebsite())

        ; Populate initial list
        PopulateWebsiteList()

        ; Handle keyboard shortcuts
        websiteGui.OnEvent("Escape", (*) => HideWebsiteLauncher())

        ; Set column width
        websiteList.ModifyCol(1, 440)

        ; Set up context-sensitive hotkeys
        HotIfWinActive("ahk_id " websiteGui.Hwnd)
        Hotkey("Enter", (*) => LaunchSelectedWebsite(), "On")
        Hotkey("Down", (*) => MoveWebsiteSelection(1), "On")
        Hotkey("Up", (*) => MoveWebsiteSelection(-1), "On")
        HotIfWinActive()
    }

    ; Reset search and refresh list
    websiteSearch.Value := ""
    PopulateWebsiteList()

    ; Center and show
    CenterWindow(websiteGui)
    websiteGui.Show()
    websiteSearch.Focus()
    websiteVisible := true
}

; Hide the launcher
HideWebsiteLauncher() {
    global websiteGui, websiteVisible

    if (websiteGui) {
        websiteGui.Hide()
        websiteVisible := false
    }
}

; Populate list with websites
PopulateWebsiteList(filter := "") {
    global websiteList, websites, filteredWebsites

    websiteList.Delete()
    filteredWebsites := []

    for site in websites {
        ; Fuzzy match filter (name only)
        if (filter == "" || FuzzyMatch(site.name, filter)) {
            websiteList.Add("", site.displayName)
            filteredWebsites.Push(site)
        }
    }

    ; Select first item if available
    if (websiteList.GetCount() > 0) {
        websiteList.Modify(1, "Select Focus")
    }
}

; Filter websites based on search
FilterWebsites() {
    global websiteSearch
    filter := websiteSearch.Value
    PopulateWebsiteList(filter)
}

; Move selection up or down
MoveWebsiteSelection(direction) {
    global websiteList

    currentRow := websiteList.GetNext()

    if (direction > 0) {  ; Down
        if (currentRow == 0) {
            websiteList.Modify(1, "Select Focus")
        } else if (currentRow < websiteList.GetCount()) {
            websiteList.Modify(currentRow + 1, "Select Focus")
        }
    } else {  ; Up
        if (currentRow > 1) {
            websiteList.Modify(currentRow - 1, "Select Focus")
        }
    }
}

; Launch selected website/app
LaunchSelectedWebsite() {
    global websiteList, filteredWebsites, config

    selectedRow := websiteList.GetNext()
    if (selectedRow == 0) {
        return
    }

    ; Get the site from filtered list
    if (selectedRow <= filteredWebsites.Length) {
        site := filteredWebsites[selectedRow]

        ; Hide launcher first
        HideWebsiteLauncher()

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

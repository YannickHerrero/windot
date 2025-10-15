; Website Launcher - Quick access to web apps in Chrome app mode
; Press Alt+Space to open launcher

#Requires AutoHotkey v2.0
#SingleInstance Force

; Get script directory for config files
global scriptDir := A_ScriptDir

; Global variables
global websites := Map()
global config := Map()
global launcherGui := ""
global isVisible := false

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
                websites[section] := {
                    name: name,
                    url: url
                }
            }
        }
    }
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
    global launcherGui, isVisible, websites, config

    ; Create GUI if it doesn't exist
    if (!launcherGui) {
        ; Get theme colors
        bg := config["theme"]["background"]
        primary := config["theme"]["primary"]
        accent := config["theme"]["accent"]
        txt := config["theme"]["text"]
        muted := config["theme"]["muted"]

        ; Get font settings
        font := config["gui"]["font"]
        fontSize := config["gui"]["fontSize"]
        titleSize := config["gui"]["titleSize"]

        launcherGui := Gui("+AlwaysOnTop -Caption +Border +ToolWindow", "Website Launcher")
        launcherGui.BackColor := bg
        launcherGui.SetFont("s" fontSize " c" accent, font)

        ; Add title
        launcherGui.SetFont("s" titleSize " Bold c" primary, font)
        launcherGui.Add("Text", "x20 y15 w360 Center", "Quick Launch")

        ; Add instructions
        launcherGui.SetFont("s9 c" muted, font)
        launcherGui.Add("Text", "x20 y45 w360 Center", "Press a key to launch • ESC to close")

        ; Add separator
        launcherGui.Add("Text", "x20 y70 w360 h1 Background" accent)

        ; Add website list
        launcherGui.SetFont("s" fontSize " c" txt, font)
        yPos := 90
        for key, site in websites {
            ; Key letter
            launcherGui.SetFont("s" fontSize " Bold c" primary, font)
            launcherGui.Add("Text", "x40 y" yPos " w30", StrUpper(key))

            ; Website name
            launcherGui.SetFont("s" fontSize " c" txt, font)
            launcherGui.Add("Text", "x80 y" yPos " w300", site.name)

            yPos += 35
        }

        ; Handle keyboard input
        launcherGui.OnEvent("Escape", (*) => HideLauncher())

        ; Center the window
        launcherGui.Show("w400 h" (yPos + 20) " Hide")

        ; Set up hotkeys for each website (only once, when GUI is created)
        for key, site in websites {
            HotIfWinActive("ahk_id " launcherGui.Hwnd)
            Hotkey(key, LaunchWebsite.Bind(site.url), "On")
        }
        HotIfWinActive()  ; Reset context
    }

    ; Center and show
    CenterWindow(launcherGui)
    launcherGui.Show()  ; Activate the window so hotkeys work
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

; Launch website in Chrome app mode
LaunchWebsite(url, *) {
    global config

    ; Hide launcher first
    HideLauncher()

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

; Website Launcher - Quick access to web apps in Chrome app mode
; Press Alt+Space to open launcher

#Requires AutoHotkey v2.0
#SingleInstance Force

; Configuration - Add your websites here
global websites := Map(
    "n", {name: "Nicoka", url: "https://acelys.nicoka.com"},
    "j", {name: "Jira", url: "https://acelys.atlassian.net/jira/for-you"},
    "b", {name: "Bitbucket", url: "https://bitbucket.org/acelys_sn/workspace/overview/"},
    "k", {name: "Keymap Editor", url: "https://nickcoutsos.github.io/keymap-editor/"},
    "m", {name: "Gmail", url: "https://mail.google.com/mail/u/3/#inbox"},
    "p", {name: "ProtonMail", url: "https://mail.proton.me/u/0/inbox"},
    "c", {name: "Claude", url: "https://www.claude.ai"},
    "g", {name: "GitHub", url: "https://github.com/YannickHerrero"},
    "o", {name: "Outlook", url: "https://outlook.office.com/mail/0/"},
    "f", {name: "Figma", url: "https://www.figma.com/files/team/"},
    "e", {name: "Expo", url: "https://expo.dev/accounts/yannick_h"}
)

; Global variables
global launcherGui := ""
global isVisible := false

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
    global launcherGui, isVisible, websites

    ; Create GUI if it doesn't exist
    if (!launcherGui) {
        launcherGui := Gui("+AlwaysOnTop -Caption +Border +ToolWindow", "Website Launcher")
        launcherGui.BackColor := "1e1e2e"
        launcherGui.SetFont("s11 c89b4fa", "Segoe UI")

        ; Add title
        launcherGui.SetFont("s13 Bold cff79c6", "Segoe UI")
        launcherGui.Add("Text", "x20 y15 w360 Center", "Quick Launch")

        ; Add instructions
        launcherGui.SetFont("s9 c6c7086", "Segoe UI")
        launcherGui.Add("Text", "x20 y45 w360 Center", "Press a key to launch • ESC to close")

        ; Add separator
        launcherGui.Add("Text", "x20 y70 w360 h1 Background89b4fa")

        ; Add website list
        launcherGui.SetFont("s11 cb4befe", "Segoe UI")
        yPos := 90
        for key, site in websites {
            ; Key letter
            launcherGui.SetFont("s11 Bold cff79c6", "Segoe UI")
            launcherGui.Add("Text", "x40 y" yPos " w30", StrUpper(key))

            ; Website name
            launcherGui.SetFont("s11 cb4befe", "Segoe UI")
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
    ; Hide launcher first
    HideLauncher()

    ; Find Chrome executable using common paths
    chromePaths := [
        EnvGet("ProgramFiles") . "\Google\Chrome\Application\chrome.exe",
        EnvGet("ProgramFiles(x86)") . "\Google\Chrome\Application\chrome.exe",
        EnvGet("LocalAppData") . "\Google\Chrome\Application\chrome.exe"
    ]

    chromeExe := ""
    for path in chromePaths {
        if (FileExist(path)) {
            chromeExe := path
            break
        }
    }

    if (!chromeExe) {
        MsgBox("Google Chrome not found!", "Error", "Icon!")
        return
    }

    ; Launch Chrome in app mode
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

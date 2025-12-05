; Help Window - Displays keyboard shortcuts and status
; Toggle with Alt+?

global helpGui := ""
global helpVisible := false

; Toggle help window
ToggleHelpWindow() {
    global helpVisible
    if (helpVisible) {
        HideHelpWindow()
    } else {
        ShowHelpWindow()
    }
}

; Show help window
ShowHelpWindow() {
    global helpGui, helpVisible, config, amphetamineEnabled

    ; Destroy existing GUI to refresh amphetamine status
    if (helpGui) {
        helpGui.Destroy()
        helpGui := ""
    }

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

    helpGui := Gui("+AlwaysOnTop -Caption +Border +ToolWindow", "Help")
    helpGui.BackColor := bg

    ; ============ LEFT COLUMN - AutoHotkey ============
    colLeft := 20

    ; Title
    helpGui.SetFont("s" titleSize " Bold c" primary, font)
    helpGui.Add("Text", "x" colLeft " y15 w280 Center", "AutoHotkey")

    ; Separator
    helpGui.Add("Text", "x" colLeft " y45 w280 h1 Background" accent)

    ; AutoHotkey shortcuts
    ahkShortcuts := [
        ["Alt + Enter", "New Terminal (CWD)"],
        ["Alt + Space", "Quick Launcher"],
        ["Alt + W", "Wallpaper Selector"],
        ["Ctrl + Alt + A", "Toggle Amphetamine"],
        ["Alt + ?", "This Help Window"]
    ]

    yPos := 60
    for shortcut in ahkShortcuts {
        helpGui.SetFont("s" fontSize " Bold c" accent, font)
        helpGui.Add("Text", "x" colLeft " y" yPos " w130", shortcut[1])
        helpGui.SetFont("s" fontSize " c" txt, font)
        helpGui.Add("Text", "x" (colLeft + 130) " y" yPos " w150", shortcut[2])
        yPos += 22
    }

    ; Separator
    yPos += 10
    helpGui.Add("Text", "x" colLeft " y" yPos " w280 h1 Background" accent)

    ; Amphetamine status
    yPos += 15
    ampStatus := amphetamineEnabled ? "ON" : "OFF"
    statusColor := amphetamineEnabled ? accent : muted

    helpGui.SetFont("s" fontSize " c" txt, font)
    helpGui.Add("Text", "x" colLeft " y" yPos " w130", "Amphetamine:")
    helpGui.SetFont("s" fontSize " Bold c" statusColor, font)
    helpGui.Add("Text", "x" (colLeft + 130) " y" yPos " w60", ampStatus)

    ; ============ RIGHT COLUMN - GlazeWM ============
    colRight := 330

    ; Title
    helpGui.SetFont("s" titleSize " Bold c" primary, font)
    helpGui.Add("Text", "x" colRight " y15 w280 Center", "GlazeWM")

    ; Separator
    helpGui.Add("Text", "x" colRight " y45 w280 h1 Background" accent)

    ; GlazeWM shortcuts grouped
    yPos := 60

    ; Focus/Navigation
    helpGui.SetFont("s9 Bold c" muted, font)
    helpGui.Add("Text", "x" colRight " y" yPos " w280", "Navigation")
    yPos += 20

    navShortcuts := [
        ["Alt + H/J/K/L", "Focus window"],
        ["Alt + 1-9", "Switch workspace"],
        ["Alt + S", "Next workspace"],
        ["Alt + D", "Recent workspace"]
    ]

    for shortcut in navShortcuts {
        helpGui.SetFont("s" fontSize " Bold c" accent, font)
        helpGui.Add("Text", "x" colRight " y" yPos " w130", shortcut[1])
        helpGui.SetFont("s" fontSize " c" txt, font)
        helpGui.Add("Text", "x" (colRight + 130) " y" yPos " w150", shortcut[2])
        yPos += 20
    }

    ; Window Management
    yPos += 8
    helpGui.SetFont("s9 Bold c" muted, font)
    helpGui.Add("Text", "x" colRight " y" yPos " w280", "Windows")
    yPos += 20

    winShortcuts := [
        ["Alt + Shift + HJKL", "Move window"],
        ["Alt + Shift + 1-9", "Move to workspace"],
        ["Alt + Q", "Close window"],
        ["Alt + F", "Fullscreen"],
        ["Alt + T", "Toggle tiling"],
        ["Alt + Shift + Space", "Toggle floating"],
        ["Alt + R", "Tiling direction"],
        ["Alt + V", "Resize mode"]
    ]

    for shortcut in winShortcuts {
        helpGui.SetFont("s" fontSize " Bold c" accent, font)
        helpGui.Add("Text", "x" colRight " y" yPos " w130", shortcut[1])
        helpGui.SetFont("s" fontSize " c" txt, font)
        helpGui.Add("Text", "x" (colRight + 130) " y" yPos " w150", shortcut[2])
        yPos += 20
    }

    ; Apps
    yPos += 8
    helpGui.SetFont("s9 Bold c" muted, font)
    helpGui.Add("Text", "x" colRight " y" yPos " w280", "Apps")
    yPos += 20

    appShortcuts := [
        ["Alt + Shift + Enter", "WezTerm"],
        ["Alt + B", "Firefox"],
        ["Alt + Shift + B", "Chrome"],
        ["Alt + A", "Claude"],
        ["Alt + N", "DuckDuckGo"]
    ]

    for shortcut in appShortcuts {
        helpGui.SetFont("s" fontSize " Bold c" accent, font)
        helpGui.Add("Text", "x" colRight " y" yPos " w130", shortcut[1])
        helpGui.SetFont("s" fontSize " c" txt, font)
        helpGui.Add("Text", "x" (colRight + 130) " y" yPos " w150", shortcut[2])
        yPos += 20
    }

    ; System
    yPos += 8
    helpGui.SetFont("s9 Bold c" muted, font)
    helpGui.Add("Text", "x" colRight " y" yPos " w280", "System")
    yPos += 20

    sysShortcuts := [
        ["Alt + Shift + R", "Reload config"],
        ["Alt + Shift + W", "Redraw windows"],
        ["Alt + Shift + P", "Pause WM"]
    ]

    for shortcut in sysShortcuts {
        helpGui.SetFont("s" fontSize " Bold c" accent, font)
        helpGui.Add("Text", "x" colRight " y" yPos " w130", shortcut[1])
        helpGui.SetFont("s" fontSize " c" txt, font)
        helpGui.Add("Text", "x" (colRight + 130) " y" yPos " w150", shortcut[2])
        yPos += 20
    }

    ; Close on Escape
    helpGui.OnEvent("Escape", (*) => HideHelpWindow())

    ; Center and show
    CenterWindow(helpGui)
    helpGui.Show()
    helpVisible := true
}

; Hide help window
HideHelpWindow() {
    global helpGui, helpVisible

    if (helpGui) {
        helpGui.Hide()
        helpVisible := false
    }
}

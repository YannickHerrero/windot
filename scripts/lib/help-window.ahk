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

    ; Title
    helpGui.SetFont("s" titleSize " Bold c" primary, font)
    helpGui.Add("Text", "x20 y15 w260 Center", "Keyboard Shortcuts")

    ; Separator
    helpGui.Add("Text", "x20 y45 w260 h1 Background" accent)

    ; Shortcuts list
    helpGui.SetFont("s" fontSize " c" txt, font)

    shortcuts := [
        ["Alt + Enter", "Terminal Launcher"],
        ["Alt + Space", "Website Launcher"],
        ["Alt + W", "Wallpaper Selector"],
        ["Ctrl + Alt + A", "Toggle Amphetamine"],
        ["Alt + ?", "This Help Window"]
    ]

    yPos := 60
    for shortcut in shortcuts {
        helpGui.SetFont("s" fontSize " Bold c" accent, font)
        helpGui.Add("Text", "x20 y" yPos " w120", shortcut[1])
        helpGui.SetFont("s" fontSize " c" txt, font)
        helpGui.Add("Text", "x140 y" yPos " w140", shortcut[2])
        yPos += 25
    }

    ; Separator
    yPos += 10
    helpGui.Add("Text", "x20 y" yPos " w260 h1 Background" accent)

    ; Amphetamine status
    yPos += 15
    ampStatus := amphetamineEnabled ? "ON" : "OFF"
    statusColor := amphetamineEnabled ? accent : muted

    helpGui.SetFont("s" fontSize " c" txt, font)
    helpGui.Add("Text", "x20 y" yPos " w120", "Amphetamine:")
    helpGui.SetFont("s" fontSize " Bold c" statusColor, font)
    helpGui.Add("Text", "x140 y" yPos " w60", ampStatus)

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

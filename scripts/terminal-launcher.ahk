; Terminal Launcher - Launch a new WezTerm instance

LaunchTerminal() {
    weztermExe := "C:\Program Files\WezTerm\wezterm-gui.exe"
    if (!FileExist(weztermExe)) {
        MsgBox("WezTerm not found!", "Error", "Icon!")
        return
    }
    Run('"' weztermExe '"')
}

; Terminal Launcher - Launch WezTerm in current directory
; If focused on WezTerm: opens new terminal in same directory
; If not focused on WezTerm: opens new terminal in home directory

LaunchTerminalInCwd() {
    ; Auto-detect WezTerm executable
    weztermExe := FindWezTerm()
    if (!weztermExe) {
        MsgBox("WezTerm not found!", "Error", "Icon!")
        return
    }

    ; Capture window info
    activeClass := WinGetClass("A")
    activeTitle := WinGetTitle("A")

    ; Check if WezTerm and extract CWD from title
    ; Title format: "WezTerm: /path/to/dir"
    if (activeClass == "org.wezfurlong.wezterm") {
        cwd := ""
        if (RegExMatch(activeTitle, "WezTerm:\s*(.+)$", &match)) {
            cwd := ConvertWslPath(match[1])
        }

        if (cwd != "") {
            ; Remove trailing slash if present
            cwd := RTrim(cwd, "\")
            Run('"' weztermExe '" start --cwd "' cwd '"')
        } else {
            Run('"' weztermExe '"')
        }
    } else {
        Run('"' weztermExe '"')
    }
}

; Convert path to Windows UNC format
ConvertWslPath(path) {
    ; Already a Windows UNC path (starts with \\)
    if (SubStr(path, 1, 2) == "\\") {
        return path
    }

    ; Path like /wsl.localhost/Ubuntu/... - just convert slashes
    if (InStr(path, "wsl.localhost")) {
        return "\" . StrReplace(path, "/", "\")
    }

    ; Pure Unix path like /home/user/... - add UNC prefix
    if (SubStr(path, 1, 1) == "/") {
        return "\\wsl.localhost\Ubuntu" . StrReplace(path, "/", "\")
    }

    return path
}

; Find WezTerm executable
FindWezTerm() {
    weztermPaths := [
        EnvGet("ProgramFiles") . "\WezTerm\wezterm-gui.exe",
        EnvGet("LocalAppData") . "\Programs\WezTerm\wezterm-gui.exe"
    ]

    for path in weztermPaths {
        if (FileExist(path)) {
            return path
        }
    }
    return ""
}

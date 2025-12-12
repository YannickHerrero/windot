; Load theme and GUI configuration from config.ini
; Includes a callback system for theme change notifications

global themeChangeCallbacks := []

; Register a callback to be called when theme changes
; Callback should be a function that takes no parameters
RegisterThemeChangeCallback(callback) {
    global themeChangeCallbacks
    themeChangeCallbacks.Push(callback)
}

; Notify all registered callbacks that theme has changed
NotifyThemeChange() {
    global themeChangeCallbacks
    for callback in themeChangeCallbacks {
        callback()
    }
}

; Load theme and GUI config from INI file
LoadThemeConfig() {
    global scriptDir, config

    ; Load INI config
    configFile := scriptDir . "\config\config.ini"
    if (!FileExist(configFile)) {
        MsgBox("Config file not found: " configFile, "Error", "Icon!")
        ExitApp()
    }

    ; Read theme settings
    config["theme"] := Map(
        "background", IniRead(configFile, "Theme", "background", "1e1e2e"),
        "primary", IniRead(configFile, "Theme", "primary", "ff79c6"),
        "accent", IniRead(configFile, "Theme", "accent", "89b4fa"),
        "text", IniRead(configFile, "Theme", "text", "b4befe"),
        "muted", IniRead(configFile, "Theme", "muted", "6c7086"),
        "border", IniRead(configFile, "Theme", "border", "45475a")
    )

    ; Read GUI settings
    config["gui"] := Map(
        "font", IniRead(configFile, "GUI", "font", "Segoe UI"),
        "fontSize", IniRead(configFile, "GUI", "fontSize", "11"),
        "titleSize", IniRead(configFile, "GUI", "titleSize", "13")
    )
}

; Reload theme config and notify all registered callbacks
ReloadTheme() {
    LoadThemeConfig()
    NotifyThemeChange()
}

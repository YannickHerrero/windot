Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -File ""C:\Users\yannick.herrero\scripts\launch-browser-app.ps1"" ""https://claude.ai""", 0, False

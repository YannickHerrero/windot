' Launch kanata fully hidden — no terminal window.
'
' kanata.exe is a console-subsystem binary, so any "shell-exec kanata"
' from GlazeWM (or "start" from cmd.exe) opens a console. Going through
' wscript lets us pass WindowStyle=0 to WshShell.Run, which suppresses
' the console entirely.
Set ws = CreateObject("WScript.Shell")
appData = ws.ExpandEnvironmentStrings("%APPDATA%")
ws.Run "kanata --cfg """ & appData & "\kanata\kanata.kbd""", 0, False

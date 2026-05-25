# Sync kanata config to %APPDATA%\kanata\kanata.kbd

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Source = Join-Path $ScriptDir "kanata.kbd"
$Dest = Join-Path $env:APPDATA "kanata\kanata.kbd"

New-Item -Path (Split-Path $Dest -Parent) -ItemType Directory -Force | Out-Null
Copy-Item -Path $Source -Destination $Dest -Force
Write-Host "[OK] kanata config -> $Dest" -ForegroundColor Green

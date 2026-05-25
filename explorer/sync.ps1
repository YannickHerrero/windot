# Sync explorer config to %APPDATA%\com.ilios.explorer\config.json

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Source = Join-Path $ScriptDir "config.json"
$Dest = Join-Path $env:APPDATA "com.ilios.explorer\config.json"

New-Item -Path (Split-Path $Dest -Parent) -ItemType Directory -Force | Out-Null
Copy-Item -Path $Source -Destination $Dest -Force
Write-Host "[OK] Explorer config -> $Dest" -ForegroundColor Green

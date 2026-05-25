# Sync wmenu config to %APPDATA%\wmenu\config\config.toml

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Source = Join-Path $ScriptDir "config.toml"
$Dest = Join-Path $env:APPDATA "wmenu\config\config.toml"

New-Item -Path (Split-Path $Dest -Parent) -ItemType Directory -Force | Out-Null
Copy-Item -Path $Source -Destination $Dest -Force
Write-Host "[OK] wmenu config -> $Dest" -ForegroundColor Green

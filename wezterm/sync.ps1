# Sync WezTerm config to the user's profile

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Source = Join-Path $ScriptDir ".wezterm.lua"
$Dest = Join-Path $env:USERPROFILE ".wezterm.lua"

Copy-Item -Path $Source -Destination $Dest -Force
Write-Host "[OK] WezTerm config -> $Dest" -ForegroundColor Green

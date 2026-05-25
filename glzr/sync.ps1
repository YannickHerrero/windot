# Sync GlazeWM config to the user's profile

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Source = Join-Path $ScriptDir "glazewm\config.yaml"
$Dest = Join-Path $env:USERPROFILE ".glzr\glazewm\config.yaml"

New-Item -Path (Split-Path $Dest -Parent) -ItemType Directory -Force | Out-Null
Copy-Item -Path $Source -Destination $Dest -Force
Write-Host "[OK] GlazeWM config -> $Dest" -ForegroundColor Green

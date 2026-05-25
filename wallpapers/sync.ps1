# Sync wallpapers to %APPDATA%\wmenu\wallpapers\
#
# wmenu's theme orchestrator reads <theme>.png from the dest dir when the
# user picks a theme from the Omakase menu and calls
# SystemParametersInfoW SPI_SETDESKWALLPAPER on it.

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DestDir = Join-Path $env:APPDATA "wmenu\wallpapers"

New-Item -Path $DestDir -ItemType Directory -Force | Out-Null

foreach ($file in Get-ChildItem -Path $ScriptDir -Filter '*.png') {
    $dst = Join-Path $DestDir $file.Name
    Copy-Item -Path $file.FullName -Destination $dst -Force
    Write-Host "[OK] $($file.Name) -> $dst" -ForegroundColor Green
}

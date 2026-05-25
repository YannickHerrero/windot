# Sync kanata config + hidden-launch wrapper to %APPDATA%\kanata\

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DestDir = Join-Path $env:APPDATA "kanata"

New-Item -Path $DestDir -ItemType Directory -Force | Out-Null

foreach ($name in 'kanata.kbd', 'launch.vbs') {
    $src = Join-Path $ScriptDir $name
    $dst = Join-Path $DestDir $name
    Copy-Item -Path $src -Destination $dst -Force
    Write-Host "[OK] $name -> $dst" -ForegroundColor Green
}

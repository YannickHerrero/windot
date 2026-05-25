# Sync wbar config and helper scripts to %APPDATA%\wbar\

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DestDir = Join-Path $env:APPDATA "wbar"

New-Item -Path $DestDir -ItemType Directory -Force | Out-Null

foreach ($name in 'config.toml', 'tiling-direction.ps1') {
    $src = Join-Path $ScriptDir $name
    $dst = Join-Path $DestDir $name
    Copy-Item -Path $src -Destination $dst -Force
    Write-Host "[OK] $name -> $dst" -ForegroundColor Green
}

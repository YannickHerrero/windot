# Install personal apps: wmenu, wbar, explorer

$ErrorActionPreference = "Stop"
. (Join-Path (Split-Path $PSScriptRoot -Parent) "lib.ps1")

Write-Host "Installing personal apps..."

Install-Package -ScoopPackage "yannick/wmenu" -Name "wmenu"
Install-Package -ScoopPackage "yannick/wbar" -Name "wbar"
Install-Package -ScoopPackage "yannick/explorer" -Name "explorer"

Write-Host "Personal apps installation complete!"

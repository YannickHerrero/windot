# Install browsers: Google Chrome, Firefox

$ErrorActionPreference = "Stop"
. (Join-Path (Split-Path $PSScriptRoot -Parent) "lib.ps1")

Write-Host "Installing browsers..."

Install-Package -ScoopPackage "extras/googlechrome" -Name "Google Chrome"
Install-Package -ScoopPackage "extras/firefox" -Name "Firefox"

Write-Host "Browsers installation complete!"

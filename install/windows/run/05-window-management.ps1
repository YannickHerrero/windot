# Install window management: GlazeWM

$ErrorActionPreference = "Stop"
. (Join-Path (Split-Path $PSScriptRoot -Parent) "lib.ps1")

Write-Host "Installing window management tools..."

Install-Package -ScoopPackage "extras/glazewm" -Name "GlazeWM"

Write-Host "Window management installation complete!"

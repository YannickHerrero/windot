# Install development tools: WezTerm, Bruno

$ErrorActionPreference = "Stop"
. (Join-Path (Split-Path $PSScriptRoot -Parent) "lib.ps1")

Write-Host "Installing development tools..."

Install-Package -ScoopPackage "extras/wezterm" -WingetId "wez.wezterm" -Name "WezTerm"
Install-Package -ScoopPackage "extras/bruno" -WingetId "Bruno.Bruno" -Name "Bruno"

Write-Host "Development tools installation complete!"

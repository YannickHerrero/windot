# Install fonts: JetBrainsMono Nerd Font

$ErrorActionPreference = "Stop"
. (Join-Path (Split-Path $PSScriptRoot -Parent) "lib.ps1")

Write-Host "Installing fonts..."

Install-Package -ScoopPackage "nerd-fonts/JetBrainsMono-NF" -WingetId "DEVCOM.JetBrainsMonoNerdFont" -Name "JetBrainsMono Nerd Font"

Write-Host "Fonts installation complete!"

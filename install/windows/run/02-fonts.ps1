# Install fonts: JetBrainsMono Nerd Font

$ErrorActionPreference = "Stop"
. (Join-Path (Split-Path $PSScriptRoot -Parent) "lib.ps1")

Write-Host "Installing fonts..."

Install-Package `
    -ScoopPackage "nerd-fonts/JetBrainsMono-NF" `
    -WingetId "DEVCOM.JetBrainsMonoNerdFont" `
    -FileExists "$env:LOCALAPPDATA\Microsoft\Windows\Fonts\JetBrainsMonoNerdFont*.ttf" `
    -Name "JetBrainsMono Nerd Font"

Write-Host "Fonts installation complete!"

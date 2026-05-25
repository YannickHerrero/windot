# Install system tools: kanata (CapsLock -> Ctrl/Esc remap)

$ErrorActionPreference = "Stop"
. (Join-Path (Split-Path $PSScriptRoot -Parent) "lib.ps1")

Write-Host "Installing system tools..."

Install-Package -ScoopPackage "extras/kanata" -Name "Kanata"

Write-Host "System tools installation complete!"

# Install WSL: Windows Subsystem for Linux

$ErrorActionPreference = "Stop"

function Install-WingetPackage {
    param([string]$PackageId, [string]$Name)

    $installed = winget list --id $PackageId 2>$null | Select-String $PackageId
    if ($installed) {
        Write-Host "[SKIP] $Name already installed" -ForegroundColor Yellow
    } else {
        Write-Host "[INSTALL] $Name" -ForegroundColor Green
        winget install --id $PackageId --accept-source-agreements --accept-package-agreements
    }
}

Write-Host "Installing WSL..."

Install-WingetPackage -PackageId "Microsoft.WSL" -Name "Windows Subsystem for Linux"

Write-Host ""
Write-Host "NOTE: You may need to restart your computer after WSL installation." -ForegroundColor Cyan
Write-Host "After restart, run 'wsl --install' to complete setup if needed." -ForegroundColor Cyan

Write-Host "WSL installation complete!"

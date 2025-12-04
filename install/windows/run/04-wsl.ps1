# Install WSL: Windows Subsystem for Linux

$ErrorActionPreference = "Stop"

function Install-WingetPackage {
    param([string]$PackageId, [string]$Name)

    $installed = winget list --id $PackageId 2>$null | Select-String $PackageId
    if ($installed) {
        Write-Host "[SKIP] $Name already installed" -ForegroundColor Yellow
    } else {
        Write-Host "[INSTALL] $Name" -ForegroundColor Green
        winget install --id $PackageId --source winget --accept-source-agreements --accept-package-agreements
    }
}

Write-Host "Installing WSL..."

Install-WingetPackage -PackageId "Microsoft.WSL" -Name "Windows Subsystem for Linux"

# Install Ubuntu
Write-Host ""
$ubuntuInstalled = wsl --list --quiet 2>$null | Select-String "Ubuntu"
if ($ubuntuInstalled) {
    Write-Host "[SKIP] Ubuntu already installed" -ForegroundColor Yellow
} else {
    Write-Host "[INSTALL] Ubuntu (latest)" -ForegroundColor Green
    wsl --install -d Ubuntu --no-launch
}

Write-Host ""
Write-Host "NOTE: You may need to restart your computer after WSL installation." -ForegroundColor Cyan
Write-Host "After restart, run 'wsl' to complete Ubuntu setup (create user/password)." -ForegroundColor Cyan

Write-Host "WSL installation complete!"

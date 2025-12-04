# Install browsers: Google Chrome, Firefox

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

Write-Host "Installing browsers..."

Install-WingetPackage -PackageId "Google.Chrome" -Name "Google Chrome"
Install-WingetPackage -PackageId "Mozilla.Firefox" -Name "Firefox"

Write-Host "Browsers installation complete!"

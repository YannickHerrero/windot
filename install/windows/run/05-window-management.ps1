# Install window management: GlazeWM

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

Write-Host "Installing window management tools..."

Install-WingetPackage -PackageId "glzr-io.glazewm" -Name "GlazeWM"

Write-Host "Window management installation complete!"

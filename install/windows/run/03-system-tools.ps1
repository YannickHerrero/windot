# Install system tools: PowerToys, UniGetUI, Windhawk

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

Write-Host "Installing system tools..."

Install-WingetPackage -PackageId "Microsoft.PowerToys" -Name "PowerToys"
Install-WingetPackage -PackageId "MartiCliment.UniGetUI" -Name "UniGetUI"
Install-WingetPackage -PackageId "RamenSoftware.Windhawk" -Name "Windhawk"

Write-Host "System tools installation complete!"

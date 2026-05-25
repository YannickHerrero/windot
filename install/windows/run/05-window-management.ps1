# Install window management: GlazeWM

$ErrorActionPreference = "Stop"

function Install-ScoopPackage {
    param([string]$Package, [string]$Name)

    $appName = ($Package -split '/')[-1]
    $installed = scoop list 2>$null | Where-Object { $_.Name -eq $appName }
    if ($installed) {
        Write-Host "[SKIP] $Name already installed" -ForegroundColor Yellow
    } else {
        Write-Host "[INSTALL] $Name" -ForegroundColor Green
        scoop install $Package
    }
}

Write-Host "Installing window management tools..."

Install-ScoopPackage -Package "extras/glazewm" -Name "GlazeWM"

Write-Host "Window management installation complete!"

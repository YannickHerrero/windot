# Install personal apps: wmenu, wbar, explorer

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

Write-Host "Installing personal apps..."

Install-ScoopPackage -Package "yannick/wmenu" -Name "wmenu"
Install-ScoopPackage -Package "yannick/wbar" -Name "wbar"
Install-ScoopPackage -Package "yannick/explorer" -Name "explorer"

Write-Host "Personal apps installation complete!"

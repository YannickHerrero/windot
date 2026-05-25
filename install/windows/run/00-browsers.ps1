# Install browsers: Google Chrome, Firefox

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

Write-Host "Installing browsers..."

Install-ScoopPackage -Package "extras/googlechrome" -Name "Google Chrome"
Install-ScoopPackage -Package "extras/firefox" -Name "Firefox"

Write-Host "Browsers installation complete!"

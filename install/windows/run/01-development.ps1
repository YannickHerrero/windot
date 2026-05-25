# Install development tools: WezTerm, Bruno

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

Write-Host "Installing development tools..."

Install-ScoopPackage -Package "extras/wezterm" -Name "WezTerm"
Install-ScoopPackage -Package "extras/bruno" -Name "Bruno"

Write-Host "Development tools installation complete!"

# Install system tools: kanata (CapsLock -> Ctrl/Esc remap)

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

Write-Host "Installing system tools..."

Install-ScoopPackage -Package "extras/kanata" -Name "Kanata"

Write-Host "System tools installation complete!"

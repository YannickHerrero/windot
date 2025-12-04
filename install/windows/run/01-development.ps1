# Install development tools: WezTerm, Bruno

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

Write-Host "Installing development tools..."

Install-WingetPackage -PackageId "wez.wezterm" -Name "WezTerm"
Install-WingetPackage -PackageId "Bruno.Bruno" -Name "Bruno"

Write-Host "Development tools installation complete!"

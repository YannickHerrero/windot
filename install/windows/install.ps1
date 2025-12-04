# Windows Install Script - select and run install scripts via fzf

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RunDir = Join-Path $ScriptDir "run"

# Check and install WinGet if not available
# Reference: https://learn.microsoft.com/en-us/windows/package-manager/winget/#install-winget-on-windows-sandbox
function Ensure-WinGet {
    $wingetAvailable = Get-Command winget -ErrorAction SilentlyContinue
    if ($wingetAvailable) {
        Write-Host "[OK] WinGet is already installed" -ForegroundColor Green
        return
    }

    Write-Host "[INSTALL] WinGet not found, installing..." -ForegroundColor Yellow
    $progressPreference = 'silentlyContinue'

    Write-Host "  Installing NuGet package provider..."
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force:$true | Out-Null

    Write-Host "  Installing Microsoft.WinGet.Client module..."
    Install-Module Microsoft.WinGet.Client -Force:$true -Confirm:$false | Out-Null

    Write-Host "  Importing Microsoft.WinGet.Client module..."
    Import-Module Microsoft.WinGet.Client

    Write-Host "  Repairing WinGet package manager..."
    Repair-WinGetPackageManager -Force:$true -Latest

    # Verify installation
    $wingetAvailable = Get-Command winget -ErrorAction SilentlyContinue
    if ($wingetAvailable) {
        Write-Host "[OK] WinGet installed successfully" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] WinGet installation failed" -ForegroundColor Red
        exit 1
    }
}

# Ensure WinGet is available before proceeding
Ensure-WinGet
Write-Host ""

# Find all install scripts in run directory
$InstallScripts = Get-ChildItem -Path $RunDir -Filter "*.ps1" | Sort-Object Name

if ($InstallScripts.Count -eq 0) {
    Write-Host "No install scripts found in $RunDir"
    exit 1
}

# Build list with display names (strip number prefix)
$Options = @("all")
$ScriptMap = @{}

foreach ($script in $InstallScripts) {
    # Get filename and remove number prefix (e.g., "00-browsers.ps1" -> "browsers")
    $displayName = $script.BaseName -replace '^\d+-', ''
    $Options += $displayName
    $ScriptMap[$displayName] = $script.FullName
}

# Check if fzf is available
$fzfAvailable = Get-Command fzf -ErrorAction SilentlyContinue

if ($fzfAvailable) {
    # Use fzf for selection
    $Selection = $Options | fzf --prompt="Select install script: " --height=40% --reverse
} else {
    # Fallback to simple menu
    Write-Host ""
    Write-Host "Select install script:" -ForegroundColor Cyan
    Write-Host ""
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host "  [$i] $($Options[$i])"
    }
    Write-Host ""
    $choice = Read-Host "Enter number"

    if ($choice -match '^\d+$' -and [int]$choice -lt $Options.Count) {
        $Selection = $Options[[int]$choice]
    } else {
        Write-Host "Invalid selection."
        exit 1
    }
}

if (-not $Selection) {
    Write-Host "No selection made."
    exit 0
}

# Execute based on selection
if ($Selection -eq "all") {
    Write-Host "Running all install scripts..."
    Write-Host ""
    foreach ($script in $InstallScripts) {
        $displayName = $script.BaseName -replace '^\d+-', ''
        Write-Host ("=" * 40)
        Write-Host "Running: $displayName"
        Write-Host ("=" * 40)
        & $script.FullName
        Write-Host ""
    }
    Write-Host "All install scripts completed!"
} else {
    # Run the selected script
    if ($ScriptMap.ContainsKey($Selection)) {
        & $ScriptMap[$Selection]
    } else {
        Write-Host "Script not found: $Selection"
        exit 1
    }
}

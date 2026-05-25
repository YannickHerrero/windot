# Windows Install Script - select and run install scripts via numbered menu

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RunDir = Join-Path $ScriptDir "run"

# Install Scoop in user mode (no admin) if not present, then ensure required buckets.
function Ensure-Scoop {
    $scoopAvailable = Get-Command scoop -ErrorAction SilentlyContinue
    if (-not $scoopAvailable) {
        Write-Host "[INSTALL] Scoop not found, installing..." -ForegroundColor Yellow
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

        $scoopAvailable = Get-Command scoop -ErrorAction SilentlyContinue
        if (-not $scoopAvailable) {
            Write-Host "[ERROR] Scoop installation failed" -ForegroundColor Red
            exit 1
        }
    }
    Write-Host "[OK] Scoop is available" -ForegroundColor Green

    # Buckets needed by the run/*.ps1 scripts.
    $buckets = @{
        'extras'     = 'https://github.com/ScoopInstaller/Extras'
        'nerd-fonts' = 'https://github.com/matthewjberger/scoop-nerd-fonts'
        'yannick'    = 'https://github.com/YannickHerrero/scoop-bucket'
    }
    $existing = scoop bucket list 2>$null | ForEach-Object { $_.Name }
    foreach ($name in $buckets.Keys) {
        if ($existing -notcontains $name) {
            Write-Host "[ADD] scoop bucket $name" -ForegroundColor Yellow
            scoop bucket add $name $buckets[$name]
        } else {
            Write-Host "[OK] bucket $name already added" -ForegroundColor Green
        }
    }
}

Ensure-Scoop
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

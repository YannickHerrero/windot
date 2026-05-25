# Shared helpers for install/windows/run/*.ps1.
# Dot-source from each run script:
#   . (Join-Path (Split-Path $PSScriptRoot -Parent) "lib.ps1")

function Install-Package {
    [CmdletBinding()]
    param(
        # Scoop package spec, e.g. "extras/googlechrome".
        [Parameter(Mandatory=$true)]
        [string]$ScoopPackage,

        # Optional winget package ID, e.g. "Google.Chrome". If the package
        # is already installed via winget we skip the scoop install — useful
        # on locked-down machines where the user cannot uninstall what IT
        # pushed via winget.
        [Parameter()]
        [string]$WingetId,

        # Optional path (supports globs). If anything matches, skip the
        # install. Use this for things like fonts where winget detection is
        # unreliable and the install would otherwise collide with a locked
        # file already in place.
        [Parameter()]
        [string]$FileExists,

        # Human label for log output.
        [Parameter(Mandatory=$true)]
        [string]$Name
    )

    $appName = ($ScoopPackage -split '/')[-1]

    $scoopInstalled = scoop list 2>$null | Where-Object { $_.Name -eq $appName }
    if ($scoopInstalled) {
        Write-Host "[SKIP] $Name already installed via scoop" -ForegroundColor Yellow
        return
    }

    if ($WingetId -and (Get-Command winget -ErrorAction SilentlyContinue)) {
        $wingetMatch = winget list --id $WingetId --exact --accept-source-agreements 2>$null |
            Select-String -SimpleMatch $WingetId -Quiet
        if ($wingetMatch) {
            Write-Host "[SKIP] $Name already installed via winget ($WingetId)" -ForegroundColor Yellow
            return
        }
    }

    if ($FileExists) {
        $matched = Get-ChildItem -Path $FileExists -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($matched) {
            Write-Host "[SKIP] $Name already present at $($matched.FullName)" -ForegroundColor Yellow
            return
        }
    }

    Write-Host "[INSTALL] $Name" -ForegroundColor Green
    scoop install $ScoopPackage
}

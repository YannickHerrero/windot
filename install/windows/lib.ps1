# Shared helpers for install/windows/run/*.ps1.
# Dot-source from each run script:
#   . (Join-Path (Split-Path $PSScriptRoot -Parent) "lib.ps1")

function Install-Package {
    [CmdletBinding()]
    param(
        # Scoop package spec, e.g. "extras/googlechrome".
        [Parameter(Mandatory=$true)]
        [string]$ScoopPackage,

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

    Write-Host "[INSTALL] $Name" -ForegroundColor Green
    scoop install $ScoopPackage
}

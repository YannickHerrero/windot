# Refresh wmenu + wbar via scoop, bouncing the running processes so the
# new .exe can land. Scoop refuses to replace a locked binary, so we stop
# both apps before pulling the update and relaunch them after.

$ErrorActionPreference = "Stop"

Write-Host "[1/4] Refreshing scoop buckets..." -ForegroundColor Cyan
scoop update

Write-Host "[2/4] Stopping wmenu and wbar..." -ForegroundColor Cyan
foreach ($exe in @('wmenu.exe', 'wbar.exe')) {
    taskkill /IM $exe /F 2>$null | Out-Null
}

Write-Host "[3/4] Updating wmenu and wbar..." -ForegroundColor Cyan
scoop update wmenu wbar

Write-Host "[4/4] Relaunching..." -ForegroundColor Cyan
Start-Process wmenu
Start-Process wbar

Write-Host "Done." -ForegroundColor Green

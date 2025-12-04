# Configure Windows settings: Appearance, Taskbar, File Explorer, Privacy

Write-Host "Configuring Windows settings..."

# ============================================================
# APPEARANCE
# ============================================================
Write-Host ""
Write-Host "Configuring appearance..." -ForegroundColor Cyan

# Enable dark mode for apps
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
Write-Host "[SET] Dark mode for apps" -ForegroundColor Green

# Enable dark mode for system
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0
Write-Host "[SET] Dark mode for system" -ForegroundColor Green

# Disable transparency effects
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0
Write-Host "[SET] Disabled transparency effects" -ForegroundColor Green

# ============================================================
# TASKBAR
# ============================================================
Write-Host ""
Write-Host "Configuring taskbar..." -ForegroundColor Cyan

# Hide search box from taskbar (0 = hidden, 1 = icon, 2 = box)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0
Write-Host "[SET] Hidden search box" -ForegroundColor Green

# Hide Task View button
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0
Write-Host "[SET] Hidden Task View button" -ForegroundColor Green

# Hide Widgets button (Windows 11)
$widgetsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $widgetsPath -Name "TaskbarDa" -Value 0 -ErrorAction SilentlyContinue
Write-Host "[SET] Hidden Widgets button" -ForegroundColor Green

# Hide Chat button (Windows 11)
Set-ItemProperty -Path $widgetsPath -Name "TaskbarMn" -Value 0 -ErrorAction SilentlyContinue
Write-Host "[SET] Hidden Chat button" -ForegroundColor Green

# Align taskbar to center (Windows 11) - 0 = left, 1 = center
Set-ItemProperty -Path $widgetsPath -Name "TaskbarAl" -Value 1 -ErrorAction SilentlyContinue
Write-Host "[SET] Taskbar aligned to center" -ForegroundColor Green

# Hide Copilot button (Windows 11)
Set-ItemProperty -Path $widgetsPath -Name "ShowCopilotButton" -Value 0 -ErrorAction SilentlyContinue
Write-Host "[SET] Hidden Copilot button" -ForegroundColor Green

# ============================================================
# FILE EXPLORER
# ============================================================
Write-Host ""
Write-Host "Configuring File Explorer..." -ForegroundColor Cyan

$explorerPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

# Show file extensions
Set-ItemProperty -Path $explorerPath -Name "HideFileExt" -Value 0
Write-Host "[SET] Show file extensions" -ForegroundColor Green

# Hide hidden files
Set-ItemProperty -Path $explorerPath -Name "Hidden" -Value 0
Write-Host "[SET] Hide hidden files" -ForegroundColor Green

# Show protected operating system files (optional - commented out for safety)
# Set-ItemProperty -Path $explorerPath -Name "ShowSuperHidden" -Value 1

# Launch File Explorer to "This PC" instead of "Quick Access"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1
Write-Host "[SET] Open Explorer to This PC" -ForegroundColor Green

# Disable compact view in File Explorer
Set-ItemProperty -Path $explorerPath -Name "UseCompactMode" -Value 0
Write-Host "[SET] Standard view mode" -ForegroundColor Green

# Disable recent files in Quick Access
Set-ItemProperty -Path $explorerPath -Name "ShowRecent" -Value 0
Write-Host "[SET] Disabled recent files in Quick Access" -ForegroundColor Green

# Disable frequent folders in Quick Access
Set-ItemProperty -Path $explorerPath -Name "ShowFrequent" -Value 0
Write-Host "[SET] Disabled frequent folders in Quick Access" -ForegroundColor Green

# ============================================================
# PRIVACY
# ============================================================
Write-Host ""
Write-Host "Configuring privacy settings..." -ForegroundColor Cyan

# Disable advertising ID
$advertisingPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
if (-not (Test-Path $advertisingPath)) {
    New-Item -Path $advertisingPath -Force | Out-Null
}
Set-ItemProperty -Path $advertisingPath -Name "Enabled" -Value 0
Write-Host "[SET] Disabled advertising ID" -ForegroundColor Green

# Disable app suggestions / tips
$contentDeliveryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
Set-ItemProperty -Path $contentDeliveryPath -Name "SubscribedContent-338388Enabled" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path $contentDeliveryPath -Name "SubscribedContent-338389Enabled" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path $contentDeliveryPath -Name "SubscribedContent-353698Enabled" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path $contentDeliveryPath -Name "SystemPaneSuggestionsEnabled" -Value 0 -ErrorAction SilentlyContinue
Write-Host "[SET] Disabled app suggestions and tips" -ForegroundColor Green

# Disable Start menu suggestions
Set-ItemProperty -Path $contentDeliveryPath -Name "SubscribedContent-338393Enabled" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path $contentDeliveryPath -Name "SubscribedContent-353694Enabled" -Value 0 -ErrorAction SilentlyContinue
Write-Host "[SET] Disabled Start menu suggestions" -ForegroundColor Green

# Disable tailored experiences
$privacyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy"
if (-not (Test-Path $privacyPath)) {
    New-Item -Path $privacyPath -Force | Out-Null
}
Set-ItemProperty -Path $privacyPath -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0
Write-Host "[SET] Disabled tailored experiences" -ForegroundColor Green

# Disable feedback frequency
$siufPath = "HKCU:\Software\Microsoft\Siuf\Rules"
if (-not (Test-Path $siufPath)) {
    New-Item -Path $siufPath -Force | Out-Null
}
Set-ItemProperty -Path $siufPath -Name "NumberOfSIUFInPeriod" -Value 0
Write-Host "[SET] Disabled feedback prompts" -ForegroundColor Green

# ============================================================
# RESTART EXPLORER
# ============================================================
Write-Host ""
Write-Host "Restarting Explorer to apply changes..." -ForegroundColor Cyan
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Process explorer

Write-Host ""
Write-Host "Windows settings configuration complete!" -ForegroundColor Green
Write-Host "Some settings may require a full restart to take effect." -ForegroundColor Yellow

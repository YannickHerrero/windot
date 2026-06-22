# Sync the WezTerm Omakase color theme into Windows Terminal (native PowerShell).
#
# The wmenu theme orchestrator regenerates %USERPROFILE%\.wezterm-colors.lua on
# every theme switch (WezTerm hot-reloads it). Windows Terminal can't read that
# Lua file, so this bridge translates it into the "wezterm-omakase" color scheme
# inside the Windows Terminal settings.json. Every other setting is untouched.
#
# Meant to be called by wmenu after a theme switch (no WSL needed):
#   powershell -NoProfile -ExecutionPolicy Bypass -File theme-sync.ps1
#
# Exit codes: 0 = synced or no change, 1 = error.

$ErrorActionPreference = "Stop"

$ColorsLua = Join-Path $env:USERPROFILE ".wezterm-colors.lua"
$WtSettings = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$SchemeName = "wezterm-omakase"

$AnsiKeys = @('black', 'red', 'green', 'yellow', 'blue', 'purple', 'cyan', 'white')
$BrightKeys = @('brightBlack', 'brightRed', 'brightGreen', 'brightYellow', 'brightBlue', 'brightPurple', 'brightCyan', 'brightWhite')

if (-not (Test-Path $ColorsLua)) { Write-Error "Colors file not found: $ColorsLua"; exit 1 }
if (-not (Test-Path $WtSettings)) { Write-Error "Windows Terminal settings not found: $WtSettings"; exit 1 }

$lua = Get-Content -Raw $ColorsLua

function Get-Scalar([string]$name) {
    $m = [regex]::Match($lua, "$name\s*=\s*""(#[0-9A-Fa-f]{6})""")
    if ($m.Success) { return $m.Groups[1].Value } else { return $null }
}

function Get-Array([string]$name) {
    $m = [regex]::Match($lua, "$name\s*=\s*\{(.*?)\}", [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $m.Success) { return @() }
    return [regex]::Matches($m.Groups[1].Value, '"(#[0-9A-Fa-f]{6})"') | ForEach-Object { $_.Groups[1].Value }
}

$ansi = @(Get-Array 'ansi')
$brights = @(Get-Array 'brights')
if ($ansi.Count -ne 8 -or $brights.Count -ne 8) {
    Write-Error "Expected 8 ansi + 8 brights, got $($ansi.Count)/$($brights.Count)"; exit 1
}

# Ordered hashtable so the scheme serializes in a stable, readable order
$scheme = [ordered]@{
    name                = $SchemeName
    foreground          = Get-Scalar 'foreground'
    background          = Get-Scalar 'background'
    cursorColor         = Get-Scalar 'cursor_bg'
    selectionBackground = Get-Scalar 'selection_bg'
}
for ($i = 0; $i -lt 8; $i++) { $scheme[$AnsiKeys[$i]] = $ansi[$i] }
for ($i = 0; $i -lt 8; $i++) { $scheme[$BrightKeys[$i]] = $brights[$i] }

foreach ($k in $scheme.Keys) {
    if (-not $scheme[$k]) { Write-Error "Missing color '$k' in $ColorsLua"; exit 1 }
}
$schemeObj = [pscustomobject]$scheme

$settings = Get-Content -Raw $WtSettings | ConvertFrom-Json
if (-not $settings.schemes) {
    $settings | Add-Member -NotePropertyName schemes -NotePropertyValue @() -Force
}

# Replace existing scheme by name, or append. Skip the write if nothing changed.
$schemes = @($settings.schemes)
$idx = -1
for ($i = 0; $i -lt $schemes.Count; $i++) {
    if ($schemes[$i].name -eq $SchemeName) { $idx = $i; break }
}

if ($idx -ge 0) {
    $existingJson = $schemes[$idx] | ConvertTo-Json -Depth 8 -Compress
    $newJson = $schemeObj | ConvertTo-Json -Depth 8 -Compress
    if ($existingJson -eq $newJson) {
        Write-Host "[$(Get-Date -Format HH:mm:ss)] No change." -ForegroundColor DarkGray
        exit 0
    }
    $schemes[$idx] = $schemeObj
}
else {
    $schemes += $schemeObj
}
$settings.schemes = $schemes

Copy-Item -Path $WtSettings -Destination "$WtSettings.bak" -Force
$settings | ConvertTo-Json -Depth 32 | Set-Content -Path $WtSettings -Encoding utf8
Write-Host "[$(Get-Date -Format HH:mm:ss)] Synced '$SchemeName' -> Windows Terminal (bg $($scheme.background))" -ForegroundColor Green

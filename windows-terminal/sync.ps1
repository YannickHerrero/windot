# Sync Windows Terminal config to the packaged app's LocalState.
#
# Windows Terminal *owns* its settings.json: it auto-adds profiles for newly
# installed WSL distros / VS / Azure, and the wmenu theme orchestrator rewrites
# the "wezterm-omakase" color scheme live. So this is a MERGE, not a copy:
#   - curated keys (defaultProfile, keybindings, newTabMenu, copy*, and
#     profiles.defaults) are taken from the repo and overlaid onto the live file
#   - the live profile list is preserved (keeps WT-generated profiles)
#   - the live "wezterm-omakase" scheme is preserved if present (keeps the
#     current dynamic theme); otherwise the repo's default scheme is added

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Source = Join-Path $ScriptDir "settings.json"
$Dest = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

$base = Get-Content -Raw $Source | ConvertFrom-Json

if (Test-Path $Dest) {
    $live = Get-Content -Raw $Dest | ConvertFrom-Json

    # Curated top-level keys we own -> overlay from repo onto live
    foreach ($key in 'defaultProfile', 'keybindings', 'newTabMenu', 'copyFormatting', 'copyOnSelect') {
        if ($base.PSObject.Properties.Name -contains $key) {
            $live | Add-Member -NotePropertyName $key -NotePropertyValue $base.$key -Force
        }
    }

    # profiles.defaults (keep the live profiles.list untouched)
    if (-not $live.profiles) {
        $live | Add-Member -NotePropertyName profiles -NotePropertyValue ([pscustomobject]@{}) -Force
    }
    $live.profiles | Add-Member -NotePropertyName defaults -NotePropertyValue $base.profiles.defaults -Force

    # schemes: add any repo scheme missing by name; keep live's if same name
    # already exists (preserves the live dynamic theme colors)
    if (-not $live.schemes) {
        $live | Add-Member -NotePropertyName schemes -NotePropertyValue @() -Force
    }
    $liveNames = @($live.schemes | ForEach-Object { $_.name })
    foreach ($s in $base.schemes) {
        if ($liveNames -notcontains $s.name) {
            $live.schemes += $s
        }
    }

    $out = $live
}
else {
    New-Item -Path (Split-Path $Dest -Parent) -ItemType Directory -Force | Out-Null
    $out = $base
}

$out | ConvertTo-Json -Depth 32 | Set-Content -Path $Dest -Encoding utf8
Write-Host "[OK] Windows Terminal config -> $Dest" -ForegroundColor Green

# Root sync script - select and run sync scripts via numbered menu

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Find all sync.ps1 scripts in subdirectories (excluding this root script)
$SyncScripts = Get-ChildItem -Path $ScriptDir -Recurse -Filter "sync.ps1" |
    Where-Object { $_.FullName -ne $MyInvocation.MyCommand.Path } |
    Sort-Object FullName

if ($SyncScripts.Count -eq 0) {
    Write-Host "No sync scripts found."
    exit 1
}

# Build options with relative paths for display
$Options = @("all")
$ScriptMap = @{}

foreach ($script in $SyncScripts) {
    $relative = $script.FullName.Substring($ScriptDir.Length + 1).Replace('\', '/')
    $Options += $relative
    $ScriptMap[$relative] = $script.FullName
}

Write-Host ""
Write-Host "Select sync script:" -ForegroundColor Cyan
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

if ($Selection -eq "all") {
    Write-Host "Running all sync scripts..."
    Write-Host ""
    foreach ($script in $SyncScripts) {
        $relative = $script.FullName.Substring($ScriptDir.Length + 1).Replace('\', '/')
        Write-Host ("=" * 40)
        Write-Host "Running: $relative"
        Write-Host ("=" * 40)
        & $script.FullName
        Write-Host ""
    }
    Write-Host "All sync scripts completed!"
} else {
    & $ScriptMap[$Selection]
}

# Windows PowerShell script to launch Google Chrome in app mode
# Usage: .\launch-browser-app.ps1 "https://example.com" [additional args...]

param(
    [Parameter(Mandatory=$true)]
    [string]$Url,

    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$AdditionalArgs
)

# Common Google Chrome installation paths
$chromePaths = @(
    "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "${env:LocalAppData}\Google\Chrome\Application\chrome.exe"
)

# Find Chrome executable
$chromeExe = $chromePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $chromeExe) {
    Write-Error "Google Chrome not found in common installation paths"
    exit 1
}

# Build arguments
$arguments = @("--app=$Url")
if ($AdditionalArgs) {
    $arguments += $AdditionalArgs
}

# Launch Chrome in app mode as a detached process
Start-Process -FilePath $chromeExe -ArgumentList $arguments

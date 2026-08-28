param(
    [string]$SqlFile = $env:SQL_FILE
)

$ErrorActionPreference = "Stop"

function Get-Setting([string]$Name, [string]$Default) {
    $value = [Environment]::GetEnvironmentVariable($Name)
    if ([string]::IsNullOrWhiteSpace($value)) { return $Default }
    return $value
}

function Test-Cdp([string]$Url) {
    try {
        Invoke-RestMethod -Uri "$Url/json/version" -TimeoutSec 3 | Out-Null
        return $true
    } catch {
        return $false
    }
}

if ([string]::IsNullOrWhiteSpace($SqlFile) -or -not (Test-Path -LiteralPath $SqlFile -PathType Leaf)) {
    throw "Usage: .\run_sqllab_cdp.ps1 QUERY.sql"
}

$SqlPath = (Resolve-Path -LiteralPath $SqlFile).Path
$RunDate = Get-Setting "RUN_DATE" (Get-Date -Format "ddMMyyyy")
$OutputRoot = Get-Setting "OUTPUT_ROOT" "output"
$OutputDir = Join-Path $OutputRoot $RunDate
$QueryName = [IO.Path]::GetFileNameWithoutExtension($SqlPath)
$ExcelOutput = Join-Path $OutputDir ("{0}_{1}.xlsx" -f $QueryName, $RunDate)
$CdpUrl = Get-Setting "CDP_URL" "http://127.0.0.1:9222"
$ChromeProfile = Get-Setting "CHROME_USER_DATA_DIR" (Join-Path $env:USERPROFILE ".chrome-sqllab-cdp")
$ChromeLog = Get-Setting "CHROME_LOG" (Join-Path $env:TEMP "sqllab-chrome.log")
$ChromeErrorLog = "$ChromeLog.err"
$CdpWaitSeconds = [int](Get-Setting "CDP_WAIT_SECONDS" "30")
$Pagination = Get-Setting "PAGINATION" "auto"
$PageSize = [int](Get-Setting "PAGE_SIZE" "9000")
$Timeout = [int](Get-Setting "TIMEOUT" "900")
$ReloadAfter = [int](Get-Setting "RELOAD_AFTER" "360")
$ReloadWaitMin = [double](Get-Setting "RELOAD_WAIT_MIN" "3")
$ReloadWaitMax = [double](Get-Setting "RELOAD_WAIT_MAX" "15")
$Delay = [double](Get-Setting "DELAY" "15")
$MaxRetries = [int](Get-Setting "MAX_RETRIES" "20")

$ChromeCandidates = @()
if ($env:ProgramFiles) { $ChromeCandidates += Join-Path $env:ProgramFiles "Google\Chrome\Application\chrome.exe" }
if (${env:ProgramFiles(x86)}) { $ChromeCandidates += Join-Path ${env:ProgramFiles(x86)} "Google\Chrome\Application\chrome.exe" }
if ($env:LOCALAPPDATA) { $ChromeCandidates += Join-Path $env:LOCALAPPDATA "Google\Chrome\Application\chrome.exe" }
$Chrome = $ChromeCandidates | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1
if (-not $Chrome) {
    throw "Google Chrome was not found. Set the Chrome path in this script or install Chrome."
}

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
$ChromeLogParent = Split-Path -Parent $ChromeLog
if ($ChromeLogParent) { New-Item -ItemType Directory -Path $ChromeLogParent -Force | Out-Null }

Write-Host "Starting Chrome with CDP..."
Write-Host "Chrome log: $ChromeLog"
Write-Host "Chrome profile: $ChromeProfile"
Start-Process -FilePath $Chrome -ArgumentList @(
    "--remote-debugging-port=9222",
    "--user-data-dir=$ChromeProfile"
) -RedirectStandardOutput $ChromeLog -RedirectStandardError $ChromeErrorLog | Out-Null

Write-Host "Waiting for CDP at $CdpUrl..."
$CdpReady = $false
for ($Attempt = 0; $Attempt -lt $CdpWaitSeconds; $Attempt++) {
    if (Test-Cdp $CdpUrl) {
        $CdpReady = $true
        break
    }
    Start-Sleep -Seconds 1
}
if (-not $CdpReady) {
    throw "CDP did not start within ${CdpWaitSeconds}s. Check $ChromeLog and $ChromeErrorLog"
}
Write-Host "CDP ready."

Read-Host "Log in/check SQL Lab in Chrome, then press Enter to run"

$FetchArgs = @(
    "fetch_sqllab.py",
    "--sql", $SqlPath,
    "--output-dir", $OutputDir,
    "--cdp-url", $CdpUrl,
    "--pagination", $Pagination,
    "--page-size", "$PageSize",
    "--timeout", "$Timeout",
    "--reload-after", "$ReloadAfter",
    "--reload-wait-min", "$ReloadWaitMin",
    "--reload-wait-max", "$ReloadWaitMax",
    "--delay", "$Delay",
    "--max-retries", "$MaxRetries"
)

& uv run python @FetchArgs
if ($LASTEXITCODE -ne 0) {
    throw "Query failed: $SqlPath"
}

& uv run python merge_csv_to_excel.py (Join-Path $OutputDir $QueryName) --output $ExcelOutput
if ($LASTEXITCODE -ne 0) {
    throw "Excel conversion failed: $SqlPath"
}
Write-Host "Finished: $ExcelOutput"

param(
    [string]$SqlDirectory = "queries\Usaha"
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

if (-not (Test-Path -LiteralPath $SqlDirectory -PathType Container)) {
    throw "SQL directory not found: $SqlDirectory"
}

$RunDate = Get-Setting "RUN_DATE" (Get-Date -Format "ddMMyyyy")
$OutputRoot = Get-Setting "OUTPUT_ROOT" "output"
$OutputDir = Join-Path $OutputRoot $RunDate
$CdpUrl = Get-Setting "CDP_URL" "http://127.0.0.1:9222"
$ChromeProfile = Get-Setting "CHROME_USER_DATA_DIR" (Join-Path $env:USERPROFILE ".chrome-sqllab-cdp")
$ChromeLog = Get-Setting "CHROME_LOG" (Join-Path $env:TEMP "sqllab-chrome.log")
$ChromeErrorLog = "$ChromeLog.err"
$CdpWaitSeconds = [int](Get-Setting "CDP_WAIT_SECONDS" "30")
$PageSize = [int](Get-Setting "PAGE_SIZE" "9000")
$Timeout = [int](Get-Setting "TIMEOUT" "900")
$ReloadAfter = [int](Get-Setting "RELOAD_AFTER" "360")
$ReloadWaitMin = [double](Get-Setting "RELOAD_WAIT_MIN" "3")
$ReloadWaitMax = [double](Get-Setting "RELOAD_WAIT_MAX" "15")
$Delay = [double](Get-Setting "DELAY" "15")
$MaxRetries = [int](Get-Setting "MAX_RETRIES" "20")
$Force = (Get-Setting "FORCE" "0") -eq "1"

$ChromeCandidates = @()
if ($env:ProgramFiles) { $ChromeCandidates += Join-Path $env:ProgramFiles "Google\Chrome\Application\chrome.exe" }
if (${env:ProgramFiles(x86)}) { $ChromeCandidates += Join-Path ${env:ProgramFiles(x86)} "Google\Chrome\Application\chrome.exe" }
if ($env:LOCALAPPDATA) { $ChromeCandidates += Join-Path $env:LOCALAPPDATA "Google\Chrome\Application\chrome.exe" }
$Chrome = $ChromeCandidates | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1
if (-not $Chrome) {
    throw "Google Chrome was not found. Set the Chrome path in this script or install Chrome."
}

$SqlFiles = @(Get-ChildItem -LiteralPath $SqlDirectory -Filter "*.sql" -File | Sort-Object Name)
if ($SqlFiles.Count -eq 0) {
    throw "No .sql files found in $SqlDirectory"
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

Read-Host "Log in/check SQL Lab in Chrome, then press Enter to run all queries"

foreach ($SqlFile in $SqlFiles) {
    $QueryName = $SqlFile.BaseName
    $MergedCsv = Join-Path $OutputDir ("{0}_{1}.csv" -f $QueryName, $RunDate)

    if ((Test-Path -LiteralPath $MergedCsv) -and -not $Force) {
        Write-Host "Skipping completed query: $($SqlFile.FullName)"
        continue
    }

    Write-Host "Running query: $($SqlFile.FullName)"
    $ResumeArgs = @()
    if ($Force) {
        $QueryRunDir = Join-Path $OutputDir $QueryName
        $PagesDir = Join-Path $QueryRunDir "pages"
        if (Test-Path -LiteralPath $PagesDir) {
            Get-ChildItem -LiteralPath $PagesDir -File |
                Where-Object { $_.Name -like "page-*.csv" -or $_.Name -like "page-*.json" } |
                Remove-Item -Force
        }
        Remove-Item -LiteralPath (Join-Path $QueryRunDir "checkpoint.json") -Force -ErrorAction SilentlyContinue
        $ResumeArgs = @("--no-resume")
    }

    $FetchArgs = @(
        "fetch_sqllab.py",
        "--sql", $SqlFile.FullName,
        "--output-dir", $OutputDir,
        "--cdp-url", $CdpUrl,
        "--pagination", "auto",
        "--page-size", "$PageSize",
        "--merged-csv", $MergedCsv,
        "--timeout", "$Timeout",
        "--reload-after", "$ReloadAfter",
        "--reload-wait-min", "$ReloadWaitMin",
        "--reload-wait-max", "$ReloadWaitMax",
        "--delay", "$Delay",
        "--max-retries", "$MaxRetries"
    ) + $ResumeArgs

    & uv run python @FetchArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Query failed: $($SqlFile.FullName)"
    }
    Write-Host "Finished: $MergedCsv"
}

Write-Host "All SQL queries completed."

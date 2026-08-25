param(
  [string]$Owner = "winccoa-tools-pack",
  [string]$Spdx = "MIT",
  [string]$WinccoaVersion = "3.21",
  [string]$TestProjectPath = "tests/WinCC_OA_Test",
  [string]$RunnerProject = "TfCustomizedSquirt",
  [string]$SourcePath = "src/Squirt",
  [string]$WinccoaInstallPath = "",
  [switch]$ApplyChanges
)

$ErrorActionPreference = "Stop"
if (Get-Variable PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
  $PSNativeCommandUseErrorActionPreference = $false
}

function Get-WinccoaInstallPath {
  param(
    [string]$Version,
    [string]$ExplicitPath
  )

  if (-not [string]::IsNullOrWhiteSpace($ExplicitPath) -and (Test-Path $ExplicitPath)) {
    return (Resolve-Path $ExplicitPath).Path
  }

  if (-not [string]::IsNullOrWhiteSpace($env:WINCC_OA_INSTALL_PATH) -and
      (Test-Path $env:WINCC_OA_INSTALL_PATH)) {
    return (Resolve-Path $env:WINCC_OA_INSTALL_PATH).Path
  }

  $regCandidates = @(
    "HKLM:\Software\ETM\WinCC_OA\$Version",
    "HKLM:\Software\WOW6432Node\ETM\WinCC_OA\$Version"
  )

  foreach ($key in $regCandidates) {
    try {
      $regValue = (Get-ItemProperty -Path $key -Name INSTALLDIR -ErrorAction Stop).INSTALLDIR
      if (-not [string]::IsNullOrWhiteSpace($regValue) -and (Test-Path $regValue)) {
        return (Resolve-Path $regValue).Path
      }
    } catch {
      # try next key
    }
  }

  $fallbacks = @(
    "C:/Program Files/Siemens/WinCC_OA/$Version",
    "C:/Siemens/WinCC_OA/$Version"
  )

  foreach ($path in $fallbacks) {
    if (Test-Path $path) {
      return (Resolve-Path $path).Path
    }
  }

  throw "No WinCC OA installation found for version $Version. Set -WinccoaInstallPath or WINCC_OA_INSTALL_PATH."
}

$repoRoot = (Resolve-Path "$PSScriptRoot/..").Path
$oaPath = Get-WinccoaInstallPath -Version $WinccoaVersion -ExplicitPath $WinccoaInstallPath
$oaBin = "$oaPath/bin"
$runnerPath = (Resolve-Path "$repoRoot/$TestProjectPath/Projects/$RunnerProject").Path
$configPath = "$runnerPath/config/config"
$scriptPath = (Resolve-Path "$repoRoot/OaDevTools/scripts/copyright.ctl").Path
$sourceAbs = (Resolve-Path "$repoRoot/$SourcePath").Path

New-Item -ItemType Directory -Force -Path "$runnerPath/config" | Out-Null
New-Item -ItemType Directory -Force -Path "$runnerPath/log" | Out-Null
New-Item -ItemType Directory -Force -Path "$repoRoot/.artifacts" | Out-Null

$configContent = @"
[general]
pvss_path = "$oaPath"
proj_path = "$repoRoot/OaDevTools"
proj_path = "$runnerPath"
proj_version = "$WinccoaVersion"
langs = "en_US.utf8"
pmonPort = 5999
"@
$configContent | Set-Content -Path $configPath -Encoding ASCII

if (-not (Test-Path $configPath)) {
  throw "Config file was not created: $configPath"
}

$stdoutLog = "$repoRoot/.artifacts/ctrl-copyright.stdout.log"
$stderrLog = "$repoRoot/.artifacts/ctrl-copyright.stderr.log"

if (Test-Path $stdoutLog) { Remove-Item $stdoutLog -Force }
if (Test-Path $stderrLog) { Remove-Item $stderrLog -Force }

$ctrlArgs = @(
  "-config", $configPath,
  "-n", "-autofreg",
  $scriptPath, $sourceAbs, $Owner, $Spdx, $(if ($ApplyChanges) { "TRUE" } else { "FALSE" }),
  "-log", "+stderr",
  "-lang", "en_US.utf8"
)

$startParams = @{
  FilePath = "$oaBin/WCCOActrl.exe"
  ArgumentList = $ctrlArgs
  NoNewWindow = $true
  Wait = $true
  PassThru = $true
  RedirectStandardOutput = $stdoutLog
  RedirectStandardError = $stderrLog
}

$process = Start-Process @startParams

$ctrlExit = $process.ExitCode

$output = @()
if (Test-Path $stdoutLog) {
  $output += Get-Content -Path $stdoutLog
}
if (Test-Path $stderrLog) {
  $output += Get-Content -Path $stderrLog
}
$output | Out-Host

if ($ctrlExit -ne 0) {
  throw "WCCOActrl exited with code $ctrlExit while running copyright helper."
}

if (-not $ApplyChanges) {
  $changePattern = "copyright|license|mismatch|updated|changed"
  $matchedLines = $output | Where-Object {
    $_ -match $changePattern -and $_ -match "\.ctl"
  }

  if ($matchedLines.Count -eq 0) {
    return
  }

  $changedFiles = @()
  foreach ($line in $matchedLines) {
    $pathMatches = [regex]::Matches($line, '[A-Za-z]:[\\/][^"\s]+\.ctl|/[A-Za-z0-9._\-/]+\.ctl')
    foreach ($m in $pathMatches) {
      $changedFiles += $m.Value
    }
  }

  $changedFiles = $changedFiles | Sort-Object -Unique

  Write-Host "Detected CTL files that need copyright updates:"
  if ($changedFiles.Count -gt 0) {
    $changedFiles | ForEach-Object { Write-Host " - $_" }
  } else {
    Write-Host "No explicit file paths parsed from tool output. Matching log lines:"
    $matchedLines | ForEach-Object { Write-Host " - $_" }
  }

  throw "Copyright updates detected. Re-run with -ApplyChanges."
}

Write-Host "Copyright and SPDX checks passed."

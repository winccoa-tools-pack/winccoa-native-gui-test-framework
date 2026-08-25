param(
  [string]$WinccoaVersion = "3.21",
  [string]$TestProjectPath = "tests/WinCC_OA_Test",
  [string]$RunnerProject = "TfCustomizedSquirt",
  [string]$RunId = "Regression-tests",
  [string]$WinccoaInstallPath = "",
  [string]$Language = "en_US.utf8"
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
$testRoot = (Resolve-Path "$repoRoot/$TestProjectPath").Path
$runnerPath = "$testRoot/Projects/$RunnerProject"
$configPath = "$runnerPath/config/config"

if (-not (Test-Path "$oaBin/WCCILpmon.exe")) {
  throw "WCCILpmon.exe not found at $oaBin"
}
if (-not (Test-Path "$oaBin/WCCOActrl.exe")) {
  throw "WCCOActrl.exe not found at $oaBin"
}

New-Item -ItemType Directory -Force -Path "$runnerPath/config" | Out-Null
New-Item -ItemType Directory -Force -Path "$runnerPath/log" | Out-Null
New-Item -ItemType Directory -Force -Path "$testRoot/Results" | Out-Null

$configContent = @"
[general]
pvss_path = "$oaPath"
proj_path = "$repoRoot/src/Squirt"
proj_path = "$oaPath/TestFramework_$WinccoaVersion"
proj_path = "$testRoot/Projects/Global"
proj_path = "$runnerPath"
proj_version = "$WinccoaVersion"
langs = "de_AT.utf8"
langs = "en_US.utf8"
pmonPort = 5999
[testFramework]
installPath = "$testRoot/"
"@
$configContent | Set-Content -Path $configPath -Encoding ASCII

$pmonCmd = '"{0}" -config "{1}" -n -autofreg -status -log +stderr' -f "$oaBin/WCCILpmon.exe", $configPath
$prevErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$pmonOutput = cmd /c $pmonCmd 2>&1
$ErrorActionPreference = $prevErrorActionPreference
$pmonExit = $LASTEXITCODE
$pmonOutput | Out-Host
if ($pmonExit -ne 0) {
  Write-Warning "WCCILpmon exited with code $pmonExit. Continuing with test execution."
}

$params = "{'testRunId':'$RunId','registerGlobalProject':true,'registerAllTools':true,'registerAllTemplates':true,'cleanOldResults':true,'cleanStoredProjects':true,'showLogViewer':false,'TfTestManager.checkForPossibleFreezeTests':true}"
$testCmd = '"{0}" -proj "{1}" -n testRunner.ctl "{2}" -log +stderr -lang "{3}"' -f "$oaBin/WCCOActrl.exe", $RunnerProject, $params, $Language
$prevErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$testOutput = cmd /c $testCmd 2>&1
$ErrorActionPreference = $prevErrorActionPreference
$testExit = $LASTEXITCODE
$testOutput | Out-Host
if ($testExit -ne 0) {
  throw "WCCOActrl testRunner.ctl exited with code $testExit."
}

$junitCmd = '"{0}" -proj "{1}" -n oaTestParsers/jsonToJUnit.ctl -log +stderr -lang "{2}"' -f "$oaBin/WCCOActrl.exe", $RunnerProject, $Language
$prevErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$junitOutput = cmd /c $junitCmd 2>&1
$ErrorActionPreference = $prevErrorActionPreference
$junitExit = $LASTEXITCODE
$junitOutput | Out-Host
if ($junitExit -ne 0) {
  throw "WCCOActrl jsonToJUnit.ctl exited with code $junitExit."
}

Write-Host "Finished local test run: $RunId"
Write-Host "Results: $testRoot/Results"

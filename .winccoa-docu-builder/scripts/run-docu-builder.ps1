#Requires -Version 5.1
<#
.SYNOPSIS
  Local helper: prepare theme+overrides, then run winccoa-docu-builder.

.EXAMPLE
  .\run-docu-builder.ps1
  .\run-docu-builder.ps1 prepare
  .\run-docu-builder.ps1 build
  .\run-docu-builder.ps1 register
#>
[CmdletBinding()]
param(
    [ValidateSet("prepare", "merge", "build", "register", "help")]
    [string] $Command = "build",

    [string] $RepoRoot = "",
    [string] $WorkerPath = "src/Squirt",
    [string] $WinccoaVersion = "3.21",
    [string] $CompanyName = "winccoa-tools-pack",
    [string] $PackageVersion = "0.2.1",
    [string] $PackageSpec = "",
    [string] $ThemePath = ".docu-builder-theme",
    [string] $ThemeSource = "",
    [switch] $SkipPrepare,
    [switch] $SkipThemeFetch,
    [string[]] $DocuArgs = @()
)

$ErrorActionPreference = "Stop"

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
}
if (-not $PackageSpec) {
    $PackageSpec = "@winccoa-tools-pack/npm-winccoa-docu-builder@$PackageVersion"
}
if ($env:SKIP_PREPARE -eq "1") { $SkipPrepare = $true }

Set-Location -LiteralPath $RepoRoot
New-Item -ItemType Directory -Force -Path (Join-Path $RepoRoot ".artifacts") | Out-Null

function Invoke-Prepare {
    if ($SkipPrepare) {
        Write-Host "SkipPrepare set - not running prepare-project-docu.ps1"
        return
    }
    $prep = Join-Path $PSScriptRoot "prepare-project-docu.ps1"
    $args = @{
        RepoRoot = $RepoRoot
        WorkerPath = $WorkerPath
        ThemePath = $ThemePath
    }
    if ($ThemeSource) { $args.ThemeSource = $ThemeSource }
    if ($SkipThemeFetch) { $args.SkipThemeFetch = $true }
    & $prep @args
}

function Resolve-Cli {
    # Returns string[]: either @('node', cli.js) or @('path-to-shim')
    $cmd = Get-Command winccoa-docu-builder -ErrorAction SilentlyContinue
    if ($cmd) { return @($cmd.Source) }

    $pkgRoot = Join-Path $RepoRoot "node_modules\@winccoa-tools-pack\npm-winccoa-docu-builder"
    $cliJs = Join-Path $pkgRoot "dist\cjs\cli.js"
    $localCmd = Join-Path $RepoRoot "node_modules\.bin\winccoa-docu-builder.cmd"

    if (-not (Test-Path -LiteralPath $cliJs)) {
        Write-Host "Installing $PackageSpec into $RepoRoot (local helper bootstrap)..."
        npm install --no-save --prefix $RepoRoot $PackageSpec
        if ($LASTEXITCODE -ne 0) { throw "npm install failed ($LASTEXITCODE)" }
    }

    if ((Test-Path -LiteralPath $cliJs) -and (Get-Command node -ErrorAction SilentlyContinue)) {
        return @("node", $cliJs)
    }
    if (Test-Path -LiteralPath $localCmd) {
        return @($localCmd)
    }

    throw "winccoa-docu-builder CLI not found after install (expected $cliJs)"
}

function Invoke-DocuCli {
    param([string] $SubCommand)
    $cli = @(Resolve-Cli)
    $args = @(
        $SubCommand
        $WorkerPath
        "-v", $WinccoaVersion
    )
    if ($SubCommand -eq "build") {
        $args += @("-c", $CompanyName)
    }
    $args += @("--project-docu", $ThemePath, "--project-docu", ".winccoa-docu-builder")
    if ($DocuArgs) { $args += $DocuArgs }

    Write-Host "Running: $($cli -join ' ') $($args -join ' ')"
    & $cli[0] @($cli | Select-Object -Skip 1) @args
    if ($LASTEXITCODE -ne 0) {
        throw "winccoa-docu-builder exited with $LASTEXITCODE"
    }
}

function Invoke-NormalizeWarnLogfile {
    $logPath = Join-Path $RepoRoot (Join-Path $WorkerPath "log\doxygen_warn_logfile.txt")
    if (-not (Test-Path -LiteralPath $logPath)) {
        return
    }
    $text = [System.IO.File]::ReadAllText($logPath)
    $pattern = '(?i)(?:[A-Za-z]:)?(?:[^:\r\n]*?/)?WinCC_OA_docuGenerator/'
    $replacement = ($WorkerPath.TrimEnd('/', '\') -replace '\\', '/') + '/'
    $updated = [regex]::Replace($text, $pattern, $replacement)
    $updated = $updated -replace '(?m)^/workspace/', ''
    $updated = $updated -replace '(?m)^/github/workspace/', ''
    if ($updated -ne $text) {
        [System.IO.File]::WriteAllText($logPath, $updated)
        Write-Host "Normalized absolute paths in $logPath"
    }
}

switch ($Command) {
    { $_ -in @("prepare", "merge") } { Invoke-Prepare }
    "build" {
        Invoke-Prepare
        Invoke-DocuCli -SubCommand "build"
        Invoke-NormalizeWarnLogfile
    }
    "register" {
        Invoke-Prepare
        Invoke-DocuCli -SubCommand "register"
    }
    "help" {
        Get-Help $PSCommandPath -Full
    }
}

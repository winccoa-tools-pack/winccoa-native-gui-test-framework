#Requires -Version 5.1
<#
.SYNOPSIS
  Merge external projectDocu sources into the worker data/projectDocu tree.

.DESCRIPTION
  Mirrors @winccoa-tools-pack/npm-winccoa-docu-builder merge rules:
  - top-level files only
  - advanced_doxygenConfig.txt concatenated (later keys win)
  - other files last-wins

.PARAMETER Source
  One or more source directories (absolute or repo-relative).

.PARAMETER RepoRoot
  Repository root. Default: parent of .winccoa-docu-builder.

.PARAMETER WorkerPath
  Worker project relative to RepoRoot. Default: src/Squirt.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
    [string[]] $Source,

    [string] $RepoRoot = "",
    [string] $WorkerPath = "src/Squirt"
)

$ErrorActionPreference = "Stop"
$AdvancedName = "advanced_doxygenConfig.txt"
$SkipNames = @(
    'README.md', 'LICENSE', '.gitignore', '.gitattributes', '.editorconfig',
    '.generated-by-docu-builder'
)

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
}

$targetDir = Join-Path $RepoRoot (Join-Path $WorkerPath "data\projectDocu")
New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

$sources = @()
foreach ($src in $Source) {
    if ([string]::IsNullOrWhiteSpace($src)) { continue }
    if (-not [System.IO.Path]::IsPathRooted($src)) {
        $src = Join-Path $RepoRoot $src
    }
    if (-not (Test-Path -LiteralPath $src -PathType Container)) {
        throw "projectDocu source is missing or not a directory: $src"
    }
    $sources += (Resolve-Path -LiteralPath $src).Path
}

if ($sources.Count -eq 0) {
    throw "usage: merge-project-docu.ps1 <source_dir> [source_dir ...]"
}

$advancedChunks = New-Object System.Collections.Generic.List[string]
$written = New-Object System.Collections.Generic.HashSet[string]

foreach ($src in $sources) {
    Write-Host "Merging projectDocu from: $src"
    Get-ChildItem -LiteralPath $src -File | Sort-Object Name | ForEach-Object {
        $name = $_.Name
        if ($SkipNames -contains $name) { return }

        $to = Join-Path $targetDir $name

        if ($name -eq $AdvancedName) {
            $body = [System.IO.File]::ReadAllText($_.FullName)
            if ($body.Length -gt 0 -and [int][char]$body[0] -eq 0xFEFF) {
                $body = $body.Substring(1)
            }
            $srcNorm = ($src -replace '\\', '/')
            $advancedChunks.Add("# --- projectDocu source: $srcNorm ---`n$($body.TrimEnd())`n") | Out-Null
            [void]$written.Add($name)
            return
        }

        Copy-Item -LiteralPath $_.FullName -Destination $to -Force
        [void]$written.Add($name)
    }
}

if ($advancedChunks.Count -gt 0) {
    $header = @(
        "# Merged by .winccoa-docu-builder/scripts/merge-project-docu.ps1"
        "# Sources applied top to bottom; later Doxygen keys override earlier ones."
        ""
    ) -join "`n"
    $outPath = Join-Path $targetDir $AdvancedName
    [System.IO.File]::WriteAllText($outPath, ($header + ($advancedChunks -join "`n")), [System.Text.UTF8Encoding]::new($false))
}

Write-Host "Merged into: $targetDir"
$written | Sort-Object | ForEach-Object { Write-Host "  - $_" }

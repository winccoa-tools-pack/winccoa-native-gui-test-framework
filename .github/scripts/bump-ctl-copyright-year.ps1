$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path "$PSScriptRoot/../..").Path
$year = (Get-Date).Year
$previousYear = $year - 1
$owner = "winccoa-tools-pack"

$targets = @("$repoRoot/src/Squirt", "$repoRoot/tests/WinCC_OA_Test")
$changed = 0

foreach ($base in $targets) {
  if (-not (Test-Path $base)) { continue }

  Get-ChildItem -Path $base -Recurse -Filter *.ctl -File | ForEach-Object {
    $file = $_.FullName
    $content = Get-Content -Path $file -Raw
    $original = $content

    $content = $content -replace "Copyright $previousYear $owner", "Copyright $year $owner"
    $content = $content -replace "Copyright \\d{4} SIEMENS AG", "Copyright $year $owner"
    $content = $content -replace "SPDX-License-Identifier:\\s*GPL-3.0-only", "SPDX-License-Identifier: MIT"

    if ($content -ne $original) {
      Set-Content -Path $file -Value $content -Encoding UTF8
      $changed++
    }
  }
}

Write-Host "Updated files: $changed"

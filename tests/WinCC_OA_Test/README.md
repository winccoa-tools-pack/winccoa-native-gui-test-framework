# WinCC OA Tests

This directory contains automated tests based on the WinCC OA TestFramework.

## Local prerequisites

- Installed WinCC OA 3.21 with `WCCILpmon.exe` and `WCCOActrl.exe`
- Installed TestFramework project under your WinCC OA installation
- PowerShell 5.1+ on Windows

## Run regression tests locally

Use the local helper script from repository root:

```powershell
./devTools/run-local-tests.ps1 -RunId "Regression-tests"
```

The script creates a dynamic config for
`tests/WinCC_OA_Test/Projects/TfCustomizedSquirt/config/config`,
registers with `-autofreg`, runs the selected test run, and converts results
to jUnit.

## Check CTL formatting locally

Dry-run check (fails if formatting changes would be needed):

```powershell
./devTools/check-ctrl-code-style.ps1 -SourcePath "src/Squirt"
```

Apply formatting locally before commit:

```powershell
./devTools/check-ctrl-code-style.ps1 -SourcePath "src/Squirt" -ApplyChanges
```

## Check copyright locally

Check only:

```powershell
./devTools/check-ctl-copyright.ps1
```

Apply automatic updates (year, owner, SPDX) and re-check:

```powershell
./devTools/check-ctl-copyright.ps1 -ApplyChanges
```

---

<!-- markdownlint-disable-next-line MD033 -->
<center>Made with ❤️ for and by the WinCC OA community</center>

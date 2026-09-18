# WinCC OA Tests

This directory contains automated tests based on the WinCC OA TestFramework.

## Local prerequisites

- Installed WinCC OA 3.21 with `WCCILpmon.exe` and `WCCOActrl.exe`
- Installed TestFramework project under your WinCC OA installation
- PowerShell 5.1+ on Windows

## Run regression tests locally

This repository no longer ships an in-repo local runner wrapper.
Run the configured test run with your local WinCC OA TestFramework setup,
using the configuration under `tests/WinCC_OA_Test/Projects/TfCustomizedSquirt`.

For the CI setup and the expected TestFramework execution model, see:

- `.github/workflows/ci.yml`
- `.github/ACTIONS_CONTRACT.md`

## Style and copyright checks

This repository no longer ships in-repo helper scripts for CTL formatting or
copyright checks.

Use the maintained org tooling instead:

- CTL formatting: `winccoa-tools-pack/github-actions-winccoa/actions/winccoa-style-check@main`
- Copyright validation: `winccoa-tools-pack/github-actions-winccoa/actions/ctrl-copyright-check@main`

The corresponding repository workflows are:

- `.github/workflows/ctrl-code-style-check.yml`
- `.github/workflows/ctrl-copyright-check.yml`

---

<!-- markdownlint-disable-next-line MD033 -->
<center>Made with ❤️ for and by the WinCC OA community</center>

# WinCC OA Tests

This directory contains automated tests based on the WinCC OA TestFramework.

## Local prerequisites

- Installed WinCC OA 3.21 with `WCCILpmon.exe` and `WCCOActrl.exe`
- Installed TestFramework project under your WinCC OA installation
- PowerShell 5.1+ on Windows
- Node.js + npm (for CTL style checks via the public CLI package)

## Run regression tests locally

Register Project TfCustomizedSquirt as runnable project
Start the WinCC OA Console whithin TfCustomizedSquirt
Start the WinCC OA ctrl manager testRunner.ctl

## GUI tests and GitHub automation

GUI tests are currently **not supported in GitHub Actions automation** because
a working display is not available. This includes the `shapes` test run in
[testRuns.config](testRuns.config), which is currently excluded from the
automated `Regression-tests` run. This limitation does not apply to non-GUI
CTRL unit tests.

**Run the GUI tests locally before merging a pull request.** A passing GitHub
Actions run does not verify GUI behavior while these tests are excluded.
Use a local WinCC OA environment with a display and the TestFramework setup
described above. Start the CTRL manager with `testRunner.ctl shapes -n` to
select the GUI shape test run explicitly.

The display setup is being investigated, and a fix is pending DevOps feedback.
There is no confirmed completion date yet. Update this section when GUI
execution is supported and the tests are enabled in GitHub automation.

## Style and copyright checks

Use the published package
[`@winccoa-tools-pack/npm-winccoa-ctrl-code-style`](https://www.npmjs.com/package/@winccoa-tools-pack/npm-winccoa-ctrl-code-style)
(CLI bin: `winccoa-ctrl-style`). CI currently pins **0.2.1**.

From the repository root (requires a local WinCC OA install):

```powershell
# one-shot via npx (no permanent install)
npx --yes @winccoa-tools-pack/npm-winccoa-ctrl-code-style@0.2.1 check ./src/Squirt -v 3.21
npx --yes @winccoa-tools-pack/npm-winccoa-ctrl-code-style@0.2.1 format ./src/Squirt -v 3.21
```

Or install the CLI, then run:

```powershell
npm install --no-save @winccoa-tools-pack/npm-winccoa-ctrl-code-style@0.2.1

# register StyleCheck (non-runnable) + worker project once
npx winccoa-ctrl-style register ./src/Squirt -v 3.21

# dry-run: exit non-zero if formatting would change files
npx winccoa-ctrl-style check ./src/Squirt -v 3.21

# format CTL in place
npx winccoa-ctrl-style format ./src/Squirt -v 3.21

# tests tree (worker path + optional -s source subtree)
npx winccoa-ctrl-style check ./src/Squirt -v 3.21 -s ./tests/WinCC_OA_Test
npx winccoa-ctrl-style format ./src/Squirt -v 3.21 -s ./tests/WinCC_OA_Test
```

Skip re-registration when the worker is already set up:

```powershell
npx winccoa-ctrl-style check ./src/Squirt -v 3.21 --no-register
```

## Check copyright locally

There is **no** published npm copyright CLI. Headers are enforced in CI by
`ctrl-copyright-check` (see `.github/workflows/ctrl-copyright-check.yml`):

- owner: `winccoa-tools-pack`
- SPDX: `MIT`
- paths: `src/Squirt`, `tests/WinCC_OA_Test`

Year bumps are handled by the scheduled workflow
`.github/workflows/yearly-copyright-update.yml`
([octivi/update-copyright-year](https://github.com/marketplace/actions/update-copyright-year)).

---

<!-- markdownlint-disable-next-line MD033 -->
<center>Made with ❤️ for and by the WinCC OA community</center>

# Squirt CLI Tests

This suite tests the pure path-validation rules used by `splash/cli.ctl`. It
runs as a CTRL manager with `-n`; it does not launch WCCOAui, create panels, or
write datapoints. It is suitable for headless execution in GitHub Actions.

## Coverage

The OaTest script is based on the installed WinCC OA
`data/hsp/templates/scriptEditor/newUnitTest.ctl` template.

| Test method | Checks |
| --- | --- |
| `testAcceptedPanelPaths` | Root-level, nested and leading-slash project panel paths |
| `testRejectedPanelPaths` | Absolute paths, traversal, malformed separators and non-panel extensions |
| `testAcceptedTestScriptPaths` | Nested `.ctl` paths under `scripts/tests/` |
| `testRejectedTestScriptPaths` | Outside-root, traversal, absolute, malformed and non-CTL paths |

The tested `SplashCliValidation` class is used by the production CLI, so the
suite exercises the same validation code. It does not invoke CLI operations
that launch or control a UI manager.

## Display-Dependent Integration

The `record` command starts WCCOAui, and end-to-end tests for recording,
pause/resume, stop, and playback require a working display and an authorized
test project. Keep those checks separate from this headless suite. Run them
locally before merging changes to manager lifecycle or recorder integration;
the repository's GH image currently has no display, so they are not part of
the automated regression run.

## Run

The `cli` run is registered in
[testRuns.config](../../testRuns.config) and included in
`Regression-tests`. With `TfCustomizedSquirt` configured for this checkout:

```powershell
& '<WinCC OA installation>/bin/WCCOActrl.exe' -proj TfCustomizedSquirt testRunner.ctl cli -n -log +stderr
```

The suite's test project manager runs
`tests/libs/classes/splash/SplashCliValidation.ctl -n`.

---

<!-- markdownlint-disable-next-line MD033 -->
<center>Made with ❤️ for and by the WinCC OA community</center>
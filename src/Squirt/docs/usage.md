# Usage

Squirt GUI tests follow the WinCC OA `OaTest` concept.

## Typical workflow

1. Record macros and verification points against native panels (`.pnl` / `.xml`).
2. Replay tests locally (GEDI + HSP) or from the command line.
3. Run the same suites under WinCC OA TestFramework in CI/CD.
4. Review assertion logs and screenshots on failures.

## Execution modes

| Mode | When to use |
| --- | --- |
| GEDI + HSP | Interactive development and local debugging |
| Command line | Repeatable local runs without the IDE UI |
| TestFramework / CI | Automated gates and release validation |

## Shape addressing constraints

- Do not use `:` in panel names.
- Do not leave shape names empty.
- Prefer unique shape names (especially inside Tab shapes).
- Avoid randomly generated module, panel, or shape names.

Only WinCC OA shapes can be recorded and replayed (no file selectors,
printers, and similar OS dialogs).

## CLI tests

The `suite_CLI` test run exercises the path validation shared by `sq-cli` and
the production CLI. It runs under a CTRL manager with `-n`, does not start a UI
manager, and can run in a headless environment such as the current GitHub
Actions image.

Run it locally through CtrlTF:

```powershell
& '<WinCC OA installation>/bin/WCCOActrl.exe' -proj TfCustomizedSquirt testRunner.ctl cli -n -log +stderr
```

The test suite and its coverage are documented in
[`suite_CLI`](../../../tests/WinCC_OA_Test/TestSuites/suite_CLI/README.md).

The suite does not start or stop WCCOAui. Recording, pause/resume, stop, and
replay integration checks require a working display and a test project with
the panel available. Run those checks locally; they are excluded from
headless CI until a display is available in the GH image.

---

<center>Made with ❤️ for and by the WinCC OA community</center>

# Splash Unit Tests

This suite tests non-GUI CTRL behavior in `classes/splash/Splash` using
`OaTest`. It does not create panels, launch managers or invoke `system()`.

## Configuration

| Setting | Value |
| --- | --- |
| CtrlTF test-run ID | `unit` |
| Suite | `suite_unit` |
| Test project | `unit` |
| Subproject | `sub_unit` |
| Manager | CTRL |
| Manager options | `tests/libs/classes/splash/Splash.ctl -n` |

[testProj.unit.config](testProj.unit.config) registers the test manager.
The `unit` entry in [testRuns.config](../../testRuns.config) selects this suite.
The test project must include the Squirt source subproject and the installed
WinCC OA OaTest libraries in its search paths.

## Coverage

The [Splash test](sub_unit/scripts/tests/libs/classes/splash/Splash.ctl) follows
the current HSP `newUnitTest.ctl` template: public `int test*()` methods,
`cla.readArguments()` and `startAll()`.

| Test method | Checks |
| --- | --- |
| `testCommandStates` | Play, pause, resume, record and ready commands, including payloads |
| `testStoppedAndUnknownStates` | Stop, finished, empty, unknown and case-sensitive inputs |
| `testCachedScriptPath` | Constructors and repeated reads preserve the cached script path |
| `testScriptParameters` | First-line marker, whitespace, empty values, newline handling and relative paths |
| `testNonScriptPaths` | Non-CTL filenames are ignored without file access |

The harness provides the global `spSplash` referenced by
`Splash::getStateFromString()`. Its default constructor enables neither
recording nor playback callbacks. The tested class remains unchanged.

Parameter tests create `data/oaTest_Splash_params.ctl` in the test project,
refuse to overwrite an existing file and remove their fixture afterward.
Tests that alter the static script-path cache restore its previous value.
The default constructor can create `scripts/tests/splash` when it is absent.

## Exclusions

The following methods are intentionally not called until process execution can
be mocked:

- `record()` and `startManager()` invoke `system()` directly.
- `play()` reaches `system()` through `startManager()`.
- `reactOnCommands()` can invoke `system()`, operate the recorder and exit.

Datapoint operations (`initInterface()`, `stop()` and `onClose()`) are also
outside this database-independent unit suite.

## Execution

With `TfCustomizedSquirt` registered and configured for this checkout, run:

```powershell
& '<WinCC OA installation>/bin/WCCOActrl.exe' -proj TfCustomizedSquirt testRunner.ctl unit -n -log +stderr
```

CtrlTF prepares the test project, runs the configured manager and collects the
OaTest results. No UI manager or launcher panel is required.

For a direct run in a registered project whose search paths include Squirt and
`sub_unit`:

```powershell
& '<WinCC OA installation>/bin/WCCOActrl.exe' -proj '<test project>' tests/libs/classes/splash/Splash.ctl -n -log +stderr
```

## Adding Tests

Start from the installed HSP `data/hsp/templates/scriptEditor/newUnitTest.ctl`.
Mirror the tested library path below `sub_unit/scripts/tests/libs`, register
the script in [testProj.unit.config](testProj.unit.config), and keep tests
deterministic. Do not call process-launching methods before mocking is available.

---

<!-- markdownlint-disable-next-line MD033 -->
<center>Made with ❤️ for and by the WinCC OA community</center>

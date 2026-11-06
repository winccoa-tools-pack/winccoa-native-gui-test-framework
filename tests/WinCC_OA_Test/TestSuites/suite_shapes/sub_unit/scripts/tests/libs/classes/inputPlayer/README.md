# Input Player Regression Scripts

These standalone OaTest scripts create their own named modules and dynamic
widgets. They do not modify the existing combined player test or require a
hand-authored shape panel. Run them sequentially in a running test project
with Squirt configured as a subproject and a desktop display available.

| Script | Coverage |
| --- | --- |
| `TextInput.ctl` | Whole-string Unicode input, empty clear, replacement, explicit commit |
| `WidgetInput.ctl` | Idempotent checkbox state, combo selection, duplicate rejection, table cell and row input |
| `ReadinessAndDrag.ctl` | Immediate checks, timeout failures, hidden/disabled targets, shortcuts, drag selection and invalid bounds |

## Run

Use a separate UI manager for each script. For example:

```powershell
$ui = '<WinCC OA installation>/bin/WCCOAui.exe'
$script = '<suite_shapes>/sub_unit/scripts/tests/libs/classes/inputPlayer/TextInput.ctl'
$arguments = '-proj "<test-project>" -p "about.pnl" -s "' + $script + '" -log +stderr'
Start-Process $ui -ArgumentList $arguments -Wait -PassThru
```

Repeat with the other script names. Read the OaTest `Checks done` summary;
the process exit code alone does not represent failed assertions. Counts
represent assertions, not test methods. Each script closes only its owned
module before exiting its UI manager.

## Current Validation

Native WinCC OA 3.22 validation on 2026-10-19:

| Script | Passed | Failed | Aborted |
| --- | ---: | ---: | ---: |
| `TextInput.ctl` | 7 | 0 | 0 |
| `WidgetInput.ctl` | 17 | 0 | 0 |
| `ReadinessAndDrag.ctl` | 27 | 1 | 0 |

`testDragSelection` remains an intentional regression detector: the direct
selection endpoint check passes, but the subsequent Backspace deletion does
not satisfy the multi-character removal assertion. Do not weaken that assertion
to accept deletion of a single character. Drag behavior
and native double-click callbacks require further event-panel validation.
Tree helpers are not covered by these passing scenarios; the existing combined
script retains its tree diagnostic, which currently fails to expand the parent.

---

<center>Made with ❤️ for and by the WinCC OA community</center>
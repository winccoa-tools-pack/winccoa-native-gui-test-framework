# Simplify Input Macros

This utility identifies low-level mouse press, optional short wait, and matching
release sequences that can use the higher-level `InputEventPlayer` click helpers.
It only rewrites events with the same coordinates and modifiers. Holds longer
than 100 ms and mismatched sequences are left unchanged. Sleeps longer than
10 seconds are reported with their line and any rationale comment directly
above. `--apply` refuses to modify a file if a long sleep has no such comment.
Runs of printable `keyClick` calls and Ctrl+A/Backspace pairs are reported as
`writeText` and `clearText` candidates. These keyboard suggestions are advisory
and are not rewritten by `--apply`, because the helpers click the target shape.
Other multi-key runs are reported for manual review rather than silently ignored.
Consecutive button-free mouse events are also reported as possible redundant
pointer movements; button releases and moves separated by another action are
preserved. These movement findings are advisory and never auto-applied.

Dry-run is the default and reports candidate replacements without changing the
input file:

```powershell
node devTools/simplify-input-macros/simplify-input-macros.mjs --dry-run path\to\macros.ctl
```

Review the report, then pass `--apply` to write the replacements:

```powershell
node devTools/simplify-input-macros/simplify-input-macros.mjs --apply path\to\macros.ctl
```

Run the converter tests with:

```powershell
node --test devTools/simplify-input-macros/simplify-input-macros.test.mjs
```

Add a short comment directly above every long sleep explaining which UI state
or event the delay is waiting for. Prefer a state/readiness wait over a long
fixed delay when the test can observe that condition.

---

<center>Made with ❤️ for and by the WinCC OA community</center>
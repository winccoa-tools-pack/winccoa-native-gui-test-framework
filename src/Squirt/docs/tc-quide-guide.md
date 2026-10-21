# Test guide panel

`panels/vision/tc_quide.pnl` provides instructions alongside an interactive
GUI test step. It is part of the Squirt framework; a worker project must have
the Squirt subproject available so WinCC OA can resolve the panel at
`panels/vision/tc_quide.pnl`.

The caller provides the guide values and controls the product-specific UI
interaction. `SplashGuidedMacroRecorder` writes `.tcQuide.json`, starts input
recording, launches the guide, and saves the recorded macro when the user
finishes. The panel itself only displays the configured values and signals
completion.

## Caller configuration

`SplashGuidedMacroRecorder.startGuide()` writes `.tcQuide.json` to the active
WinCC OA project root before launching the panel. The panel reads
`PROJ_PATH + ".tcQuide.json"` once during its `Initialize` event. Changing the
file while the panel is open does not refresh the displayed fields.

The JSON object has three string properties:

| Property | Purpose |
| --- | --- |
| `macroName` | Name the caller or recording consumer will use for the macro. |
| `libraryPath` | Full native path to the destination CTRL library, such as `C:\Project\scripts\libs\macros.ctl`. |
| `quide` | Instructions displayed in the guide. The property spelling is `quide`. |

Example for a Windows worker project:

```json
{
  "macroName": "macro_selectDP",
  "libraryPath": "C:\\WinCC_OA_Proj\\DPE_monitor_test_3.22\\scripts\\libs\\macros.ctl",
  "quide": "In the DPE selector, choose the requested data point and add it to the monitor."
}
```

Use valid JSON escaping for Windows backslashes. Supply all three properties
explicitly rather than relying on empty or panel defaults. The recorder helper
requires a `macro_` function name and a full `.ctl` path under the active
project's `scripts/libs` directory.

## Open the guide

The panel path is relative to the Squirt subproject's `panels` directory. In a
GUI test, start recording before the interaction, then launch the guide after
the test reaches the point where the user should follow its instructions:

```ctrl
#uses "classes/splash/SplashGuidedMacroRecorder"

SplashGuidedMacroRecorder recorder = SplashGuidedMacroRecorder();
recorder.startRecording("data/tmp/macro_capture.ctl", "macro_selectDP",
                        "C:\\Project\\scripts\\libs\\macros.ctl");
// Open the product-specific selector before presenting the guide.
recorder.startGuide("vision/tc_quide.pnl",
                    "Choose the requested data point and confirm it.");
```

Check each method's return value and use `getErrorMessage()` for setup failures.
After launch, wait for `isRecordingStopped()` before checking
`isRecordingSaved()`. The guide runs in a separate UI process, so its close
does not terminate the test manager.

## JSON and command handshake

1. The caller supplies `macroName`, `libraryPath`, and `quide` to the helper.
2. `startGuide()` writes `.tcQuide.json` in the worker project root and opens
  `vision/tc_quide.pnl` from the Squirt panel resources.
3. The panel's `Initialize` event decodes the JSON and fills `macroNameInput`,
   `libraryPathInput`, and `guideText`.
4. When the user clicks **Finish recording**, the panel sends
   `stop|<macroName>|<libraryPath>` to `_Splash.command`, clears
   `_Splash.response`, and closes the guide panel. The panel's Close event also
   attempts to send the stop payload; a guard prevents duplicate sends.
5. The helper's `_Splash.command` listener stops recording, converts the
  captured interaction into the configured macro function, writes the
  temporary script, and appends the function to the configured library. The
  caller waits for completion and checks the helper's saved/error status.

For example, with the sample JSON above, the command value is:

```text
stop|macro_selectDP|C:\WinCC_OA_Proj\DPE_monitor_test_3.22\scripts\libs\macros.ctl
```

`startRecording()` clears any stale `_Splash.command` value and registers the
listener before the guide is opened. The caller should start recording before
opening the UI interaction that it wants captured.

---

<center>Made with ❤️ for and by the WinCC OA community</center>
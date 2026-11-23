# Touch Input Guide

`SquirtInputEventPlayer` injects native UI touch frames through
`sendTouchEvent`. Injection is not proof that a widget recognized a gesture.
Check its callbacks and resulting state, as the runnable examples do.
These helpers do not change existing mouse APIs.

## APIs

All addresses have the form `module.panelInstance:shapeName`. Include
`#uses "classes/SquirtInputEventPlayer"` in the UI script.

| Method | Behavior |
| --- | --- |
| `touchFrame(address, points, timeout=2000)` | Validates and sends one complete frame; caller owns the sequence. |
| `tapShape(address, timeout=2000)` | Center press, 50 ms dwell, release. |
| `doubleTapShape(address, timeout=2000)` | Two taps with a 50 ms gap. |
| `longPressShape(address, duration=1200, timeout=2000)` | Center press, dwell, release. |
| `swipeShape(address, fromX, fromY, toX, toY, steps=10, duration=300, timeout=2000)` | One contact with interpolated movement and release. |
| `twoContactGesture(address, starts, ends, steps=10, duration=300, timeout=2000)` | Exactly two persistent contacts, interpolated movement, simultaneous release. |

`starts` and `ends` are `dyn_mapping` arrays with integer `id`, `x`, `y`
entries. Both arrays must have the same IDs in the same order. The helper
supplies states. Steps must be positive; durations must be nonnegative.
There is no generic `pinchShape` recognizer or guarantee of zoom, swipe,
double-click, context-menu, or drag-and-drop recognition on arbitrary widgets.

## Readiness And Timing

The target must exist, be visible and enabled, and have nonzero dimensions.
Readiness waits default to 2000 ms and throw on failure. Coordinates are
integer target-local positions, not screen coordinates: `0 <= x < width`
and `0 <= y < height`. Endpoints are validated before a gesture presses.
High-level gestures resolve the target once; do not move, resize, hide or
destroy it during the sequence. Explicit frames recheck readiness each time.
These checks do not guarantee that an overlapping window leaves it unobscured.

Inherited `setTimeFactor(factor)` multiplies `sleep()` durations, including
dwell, inter-tap gaps, movement intervals and polling sleeps. Default is 1.0;
use a positive factor. Readiness deadlines use elapsed time, not a scaled
timeout. Speeding up playback can defeat native long-press/double-tap/swipe
thresholds. The behavioral tests and examples use the default factor; the
frame-contract test uses 0.01 because it records frames without injecting them.

## Contact Lifecycle

Each `touchFrame` takes a nonempty `dyn_mapping`. Each mapping must contain
integer `id`, `x`, `y` and a string `state`. IDs must be nonnegative and unique
within a frame. States are exactly `pressed`, `moved`, `stationary`, `released`.

1. Introduce a contact with `pressed` and retain its ID until release.
2. Include every active contact in every frame. Use `stationary` for a contact
   that stays still while another moves; do not silently omit it.
3. Include the final position in a `released` frame. Remove that contact from
   subsequent frames; never send it as released a second time.
4. Finish every contact before starting another independent sequence.

Validation is per frame, not a cross-frame state machine: the library does not
detect a moved-before-pressed ID or a missing release. IDs are contact identities,
not array indexes. The high-level one-contact helpers use ID 1; two-contact
helpers use the supplied IDs. Do not interleave helpers, players, threads or
manual touch frames on a shared UI touch stream. There is no concurrency lock,
contact allocator, cancellation API or automatic contact reconciliation.

High-level helpers attempt to release all their contacts at the latest
positions if dispatch or a wait throws, then rethrow the original exception.
Cleanup itself is best-effort and its error is logged. `touchFrame` has no
automatic sequence cleanup: callers must catch errors and attempt release of
all still-active contacts on the same surviving target. Do not suppress the
original failure or claim cleanup succeeded after target destruction.

## Release Policy Matters

On the test-owned [touch surface](sub_uiEvents/panels/touchSurface.pnl), spread
and pinch are recognized with **both contacts released in the same frame**.
The [spread/pinch example](sub_uiEvents/scripts/examples/touchSpreadPinch.ctl)
uses `twoContactGesture` and checks two native zoom callbacks per gesture plus
the direction of `zoomFactor` change.

The observed native **two-finger swipe** instead uses staged release in
[multiTouchEvents.ctl](sub_uiEvents/scripts/tests/panels/multiTouchEvents.ctl):
after moving both contacts right, release ID 1 while ID 2 remains stationary,
wait 30 ms, then release ID 2 alone. For the final two frames:

```ctrl
points[1]["state"] = "released";
points[2]["state"] = "stationary";
player.touchFrame(address, points);
player.sleep(30);
points[2]["state"] = "released";
player.touchFrame(address, makeDynMapping(points[2]));
```

Do not substitute `twoContactGesture` for this swipe sequence: its simultaneous
release policy is different. These are observed fixture/native-3.22 behaviors,
not universal rules for all widgets, versions or platforms.

## Touch And Mouse Events

The [tap example](sub_uiEvents/scripts/examples/touchTap.ctl) uses the
`UiEventTestPanels/ToolVerification.pnl` fixture with adjusted child-panel
paths, instance `main_pnl`, and
checks `PUSH_BUTTON_CLICK` through `SELECTION_LIST_RESULTS`.
Native touch handling can generate mouse-style callbacks. In the behavioral
test, tap reports `MouseButtonRelease` with `isSynthesized=false`, while
double-tap reports `MouseButtonDblClick` with `isSynthesized=true`. Long press
produces a left press, right press, then right-button release. The fixture's
release prefix still says "left mouse released"; assert the JSON button too.
`isSynthesized` is callback metadata, not reliable provenance for whether a
test injected touch. Neither mouse callbacks nor dispatch success alone prove
native pinch recognition. Zoom changes and gesture payloads provide that evidence.

## Run Examples And Tests

Use an interactive desktop with the already-running `DPE_monitor_test_3.22`.
Its existing configuration includes Squirt and this suite's `sub_uiEvents`.
Do not restart CtrlTF or edit configuration. Use current
`main/UiFiles/scripts/libs/classes/InputEventPlayer.ctl` and
`main/Test/CtrlTF/WinCC_OA_Test/TestSuites/suite_MultiTouch` as authoring references,
not potentially older installation scripts.

Run sequentially with native WinCC OA 3.22, **`-touch -style fusion`**:

```powershell
$ui = 'C:\Program Files\Siemens\WinCC_OA\3.22\bin\WCCOAui.exe'
$root = 'C:\ws\winccoa-tools-pack\winccoa-native-gui-test-framework\tests\WinCC_OA_Test\TestSuites\suite_uiEvents\sub_uiEvents\scripts'
$scripts = @(
  'examples\touchTap.ctl',
  'examples\touchSpreadPinch.ctl',
  'tests\panels\touchEvents.ctl',
  'tests\panels\multiTouchEvents.ctl',
  'tests\libs\classes\SquirtTouchFrames.ctl'
)
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
foreach ($relative in $scripts) {
  $name = [IO.Path]::GetFileNameWithoutExtension($relative)
  $prefix = Join-Path $env:TEMP "$name-$stamp"
  $process = Start-Process $ui -ArgumentList @(
    '-proj', 'DPE_monitor_test_3.22', '-p', 'about.pnl',
    '-s', (Join-Path $root $relative), '-touch', '-style', 'fusion',
    '-log', '+stderr'
  ) -RedirectStandardError "$prefix.err.log" `
    -RedirectStandardOutput "$prefix.out.log" -PassThru
  if (-not $process.WaitForExit(60000)) {
    $process.Kill()
    throw "Timed out: $relative; inspect $prefix.err.log"
  }
  $log = Get-Content "$prefix.err.log" -Raw
  Write-Output "$relative : $prefix.err.log"
  Get-Content "$prefix.err.log" -Tail 20
  if ($log -notmatch 'Checks done' -or
      $log -notmatch 'Failed : 0' -or $log -notmatch 'Aborted : 0') {
    throw "Incomplete or failed test: $relative"
  }
}
```

Both examples use OaTest cleanup and `exit(0)` to terminate only their own UI
manager. They refuse an already-open example module rather than reusing it.
The process exit code is not the verdict: require the final `Checks done`
summary and review all counts and diagnostics. Keep stderr and stdout.
For syntax-only checking use the same UI executable with
`-proj DPE_monitor_test_3.22 -n -syntax <absolute-script> -touch -style fusion -log +stderr`.
A CTRL-only check is not authoritative for UI APIs.

## Verified Evidence

Fresh local run: **2026-10-20 00:00:58**, native Windows 3.22.0,
`DPE_monitor_test_3.22`, default time factor, `-touch -style fusion`.
The previous agent's 2026-10-19 stderr summaries were also read directly and
confirmed 44, 18 and 161 passed assertions, not merely a prior progress claim.

All fresh logs are in `C:\Users\atw12ru2\AppData\Local\Temp`:

| Script | Passed assertions | Stderr log |
| --- | --- | --- |
| `touchEvents.ctl` | 44 | `touchEvents-fresh-20261020-000058.err.log` |
| `multiTouchEvents.ctl` | 18 | `multiTouchEvents-fresh-20261020-000058.err.log` |
| `SquirtTouchFrames.ctl` | 161 | `SquirtTouchFrames-fresh-20261020-000058.err.log` |
| `touchTap.ctl` | 5 | `touchTap-fresh-20261020-000058.err.log` |
| `touchSpreadPinch.ctl` | 8 | `touchSpreadPinch-fresh-20261020-000058.err.log` |

Every summary reports 0 failed, aborted, known bugs, skipped and instable.
The three tests total **223** assertions; the examples add **13**.
Frame-contract checks record dispatches and inject failures; they do not
prove gesture recognition. Behavioral logs show spread zoom
`1 -> 1.6675`, pinch `1.6675 -> 0.9995004995005`, two zoom callbacks per
gesture, and swipe payload `touchpoints:2, horizontal:right, vertical:none`.
The example independently reproduced the same zoom changes.

Stdout files use the same stems with `.out.log`. Native syntax logs are
`touchTap-syntax-20261020-000001.err.log` and
`touchSpreadPinch-syntax-20261020-000044.err.log`, also with paired stdout.
These are local temporary evidence, not committed artifacts.

The tap example, single-touch test and frame-contract test each report a
missing `pictures/SplashLogo.jpg` pixmap warning from the existing fixture.
It is not suppressed; assertions still pass. No fixtures were repaired here.
Existing mouse-suite clipboard/focus failures remain unresolved and unchanged;
touch results do not supersede them.

## Post-Rename Verification

On 2026-10-20 at 00:16:10, all six scripts were run sequentially against
the existing project with native 3.22.0. Touch runs used `-touch -style fusion`;
the mouse run did not. Every run exited zero and emitted `Checks done`.

| Script | Passed | Failed | Aborted |
| --- | --- | --- | --- |
| `touchEvents.ctl` | 44 | 0 | 0 |
| `multiTouchEvents.ctl` | 18 | 0 | 0 |
| `SquirtTouchFrames.ctl` | 161 | 0 | 0 |
| `touchTap.ctl` | 5 | 0 | 0 |
| `touchSpreadPinch.ctl` | 8 | 0 | 0 |
| `uiEvents.ctl` | 139 | 2 | 0 |

Logs are in the same temporary directory as above, named
`ui-event-rename-<script-stem>-20261020-001610.err.log`, with paired
`.out.log` files. The two mouse failures are the existing
`testTextClipboardFocus` record-count and exact-sequence assertions.
The missing JPG pixmap warning remains unsuppressed.

Native UI syntax checks passed for the four updated CTL files: `uiEvents`,
`touchEvents`, `SquirtTouchFrames` and `touchTap`. Their logs use
`ui-event-rename-<script-stem>-syntax-20261020-001549.err.log`.
All six renamed main/child-panel references resolve. The suite has zero
obsolete-label matches in content and filenames, including ignored files.

The retained `sub_uiEvents/pictures/SplashLogo.png` has identical SHA-256
before and after the rename:
`FD3E2E6C7ABB1DCDCDCE98C1226BC17D2205401542E424B9998C64C9754141C8`.
No matching image directory existed in this checkout, so no image move was
needed. The main panel's child-panel paths changed; callbacks and legal
notices were preserved.

---

<center>Made with ❤️ for and by the WinCC OA community</center>
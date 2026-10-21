# Native UI Event Tests

Standalone OaTest coverage with legacy UI event fixtures copied from the
WinCC OA source repository, source commit
`e1a46247aaa4d6b16a79f2831125abb7885af0a1`.

The panels are under `sub_uiEvents/panels/UiEventTestPanels`. Their internal
child-panel references are adjusted to the renamed directory, so the main
panel is not byte-identical to the source. The replacement logo is retained
unchanged at `sub_uiEvents/pictures/SplashLogo.png`. There is no fixture
directory under `sub_uiEvents/images` in this checkout.
No legacy test driver, project configuration, generated screenshot
or screenshot reference baseline was copied.

## Provenance

The three panels originate in the WinCC OA source repository. Their notices
and callbacks are preserved; only the child-panel paths are adjusted. The
original fixtures referenced `pictures/ETM_Logo.jpg`, which is not included
here. Copying the panels here does not establish that they or the ETM logo
are licensed under this repository's MIT license. Confirm redistribution
terms before publishing or packaging them.

The new CTL driver and replacement logo are repository-owned content, not a
relicensing of the copied resources. The replacement PNG is a transparent
625x188 raster rendering of `src/Squirt/docs/images/squirt-logo.svg`, including
its Splash wordmark and taglines. It replaces the previous checker artwork
and is not a screenshot baseline.

SHA-256 of the original image and the retained replacement `SplashLogo.png`:

```text
Original:    1647687F1D8CD5CFA23554554CAC40B7C7BF555DCAB28BE622622CA984DC4210
Replacement: FD3E2E6C7ABB1DCDCDCE98C1226BC17D2205401542E424B9998C64C9754141C8
```

## Panel Contract

Open `UiEventTestPanels/ToolVerification.pnl` with the panel instance name
`main_pnl`. RegisterPanel2 locates the result list using that name in its
owning module. Preserve it when selecting a test-owned module name.

The main panel references `RegisterPanel1.pnl` and `RegisterPanel2.pnl` under
the same `UiEventTestPanels` directory. The screenshot shape still references
`pictures/SplashLogo.jpg`, which is absent; the retained logo is the PNG at
`pictures/SplashLogo.png`. This rename does not change that existing warning.
The named `del_en.gif` resource is not included in the source subtree; check
its resolution through the configured WinCC OA installation.

Callbacks append records to `SELECTION_LIST_RESULTS`. Most mouse/key records
contain a descriptive prefix followed by `jsonEncode(event, true)`. Other
callbacks report initialization, focus, text verification, table and drop
information. A new native driver should read individual records, decode the
JSON where present, and assert their order and values. Do not reproduce the
legacy driver's substring search across the complete accumulated list: it can
combine unrelated events into a false pass.

## Existing Test Intent

The legacy UI event fixtures and their original driver provide the expectations:

- Panel opening and eight initialization messages.
- Left clicks and double-clicks with no modifiers, Ctrl, and Ctrl+Alt.
- Mouse press/release and modifier-release ordering; right-button events.
- Table row 1, column `Forename`, with value `Martin`.
- Tab changes through mouse and arrow keys, followed by the second tab's button.
- Focus transitions and clipboard transfer of `Tool Verification 2`.
- Geometry, appearance and screenshot comparison.

The original drag/drop case is disabled. RegisterPanel1's drop callback refers
to `SELECTION_LIST1`, which is absent; repair it in a deliberate fixture change
before enabling drop coverage. Some legacy release expectations also combine
`buttons:0` with `buttonsAsString:LeftButton`; verify actual event semantics
rather than copying those assertions unchanged.

## Implemented Coverage

The standalone driver is `sub_uiEvents/scripts/tests/panels/uiEvents.ctl`.
It adapts the current UiFiles HSP `newUnitTest.ctl` structure and uses
`#uses "classes/SquirtInputEventPlayer"` plus public OaTest methods:

- `testInitialization`: all eight initialization records in creation order.
- `testLeftClicks`: no modifier, Ctrl, and Ctrl+Alt; release event fields.
- `testPressRelease`: left press/release order, including modifiers on press
	and no modifiers on release; held-button names must agree with bitmasks.
- `testRightClicks`: no modifier and Ctrl; only the right-press callback.
- `testTableCell`: row 1, column Forename, value Martin, in exact record order.
- `testTabs`: mouse selection and right-arrow navigation, each followed by
	the RP2 button's actual prefix/JSON callback pair.
- `testTextClipboardFocus`: keyboard entry, select-all/copy/paste shortcuts,
	four ordered focus transitions and exact pasted-text verification.
- `testNativeDoubleClick`: actual native `MouseButtonDblClick`, not two
	ordinary clicks or a manually invoked callback.

Each action starts with the fixture's clear button. Bounded waits check exact
list sizes; adjacent prefix/JSON pairs are decoded and checked individually.
There is no accumulated-log substring search. Clipboard/focus expectations
remain strict even when they fail. The clipboard case uses the desktop
clipboard and can replace its current contents; run on a test desktop.

## Direct Native Run

The existing `DPE_monitor_test_3.22` configuration already includes Squirt and
this suite's `sub_uiEvents`. Do not edit that configuration, restart the
project, or start the whole CtrlTF runner. The project must already be running.
Use an interactive Windows desktop with the native 3.22 binaries and Noto Sans.
The API reference for authoring is the current source tree at
`C:\ws\ETM\WinCCOA\main\UiFiles`, not installation scripts.

Run this PowerShell command directly; no CtrlTF configuration is required:

```powershell
$script = 'C:\ws\winccoa-tools-pack\winccoa-native-gui-test-framework\tests\WinCC_OA_Test\TestSuites\suite_uiEvents\sub_uiEvents\scripts\tests\panels\uiEvents.ctl'
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$err = Join-Path $env:TEMP "uiEvents-$stamp.err.log"
$out = Join-Path $env:TEMP "uiEvents-$stamp.out.log"
$process = Start-Process 'C:\Program Files\Siemens\WinCC_OA\3.22\bin\WCCOAui.exe' -ArgumentList @('-proj', 'DPE_monitor_test_3.22', '-p', 'about.pnl', '-s', $script, '-log', '+stderr') -RedirectStandardError $err -RedirectStandardOutput $out -Wait -PassThru
Get-Content $err -Tail 30
```

The driver opens its own `suite_uiEvents_native` module with instance
`main_pnl`. A preexisting module of that name causes setup to stop rather than
reuse another fixture. OaTest handles teardown and `exit(0)` terminates only
this UI manager. Existing combined/standalone Squirt tests are unchanged.

**The process exit code is not a test verdict.** Require a final OaTest
`Checks done` summary and inspect its Failed and Aborted counts. Missing summary
means the run is incomplete, even when the UI process exits zero. Keep stderr
and stdout separate: OaTest results are on stderr, original panel Debug calls
may write on stdout. A CTRL-manager-only syntax check reports UI APIs/constants
as undefined and is not authoritative for this UI script.

## Touch Tests And Examples

The [touch guide](touch.md) documents APIs, complete contact frames, release
policies, timing, cleanup limitations, runnable examples and fresh native logs.
Run touch scripts with `-touch -style fusion` against the existing live project;
do not restart CtrlTF or edit configuration.

- [Single-touch behavior](sub_uiEvents/scripts/tests/panels/touchEvents.ctl):
	tap, double-tap, explicit press/release and long press; 44 assertions.
- [Multitouch behavior](sub_uiEvents/scripts/tests/panels/multiTouchEvents.ctl):
	native spread/pinch zoom and one-/two-finger swipe payloads; 18 assertions.
- [Frame contracts](sub_uiEvents/scripts/tests/libs/classes/SquirtTouchFrames.ctl):
	framing, validation and injected-failure cleanup; 161 assertions.
- [Runnable tap example](sub_uiEvents/scripts/examples/touchTap.ctl):
	actual ToolVerification click callback; 5 assertions.
- [Runnable spread/pinch example](sub_uiEvents/scripts/examples/touchSpreadPinch.ctl):
	actual touchSurface zoom callbacks and zoom changes; 8 assertions.

All five fresh runs on 2026-10-20 report zero failures or aborts. Full log names
and the unsuppressed missing-pixmap warning are recorded in the guide.
Generic two-contact injection does not guarantee pinch recognition, and the
native two-finger swipe uses staged release rather than the helper's
simultaneous release. The mouse driver and its known failures are unchanged.

## Live Results

Post-rename native 3.22.0 verification on 2026-10-20 completed all six direct
runs with final `Checks done` summaries. The five touch scripts passed
44, 18, 161, 5 and 8 assertions respectively, with zero failures or aborts.
The mouse driver retained 139 passed, 2 failed and 0 aborted assertions;
both failures remain in `testTextClipboardFocus`, with three records instead
of five and the same missing right-field focus/paste sequence. No assertions
were relaxed. See the [post-rename evidence](touch.md#post-rename-verification)
for log names and the unchanged logo checksum.

Native 3.22.0 on 2026-10-19, project `DPE_monitor_test_3.22`:

- Initial five-method run: 108 passed assertions, 0 failed, 0 aborted.
- Extended eight-method run: 139 passed assertions, 2 failed, 0 aborted,
	0 known bugs, 0 skipped, 0 instable. These are assertion counts, not cases.
- Initialization, left/right clicks, modifier press/release, table, both tab
	navigation paths, and the actual native double-click callback passed.
- Remaining failures are both in `testTextClipboardFocus`: expected five
	records but received three, and the exact expected record sequence differs.
	Actual: `focus in: TEXT_LEFT`, `focus out: TEXT_LEFT`,
	`Textfield_RIGHT, Value is: ` (empty). TEXT_RIGHT reports enabled and visible,
	but no focus-in/out records arrive and paste is not verified. Using the
	legacy `(50,50)` editor click did not fix it. This is an unresolved native
	interaction limitation, not a passing clipboard test or a suppressed failure.

Drag/drop, geometry, appearance and screenshot comparisons are not enabled.
RegisterPanel1's absent `SELECTION_LIST1` remains unchanged. Physical DPI,
locale and style must be controlled before adding pixel/geometry baselines;
this work does not change scaling settings or fixture callbacks.

---

<center>Made with ❤️ for and by the WinCC OA community</center>
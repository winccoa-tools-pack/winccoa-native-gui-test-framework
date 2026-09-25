# suite_unit — GUI Shape Unit Tests

## Overview

The `suite_unit` test suite provides **real GUI unit tests** for WinCC OA shape wrapper classes. Each test:

1. **Starts** from the universal `about.pnl` panel (exists in all WinCC OA versions)
2. **Creates** an isolated test panel via `ModuleOnWithPanel()` with exact module/panel names for reproducibility
3. **Dynamically adds** the shape under test via `addShape()`
4. **Validates** wrapper attributes and behavior via assertions
5. **Exits cleanly** via the `exit()` function (no explicit panel close needed)

This architecture ensures **test isolation**, **deterministic behavior**, and **version compatibility**.

---

## Test Architecture

### Launcher Panel vs. Test Panel

| Context | Panel | Role | Lifecycle |
|---------|-------|------|-----------|
| **Test Framework** | `about.pnl` | Universal launcher; exists in all versions | Open at test start (TestFramework) |
| **Test Script** | `shapesTest.pnl` | Isolated test context; created per test | Created in setUp() via `ModuleOnWithPanel()` |

**Why two panels?**

- `about.pnl` is guaranteed to exist, ensuring tests can launch in any WinCC OA version.
- `shapesTest.pnl` is created dynamically, providing an isolated, repeatable test environment.
- Test isolation prevents interference from other running components.

### Test Lifecycle


1. TestFramework launches test with: about.pnl + test script (-p about.pnl -s GuiTest{Shape}.ctl -n)
2. setUp() → ModuleOnWithPanel() creates shapesTest.pnl in module "shapesTestModule"
3. addShape() dynamically adds the test shape to the isolated panel
4. testXxx() methods execute validation logic via shape wrapper class
5. tearDown() is called automatically by OaTest (optional cleanup; not needed)
6. exit() closes all panels and managers (TestFramework integration)


### Panel Creation Example (from GuiTestArc.ctl)

```ctl
public int setUp()
{
  OaTest::setUp();
  
  // Create isolated test panel with exact module/panel name
  ModuleOnWithPanel("shapesTestModule", -1, -1, 600, 450, 2, 2, "", 
                    "shapesTest.pnl", "shapesTestPanel", makeDynString());
  
  // Poll for panel to open (blocking)
  while (isPanelOpen("shapesTestPanel", "shapesTestModule") == false)
    delay(0.100);
  
  // Dynamically add test shape
  testArc = addShape("shapesTestModule", "shapesTestPanel", 1, "ARC", "testArc");
  return 0;
}
```

### Shape Validation Example

```ctl
  public int testAttributes()
  {
    this.assertEqual(testShape.name(), "testSelectionList",
                     "Expected shape name to match the generated test name");

    setThrowErrorAsException(true);
    testShape.position(10, 20);
    setValue(testShape, "size", 100, 200);
    setThrowErrorAsException(false);

    GuiTestSelectionList wrapper = GuiTestSelectionList(testShape);
    const mapping current = wrapper.getCurrentAttributes();

    this.assertTrue(current.contains("visible"), "Expected visible attribute");
    this.assertTrue(current.contains("enabled"), "Expected enabled attribute");
    this.assertTrue(current.contains("position.x"), "Expected position.x attribute");
    this.assertTrue(current.contains("position.y"), "Expected position.y attribute");
    this.assertTrue(current.contains("size.w"), "Expected size.w attribute");
    this.assertTrue(current.contains("size.h"), "Expected size.h attribute");

    this.assertEqual(current.value("position.x"), 10,
                     "Expected wrapper to read the x-position");
    this.assertEqual(current.value("position.y"), 20,
                     "Expected wrapper to read the y-position");
    this.assertEqual(current.value("size.w"), 100,
                     "Expected wrapper to read the width");
    this.assertEqual(current.value("size.h"), 200,
                     "Expected wrapper to read the height");

    testShape.visible(FALSE);
    this.assertEqual(wrapper.getCurrentAttributes().value("visible"), false,
                     "Expected visible state to toggle off");

    testShape.visible(true);
    this.assertEqual(wrapper.getCurrentAttributes().value("visible"), true,
                     "Expected visible state to toggle on");

    return 0;
  }
```

---

## Test Files

### Directory Structure

```
suite_unit/
├── README.md (this file)
├── sub_unit/
│   └── scripts/
│       └── tests/
│           └── libs/
│               └── classes/
│                   └── splash/
│                       └── shapes/
│                           ├── GuiTestArc.ctl
│                           ├── GuiTestCascadeButton.ctl
│                           ├── GuiTestCheckBox.ctl
│                           ├── GuiTestPushButton.ctl
│                           ├── GuiTestSlider.ctl
│                           ├── GuiTestTable.ctl
│                           └── ... (31 more shape tests)
└── testProj.unit.config
```

### Test File Naming Convention

- **File:** `GuiTest{ShapeName}.ctl`
- **Class:** `TstGuiTest{ShapeName} : OaTest`
- **Shape Type:** Matches Siemens WinCC OA shape names (e.g., `ARC`, `PUSH_BUTTON`, `LINE`, `SLIDER`)

### Configuration (testProj.unit.config)

Each test entry uses **UI manager mode** with the universal `about.pnl`:

```json
{
  "MANAGER_TYPE" : "UI",
  "MANAGER_OPTIONS" : "-p about.pnl -s tests/libs/classes/splash/shapes/GuiTest{ShapeName}.ctl -n"
}
```

**Key elements:**

- `MANAGER_TYPE: UI` — runs in UI manager context (not CTRL manager)
- `-p about.pnl` — launches from universal launcher panel
- `-s GuiTest{ShapeName}.ctl` — runs test script
- `-n` — non-interactive mode (no pause for input)

---

## Adding New Shape Tests

### Steps

1. **Copy template** from `newUnitTest.ctl` (WinCC OA HSP template):

   ```text
   <wincc--oa-install-path>/data/hsp/templates/scriptEditor/newUnitTest.ctl
   ```

2. **Adapt for your shape:**

   ```ctl
   class TstGuiTest{ShapeName} : OaTest
   {
     private shape<"{SHAPE_TYPE}"> testShape;
     
     public int setUp()
     {
       OaTest::setUp();
       ModuleOnWithPanel("shapesTestModule", -1, -1, 600, 450, 2, 2, "", 
                         "shapesTest.pnl", "shapesTestPanel", makeDynString());
       while (isPanelOpen("shapesTestPanel", "shapesTestModule") == false)
         delay(0.100);
       testShape = addShape("shapesTestModule", "shapesTestPanel", 1, 
                           "{SHAPE_TYPE}", "test{ShapeName}");
       return 0;
     }
     
     public int testAttributeMapping()
     {
       // Your validation logic here
       GuiTest{ShapeName} wrapper = GuiTest{ShapeName}(testShape);
       // Assert wrapper behavior
       return 0;
     }
   }
   ```

3. **Add to testProj.unit.config:**

   ```json
   { "MANAGER_TYPE" : "UI", "MANAGER_OPTIONS" : "-p about.pnl -s tests/libs/classes/splash/shapes/GuiTest{ShapeName}.ctl -user root:" }
   ```

4. **Follow code style:** See [`winccoa-qa`](../../skills/winccoa-qa/) skill for CTL style requirements.

---

## Related Skills

For comprehensive guidance on different aspects of this test suite, see:

| Skill | Purpose |
| ------- | --------- |
| `winccoa-oatest` | OaTest framework concepts and lifecycle |
| `winccoa-gui-shape-tests` | GUI shape testing patterns, panel isolation, dynamic shape creation |
| `winccoa-qa` | CTL code style, syntax validation, quality gates |
| `winccoa-ctrl-test-framework` | CtrlTF runner operations and test execution |
| `winccoa-control-script` | CTL coding fundamentals and debugging |

---

## Debugging & Troubleshooting

### Test Fails: Panel Not Found

**Problem:** `isPanelOpen()` timeout after `ModuleOnWithPanel()`

**Solution:**

- Verify `shapesTest.pnl` exists in the project's panel directory
- Check `ModuleOnWithPanel()` return value (0 = success)
- Increase poll delay if system is slow

### Test Fails: Shape Not Created

**Problem:** `addShape()` returns 0 (invalid)

**Solution:**

- Verify panel is open (`isPanelOpen()` returns true)
- Check shape type matches WinCC OA enum (e.g., `"ARC"`, `"PUSH_BUTTON"`)
- Verify layer and position parameters are valid

### Test Execution Error

**Problem:** Test runs but asserts fail

**Solution:**

- Verify wrapper class exists (`GuiTest{ShapeName}` in libraries)
- Check wrapper attribute mappings match shape properties
- Use `getValue(shape, ...)` to inspect actual shape state before assertion

---

## Running Tests Locally

### Using WinCC OA TestFramework (Recommended)

Register Project TfCustomizedSquirt as runnable project
Start the WinCC OA Console whithin TfCustomizedSquirt
Start the WinCC OA ctrl manager testRunner.ctl

### Using GEDI (Interactive)

1. Register the test project in WinCC OA Project Manager
2. Open GEDI
3. Navigate to **Tests** > **suite_unit**
4. Right-click test > **Run Selected**

---

## Code Quality Requirements

✓ **File header** with `@file`, `@copyright MIT`, `@brief`  
✓ **Doxygen-style comments** for all public/protected members and methods  
✓ **Section markers** (`//@public members`, `//@protected members`, `//@private members`)  
✓ **Line length** ≤ 80 characters where practical  
✓ **No trailing spaces** or trailing blank lines  
✓ **Formatted with astyle** (WinCC OA tool)  
✓ **Localized strings** wrapped in `tr()` for `de_AT.utf8` and `en_US.utf8`

---

## Contributing

When adding or modifying shape tests:

1. **Keep changes focused** — one shape test per PR
2. **Test locally first** — verify with `testRunner.ctl` before pushing
3. **Preserve existing tests** — do not refactor unrelated tests in the same PR
4. **Update this README** if test architecture changes
5. **Add or update skills** if new patterns emerge

---

<!-- markdownlint-disable-next-line MD033 -->
<center>Made with ❤️ for and by the WinCC OA community</center>

---
name: winccoa-gui-shape-tests
description: GUI shape unit testing with panel isolation and dynamic shape creation. Use when creating or debugging OaTest-based GUI shape tests with ModuleOnWithPanel(), addShape(), and GuiTest* wrapper validation.
---

# winccoa-gui-shape-tests

Purpose
-------
Guide for **creating and debugging OaTest-based GUI shape tests** in WinCC OA using:
- Panel isolation via `ModuleOnWithPanel()`
- Dynamic shape creation via `addShape()`
- Shape wrapper validation via `GuiTest{ShapeName}` classes
- Deterministic cleanup via `exit()` (TestFramework integration)

**Use this skill when:**
- Adding new shape unit tests
- Debugging shape test failures
- Understanding shape test architecture
- Migrating existing shape tests to real GUI tests

**Not this skill:**
- CtrlTF runner operations → use `winccoa-ctrl-test-framework`
- OaTest framework basics → use `winccoa-oatest`
- CTL coding fundamentals → use `winccoa-control-script`

---

Architecture: Dual-Panel Pattern
--------------------------------

### Why Two Panels?

| Panel | Purpose | Lifecycle | Who Creates |
|-------|---------|-----------|-------------|
| `about.pnl` | Universal launcher (exists in all versions) | Open by TestFramework at test start | TestFramework |
| `shapesTest.pnl` | Isolated test context with exact module/panel names | Created per test via `ModuleOnWithPanel()` | Test setUp() |

**Benefits:**
- ✓ Version compatibility — `about.pnl` guaranteed to exist
- ✓ Test isolation — each test gets own panel module instance
- ✓ Reproducibility — exact module/panel names prevent state bleeding
- ✓ Concurrency safe — no interference from other tests/managers

### Panel Configuration (testProj.unit.config)

```json
{ 
  "MANAGER_TYPE" : "UI", 
  "MANAGER_OPTIONS" : "-p about.pnl -s tests/libs/classes/splash/shapes/GuiTest{ShapeName}.ctl -n" 
}
```

**Elements:**
- `-p about.pnl` — TestFramework opens `about.pnl` first
- `-s GuiTest{ShapeName}.ctl` — then runs your test script
- `-n` — non-interactive mode
- **Note:** `shapesTest.pnl` is created **inside** your test script; it's not specified in config

---

Test Lifecycle & Cleanup
------------------------

### setUp() → testXxx() → tearDown() → exit()

```
1. TestFramework starts UI manager with about.pnl
2. setUp() runs:
   - ModuleOnWithPanel() creates shapesTest.pnl
   - isPanelOpen() polls until ready
   - addShape() dynamically adds test shape
3. testXxx() runs — validate wrapper attributes/behavior
4. tearDown() runs (optional cleanup; not required)
5. exit() closes all panels/managers (TestFramework handles)
```

### Why No Explicit Panel Close in tearDown()?

The test uses **dirty exit** via `exit()`:
- ✓ Fast — no explicit cleanup logic needed
- ✓ Safe — TestFramework exits all managers at test end
- ✓ Reliable — `exit()` cleans up all panel instances
- ✗ Not suitable for long-running services (but fine for unit tests)

**tearDown() remains empty** (or calls `OaTest::tearDown()`) because:
1. Panel resources are tied to the module lifecycle
2. `exit()` fires after tearDown() and closes everything
3. Explicit `PanelOff()` in tearDown() would be redundant

---

Core Functions
--------------

### ModuleOnWithPanel()

Opens a panel in a dedicated module with exact naming for reproducibility.

```ctl
ModuleOnWithPanel(
  "shapesTestModule",    // Module name (exact, for reproducibility)
  -1, -1,                // Position (-1 = default)
  600, 450,              // Size (width, height)
  2, 2,                  // Layers/other params
  "",                    // Optional params
  "shapesTest.pnl",      // Panel file name
  "shapesTestPanel",     // Panel instance name (exact)
  makeDynString()        // Initialization strings
);
```

**Note:** No return value; use `isPanelOpen()` to verify the panel opened successfully.

### isPanelOpen()

Polls for panel readiness (blocking until true or timeout).

```ctl
while (isPanelOpen("shapesTestPanel", "shapesTestModule") == false)
  delay(0.100);  // Poll every 100ms
```

### addShape()

Dynamically creates a shape on the running panel.

```ctl
shape<"ARC"> testShape = addShape(
  "shapesTestModule",    // Module name
  "shapesTestPanel",     // Panel instance name
  1,                     // Layer
  "ARC",                 // Shape type (matches WinCC OA enums)
  "testArc"              // Shape name (for debugging)
);
```

**Returns:** shape object if success; 0 if failed.

**Shape types:** `"ARC"`, `"PUSH_BUTTON"`, `"CHECKBOX"`, `"SLIDER"`, `"LINE"`, `"RECTANGLE"`, `"ELLIPSE"`, `"POLYGON"`, `"TEXT"`, etc.

### setValue() / getValue()

Set and read shape attributes.

```ctl
// Set shape position and size
setValue(testShape, "position", 10, 20);
setValue(testShape, "size", 100, 200);

// Read attributes
dyn_float pos = getValue(testShape, "position");
dyn_float size = getValue(testShape, "size");
```

### shape.panel()

Get the panel object containing a shape.

```ctl
panel testPanel = testShape.panel();
string panelName = testPanel.name();  // "shapesTestPanel"
```

---

Complete Test Template
----------------------

```ctl
/**
  @file $relPath
  @copyright MIT
  @brief Real tests for classes/splash/shapes/GuiTestPushButton.ctl.
  @test Verifies the shape wrapper library can create and validate a live PUSH_BUTTON shape.
  @AIgeneratedHelpContent
*/

#uses "classes/TimeOut"
#uses "panel"
#uses "classes/oaTest/OaTest"
#uses "classes/splash/shapes/GuiTestPush{ShapeName}"

//------------------------------------------------------------------------------
/**
  @brief Real tests for GuiTestPushButton.
  @AIgeneratedHelpContent
*/
class TstGuiTest{ShapeName} : OaTest
{
//-----------------------------------------------------------------------------
//@public members
//-----------------------------------------------------------------------------
  public int setUp()
  {
    if (OaTest::setUp() != 0)
      return -1;

    //ModuleOnWithPanel (in panel.ctl) being used so I can open the panel where I want it an so I can open it regulary;
    ModuleOnWithPanel("shapesTestModule", -1, -1, 600, 450, 2, 2, "", "shapesTest.pnl", "shapesTestPanel", makeDynString());

    while (isPanelOpen("shapesTestPanel", "shapesTestModule") == false)
      delay(0.100);

//    shape addShape(string moduleName, string panelName, int layer, string shapeType, string shapeName);
    testShape = addShape("shapesTestModule", "shapesTestPanel", 1, "{SHAPE_TYPE}", "test{ShapeName}");

    this.tcData.enableStackTraceOn("Pass", false);
    return 0;
  }

  //---------------------------------------------------------------------------
  /**
    @test todo fill it.
  */
  public int testLibraryIsAvailable()
  {

    this.assertTrue(testShape != 0, "Expected a shape to be created");
    return 0;
  }

  //---------------------------------------------------------------------------
  /**
    @test Verify shape attributes after dynamic creation and modification.
  */
  public int testAttributes()
  {
    this.assertEqual(testShape.name(), "test{ShapeName}", "Expected shape name to be test{ShapeName}");

    testShape.position(10, 20);
    setValue(testShape, "size", 100, 200);
    GuiTestPush{ShapeName} testShapeObject = GuiTestPush{ShapeName}(testShape);
    const mapping expected = makeMapping(
                               "enabled", true,
                               "visible", true,
                               "position.x", 10,
                               "position.y", 20,
                               "size.w", 100,
                               "size.h", 200,
                               "buttonType", 0,
                               "borderStyle", 8,
                               "fill", "",
                               "toggleState", false,
                               "updatesEnabled", true,
                               "font", (langString)"Segoe UI,9,-1,5,400,0,0,0,0,0,0,0,0,0,0,1",
                               "textPosition", "TEXT_RIGHT_OF_PIXMAP",
                               "text", (langString)"testButton"
                               );
    const mapping current = testShapeObject.getCurrentAttributes();

    this.assertEqual(expected.count(), current.count(), "Check count of attributes");

    for (int i = 0; i < current.count(); i++)
    {
      this.info("var type: " + getTypeName(current.value(current.keyAt(i))));
      this.assertEqual(current.value(current.keyAt(i)), expected.value(current.keyAt(i)), "compare values at key: $1".subst(current.keyAt(i)));
    }

    testShape.visible(FALSE);

    this.assertEqual(testShapeObject.getCurrentAttributes().value("visible"), false);

    testShape.visible(true);

    this.assertEqual(testShapeObject.getCurrentAttributes().value("visible"), true);
    return 0;
  }

  public int testEvents()
  {
    this.testShape.visible(true);
    this.assertTrue(testShape.visible());
    this.info("Scriptables: " + this.testShape.scriptNames());
    this.testShape.script("Clicked", "void main() {this.visible(false);}");
    delay(0, 100);
    // simulate click (press, wait, release)
    sendMouseEvent(testShape, 10, 10, MOUSE_LBUTTON);
    delay(0, 50);
    sendMouseEvent(testShape, 10, 10, 0);

    GuiTestPush{ShapeName} testShapeObject = GuiTestPush{ShapeName}(testShape);
    dyn_string fails;
    TimeOut timeOut = TimeOut(5);
    int rc;

    while (!timeOut.hasExpired())
    {
      fails.clear();
      rc = testShapeObject.assertAttributes(makeMapping("visible", false), fails);

      if (rc == 0)
        break;

      delay(0, 50);
    }

    this.assertEqual(rc, 0);
    this.tcData.setMaxCountOfPrintedCharacters(0);
    this.assertEqual(fails, makeDynString());
    return 0;
  }
//-----------------------------------------------------------------------------
//@protected members
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
//@private members
//-----------------------------------------------------------------------------
  private shape<"{SHAPE_TYPE}"> testShape;
};

//------------------------------------------------------------------------------
void main(...)
{
  va_list list;
  int count = va_start(list);
  TstGuiTest{ShapeName} test;
  test.cla.readArguments(list, count);
  va_end(list);

  test.startAll();

  // we are in panel and we need to close it, otherwise it will wait for user events -> freeze
  exit(0);
}


```

---

Common Issues & Solutions
--------------------------

### Issue: `isPanelOpen()` Timeout

**Symptom:** Test fails waiting for panel to open

**Causes:**
1. `shapesTest.pnl` file not found
2. `ModuleOnWithPanel()` failed silently (check return value)
3. WinCC OA system overloaded (increase poll time)

**Best Practice — Robust Polling Loop:**
```ctl
// Check ModuleOnWithPanel return value FIRST
int rc = ModuleOnWithPanel("shapesTestModule", -1, -1, 600, 450, 2, 2, "", 
                          "shapesTest.pnl", "shapesTestPanel", makeDynString());
if (rc != 0) {
  this.fail("ModuleOnWithPanel() failed with code: " + rc);
  return rc;
}

// Poll with timeout protection
int maxWaits = 100;  // ~10 seconds at 100ms interval
int waits = 0;
while (!isPanelOpen("shapesTestPanel", "shapesTestModule")) {
  if (waits >= maxWaits) {
    this.fail("Panel failed to open after " + (maxWaits * 100) + "ms");
    return -1;
  }
  delay(0.100);
  waits++;
}

// Verify panel is ready before adding shape
if (!isPanelOpen("shapesTestPanel", "shapesTestModule")) {
  this.fail("Panel became unavailable after opening");
  return -1;
}
```

**Key improvements:**
- ✓ Validates `ModuleOnWithPanel()` return code immediately
- ✓ Timeout protection (avoid infinite wait)
- ✓ Error messages with context (timeout duration, return codes)
- ✓ Double-check panel readiness before proceeding

### Issue: `addShape()` Returns 0 (Invalid)

**Symptom:** Shape creation fails; `testShape == 0`

**Causes:**
1. Panel not open (verify `isPanelOpen()` returned true)
2. Shape type name incorrect (must match WinCC OA enum exactly)
3. Invalid layer or position parameters

**Best Practice — Shape Creation with Validation:**
```ctl
// Verify panel is open BEFORE adding shape
if (!isPanelOpen("shapesTestPanel", "shapesTestModule")) {
  this.fail("Panel not ready; cannot add shape");
  return -1;
}

// Create shape with full validation
shape<"{SHAPE_TYPE}"> testShape = addShape("shapesTestModule", "shapesTestPanel", 1, 
                                          "{SHAPE_TYPE}", "test{ShapeName}");

// Check return value IMMEDIATELY
if (testShape == 0) {
  this.fail("Failed to create test shape; verify panel state and shape type");
  return -1;
}

// Optional: inspect shape properties to confirm creation
DebugN("Shape created: " + testShape.name() + " on panel: " + testShape.panel().name());
```

**Shape type validation checklist:**
- ✓ Use exact WinCC OA shape enum names: `"ARC"`, `"PUSH_BUTTON"`, `"CHECKBOX"`, etc.
- ✓ NOT camelCase or abbreviated versions
- ✓ Check WinCC OA documentation for correct spelling
- ✓ Verify panel is definitely open before calling `addShape()`

### Issue: Wrapper Attributes Don't Match

**Symptom:** Assertions fail on attribute comparison

**Causes:**
1. Wrapper property name mismatch (e.g., `getX()` vs `getXPos()`)
2. Attribute value type mismatch (int vs float)
3. Shape not positioned before reading

**Solutions:**
```ctl
// Always position/size BEFORE reading via wrapper
testShape.position(10, 20);
setValue(testShape, "size", 100, 200);

// Inspect actual values before assertion
GuiTest{ShapeName} wrapper = GuiTest{ShapeName}(testShape);
DebugN("Wrapper X: " + wrapper.getX() + ", expected 10");

// Check wrapper class for correct property names
// (See GuiTest{ShapeName} implementation in libs/classes/splash/shapes/)
```

---

Related Documentation
---------------------

| Resource | Purpose |
|----------|---------|
| [suite_unit README](../../../tests/WinCC_OA_Test/TestSuites/suite_unit/README.md) | Architecture and test files overview |
| `winccoa-oatest` skill | OaTest framework lifecycle and assertions |
| `winccoa-control-script` skill | CTL coding fundamentals and debugging |
| `winccoa-qa` skill | Code style and quality gates |

---

<!-- markdownlint-disable-next-line MD033 -->
<center>Made with ❤️ for and by the WinCC OA community</center>

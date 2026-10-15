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
#uses "classes/splash/shapes/GuiTestPushButton"

//------------------------------------------------------------------------------
/**
  @brief Real tests for GuiTestPushButton.
  @AIgeneratedHelpContent
*/
class TstGuiTestPushButton : OaTest
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
    testShape = addShape("shapesTestModule", "shapesTestPanel", 1, "PUSH_BUTTON", "testButton");

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
    this.assertEqual(testShape.name(), "testButton", "Expected shape name to be testButton");

    setThrowErrorAsException(true);
    testShape.position(10, 20);
    setValue(testShape, "size", 100, 200);
    setThrowErrorAsException(false);
    GuiTestPushButton testShapeObject = GuiTestPushButton(testShape);
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

    GuiTestPushButton testShapeObject = GuiTestPushButton(testShape);
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
  private shape<"PUSH_BUTTON"> testShape;
};

//------------------------------------------------------------------------------
void main(...)
{
  va_list list;
  int count = va_start(list);
  TstGuiTestPushButton test;
  test.cla.readArguments(list, count);
  va_end(list);

  test.startAll();

  // we are in panel and we need to close it, otherwise it will wait for user events -> freeze
  exit(0);
}

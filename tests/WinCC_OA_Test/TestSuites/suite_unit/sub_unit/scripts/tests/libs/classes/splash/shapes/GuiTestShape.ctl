/**
  @file $relPath
  @copyright MIT
  @brief Real tests for classes/splash/shapes/GuiTestShape.ctl.
  @test Verifies the shape wrapper library can create and validate a live GENERIC shape.
  @AIgeneratedHelpContent
*/

#uses "panel"
#uses "classes/oaTest/OaTest"
#uses "classes/splash/shapes/GuiTestShape"
#uses "classes/splash/shapes/GuiTestPushButton"

//------------------------------------------------------------------------------
/**
  @brief Real tests for GuiTestShape.
  @AIgeneratedHelpContent
*/
class TstGuiTestShape : OaTest
{
//-----------------------------------------------------------------------------
//@public members
//-----------------------------------------------------------------------------

  //---------------------------------------------------------------------------
  /**
    @test Verifies the wrapper exposes the core shape attributes that must remain valid.
  */
  public int testAttributes()
  {
    //ModuleOnWithPanel (in panel.ctl) being used so I can open the panel where I want it an so I can open it regulary;
    ModuleOnWithPanel("shapesTestModule", -1, -1, 600, 450, 2, 2, "", "shapesTest.pnl", "shapesTestPanel", makeDynString());

    while (isPanelOpen("shapesTestPanel", "shapesTestModule") == false)
      delay(0.100);

//    shape addShape(string moduleName, string panelName, int layer, string shapeType, string shapeName);
    shape testShape = addShape("shapesTestModule", "shapesTestPanel", 1, "PUSH_BUTTON", "testButton");

    GuiTestPushButton testShapeObject = GuiTestPushButton(testShape);

    this.assertNotEqual(testShapeObject.toString(), "", "Expected a live shape instance");

    setThrowErrorAsException(true);
    testShapeObject.showAttention("OK");
    testShapeObject.showAttention("FAIL");
    setThrowErrorAsException(false);

    this.pass("Expected the wrapper to expose the core shape attributes that must remain valid");

    return 0;
  }

//-----------------------------------------------------------------------------
//@protected members
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
//@private members
//-----------------------------------------------------------------------------
};

//------------------------------------------------------------------------------
void main(...)
{
  va_list list;
  int count = va_start(list);
  TstGuiTestShape test;
  test.cla.readArguments(list, count);
  va_end(list);

  test.startAll();

  exit(0);
}


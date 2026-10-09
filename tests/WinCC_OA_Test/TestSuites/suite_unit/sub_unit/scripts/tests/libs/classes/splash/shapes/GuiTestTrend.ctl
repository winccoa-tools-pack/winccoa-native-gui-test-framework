/**
  @file $relPath
  @copyright MIT
  @brief Real tests for classes/splash/shapes/Guitestrend.ctl.
  @test Verifies the shape wrapper library can create and validate a live TREND shape.
  @AIgeneratedHelpContent
*/

#uses "panel"
#uses "classes/oaTest/OaTest"
#uses "classes/splash/shapes/GuiTestTrend"

//------------------------------------------------------------------------------
/**
  @brief Real tests for GuiTestTrend.
  @AIgeneratedHelpContent
*/
class TstGuiTestTrend : OaTest
{
//-----------------------------------------------------------------------------
//@public members
//-----------------------------------------------------------------------------
  public int setUp()
  {
    if (OaTest::setUp() != 0)
      return -1;

    ModuleOnWithPanel("shapesTestModule", -1, -1, 600, 450, 2, 2, "",
                      "shapesTest.pnl", "shapesTestPanel", makeDynString());

    while (isPanelOpen("shapesTestPanel", "shapesTestModule") == false)
      delay(0.100);

    testShape = addShape("shapesTestModule", "shapesTestPanel", 1,
                         "TREND", "testrend");

    this.assertTrue(testShape != 0, "Expected a shape to be created");
    return 0;
  }

  //---------------------------------------------------------------------------
  /**
    @test Verifies the wrapper library resolves and the live shape is available.
  */
  public int testLibraryIsAvailable()
  {
    this.assertTrue(testShape != 0, "Expected a live shape instance");
    return 0;
  }

  //---------------------------------------------------------------------------
  /**
    @test Verifies the wrapper exposes the core shape attributes that must remain valid.
  */
  public int testAttributes()
  {
    this.assertEqual(testShape.name(), "testrend",
                     "Expected shape name to match the generated test name");

    setThrowErrorAsException(true);
    testShape.position(10, 20);
    setValue(testShape, "size", 100, 200);
    setThrowErrorAsException(false);

    GuiTestTrend wrapper = GuiTestTrend(testShape);
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

  //---------------------------------------------------------------------------
  /**
    @brief Cleanup after tests complete.
    @return Return code from OaTest::tearDown().
  */
  public int tearDown()
  {
    return OaTest::tearDown();
  }

//-----------------------------------------------------------------------------
//@protected members
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
//@private members
//-----------------------------------------------------------------------------
  private shape<"TREND"> testShape;
};

//------------------------------------------------------------------------------
void main(...)
{
  va_list list;
  int count = va_start(list);
  TstGuiTestTrend test;
  test.cla.readArguments(list, count);
  va_end(list);

  test.startAll();

  exit(0);
}


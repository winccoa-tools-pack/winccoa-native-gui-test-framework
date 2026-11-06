/**
  @file $relPath
  @copyright MIT
  @brief Real tests for classes/splash/shapes/GuiTestSpacer.ctl.
  @test Verifies the shape wrapper library can inspect a live SPACER shape.
  @AIgeneratedHelpContent
*/

#uses "panel"
#uses "classes/oaTest/OaTest"
#uses "classes/splash/shapes/GuiTestSpacer"

//------------------------------------------------------------------------------
/**
  @brief Real tests for GuiTestSpacer.
  @AIgeneratedHelpContent
*/
class TstGuiTestSpacer : OaTest
{
//@public members

  public int setUp()
  {
    if (OaTest::setUp() != 0)
      return -1;

    ModuleOnWithPanel("shapesTestModule", -1, -1, 600, 450, 2, 2, "",
                      "shapesTest.pnl", "shapesTestPanel", makeDynString());

    int waitMs = 0;

    while (!isPanelOpen("shapesTestPanel", "shapesTestModule") &&
           waitMs < 5000)
    {
      delay(0, 100);
      waitMs += 100;
    }

    if (!isPanelOpen("shapesTestPanel", "shapesTestModule"))
    {
      this.abort("The isolated shapes test panel did not open.");
      return -1;
    }

    testShape = addShape("shapesTestModule", "shapesTestPanel", 1,
                         "SPACER", "testSpacer");
    this.assertTrue(testShape != 0, "Expected a SPACER shape to be created");
    return 0;
  }

  /**
    @test Verifies the wrapper reads visibility and geometry from a live SPACER.
  */
  public int testAttributes()
  {
    GuiTestSpacer spacer = GuiTestSpacer(testShape);
    const mapping current = spacer.getCurrentAttributes();

    this.assertTrue(current.contains("visible"),
                    "Expected the SPACER visibility attribute");
    this.assertTrue(current.contains("position.x"),
                    "Expected the SPACER x-position attribute");
    this.assertTrue(current.contains("position.y"),
                    "Expected the SPACER y-position attribute");
    this.assertTrue(current.contains("size.w"),
                    "Expected the SPACER width attribute");
    this.assertTrue(current.contains("size.h"),
                    "Expected the SPACER height attribute");
    return 0;
  }

  public int tearDown()
  {
    return OaTest::tearDown();
  }

//@protected members

//@private members
  private shape<"SPACER"> testShape;
};

//------------------------------------------------------------------------------
void main(...)
{
  va_list list;
  int count = va_start(list);
  TstGuiTestSpacer test;
  test.cla.readArguments(list, count);
  va_end(list);
  test.startAll();
  exit(0);
}

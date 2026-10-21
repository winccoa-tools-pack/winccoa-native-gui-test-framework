/**
  @file $relPath
  @copyright MIT
  @brief Real tests for classes/splash/shapes/GuiTestSelectionList.ctl.
  @test Verifies the shape wrapper library can create and validate a live SELECTION_LIST shape.
  @AIgeneratedHelpContent
*/

#uses "panel"
#uses "classes/oaTest/OaTest"
#uses "classes/splash/shapes/GuiTestSelectionList"

//------------------------------------------------------------------------------
/**
  @brief Real tests for GuiTestSelectionList.
  @AIgeneratedHelpContent
*/
class TstGuiTestSelectionList : OaTest
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
                         "SELECTION_LIST", "testSelectionList");

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
    this.assertTrue(current.contains("font"), "Expected font attribute");
    this.assertTrue(current.contains("items"), "Expected items attribute");
    this.assertTrue(current.contains("selectedItems"), "Expected selectedItems attribute");

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

  /**
    @test Verifies selection by displayed text and one-based item position.
  */
  public int testSelectItem()
  {
    testShape.deleteAllItems();
    testShape.appendItem("First item");
    testShape.appendItem("Second item");
    GuiTestSelectionList wrapper = GuiTestSelectionList(testShape);

    this.assertEqual(wrapper.selectItem("Second item"), 0,
                     "Expected the helper to select an item by text");
    this.assertEqual(testShape.selectedText(), "Second item",
                     "Expected the selected text to match");

    this.assertEqual(wrapper.selectItem(1), 0,
                     "Expected the helper to select an item by position");
    this.assertEqual(testShape.selectedText(), "First item",
                     "Expected one-based position 1 to select the first item");

    const mapping current = wrapper.getCurrentAttributes();
    this.assertEqual(current.value("items"),
                     makeDynString("First item", "Second item"),
                     "Expected the snapshot to include all list items");
    this.assertEqual(current.value("selectedItems"),
                     makeDynString("First item"),
                     "Expected the snapshot to include selected items");
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
  private shape<"SELECTION_LIST"> testShape;
};

//------------------------------------------------------------------------------
void main(...)
{
  va_list list;
  int count = va_start(list);
  TstGuiTestSelectionList test;
  test.cla.readArguments(list, count);
  va_end(list);

  test.startAll();

  exit(0);
}


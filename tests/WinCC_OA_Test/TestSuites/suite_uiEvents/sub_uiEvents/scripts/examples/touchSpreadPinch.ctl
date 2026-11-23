/**
  @file $relPath
  @brief Runnable two-contact spread and pinch on touchSurface.pnl.
  @copyright MIT
  @AIgeneratedHelpContent
*/
#uses "classes/SquirtInputEventPlayer"
#uses "classes/oaTest/OaTest"

/**
  @brief Checks native panel zoom, not merely successful touch injection.
  @AIgeneratedHelpContent
*/
class TouchSpreadPinchExample : OaTest
{
//@public members
  /** @brief Opens a resizable surface and adds a fixed-size target.
      @return Zero on success. @AIgeneratedHelpContent */
  public int setUp()
  {
    OaTest::setUp();

    if (isModuleOpen(moduleName))
      return -1;

    ModuleOnWithPanel(moduleName, -1, -1, 650, 450, 2, 2, "",
                      "touchSurface.pnl", "touch_surface", makeDynString());
    player.waitForPanelOpen(moduleName, "touch_surface", 5000);
    surface = getShape(moduleName + ".touch_surface:");
    shape target = addShape(moduleName, "touch_surface", 1,
                            "RECTANGLE", "touchTarget");
    setValue(target, "position", 0, 0, "size", 600, 400);
    player.sleep(200);
    return 0;
  }

  /** @test Spread increases native zoom and pinch reduces it.
      @AIgeneratedHelpContent */
  public int testSpreadAndPinch()
  {
    string address = moduleName + ".touch_surface:touchTarget";
    dyn_mapping narrow = makeDynMapping(
                           makeMapping("id", 1, "x", 180, "y", 180),
                           makeMapping("id", 2, "x", 300, "y", 180));
    dyn_mapping wide = makeDynMapping(
                         makeMapping("id", 1, "x", 140, "y", 180),
                         makeMapping("id", 2, "x", 340, "y", 180));
    float before = surface.zoomFactor;
    invokeMethod(surface, "clearRecords");
    player.twoContactGesture(address, narrow, wide, 10, 300);
    expectZoomCallbacks();
    float expanded = surface.zoomFactor;
    this.info("Spread example zoom: " + before + " -> " + expanded);
    assertTrue(expanded > before, "Native spread increases panel zoom");

    invokeMethod(surface, "clearRecords");
    player.twoContactGesture(address, wide, narrow, 10, 300);
    expectZoomCallbacks();
    float contracted = surface.zoomFactor;
    this.info("Pinch example zoom: " + expanded + " -> " + contracted);
    assertTrue(contracted < expanded, "Native pinch reduces panel zoom");
    return 0;
  }

//@protected members

//@private members
  private string moduleName = "suite_uiEvents_example_spread_pinch";
  private SquirtInputEventPlayer player;
  private shape surface;

  private void expectZoomCallbacks()
  {
    dyn_string records;

    for (int attempt = 0; attempt < 100; attempt++)
    {
      records = invokeMethod(surface, "records");

      if (dynlen(records) >= 2)
        break;

      player.sleep(20);
    }

    player.sleep(100);
    records = invokeMethod(surface, "records");
    this.info("Spread/pinch example records: " + jsonEncode(records));
    assertEqual(dynlen(records), 2, "Exact native zoom callback count");

    for (int index = 1; index <= dynlen(records); index++)
    {
      mapping event = jsonDecode(records[index]);
      assertEqual((string)event["type"], "zoom", "Native zoom callback");
    }
  }
};

/** @brief Runs the example, then terminates only this UI manager.
    @AIgeneratedHelpContent */
void main(...)
{
  va_list arguments;
  int count = va_start(arguments);
  TouchSpreadPinchExample test;
  test.cla.readArguments(arguments, count);
  va_end(arguments);
  test.startAll();
  exit(0);
}
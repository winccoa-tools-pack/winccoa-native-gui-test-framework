/**
  @file $relPath
  @brief Native two-contact zoom and swipe behavior on a test-owned panel.
  @copyright MIT
  @AIgeneratedHelpContent
*/
#uses "classes/SquirtInputEventPlayer"
#uses "classes/oaTest/OaTest"

/**
  @brief Requires native zoom and gesture callbacks, not just dispatch.
  @AIgeneratedHelpContent
*/
class TstMultiTouchEvents : OaTest
{
//@public members
  /** @brief Opens a resizable blank touch surface.
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

  /** @test Spread increases panel zoom and pinch reduces it, with callbacks.
      @AIgeneratedHelpContent */
  public int testSpreadAndPinch()
  {
    float before = surface.zoomFactor;
    invokeMethod(surface, "clearRecords");
    dyn_mapping narrow = makeDynMapping(makeMapping("id", 1, "x", 180, "y", 180),
                                        makeMapping("id", 2, "x", 300, "y", 180));
    dyn_mapping wide = makeDynMapping(makeMapping("id", 1, "x", 140, "y", 180),
                                      makeMapping("id", 2, "x", 340, "y", 180));
    player.twoContactGesture(address, narrow, wide, 10, 300);
    expectCallback("zoom", 2);
    float expanded = surface.zoomFactor;
    this.info("Spread zoom: " + before + " -> " + expanded);
    assertTrue(expanded > before, "Spread changes native panel zoom");
    invokeMethod(surface, "clearRecords");
    player.twoContactGesture(address, wide, narrow, 10, 300);
    expectCallback("zoom", 2);
    float contracted = surface.zoomFactor;
    this.info("Pinch zoom: " + expanded + " -> " + contracted);
    assertTrue(contracted < expanded, "Pinch changes native panel zoom");
    return 0;
  }

  /** @test Same-direction contacts yield a genuine two-finger swipe payload.
      @AIgeneratedHelpContent */
  public int testTwoFingerSwipe()
  {
    invokeMethod(surface, "clearRecords");
    dyn_mapping points = makeDynMapping(
                           makeMapping("id", 1, "state", "pressed", "x", 100, "y", 120),
                           makeMapping("id", 2, "state", "pressed", "x", 100, "y", 220));
    player.touchFrame(address, points);

    for (int step = 1; step <= 10; step++)
    {
      player.sleep(30);

      for (int contact = 1; contact <= 2; contact++)
      {
        points[contact]["state"] = "moved";
        points[contact]["x"] = 100 + 30 * step;
      }

      player.touchFrame(address, points);
    }

    points[1]["state"] = "released";
    points[2]["state"] = "stationary";
    player.touchFrame(address, points);
    player.sleep(30);
    points[2]["state"] = "released";
    player.touchFrame(address, makeDynMapping(points[2]));
    mapping event = expectCallback("swipe");

    if (mappingHasKey(event, "data"))
    {
      mapping data = event["data"];
      assertEqual((int)data["touchpoints"], 2, "Two contacts recognized");
      assertEqual((string)data["horizontal"], "right", "Rightward swipe");
      assertEqual((string)data["vertical"], "none", "No vertical swipe");
    }
    else
      assertTrue(false, "Native swipe payload required");

    return 0;
  }

  /** @test The high-level one-contact swipe triggers a native payload.
      @AIgeneratedHelpContent */
  public int testSingleFingerSwipe()
  {
    invokeMethod(surface, "clearRecords");
    player.swipeShape(address, 100, 180, 400, 180, 10, 300);
    mapping event = expectCallback("swipe");

    if (mappingHasKey(event, "data"))
    {
      mapping data = event["data"];
      assertEqual((int)data["touchpoints"], 1, "One contact recognized");
      assertEqual((string)data["horizontal"], "right", "Rightward swipe");
      assertEqual((string)data["vertical"], "none", "No vertical swipe");
    }
    else
      assertTrue(false, "Native swipe payload required");

    return 0;
  }

//@protected members

//@private members
  private string moduleName = "suite_uiEvents_multitouch";
  private string address = "suite_uiEvents_multitouch.touch_surface:touchTarget";
  private SquirtInputEventPlayer player;
  private shape surface;

  private mapping expectCallback(const string &type, int expected = 1)
  {
    dyn_string records;

    for (int attempt = 0; attempt < 100; attempt++)
    {
      records = invokeMethod(surface, "records");

      if (dynlen(records) >= expected)
        break;

      player.sleep(20);
    }

    player.sleep(100);
    records = invokeMethod(surface, "records");
    this.info("Native gesture records: " + jsonEncode(records));
    assertEqual(dynlen(records), expected, "Exact native callback count");
    mapping event;

    if (dynlen(records) > 0)
    {
      for (int index = 1; index <= dynlen(records); index++)
      {
        event = jsonDecode(records[index]);
        assertEqual((string)event["type"], type, "Ordered native callback type");
      }
    }

    return event;
  }
};

void main(...)
{
  va_list arguments;
  int count = va_start(arguments);
  TstMultiTouchEvents test;
  test.cla.readArguments(arguments, count);
  va_end(arguments);
  test.startAll();
  exit(0);
}
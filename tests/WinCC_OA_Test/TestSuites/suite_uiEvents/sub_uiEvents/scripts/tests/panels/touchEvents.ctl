/**
  @file $relPath
  @brief Standalone behavioral touch tests using unchanged event fixtures.
  @copyright MIT
  @AIgeneratedHelpContent
*/
#uses "classes/SquirtInputEventPlayer"
#uses "classes/oaTest/OaTest"

/**
  @brief Verifies callbacks rather than treating dispatch as recognition.
  @AIgeneratedHelpContent
*/
class TstTouchEvents : OaTest
{
//@public members
  /** @brief Opens an isolated instance of the existing event fixture.
      @return Zero on success. @AIgeneratedHelpContent */
  public int setUp()
  {
    OaTest::setUp();

    if (isModuleOpen(moduleName))
      return -1;

    ModuleOnWithPanel(moduleName, -1, -1, 900, 800, 2, 2, "",
                      "UiEventTestPanels/ToolVerification.pnl", "main_pnl",
                      makeDynString());
    player.waitForPanelOpen(moduleName, "main_pnl", 5000);
    results = player.getShapeWait(address("SELECTION_LIST_RESULTS"));
    player.sleep(500);
    return 0;
  }

  /** @test A touch tap produces one click with native provenance metadata.
      @AIgeneratedHelpContent */
  public int testTap()
  {
    clearResults();
    player.tapShape(address("PUSH_BUTTON_CLICK"));
    expectCount(2);
    expectEvent(1, "single left click: ", "MouseButtonRelease", false);
    return 0;
  }

  /** @test Two touch taps produce the native double-click callback.
      @AIgeneratedHelpContent */
  public int testDoubleTap()
  {
    clearResults();
    player.doubleTapShape(address("PUSH_BUTTON_DBLCLICK"));
    expectCount(2);
    expectEvent(1, "double left click: ", "MouseButtonDblClick", true);
    return 0;
  }

  /** @test Explicit press/release frames produce ordered button callbacks.
      @AIgeneratedHelpContent */
  public int testExplicitFrames()
  {
    clearResults();
    string target = address("PUSH_BUTTON_PRESS_RELEASE");
    player.touchFrame(target, makeDynMapping(makeMapping(
          "id", 7, "state", "pressed", "x", 50, "y", 50)));
    expectCount(2);
    player.touchFrame(target, makeDynMapping(makeMapping(
          "id", 7, "state", "released", "x", 50, "y", 50)));
    expectCount(4);
    expectEvent(1, "left mouse pressed: ", "MouseButtonPress", false);
    expectEvent(3, "left mouse released: ", "MouseButtonRelease", false);
    return 0;
  }

  /** @test A hold yields left press, right press, then right-button release.
      @AIgeneratedHelpContent */
  public int testLongPress()
  {
    clearResults();
    player.longPressShape(address("PUSH_BUTTON_PRESS_RELEASE"), 1500);
    expectCount(6);
    expectEvent(1, "left mouse pressed: ", "MouseButtonPress", false);
    expectEvent(3, "right mouse pressed: ", "MouseButtonPress", true, MOUSE_RIGHT);
    expectEvent(5, "left mouse released: ", "MouseButtonRelease", false,
                MOUSE_RIGHT);
    return 0;
  }

//@protected members

//@private members
  private string moduleName = "suite_uiEvents_touch";
  private SquirtInputEventPlayer player;
  private shape results;

  private string address(const string &shapeName)
  {
    return moduleName + ".main_pnl:" + shapeName;
  }

  private void clearResults()
  {
    player.clickShape(address("PUSH_BUTTON_DELETERESULTS"));
    expectCount(0);
    player.sleep(500);
  }

  private void expectCount(int expected)
  {
    for (int attempt = 0; attempt < 50; attempt++)
    {
      if (dynlen(results.items()) == expected)
        break;

      player.sleep(20);
    }

    player.sleep(100);
    dyn_string entries = results.items();
    this.info("Touch callback records: " + jsonEncode(entries));
    assertEqual(dynlen(entries), expected, "Exact callback record count");
  }

  private void expectEvent(int index, const string &prefix,
                           const string &eventType, bool synthesized,
                           int button = MOUSE_LEFT)
  {
    dyn_string entries = results.items();

    if (dynlen(entries) < index + 1)
    {
      assertTrue(false, "Missing touch-derived prefix/JSON pair");
      return;
    }

    assertEqual(entries[index], prefix, "Ordered callback prefix");
    mapping event = jsonDecode(entries[index + 1]);
    assertEqual((string)event["type"], eventType, "Derived event type");
    assertEqual((bool)event["isSynthesized"], synthesized,
                "Native callback flag is not injection provenance");
    assertEqual((int)event["button"], button, "Derived button");
    assertEqual((int)event["modifiers"], 0, "No keyboard modifiers");
  }
};

void main(...)
{
  va_list arguments;
  int count = va_start(arguments);
  TstTouchEvents test;
  test.cla.readArguments(arguments, count);
  va_end(arguments);
  test.startAll();
  exit(0);
}
/**
  @file $relPath
  @brief Runnable touch tap with a real fixture callback assertion.
  @copyright MIT
  @AIgeneratedHelpContent
*/
#uses "classes/SquirtInputEventPlayer"
#uses "classes/oaTest/OaTest"

/**
  @brief Opens ToolVerification and checks a touch-derived click.
  @AIgeneratedHelpContent
*/
class TouchTapExample : OaTest
{
//@public members
  /** @brief Opens an isolated fixture instance.
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
    return 0;
  }

  /** @test A touch tap yields the fixture's prefix and release payload.
      @AIgeneratedHelpContent */
  public int testTap()
  {
    string panelAddress = moduleName + ".main_pnl:";
    shape results = player.getShapeWait(
                      panelAddress + "SELECTION_LIST_RESULTS");
    player.clickShape(panelAddress + "PUSH_BUTTON_DELETERESULTS");
    player.sleep(500);
    assertEqual(dynlen(results.items()), 0, "Fixture records cleared");
    player.tapShape(panelAddress + "PUSH_BUTTON_CLICK");

    for (int attempt = 0; attempt < 50; attempt++)
    {
      if (dynlen(results.items()) >= 2)
        break;

      player.sleep(20);
    }

    player.sleep(100);
    dyn_string entries = results.items();
    this.info("Tap example records: " + jsonEncode(entries));
    assertEqual(dynlen(entries), 2, "Exactly one prefix/payload pair");

    if (dynlen(entries) == 2)
    {
      assertEqual(entries[1], "single left click: ", "Click callback");
      mapping event = jsonDecode(entries[2]);
      assertEqual((string)event["type"], "MouseButtonRelease",
                  "Touch-derived release");
      assertEqual((int)event["button"], MOUSE_LEFT, "Left button");
    }

    return 0;
  }

//@protected members

//@private members
  private string moduleName = "suite_uiEvents_example_tap";
  private SquirtInputEventPlayer player;
};

/** @brief Runs the example, then terminates only this UI manager.
    @AIgeneratedHelpContent */
void main(...)
{
  va_list arguments;
  int count = va_start(arguments);
  TouchTapExample test;
  test.cla.readArguments(arguments, count);
  va_end(arguments);
  test.startAll();
  exit(0);
}
/**
  @file $relPath
  @copyright MIT
  @test Standalone readiness, shortcut and editor drag checks.
  @AIgeneratedHelpContent
*/

#uses "classes/SquirtInputEventPlayer"
#uses "classes/oaTest/OaTest"
#uses "panel"

/**
  @brief Isolated readiness failures and keyboard/mouse input tests.
  @AIgeneratedHelpContent
*/
class TstSquirtStandaloneReadinessAndDrag : OaTest
{
//@public members
  /**
    @brief Opens the owned panel and creates an isolated text field.
    @return Zero on success, minus one if base setup fails.
    @AIgeneratedHelpContent
  */
  public int setUp()
  {
    if (OaTest::setUp() != 0)
      return -1;

    ModuleOnWithPanel("squirtStandaloneReadiness", -1, -1, 700, 500, 2, 2, "",
                      "about.pnl", "standaloneReadiness", makeDynString());
    player.waitForPanelOpen("squirtStandaloneReadiness", "standaloneReadiness");
    editor = addShape("squirtStandaloneReadiness", "standaloneReadiness", 1,
                      "TEXT_FIELD", "readinessEditor");
    setValue(editor, "position", 20, 20, "size", 240, 35,
             "visible", true, "enabled", true);
    return 0;
  }

  /**
    @test Zero-timeout panel and attribute checks accept the current state.
    @return Zero after assertions.
    @AIgeneratedHelpContent
  */
  public int testImmediatePanelStates()
  {
    player.waitForPanelOpen("squirtStandaloneReadiness", "standaloneReadiness", 0);
    this.assertTrue(isPanelOpen("standaloneReadiness",
                                "squirtStandaloneReadiness"),
                    "Owned panel is immediately open");
    player.waitForPanelClosed("squirtStandaloneReadiness", "absentPanel", 0);
    this.assertTrue(!isPanelOpen("absentPanel", "squirtStandaloneReadiness"),
                    "Missing panel in an open module is immediately closed");
    player.waitForPanelClosed("squirtStandaloneAbsent", "absentPanel", 0);
    this.assertTrue(!isModuleOpen("squirtStandaloneAbsent"),
                    "Missing module is immediately closed");
    player.waitForAttribute(address, "visible", true, 0);
    this.assertTrue(editor.visible, "Visible attribute matches immediately");
    return 0;
  }

  /**
    @test Waiting for absent panels to open or open panels to close times out.
    @return Zero after assertions.
    @AIgeneratedHelpContent
  */
  public int testPanelStateTimeouts()
  {
    bool rejected = false;

    try
    {
      player.waitForPanelOpen("squirtStandaloneReadiness", "absentPanel", 80);
    }
    catch { rejected = true; }

    this.assertTrue(rejected, "Missing panel open wait times out");
    rejected = false;

    try
    {
      player.waitForPanelClosed("squirtStandaloneReadiness",
                                "standaloneReadiness", 80);
    }
    catch { rejected = true; }

    this.assertTrue(rejected, "Open panel close wait times out");
    return 0;
  }

  /**
    @test Hidden shapes reject input after a bounded readiness wait.
    @return Zero after assertions.
    @AIgeneratedHelpContent
  */
  public int testHiddenTimeout()
  {
    editor.visible = false;
    bool rejected = false;

    try { player.clickShape(address, 80); }
    catch { rejected = true; }

    editor.visible = true;
    this.assertTrue(rejected, "Hidden editor readiness times out");
    return 0;
  }

  /**
    @test Disabled shapes reject input after a bounded readiness wait.
    @return Zero after assertions.
    @AIgeneratedHelpContent
  */
  public int testDisabledTimeout()
  {
    editor.enabled = false;
    bool rejected = false;

    try { player.clickShape(address, 80); }
    catch { rejected = true; }

    editor.enabled = true;
    this.assertTrue(rejected, "Disabled editor readiness times out");
    return 0;
  }

  /**
    @test Missing shapes time out for both input readiness and attribute waits.
    @return Zero after assertions.
    @AIgeneratedHelpContent
  */
  public int testMissingTimeout()
  {
    string missing =
      "squirtStandaloneReadiness.standaloneReadiness:missingEditor";
    bool rejected = false;

    try { player.clickShape(missing, 80); }
    catch { rejected = true; }

    this.assertTrue(rejected, "Missing editor readiness times out");
    rejected = false;

    try { player.waitForAttribute(missing, "text", "", 80); }
    catch { rejected = true; }

    this.assertTrue(rejected, "Missing editor attribute wait times out");
    return 0;
  }

  /**
    @test An existing shape with a mismatched attribute also times out.
    @return Zero after assertions.
    @AIgeneratedHelpContent
  */
  public int testAttributeTimeout()
  {
    bool rejected = false;

    try { player.waitForAttribute(address, "text", "not present", 80); }
    catch { rejected = true; }

    this.assertTrue(rejected, "Mismatched text attribute wait times out");
    return 0;
  }

  /**
    @test Select All and Backspace shortcuts operate on the target editor.
    @return Zero after assertions.
    @AIgeneratedHelpContent
  */
  public int testEditorShortcut()
  {
    player.replaceText(address, "remove this text");
    this.assertEqual(editor.text, "remove this text", "Shortcut input is present");
    player.pressShortcut(address, 0x41, KEY_CONTROL);
    player.keyClick("", 0x01000003, 0);
    this.assertEqual(editor.text, "", "Target shortcut selects all text");
    return 0;
  }

  /**
    @test Dragging across editor text creates a selection removed by Backspace.
    @return Zero after assertions.
    @AIgeneratedHelpContent
  */
  public int testDragSelection()
  {
    player.replaceText(address, "drag selection");
    player.dragShape(address, 5, 15, 150, 15);
    int selectionStart, selectionEnd;
    getValue(editor, "select", selectionStart, selectionEnd);
    this.assertTrue(abs(selectionEnd - selectionStart) > 1,
                    "Drag creates a multi-character selection before deletion");
    this.assertEqual(editor.text, "drag selection", "Drag alone preserves text");
    player.keyClick("", 0x01000003, 0);
    this.assertTrue(strlen(editor.text) < strlen("drag selection") - 1,
                    "Drag selects more than one character for deletion");
    return 0;
  }

  /**
    @test Negative and upper-bound coordinates and nonpositive steps fail.
    @return Zero after assertions.
    @AIgeneratedHelpContent
  */
  public int testInvalidDragBounds()
  {
    player.replaceText(address, "unchanged");
    dyn_int fromXs = makeDynInt(-1, 5, 240, 5, 5, 5, 5, 5, 5, 5);
    dyn_int fromYs = makeDynInt(5, -1, 5, 35, 5, 5, 5, 5, 5, 5);
    dyn_int toXs = makeDynInt(10, 10, 10, 10, -1, 10, 240, 10, 10, 10);
    dyn_int toYs = makeDynInt(10, 10, 10, 10, 10, -1, 10, 35, 10, 10);
    dyn_int steps = makeDynInt(10, 10, 10, 10, 10, 10, 10, 10, 0, -1);

    for (int index = 1; index <= dynlen(steps); index++)
    {
      bool rejected = false;

      try
      {
        player.dragShape(address, fromXs[index], fromYs[index],
                         toXs[index], toYs[index], steps[index]);
      }
      catch { rejected = true; }

      this.assertTrue(rejected, "Invalid drag case " + index + " is rejected");
    }

    this.assertEqual(editor.text, "unchanged", "Invalid drags preserve text");
    player.replaceText(address, "still usable");
    this.assertEqual(editor.text, "still usable", "Input works after rejection");
    return 0;
  }

  /**
    @brief Closes only this script's owned module.
    @return Base teardown result.
    @AIgeneratedHelpContent
  */
  public int tearDown()
  {
    moduleOff("squirtStandaloneReadiness");
    player.waitForPanelClosed("squirtStandaloneReadiness", "standaloneReadiness");
    return OaTest::tearDown();
  }

//@protected members
//@private members
  private SquirtInputEventPlayer player;
  private shape editor;
  private string address =
    "squirtStandaloneReadiness.standaloneReadiness:readinessEditor";
};

/**
  @brief Parses OaTest arguments, runs all cases and exits the UI manager.
  @AIgeneratedHelpContent
*/
void main(...)
{
  va_list arguments;
  int count = va_start(arguments);
  TstSquirtStandaloneReadinessAndDrag test;
  test.cla.readArguments(arguments, count);
  va_end(arguments);
  test.startAll();
  exit(0);
}
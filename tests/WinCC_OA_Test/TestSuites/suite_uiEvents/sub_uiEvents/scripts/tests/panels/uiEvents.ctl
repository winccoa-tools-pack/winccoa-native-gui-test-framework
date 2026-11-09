/**
  @file $relPath
  @brief Standalone native tests of the copied ToolVerification callbacks.
  @copyright MIT
  @AIgeneratedHelpContent
*/
#uses "classes/SquirtInputEventPlayer"
#uses "classes/oaTest/OaTest"

/**
  @brief Exercises real panel callbacks in a test-owned UI module.
  @AIgeneratedHelpContent
*/
class TstUiEvents : OaTest
{
//@public members

  /**
    @brief Opens the fixture without changing the hosting project.
    @return Zero after successful setup.
    @AIgeneratedHelpContent
  */
  public int setUp()
  {
    OaTest::setUp();
    player.enablePrintWievInfoOnPanelSwtich = false;

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

  /**
    @test All eight initialization callbacks arrive in panel creation order.
    @AIgeneratedHelpContent
  */
  public int testInitialization()
  {
    dyn_string expected = makeDynString("init: TEXT_LEFT", "init: TEXT_RIGHT",
                                        "init: PUSH_BUTTON_CLICK", "init: TAB1", "init: SCREENSHOT",
                                        "init: PUSH_BUTTON_DBLCLICK", "init: PUSH_BUTTON_PRESS_RELEASE",
                                        "init: PUSH_BUTTON_TXTVERIFICATION");
    dyn_string actual;
    dyn_string entries = results.items();

    for (int index = 1; index <= dynlen(entries); index++)
      if (entries[index].startsWith("init: "))
        dynAppend(actual, entries[index]);

    assertEqual(actual, expected, "Individual initialization records in order");
    return 0;
  }

  /**
    @test Left clicks preserve no modifier, Ctrl, and Ctrl+Alt.
    @AIgeneratedHelpContent
  */
  public int testLeftClicks()
  {
    dyn_int modifiers = makeDynInt(0, KEY_CONTROL, KEY_CONTROL | KEY_ALT);

    for (int index = 1; index <= dynlen(modifiers); index++)
    {
      clearResults();
      player.makeCurrent(address("PUSH_BUTTON_CLICK"));
      player.leftMouseClick(50, 50, modifiers[index]);
      expectCount(2);
      expectMouse(1, "single left click: ", "MouseButtonRelease",
                  MOUSE_LEFT, 0, modifiers[index]);
    }

    return 0;
  }

  /**
    @test Press precedes release; releasing Ctrl changes only release modifiers.
    @AIgeneratedHelpContent
  */
  public int testPressRelease()
  {
    dyn_int modifiers = makeDynInt(0, KEY_CONTROL, KEY_CONTROL | KEY_ALT);

    for (int index = 1; index <= dynlen(modifiers); index++)
    {
      clearResults();
      player.makeCurrent(address("PUSH_BUTTON_PRESS_RELEASE"));
      player.mouseEvent(50, 50, MOUSE_LEFT, modifiers[index]);
      player.sleep(100);
      player.mouseEvent(50, 50, 0, 0);
      expectCount(4);
      expectMouse(1, "left mouse pressed: ", "MouseButtonPress",
                  MOUSE_LEFT, MOUSE_LEFT, modifiers[index]);
      expectMouse(3, "left mouse released: ", "MouseButtonRelease",
                  MOUSE_LEFT, 0, 0);
    }

    return 0;
  }

  /**
    @test Right clicks invoke only the right-press callback, including Ctrl.
    @AIgeneratedHelpContent
  */
  public int testRightClicks()
  {
    dyn_int modifiers = makeDynInt(0, KEY_CONTROL);

    for (int index = 1; index <= dynlen(modifiers); index++)
    {
      clearResults();
      player.makeCurrent(address("PUSH_BUTTON_PRESS_RELEASE"));
      player.rightMouseClick(50, 50, modifiers[index]);
      expectCount(2);
      expectMouse(1, "right mouse pressed: ", "MouseButtonPress",
                  MOUSE_RIGHT, MOUSE_RIGHT, modifiers[index]);
    }

    return 0;
  }

  /**
    @test Table cell input reports row, column and value as separate records.
    @AIgeneratedHelpContent
  */
  public int testTableCell()
  {
    clearResults();
    player.makeCurrent(address("TABLE1"));
    player.mouseEventTableCell(1, 0, MOUSE_LEFT, 0);
    player.sleep(100);
    player.mouseEventTableCell(1, 0, 0, 0);
    expectCount(3);
    assertEqual(results.items(), makeDynString("Zeile: 1",
        "Spalte: Forename", "Value: Martin"), "Ordered table callback records");
    return 0;
  }

  /**
    @test Mouse and arrow-key tab navigation expose the RP2 callback.
    @AIgeneratedHelpContent
  */
  public int testTabs()
  {
    clearResults();
    player.makeCurrent(address("TAB1"));
    player.leftMouseClick(80, 15);
    player.sleep(200);
    player.makeCurrent(address("PUSH_BUTTON_RP2"));
    player.leftMouseClick(50, 50);
    expectCount(2);
    expectMouse(1, "RP2 single click: ", "MouseButtonRelease",
                MOUSE_LEFT, 0, 0);
    player.sleep(1100);
    clearResults();
    player.makeCurrent(address("TAB1"));
    player.leftMouseClick(20, 10);
    player.keyClick("", KEY_RIGHT, 0);
    player.sleep(200);
    player.makeCurrent(address("PUSH_BUTTON_RP2"));
    player.leftMouseClick(50, 50);
    expectCount(2);
    expectMouse(1, "RP2 single click: ", "MouseButtonRelease",
                MOUSE_LEFT, 0, 0);
    player.sleep(1100);
    return 0;
  }

  /**
    @test Text entry, clipboard transfer and focus callbacks retain exact order.
    @AIgeneratedHelpContent
  */
  public int testTextClipboardFocus()
  {
    clearResults();
    shape rightEditor = player.getShapeWait(address("TEXT_RIGHT"));
    this.info("TEXT_RIGHT enabled=" + rightEditor.enabled +
              ", visible=" + rightEditor.visible);
    player.replaceText(address("TEXT_LEFT"), "Tool Verification 2");
    player.keyClick("\x01", 65, KEY_CONTROL);
    player.keyClick("", 16777249, 0);
    player.keyClick("\x03", 67, KEY_CONTROL);
    player.keyClick("", 16777249, 0);
    player.makeCurrent(address("TEXT_RIGHT"));
    player.leftMouseClick(50, 50);
    player.sleep(300);
    player.keyClick("\x01", 65, KEY_CONTROL);
    player.keyClick("\x16", 86, KEY_CONTROL);
    player.keyClick("", 16777249, 0);
    player.sleep(200);
    player.clickShape(address("PUSH_BUTTON_TXTVERIFICATION"));
    expectCount(5);
    assertEqual(results.items(), makeDynString("focus in: TEXT_LEFT",
        "focus out: TEXT_LEFT", "focus in: TEXT_RIGHT",
        "focus out: TEXT_RIGHT",
        "Textfield_RIGHT, Value is: Tool Verification 2"),
                "Focus transitions precede verification of the pasted text");
    return 0;
  }

  /**
    @test Double click must deliver MouseButtonDblClick, not two clicks.
    @AIgeneratedHelpContent
  */
  public int testNativeDoubleClick()
  {
    clearResults();
    player.makeCurrent(address("PUSH_BUTTON_DBLCLICK"));
    player.leftMouseDoubleClick(50, 50);
    expectCount(2);
    expectMouse(1, "double left click: ", "MouseButtonDblClick",
                MOUSE_LEFT, MOUSE_LEFT, 0);
    return 0;
  }

//@protected members

//@private members
  private string moduleName = "suite_uiEvents_native";
  private SquirtInputEventPlayer player;
  private shape results;

  private string address(const string & shapeName)
  {
    return moduleName + ".main_pnl:" + shapeName;
  }

  private void clearResults()
  {
    player.clickShape(address("PUSH_BUTTON_DELETERESULTS"));
    expectCount(0);
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
    this.info("Callback records: " + jsonEncode(entries));
    assertEqual(dynlen(entries), expected, "Exact callback record count");
  }

  private void expectMouse(int index, const string & prefix,
                           const string & eventType, int button,
                           int buttons, int modifiers)
  {
    dyn_string entries = results.items();

    if (dynlen(entries) < index + 1)
    {
      assertTrue(false, "Missing prefix/JSON pair: " + prefix);
      return;
    }

    assertEqual(entries[index], prefix, "Callback prefix at expected index");
    mapping event = jsonDecode(entries[index + 1]);
    assertEqual((string)event["type"], eventType, "Native event type");
    assertEqual((int)event["button"], button, "Changed mouse button");
    assertEqual((int)event["buttons"], buttons, "Currently held buttons");
    assertEqual((int)event["modifiers"], modifiers, "Keyboard modifiers");
    assertFalse((bool)event["isSynthesized"], "Native callback provenance");
    assertEqual((string)event["buttonAsString"],
                button == MOUSE_LEFT ? "LeftButton" : "RightButton",
                "Changed button name");
    assertEqual((string)event["buttonsAsString"], buttons == 0 ? "NoButton" :
                (buttons == MOUSE_LEFT ? "LeftButton" : "RightButton"),
                "Held button names agree with bitmask");
  }
};

void main(...)
{
  va_list arguments;
  int count = va_start(arguments);
  TstUiEvents test;
  test.cla.readArguments(arguments, count);
  va_end(arguments);
  test.startAll();
  exit(0);
}
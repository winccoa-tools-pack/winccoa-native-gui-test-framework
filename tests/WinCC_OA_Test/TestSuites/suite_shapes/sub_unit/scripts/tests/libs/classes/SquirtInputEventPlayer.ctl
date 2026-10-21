/**
  @file tests/WinCC_OA_Test/TestSuites/suite_shapes/sub_unit/scripts/tests/libs/classes/SquirtInputEventPlayer.ctl
  @copyright MIT
  @test Exercises input helpers against isolated, dynamically created widgets.
  @AIgeneratedHelpContent
*/

#uses "classes/SquirtInputEventPlayer"
#uses "classes/oaTest/OaTest"
#uses "panel"

/**
  @brief Live UI regression tests for the Squirt input helpers.
  @AIgeneratedHelpContent
*/
class TstSquirtInputEventPlayer : OaTest
{
//@public members
  /**
    @brief Creates an isolated panel and editable text field.
    @return Zero on success.
    @AIgeneratedHelpContent
  */
  public int setUp()
  {
    if (OaTest::setUp() != 0)
      return -1;

    ModuleOnWithPanel("squirtInputHelpers", -1, -1, 700, 500, 2, 2, "",
                      "about.pnl", "inputHelpers", makeDynString());
    player.waitForPanelOpen("squirtInputHelpers", "inputHelpers");
    editor = addShape("squirtInputHelpers", "inputHelpers", 1,
                      "TEXT_FIELD", "inputEditor");
    setValue(editor, "position", 20, 20, "size", 240, 35,
             "visible", true, "enabled", true);
    return 0;
  }

  /**
    @test Whole-string input, clear, replacement and explicit commit.
    @AIgeneratedHelpContent
  */
  public int testTextInput()
  {
    player.replaceText(address, "initial");
    player.waitForAttribute(address, "text", "initial");
    player.clearText(address);
    player.waitForAttribute(address, "text", "");
    player.writeText(address, "replacement");
    player.waitForAttribute(address, "text", "replacement");
    player.commitText(address);
    this.assertEqual(editor.text, "replacement", "Editor retains input");
    return 0;
  }

  /**
    @test Multibyte and supplementary Unicode survive a whole-string key event.
    @AIgeneratedHelpContent
  */
  public int testUnicodeInput()
  {
    string sample = "Grüße 漢字 😀";
    player.replaceText(address, sample);
    this.assertTrue(editor.text == sample, "Unicode input round-trips");
    player.clearText(address);
    this.assertTrue(editor.text == "", "Unicode input clears completely");
    return 0;
  }

  /**
    @test Checkbox requests are idempotent and change state through input.
    @AIgeneratedHelpContent
  */
  public int testCheckboxInput()
  {
    shape checkbox = addShape("squirtInputHelpers", "inputHelpers", 1,
                              "CHECK_BOX", "inputCheckbox");
    setValue(checkbox, "position", 20, 70, "size", 240, 70,
             "visible", true, "enabled", true);
    string target = "squirtInputHelpers.inputHelpers:inputCheckbox";
    player.setChecked(target, 0, true);
    player.setChecked(target, 0, true);
    bool checked;
    getValue(checkbox, "state", 0, checked);
    this.assertTrue(checked, "Repeated true does not toggle off");
    player.setChecked(target, 0, false);
    getValue(checkbox, "state", 0, checked);
    this.assertTrue(!checked, "False request toggles through input");
    return 0;
  }

  /**
    @test Exact combo selection, repeated requests and duplicate rejection.
    @AIgeneratedHelpContent
  */
  public int testComboInput()
  {
    shape combo = addShape("squirtInputHelpers", "inputHelpers", 1,
                           "COMBO_BOX", "inputCombo");
    setValue(combo, "position", 300, 20, "size", 240, 35,
             "items", makeDynString("First", "Second", "Third"),
             "visible", true, "enabled", true);
    string target = "squirtInputHelpers.inputHelpers:inputCombo";
    player.selectComboItemByText(target, "Third");
    player.selectComboItemByText(target, "First");
    player.selectComboItemByText(target, "First");
    this.assertEqual(combo.selectedText, "First", "Combo selection via keys");
    setValue(combo, "items", makeDynString("Duplicate", "Duplicate"));
    bool rejected = false;

    try { player.selectComboItemByText(target, "Duplicate"); }
    catch { rejected = true; }

    this.assertTrue(rejected, "Duplicate combo labels must be rejected");
    return 0;
  }

  /**
    @test Table click, row lookup and rejection of ambiguous values.
    @AIgeneratedHelpContent
  */
  public int testTableInput()
  {
    shape table = addShape("squirtInputHelpers", "inputHelpers", 1,
                           "TABLE", "inputTable");
    setValue(table, "position", 20, 170, "size", 260, 180,
             "visible", true, "enabled", true);
    table.insertColumn(0);
    table.columnName(0) = "Value";
    table.appendLine("Value", "Unique");
    table.appendLine("Value", "Duplicate");
    table.appendLine("Value", "Duplicate");
    string target = "squirtInputHelpers.inputHelpers:inputTable";
    player.clickTableCell(target, 0, 0);
    this.assertEqual(player.selectTableRowByValue(target, "Value", "Unique"),
                     0, "Unique row uses zero-based indexing");
    player.doubleClickTableCell(target, 0, 0);
    bool rejected = false;

    try { player.selectTableRowByValue(target, "Value", "Duplicate"); }
    catch { rejected = true; }

    this.assertTrue(rejected, "Duplicate table values must be rejected");
    return 0;
  }

  /**
    @test Tree ancestors expand and a child is selected through input.
    @AIgeneratedHelpContent
  */
  public int testTreeInput()
  {
    shape tree = addShape("squirtInputHelpers", "inputHelpers", 1,
                          "TREE", "inputTree");
    setValue(tree, "position", 310, 170, "size", 260, 180,
             "visible", true, "enabled", true);
    tree.addColumn("Name");
    tree.appendItem("", "parent", "Parent");
    tree.appendItem("parent", "child", "Child");
    string target = "squirtInputHelpers.inputHelpers:inputTree";
    player.expandTreePath(target, makeDynString("parent"));
    this.assertTrue(tree.isOpen("parent"), "Parent expands via input");
    player.selectTreePath(target, makeDynString("parent", "child"));
    this.assertEqual(tree.selectedItem(), "child", "Child selected via input");
    return 0;
  }

  /**
    @test Shortcuts focus their target; dragging selects editor text.
    @AIgeneratedHelpContent
  */
  public int testShortcutAndDrag()
  {
    player.replaceText(address, "drag selection");
    player.pressShortcut(address, 0x41, KEY_CONTROL);
    player.keyClick("", 0x01000003, 0);
    this.assertTrue(editor.text == "", "Shortcut selects target text");
    player.replaceText(address, "drag selection");
    player.dragShape(address, 5, 15, 150, 15);
    player.keyClick("", 0x01000003, 0);
    this.assertTrue(strlen(editor.text) < strlen("drag selection"),
                    "Drag selects editor text");
    return 0;
  }

  /**
    @test Immediate checks and hidden/disabled shape rejection.
    @AIgeneratedHelpContent
  */
  public int testReadiness()
  {
    player.waitForPanelOpen("squirtInputHelpers", "inputHelpers", 0);
    player.waitForPanelClosed("absentSquirtModule", "absentPanel", 0);
    player.waitForAttribute(address, "visible", true, 0);
    editor.enabled = false;
    bool rejected = false;

    try { player.clickShape(address, 0); }
    catch { rejected = true; }

    this.assertTrue(rejected, "Disabled target must be rejected");
    editor.enabled = true;
    editor.visible = false;
    rejected = false;

    try { player.clickShape(address, 0); }
    catch { rejected = true; }

    this.assertTrue(rejected, "Hidden target must be rejected");
    editor.visible = true;
    return 0;
  }

  /**
    @test Invalid drag parameters fail before pressing a mouse button.
    @AIgeneratedHelpContent
  */
  public int testInvalidDrag()
  {
    bool rejected = false;

    try { player.dragShape(address, 0, 0, 10, 10, 0); }
    catch { rejected = true; }

    this.assertTrue(rejected, "Zero drag steps must be rejected");
    return 0;
  }

  /**
    @brief Closes only the test-owned module.
    @return Base teardown result.
    @AIgeneratedHelpContent
  */
  public int tearDown()
  {
    moduleOff("squirtInputHelpers");
    player.waitForPanelClosed("squirtInputHelpers", "inputHelpers");
    return OaTest::tearDown();
  }

//@protected members
//@private members
  private SquirtInputEventPlayer player;
  private shape editor;
  private string address = "squirtInputHelpers.inputHelpers:inputEditor";
};

void main(...)
{
  va_list arguments;
  int count = va_start(arguments);
  TstSquirtInputEventPlayer test;
  test.cla.readArguments(arguments, count);
  va_end(arguments);
  test.startAll();
  exit(0);
}
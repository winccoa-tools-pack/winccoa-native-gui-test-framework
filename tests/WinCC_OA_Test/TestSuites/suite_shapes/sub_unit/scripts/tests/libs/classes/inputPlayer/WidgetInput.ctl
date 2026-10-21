/**
  @file $relPath
  @copyright MIT
  @test Standalone checkbox, combo and table input checks.
  @AIgeneratedHelpContent
*/

#uses "classes/SquirtInputEventPlayer"
#uses "classes/oaTest/OaTest"
#uses "panel"

/**
  @brief Isolated widget input tests without shared panel dependencies.
  @AIgeneratedHelpContent
*/
class TstSquirtStandaloneWidgetInput : OaTest
{
//@public members
  /**
    @brief Opens the owned panel and creates checkbox, combo and table shapes.
    @return Zero on success, minus one if base setup fails.
    @AIgeneratedHelpContent
  */
  public int setUp()
  {
    if (OaTest::setUp() != 0)
      return -1;

    ModuleOnWithPanel("squirtStandaloneWidget", -1, -1, 700, 500, 2, 2, "",
                      "about.pnl", "standaloneWidget", makeDynString());
    player.waitForPanelOpen("squirtStandaloneWidget", "standaloneWidget");
    checkbox = addShape("squirtStandaloneWidget", "standaloneWidget", 1,
                        "CHECK_BOX", "widgetCheckbox");
    setValue(checkbox, "position", 20, 20, "size", 240, 70,
             "visible", true, "enabled", true);
    combo = addShape("squirtStandaloneWidget", "standaloneWidget", 1,
                     "COMBO_BOX", "widgetCombo");
    setValue(combo, "position", 300, 20, "size", 240, 35,
             "items", makeDynString("First", "Middle", "Last"),
             "visible", true, "enabled", true);
    table = addShape("squirtStandaloneWidget", "standaloneWidget", 1,
                     "TABLE", "widgetTable");
    setValue(table, "position", 20, 170, "size", 400, 180,
             "visible", true, "enabled", true);
    table.insertColumn(0);
    table.columnName(0) = "Value";
    table.appendLine("Value", "Duplicate");
    table.appendLine("Value", "Unique");
    table.appendLine("Value", "Duplicate");
    return 0;
  }

  /**
    @test Repeated checked and unchecked requests never toggle unexpectedly.
    @return Zero after assertions.
    @AIgeneratedHelpContent
  */
  public int testCheckboxIdempotence()
  {
    bool checked;
    player.setChecked(checkboxAddress, 0, true);
    getValue(checkbox, "state", 0, checked);
    this.assertTrue(checked, "True request checks the item");
    player.setChecked(checkboxAddress, 0, true);
    getValue(checkbox, "state", 0, checked);
    this.assertTrue(checked, "Repeated true remains checked");
    player.setChecked(checkboxAddress, 0, false);
    getValue(checkbox, "state", 0, checked);
    this.assertTrue(!checked, "False request unchecks the item");
    player.setChecked(checkboxAddress, 0, false);
    getValue(checkbox, "state", 0, checked);
    this.assertTrue(!checked, "Repeated false remains unchecked");
    return 0;
  }

  /**
    @test First and last combo items are reachable and repeated input is stable.
    @return Zero after assertions.
    @AIgeneratedHelpContent
  */
  public int testComboFirstAndLast()
  {
    player.selectComboItemByText(comboAddress, "Last");
    this.assertEqual(combo.selectedText, "Last", "Last item selected");
    player.selectComboItemByText(comboAddress, "First");
    this.assertEqual(combo.selectedText, "First", "First item selected");
    player.selectComboItemByText(comboAddress, "First");
    this.assertEqual(combo.selectedText, "First", "Repeated selection is stable");
    return 0;
  }

  /**
    @test Duplicate combo labels are rejected without changing selection.
    @return Zero after assertions.
    @AIgeneratedHelpContent
  */
  public int testComboDuplicateRejection()
  {
    combo.items = makeDynString("First", "Duplicate", "Duplicate", "Last");
    player.selectComboItemByText(comboAddress, "First");
    bool rejected = false;

    try { player.selectComboItemByText(comboAddress, "Duplicate"); }
    catch { rejected = true; }

    this.assertTrue(rejected, "Duplicate combo labels are rejected");
    this.assertEqual(combo.selectedText, "First", "Rejected input keeps selection");
    return 0;
  }

  /**
    @test Unique table values resolve to their zero-based row and select it.
    @return Zero after assertions.
    @AIgeneratedHelpContent
  */
  public int testTableUniqueRow()
  {
    this.assertEqual(player.selectTableRowByValue(tableAddress, "Value", "Unique"),
                     1, "Unique value resolves to the second row");
    int row, column;
    getValue(table, "currentCell", row, column);
    this.assertEqual(row, 1, "Unique row becomes current through input");
    this.assertEqual(column, 0, "Unique value column becomes current");
    return 0;
  }

  /**
    @test Duplicate table values are rejected before changing the selected row.
    @return Zero after assertions.
    @AIgeneratedHelpContent
  */
  public int testTableDuplicateRejection()
  {
    player.selectTableRowByValue(tableAddress, "Value", "Unique");
    bool rejected = false;

    try { player.selectTableRowByValue(tableAddress, "Value", "Duplicate"); }
    catch { rejected = true; }

    this.assertTrue(rejected, "Duplicate table values are rejected");
    int row, column;
    getValue(table, "currentCell", row, column);
    this.assertEqual(row, 1, "Rejected lookup keeps the current unique row");
    return 0;
  }

  /**
    @test Cell clicks and repeated click pairs select their requested rows.
    @return Zero after assertions.
    @AIgeneratedHelpContent
  */
  public int testTableCellClick()
  {
    player.clickTableCell(tableAddress, 2, 0);
    int row, column;
    getValue(table, "currentCell", row, column);
    this.assertEqual(row, 2, "Cell click makes the last row current");
    this.assertEqual(column, 0, "Cell click makes the requested column current");
    player.doubleClickTableCell(tableAddress, 0, 0);
    getValue(table, "currentCell", row, column);
    this.assertEqual(row, 0, "Click pair makes the first row current");
    return 0;
  }

  /**
    @brief Closes only this script's owned module.
    @return Base teardown result.
    @AIgeneratedHelpContent
  */
  public int tearDown()
  {
    moduleOff("squirtStandaloneWidget");
    player.waitForPanelClosed("squirtStandaloneWidget", "standaloneWidget");
    return OaTest::tearDown();
  }

//@protected members
//@private members
  private SquirtInputEventPlayer player;
  private shape checkbox;
  private shape combo;
  private shape table;
  private string checkboxAddress =
    "squirtStandaloneWidget.standaloneWidget:widgetCheckbox";
  private string comboAddress =
    "squirtStandaloneWidget.standaloneWidget:widgetCombo";
  private string tableAddress =
    "squirtStandaloneWidget.standaloneWidget:widgetTable";
};

/**
  @brief Parses OaTest arguments, runs all cases and exits the UI manager.
  @AIgeneratedHelpContent
*/
void main(...)
{
  va_list arguments;
  int count = va_start(arguments);
  TstSquirtStandaloneWidgetInput test;
  test.cla.readArguments(arguments, count);
  va_end(arguments);
  test.startAll();
  exit(0);
}
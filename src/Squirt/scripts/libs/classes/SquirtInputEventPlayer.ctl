/**
  @file src/Squirt/scripts/libs/classes/SquirtInputEventPlayer.ctl
  @copyright MIT
*/

#uses "classes/InputEventPlayer"
#uses "classes/TimeOut"
#uses "classes/json/JsonFile"

/**
  @brief Core input player for Squirt GUI tests.
  @AIgeneratedHelpContent

  Extends the WinCC OA input event player with panel-aware diagnostics,
  screenshot capture, and convenience helpers for mouse-based interactions.
  Tests can use this class as the lowest-level interaction layer before
  introducing shape-specific wrappers.
*/
class SquirtInputEventPlayer : InputEventPlayer
{
//@public members
  /**
    @brief Enables logging of the visible view on panel switches.

    When enabled, the player prints the active module, panel, and visible
    shapes each time a new panel becomes current.
  */
  public bool enablePrintWievInfoOnPanelSwtich = true;

  /**
    @brief Sleeps only for meaningful, positive scaled durations.
    @param milli Requested duration in milliseconds before time scaling.
    @details Overrides InputEventPlayer::sleep because the base forwards
    negative and sub-millisecond scaled values directly to delay().
    Nonpositive requests or time factors and effective waits below 1 ms
    are ignored rather than passed to the native delay function.
    @override
    @AIgeneratedHelpContent
  */
  public sleep(int milli)
  {
    const float factor = this.getTimeFactor();

    if (milli <= 0 || factor <= 0)
      return;

    const float duration = milli * factor;

    if (duration < 1.0)
      return;

    delay(0, duration);
  }

  /**
    @brief Makes the given shape current and tracks its owning panel.

    When the shape does not exist yet, the function waits up to @p timeout
    milliseconds. On failure, it captures the current panel state and
    rethrows the original exception.

    @param shapeName Fully qualified shape address.
    @param timeout Timeout in milliseconds.
    @override
  */
  public makeCurrent(string shapeName, int timeout = 5000)
  {
    // this is bug in the UI, you will catch wrong refNamePath like
    // ["Group114...Border2"]["vs"]["Border2"]
    if (shapeName.contains(".."))
    {
      this.currentShape = 0;
      throwError(makeError("", PRIO_WARNING, ERR_SYSTEM, 54, "Probably the reference / shape name is not defined.", shapeName));
      return;
    }

    try
    {
      this.currentShape = getShapeWait(shapeName, timeout);
      shape newPanel = this.currentShape.shapeType == "PANEL" ?  this.currentShape : this.currentShape.panel;
      bool panelSwitch = this.currentPanel == 0 || this.currentPanel != newPanel;
      this.currentPanel = newPanel;

      if (this.enablePrintWievInfoOnPanelSwtich && panelSwitch)
      {
        this.printViewInfo(currentPanel.moduleName, this.currentPanel.name());
      }
    }

    catch
    {
      dyn_errClass exception = getLastException();
      takeScreen("failed");
      // ensure the caller sees this function as the point of failure
      throw (exception);
    }

    takeScreen("success");
  }

  //-----------------------------------------------------------------------------
  /**
    @brief Returns the file path of the current panel.
    @return Panel file path of the current panel shape.
  */
  protected string getCurrentPanelPath()
  {
    return this.currentPanel.panelFileName();
  }

  //-----------------------------------------------------------------------------
  /**
    @brief Waits until a shape becomes available.

    The function validates module availability, panel availability, and the
    final shape lookup. When the lookup fails, it logs the last known reason
    together with view information before throwing an exception.

    @param shapeName Fully qualified shape address.
    @param timeout Timeout in milliseconds.
    @return The resolved shape handle.
  */
  public shape getShapeWait(string shapeName, int timeout = 2000)
  {
    const string moduleName = getModuleNameFromShapeAddress(shapeName);
    const string panelName = getPanelNameFromShapeAddress(shapeName);

    TimeOut _timeout = TimeOut((float)timeout / 1000.0);

    string lastReason;

    while (!_timeout.hasExpired())
    {
      lastReason.clear();

      if (!isModuleOpen(moduleName))
        lastReason = "The odule $1 is not openned".subst(moduleName);
      else if (!isPanelOpen(panelName, moduleName))
        lastReason = "The panel $1 in the module $2 is not openned".subst(panelName, moduleName);
      else if (!shapeExists(shapeName))
        lastReason = "The shape $1 does not exists".subst(shapeName);
      else
        break;

      delay(0, 200);
    }

    if (!lastReason.isEmpty())
    {
      throwError(makeError("", PRIO_INFO, ERR_CONTROL, 0, lastReason));
      this.printViewInfo(moduleName, panelName);


      throw (makeError("uim", PRIO_SEVERE, ERR_PARAM, 13, // no such object
                       __FILE__, __FUNCTION__, shapeName));
    }

    return getShape(shapeName);
  }

  /**
    @brief Performs a right mouse click on the current shape.
    @param x Relative x coordinate inside the current shape.
    @param y Relative y coordinate inside the current shape.
    @param modifiers Keyboard modifiers pressed during the click.
  */
  public rightMouseClick(int x, int y, int modifiers = 0)
  {
    this.mouseClickOnShape(this.currentShape, x, y, MOUSE_RIGHT, modifiers);
  }

  /**
    @brief Performs a right mouse click on a specific shape.
    @param sh Target shape.
    @param x Relative x coordinate inside the target shape.
    @param y Relative y coordinate inside the target shape.
    @param modifiers Keyboard modifiers pressed during the click.
  */
  public rightMouseClickOnShape(shape sh, int x, int y, int modifiers = 0)
  {
    this.mouseClickOnShape(sh, x, y, MOUSE_RIGHT, modifiers);
  }

  /**
    @brief Simulates a mouse click on the current shape.
    @param x Relative x coordinate inside the current shape.
    @param y Relative y coordinate inside the current shape.
    @param buttons Mouse button bitmask to press.
    @param modifiers Keyboard modifier bitmask.
  */
  public mouseClick(int x, int y, int buttons, int modifiers = 0)
  {
    this.mouseClickOnShape(this.currentShape, x, y, buttons, modifiers);
  }

  /**
    @brief Sends a press/release pair and honors shallMoveCursor().
    @param sh Target shape.
    @param x Relative x coordinate inside the target shape.
    @param y Relative y coordinate inside the target shape.
    @param buttons Mouse button bitmask to press.
    @param modifiers Keyboard modifier bitmask.
    @AIgeneratedHelpContent
  */
  public mouseClickOnShape(shape sh, int x, int y, int buttons, int modifiers = 0)
  {
    this.doMoveCursor(sh, x, y);

    sendMouseEvent(sh, x, y, buttons, modifiers);
    delay(0, 50);
    sendMouseEvent(sh, x, y, 0, modifiers);
  }

  /**
    @brief Performs two right mouse click sequences on the current shape.
    @param x Relative x coordinate inside the current shape.
    @param y Relative y coordinate inside the current shape.
    @param modifiers Keyboard modifiers pressed during the click.
    @AIgeneratedHelpContent
  */
  public rightMouseDoubleClick(int x, int y, int modifiers = 0)
  {
    this.mouseDoubleClickOnShape(this.currentShape, x, y, MOUSE_RIGHT, modifiers);
  }

  //-----------------------------------------------------------------------------
  /**
    @brief Performs a left mouse double click on the current shape.
    @param x Relative x coordinate inside the current shape.
    @param y Relative y coordinate inside the current shape.
    @param modifiers Keyboard modifiers pressed during the click.
  */
  public leftMouseDoubleClick(int x, int y, int modifiers = 0)
  {
    this.mouseDoubleClickOnShape(this.currentShape, x, y, MOUSE_LEFT, modifiers);
  }

  //-----------------------------------------------------------------------------
  /**
    @brief Performs a left mouse double click on a specific shape.
    @param sh Target shape.
    @param x Relative x coordinate inside the target shape.
    @param y Relative y coordinate inside the target shape.
    @param modifiers Keyboard modifiers pressed during the click.
  */
  public leftMouseDoubleClickOnShape(shape sh, int x, int y, int modifiers = 0)
  {
    this.mouseDoubleClickOnShape(sh, x, y, MOUSE_LEFT, modifiers);
  }

  //-----------------------------------------------------------------------------
  /**
    @brief Performs a left mouse click on a specific shape.
    @param sh Target shape.
    @param x Relative x coordinate inside the target shape.
    @param y Relative y coordinate inside the target shape.
    @param modifiers Keyboard modifiers pressed during the click.
  */
  public leftMouseClickOnShape(shape sh, int x, int y, int modifiers = 0)
  {
    this.mouseClickOnShape(sh, x, y, MOUSE_LEFT, modifiers);
  }

  //-----------------------------------------------------------------------------
  /**
    @brief Performs a left mouse click on the current shape.
    @param x Relative x coordinate inside the current shape.
    @param y Relative y coordinate inside the current shape.
    @param modifiers Keyboard modifiers pressed during the click.
  */
  public leftMouseClick(int x, int y, int modifiers = 0)
  {
    this.mouseClickOnShape(this.currentShape, x, y, MOUSE_LEFT, modifiers);
  }

  //-----------------------------------------------------------------------------
  /**
    @brief Simulates a mouse double click on a specific shape.

    The function sends two click sequences with a short delay between them.

    @param sh Target shape.
    @param x Relative x coordinate inside the target shape.
    @param y Relative y coordinate inside the target shape.
    @param buttons Mouse button bitmask to press.
    @param modifiers Keyboard modifier bitmask.
  */
  public mouseDoubleClickOnShape(shape sh, int x, int y, int buttons, int modifiers = 0)
  {
    this.mouseClickOnShape(sh, x, y, buttons, modifiers);
    delay(0, 50);
    this.mouseClickOnShape(sh, x, y, buttons, modifiers);
  }

  //-----------------------------------------------------------------------------
  /**
    @brief Returns the current panel shape.
    @return Current panel shape.
  */
  public shape getCurrentPanel() { return currentPanel; }

  //-----------------------------------------------------------------------------
  /**
    @brief Returns the current shape.
    @return Current shape.
  */
  public shape getCurrentShape() { return currentShape; }

  /**
    @brief Clicks the center of a visible, enabled shape.
    @param address Fully qualified shape address.
    @param timeout Readiness timeout in milliseconds.
    @AIgeneratedHelpContent
  */
  public void clickShape(const string &address, int timeout = 2000)
  {
    shape target = this.readyShape(address, timeout);
    int width, height;
    getValue(target, "size", width, height);
    this.mouseClickOnShape(target, width / 2, height / 2, MOUSE_LEFT);
  }

  /**
    @brief Waits for a scalar attribute without logging its value.
    @param address Fully qualified shape address.
    @param attribute Scalar readable attribute name.
    @param expected Expected attribute value.
    @param timeout Timeout in milliseconds; zero checks once.
    @AIgeneratedHelpContent
  */
  public void waitForAttribute(const string &address, const string &attribute,
                               const anytype &expected, int timeout = 2000)
  {
    TimeOut limit = TimeOut((float)timeout / 1000.0);

    do
    {
      if (shapeExists(address))
      {
        anytype actual;

        if (getValue(getShape(address), attribute, actual) == 0 &&
            actual == expected)
          return;
      }

      if (limit.hasExpired())
        break;

      this.sleep(20);
    }
    while (true);

    this.actionFailed("Attribute wait timed out", address);
  }

  /**
    @brief Waits for a panel instance to open.
    @param moduleName Owning module name.
    @param panelName Panel instance name, not its file name.
    @param timeout Timeout in milliseconds; zero checks once.
    @AIgeneratedHelpContent
  */
  public void waitForPanelOpen(const string &moduleName, const string &panelName,
                               int timeout = 2000)
  {
    this.waitForPanelState(moduleName, panelName, true, timeout);
  }

  /**
    @brief Waits for a panel instance to close, including its module closing.
    @param moduleName Owning module name.
    @param panelName Panel instance name.
    @param timeout Timeout in milliseconds; zero checks once.
    @AIgeneratedHelpContent
  */
  public void waitForPanelClosed(const string &moduleName, const string &panelName,
                                 int timeout = 2000)
  {
    this.waitForPanelState(moduleName, panelName, false, timeout);
  }

  /**
    @brief Idempotently changes one checkbox item using mouse input.
    @param address Fully qualified CHECK_BOX address.
    @param index Zero-based item index.
    @param checked Requested state.
    @param timeout Shared readiness and postcondition timeout in milliseconds.
    @AIgeneratedHelpContent
  */
  public void setChecked(const string &address, int index, bool checked,
                         int timeout = 2000)
  {
    TimeOut limit = TimeOut((float)timeout / 1000.0);
    shape target = this.readyShape(address, timeout);

    if (target.shapeType != "CHECK_BOX" || index < 0)
      this.actionFailed("Expected a checkbox and nonnegative item index", address);

    bool actual;

    if (getValue(target, "state", index, actual) != 0)
      this.actionFailed("Cannot read checkbox item", address);

    if (actual == checked)
      return;

    this.mouseEventMultiLabeled(index, MOUSE_LEFT, 0);
    this.sleep(50);
    this.mouseEventMultiLabeled(index, 0, 0);

    do
    {
      if (getValue(target, "state", index, actual) == 0 && actual == checked)
        return;

      if (limit.hasExpired())
        break;

      this.sleep(20);
    }
    while (true);

    this.actionFailed("Checkbox state did not change", address);
  }

  /**
    @brief Inserts a complete string through one key event, without logging it.
    @param address Fully qualified editable shape address.
    @param text Text to insert at the current cursor/selection.
    @param timeout Readiness timeout in milliseconds.
    @note Does not commit. No byte-wise splitting of UTF-8 input is performed.
    @AIgeneratedHelpContent
  */
  public void writeText(const string &address, const string &text,
                        int timeout = 2000)
  {
    this.clickShape(address, timeout);
    this.keyClick(text, 0, 0);
  }

  /**
    @brief Clears an editor using Select All and Backspace key events.
    @param address Fully qualified editable shape address.
    @param timeout Readiness timeout in milliseconds.
    @AIgeneratedHelpContent
  */
  public void clearText(const string &address, int timeout = 2000)
  {
    this.clickShape(address, timeout);
    this.keyClick("", 0x41, KEY_CONTROL);
    this.keyClick("", 0x01000003, 0);
  }

  /**
    @brief Replaces editor text using clearText and a complete key event.
    @param address Fully qualified editable shape address.
    @param text Replacement text, never logged by this helper.
    @param timeout Readiness timeout in milliseconds.
    @note Does not commit the edited value.
    @AIgeneratedHelpContent
  */
  public void replaceText(const string &address, const string &text,
                          int timeout = 2000)
  {
    this.clearText(address, timeout);
    this.keyClick(text, 0, 0);
  }

  /**
    @brief Explicitly commits the current editor using Return.
    @param address Fully qualified editable shape address.
    @param timeout Readiness timeout in milliseconds.
    @AIgeneratedHelpContent
  */
  public void commitText(const string &address, int timeout = 2000)
  {
    this.pressShortcut(address, KEY_RETURN, 0, timeout);
  }

  /**
    @brief Sends one key with a modifier mask to the target window.
    @param address Fully qualified target shape address.
    @param key Qt key code, for example KEY_RETURN.
    @param modifiers KEY_CONTROL, KEY_SHIFT, KEY_ALT or their bitwise union.
    @param timeout Readiness timeout in milliseconds.
    @AIgeneratedHelpContent
  */
  public void pressShortcut(const string &address, int key, int modifiers = 0,
                            int timeout = 2000)
  {
    this.clickShape(address, timeout);
    this.keyClick("", key, modifiers);
  }

  /**
    @brief Clicks a visible table cell using the inherited geometry API.
    @param address Fully qualified TABLE address.
    @param row Zero-based row index.
    @param column Zero-based column index.
    @param timeout Readiness timeout in milliseconds.
    @note The cell must already be visible; no scrolling or state writes occur.
    @AIgeneratedHelpContent
  */
  public void clickTableCell(const string &address, int row, int column,
                             int timeout = 2000)
  {
    shape target = this.readyShape(address, timeout);

    if (row < 0 || column < 0 || target.shapeType != "TABLE" ||
        row >= target.lineCount || column >= target.columnCount)
      this.actionFailed("Table cell index is out of range", address);

    string columnName = target.columnName(column);
    int cellX, cellY, width, height;

    if (getValue(target, "cellGeometry", row, columnName,
                 cellX, cellY, width, height) != 0 || width <= 2 || height <= 2)
      this.actionFailed("Expected a visible table cell", address);

    this.mouseClickOnShape(target, cellX + 2, cellY + 2, MOUSE_LEFT);
  }

  /**
    @brief Finds exactly one matching table row and clicks its matching cell.
    @param address Fully qualified TABLE address.
    @param column Column name or #1-style column identifier.
    @param value Expected cell value; not included in diagnostics.
    @param timeout Readiness timeout in milliseconds.
    @return Zero-based matched row index.
    @note Duplicate matches fail before input. Selection follows table policy.
    @AIgeneratedHelpContent
  */
  public int selectTableRowByValue(const string &address, const string &column,
                                   const anytype &value, int timeout = 2000)
  {
    shape target = this.readyShape(address, timeout);

    if (target.shapeType != "TABLE")
      this.actionFailed("Expected a table", address);

    int count;

    if (getValue(target, "lineCount", count) != 0)
      this.actionFailed("Cannot read table row count", address);

    int match = -1;

    for (int row = 0; row < count; row++)
    {
      anytype actual;

      if (getValue(target, "cellValueRC", row, column, actual) != 0)
        this.actionFailed("Cannot read table cell", address);

      if (actual == value)
      {
        if (match >= 0)
          this.actionFailed("Ambiguous table row value", address);

        match = row;
      }
    }

    if (match < 0)
      this.actionFailed("Table row value not found", address);

    int cellX, cellY, width, height;

    if (getValue(target, "cellGeometry", match, column,
                 cellX, cellY, width, height) != 0 || width <= 2 || height <= 2)
      this.actionFailed("Matched table cell is not visible", address);

    this.mouseClickOnShape(target, cellX + 2, cellY + 2, MOUSE_LEFT);
    return match;
  }

  /**
    @brief Sends two table-cell press/release pairs, not a native DblClick event.
    @param address Fully qualified TABLE address.
    @param row Zero-based row index.
    @param column Zero-based column index.
    @param timeout Readiness timeout in milliseconds.
    @note A DoubleClicked callback is not guaranteed by sendMouseEvent.
    @AIgeneratedHelpContent
  */
  public void doubleClickTableCell(const string &address, int row, int column,
                                   int timeout = 2000)
  {
    this.clickTableCell(address, row, column, timeout);
    this.sleep(50);
    this.clickTableCell(address, row, column, timeout);
  }

  /**
    @brief Selects one unique combo item using arrow and Return key events.
    @param address Fully qualified COMBO_BOX address.
    @param text Exact item text; never included in helper diagnostics.
    @param timeout Readiness and postcondition timeout in milliseconds.
    @note Duplicate labels fail before input; this commits the selection.
    @AIgeneratedHelpContent
  */
  public void selectComboItemByText(const string &address, const string &text,
                                    int timeout = 2000)
  {
    shape target = this.readyShape(address, timeout);

    if (target.shapeType != "COMBO_BOX")
      this.actionFailed("Expected a combo box", address);

    dyn_string items;

    if (getValue(target, "items", items) != 0)
      this.actionFailed("Cannot read combo items", address);

    int match = 0;

    for (int index = 1; index <= dynlen(items); index++)
    {
      if (items[index] == text)
      {
        if (match > 0)
          this.actionFailed("Ambiguous combo item text", address);

        match = index;
      }
    }

    if (match == 0)
      this.actionFailed("Combo item not found", address);

    string selected;

    if (getValue(target, "selectedText", selected) == 0 && selected == text)
      return;

    this.clickShape(address, timeout);

    for (int index = 1; index <= dynlen(items); index++)
      this.keyClick("", KEY_UP, 0);

    for (int index = 1; index < match; index++)
      this.keyClick("", KEY_DOWN, 0);

    this.keyClick("", KEY_RETURN, 0);
    this.waitForAttribute(address, "selectedText", text, timeout);
  }

  /**
    @brief Expands tree item IDs using selection and Right Arrow input.
    @param address Fully qualified TREE address.
    @param itemIds Ordered IDs of expandable ancestors, not display labels.
    @param timeout Timeout for the complete expansion in milliseconds.
    @note IDs are supplied by the caller; label-to-ID resolution is not inferred.
    @AIgeneratedHelpContent
  */
  public void expandTreePath(const string &address, const dyn_string &itemIds,
                             int timeout = 2000)
  {
    TimeOut limit = TimeOut((float)timeout / 1000.0);
    shape target = this.readyShape(address, timeout);

    if (target.shapeType != "TREE" || dynlen(itemIds) == 0)
      this.actionFailed("Expected a tree and nonempty item ID path", address);

    for (int index = 1; index <= dynlen(itemIds); index++)
    {
      string itemId = itemIds[index];

      while (!target.itemExists(itemId) && !limit.hasExpired())
        this.sleep(20);

      if (!target.itemExists(itemId))
        this.actionFailed("Tree path item does not exist", address);

      if (target.isOpen(itemId))
        continue;

      int cellX, cellY, width, height;
      target.getCellGeometry(itemId, 0, cellX, cellY, width, height);

      if (width <= 2 || height <= 2)
        this.actionFailed("Tree path item is not visible", address);

      this.mouseClickOnShape(target, cellX + width / 2,
                             cellY + height / 2, MOUSE_LEFT);
      this.keyClick("", KEY_RIGHT, 0);

      while (!target.isOpen(itemId) && !limit.hasExpired())
        this.sleep(20);

      if (!target.isOpen(itemId))
        this.actionFailed("Tree path item did not expand", address);
    }
  }

  /**
    @brief Expands ancestors and clicks the last tree item ID in column zero.
    @param address Fully qualified TREE address.
    @param itemIds Ordered ancestor IDs followed by the target ID.
    @param timeout Timeout for readiness and expansion in milliseconds.
    @note The final item must be visible; native scrolling is not synthesized.
    @AIgeneratedHelpContent
  */
  public void selectTreePath(const string &address, const dyn_string &itemIds,
                             int timeout = 2000)
  {
    if (dynlen(itemIds) == 0)
      this.actionFailed("Expected a nonempty tree item ID path", address);

    if (dynlen(itemIds) > 1)
    {
      dyn_string ancestors = itemIds;
      dynRemove(ancestors, dynlen(ancestors));
      this.expandTreePath(address, ancestors, timeout);
    }

    shape target = this.readyShape(address, timeout);
    string itemId = itemIds[dynlen(itemIds)];

    if (target.shapeType != "TREE" || !target.itemExists(itemId))
      this.actionFailed("Tree target item does not exist", address);

    int cellX, cellY, width, height;
    target.getCellGeometry(itemId, 0, cellX, cellY, width, height);

    if (width <= 2 || height <= 2)
      this.actionFailed("Tree target item is not visible", address);

    this.mouseClickOnShape(target, cellX + width / 2,
                           cellY + height / 2, MOUSE_LEFT);
    TimeOut limit = TimeOut((float)timeout / 1000.0);

    while (target.selectedItem() != itemId && !limit.hasExpired())
      this.sleep(20);

    if (target.selectedItem() != itemId)
      this.actionFailed("Tree target item was not selected", address);
  }

  /**
    @brief Drags within one shape using interpolated held-button mouse events.
    @param address Fully qualified target address.
    @param fromX Starting local x coordinate.
    @param fromY Starting local y coordinate.
    @param toX Ending local x coordinate.
    @param toY Ending local y coordinate.
    @param steps Positive number of move events.
    @param timeout Readiness timeout in milliseconds.
    @note Does not implement cross-widget native drag-and-drop MIME transfer.
    @AIgeneratedHelpContent
  */
  public void dragShape(const string &address, int fromX, int fromY,
                        int toX, int toY,
                        int steps = 10, int timeout = 2000)
  {
    shape target = this.readyShape(address, timeout);
    int width, height;
    getValue(target, "size", width, height);

    if (steps < 1 || fromX < 0 || fromY < 0 || toX < 0 || toY < 0 ||
        fromX >= width || toX >= width || fromY >= height || toY >= height)
      this.actionFailed("Invalid drag coordinates or step count", address);

    this.mouseEvent(fromX, fromY, MOUSE_LEFT, 0);

    try
    {
      for (int step = 1; step <= steps; step++)
      {
        this.mouseEvent(fromX + (toX - fromX) * step / steps,
                        fromY + (toY - fromY) * step / steps, MOUSE_LEFT, 0);
        this.sleep(20);
      }
    }
    catch
    {
      dyn_errClass exception = getLastException();
      this.mouseEvent(toX, toY, 0, 0);
      throw (exception);
    }

    this.mouseEvent(toX, toY, 0, 0);
  }

  /**
    @brief Injects one explicit touch frame without changing mouse behavior.
    @param address Fully qualified target shape address.
    @param points Contacts with integer id, state, x and y entries.
    @param timeout Readiness timeout in milliseconds.
    @note States are pressed, moved, stationary and released. Callers own
    contact lifetimes across frames. Coordinates are local to the target.
    @AIgeneratedHelpContent
  */
  public void touchFrame(const string &address, const dyn_mapping &points,
                         int timeout = 2000)
  {
    shape target = this.readyShape(address, timeout);
    this.validateTouchFrame(target, points, address);
    this.dispatchTouchFrame(target, points);
  }

  /**
    @brief Taps the center of a visible, enabled target using touch input.
    @param address Fully qualified shape address.
    @param timeout Readiness timeout in milliseconds.
    @AIgeneratedHelpContent
  */
  public void tapShape(const string &address, int timeout = 2000)
  {
    this.longPressShape(address, 50, timeout);
  }

  /**
    @brief Sends two center taps separated by 50 scaled milliseconds.
    @param address Fully qualified shape address.
    @param timeout Readiness timeout in milliseconds per tap.
    @note A native DoubleClicked callback depends on the target widget.
    @AIgeneratedHelpContent
  */
  public void doubleTapShape(const string &address, int timeout = 2000)
  {
    this.tapShape(address, timeout);
    this.sleep(50);
    this.tapShape(address, timeout);
  }

  /**
    @brief Holds one contact at the target center, then releases it.
    @param address Fully qualified shape address.
    @param duration Nonnegative dwell in scaled milliseconds.
    @param timeout Readiness timeout in milliseconds.
    @note Long-press recognition depends on widget policy and scaled dwell.
    @AIgeneratedHelpContent
  */
  public void longPressShape(const string &address, int duration = 1200,
                             int timeout = 2000)
  {
    if (duration < 0)
      this.actionFailed("Touch duration must be nonnegative", address);

    shape target = this.readyShape(address, timeout);
    int width, height;
    getValue(target, "size", width, height);
    dyn_mapping contacts = makeDynMapping(makeMapping(
                                            "id", 1, "state", "pressed", "x", width / 2, "y", height / 2));
    this.validateTouchFrame(target, contacts, address);

    try
    {
      this.dispatchTouchFrame(target, contacts);
      this.sleep(duration);
      contacts[1]["state"] = "released";
      this.dispatchTouchFrame(target, contacts);
    }
    catch
    {
      dyn_errClass exception = getLastException();
      this.releaseTouchContacts(target, contacts);
      throw (exception);
    }
  }

  /**
    @brief Moves one touch contact between explicit local endpoints.
    @param address Fully qualified shape address.
    @param fromX Starting local x coordinate.
    @param fromY Starting local y coordinate.
    @param toX Ending local x coordinate.
    @param toY Ending local y coordinate.
    @param steps Positive number of movement frames.
    @param duration Nonnegative total movement time in scaled milliseconds.
    @param timeout Readiness timeout in milliseconds.
    @note Does not promise a Swipe or drag-and-drop callback.
    @AIgeneratedHelpContent
  */
  public void swipeShape(const string &address, int fromX, int fromY,
                         int toX, int toY, int steps = 10,
                         int duration = 300, int timeout = 2000)
  {
    dyn_mapping starts = makeDynMapping(makeMapping(
                                          "id", 1, "x", fromX, "y", fromY));
    dyn_mapping ends = makeDynMapping(makeMapping(
                                        "id", 1, "x", toX, "y", toY));
    this.runTouchGesture(address, starts, ends, steps, duration, timeout);
  }

  /**
    @brief Moves two persistent contacts, for example a pinch or spread.
    @param address Fully qualified shape address.
    @param starts Exactly two mappings with integer id, x and y entries.
    @param ends Endpoints in the same order with matching contact IDs.
    @param steps Positive number of movement frames.
    @param duration Nonnegative total movement time in scaled milliseconds.
    @param timeout Readiness timeout in milliseconds.
    @note Both contacts occur in every frame. Widget gesture recognition
    must be asserted separately; injection alone does not prove recognition.
    @AIgeneratedHelpContent
  */
  public void twoContactGesture(const string &address,
                                const dyn_mapping &starts,
                                const dyn_mapping &ends, int steps = 10,
                                int duration = 300, int timeout = 2000)
  {
    if (dynlen(starts) != 2 || dynlen(ends) != 2)
      this.actionFailed("Expected exactly two touch endpoints", address);

    this.runTouchGesture(address, starts, ends, steps, duration, timeout);
  }

//@protected members
  /** Current panel tracked for screenshots and diagnostics. */
  protected shape/*<"PANEL">*/ currentPanel;

  /**
    @brief Dispatches a validated frame to the native UI touch injector.
    @param target Resolved target shape.
    @param points Complete contact frame.
    @noExternalUse
    @AIgeneratedHelpContent
  */
  protected void dispatchTouchFrame(const shape &target,
                                    const dyn_mapping &points)
  {
    if (sendTouchEvent(target, points) != 0)
      this.actionFailed("Native touch dispatch failed", target.name());
  }

  /**
    @brief Moves the visible cursor when enabled and a target is available.
    @param sh Target shape used to resolve global coordinates.
    @param x Relative x coordinate inside the target shape.
    @param y Relative y coordinate inside the target shape.
    @AIgeneratedHelpContent
  */
  protected void doMoveCursor(const shape &sh, int x, int y)
  {
    if (this.shallMoveCursor() && sh)
    {
      int globalX, globalY;
      getValue(sh, "mapToGlobal", x, y, globalX, globalY);
      setCursorPosition(globalX, globalY, true);
    }
  }

  /**
    @brief Captures the current panel into a standard screenshot path.
    @param suffix Suffix appended to the output file name.
  */
  protected void takeScreen(const string & suffix)
  {
    if (!shapeExists(currentPanel))
      return;

    const string imageDir = PROJ_PATH + DATA_REL_PATH + "splash/captures/";

    if (!isdir(imageDir))
      mkdir(imageDir);

    const string imagePath = imageDir + "latest-" + suffix + ".png";

    if (isfile(imagePath))
      remove(imagePath);

    setValue(currentPanel, "imageToFile",  imagePath);
  }

//@private members
  private void releaseTouchContacts(const shape &target,
                                    const dyn_mapping &contacts)
  {
    try
    {
      dyn_mapping released = contacts;

      for (int index = 1; index <= dynlen(released); index++)
        released[index]["state"] = "released";

      this.dispatchTouchFrame(target, released);
    }
    catch
    {
      dyn_errClass cleanupError = getLastException();
      throwError(cleanupError);
    }
  }

  private void runTouchGesture(const string &address,
                               const dyn_mapping &starts,
                               const dyn_mapping &ends, int steps,
                               int duration, int timeout)
  {
    if (steps < 1 || duration < 0 || dynlen(starts) == 0 ||
        dynlen(starts) != dynlen(ends))
      this.actionFailed("Invalid touch steps, duration or endpoints", address);

    shape target = this.readyShape(address, timeout);
    dyn_mapping contacts = starts;
    dyn_mapping finalContacts = ends;

    for (int index = 1; index <= dynlen(contacts); index++)
    {
      contacts[index]["state"] = "pressed";
      finalContacts[index]["state"] = "released";
    }

    this.validateTouchFrame(target, contacts, address);
    this.validateTouchFrame(target, finalContacts, address);

    for (int index = 1; index <= dynlen(contacts); index++)
      if (contacts[index]["id"] != finalContacts[index]["id"])
        this.actionFailed("Touch endpoint IDs must match in order", address);

    try
    {
      this.dispatchTouchFrame(target, contacts);

      for (int step = 1; step <= steps; step++)
      {
        this.sleep(duration * step / steps - duration * (step - 1) / steps);

        for (int index = 1; index <= dynlen(contacts); index++)
        {
          int fromX = starts[index]["x"];
          int fromY = starts[index]["y"];
          int toX = ends[index]["x"];
          int toY = ends[index]["y"];
          contacts[index]["x"] = fromX + (toX - fromX) * step / steps;
          contacts[index]["y"] = fromY + (toY - fromY) * step / steps;
          contacts[index]["state"] = fromX == toX && fromY == toY ?
                                     "stationary" : "moved";
        }

        this.dispatchTouchFrame(target, contacts);
      }

      this.dispatchTouchFrame(target, finalContacts);
    }
    catch
    {
      dyn_errClass exception = getLastException();
      this.releaseTouchContacts(target, contacts);
      throw (exception);
    }
  }

  private void validateTouchFrame(const shape &target,
                                  const dyn_mapping &points,
                                  const string &address)
  {
    int width, height;
    getValue(target, "size", width, height);
    dyn_int ids;

    if (dynlen(points) == 0)
      this.actionFailed("Expected at least one touch contact", address);

    for (int index = 1; index <= dynlen(points); index++)
    {
      mapping point = points[index];

      if (!mappingHasKey(point, "id") || !mappingHasKey(point, "state") ||
          !mappingHasKey(point, "x") || !mappingHasKey(point, "y"))
        this.actionFailed("Touch contact requires id, state, x and y", address);

      if (getType(point["id"]) != INT_VAR ||
          getType(point["x"]) != INT_VAR || getType(point["y"]) != INT_VAR ||
          getType(point["state"]) != STRING_VAR)
        this.actionFailed("Touch id/x/y must be int and state string", address);

      int id = point["id"];
      int posX = point["x"];
      int posY = point["y"];
      string state = point["state"];

      if (id < 0 || dynContains(ids, id) || posX < 0 || posY < 0 ||
          posX >= width || posY >= height ||
          (state != "pressed" && state != "moved" &&
           state != "stationary" && state != "released"))
        this.actionFailed("Invalid touch contact or duplicate ID", address);

      dynAppend(ids, id);
    }
  }

  private void actionFailed(const string &reason, const string &address)
  {
    throw (makeError("uim", PRIO_SEVERE, ERR_PARAM, 13, reason, address));
  }

  private shape readyShape(const string &address, int timeout)
  {
    TimeOut limit = TimeOut((float)timeout / 1000.0);

    do
    {
      if (shapeExists(address))
      {
        shape target = getShape(address);
        bool visible, enabled;
        int width, height;

        if (getValue(target, "visible", visible, "enabled", enabled,
                     "size", width, height) == 0 &&
            visible && enabled && width > 0 && height > 0)
        {
          this.currentShape = target;
          this.currentPanel = target.panel;
          return target;
        }
      }

      if (limit.hasExpired())
        break;

      this.sleep(20);
    }
    while (true);

    this.actionFailed("Shape is missing, hidden, disabled or empty", address);
    return 0;
  }

  private void waitForPanelState(const string &moduleName, const string &panelName,
                                 bool open, int timeout)
  {
    TimeOut limit = TimeOut((float)timeout / 1000.0);

    do
    {
      bool actual = isModuleOpen(moduleName) &&
                    isPanelOpen(panelName, moduleName);

      if (actual == open)
        return;

      if (limit.hasExpired())
        break;

      this.sleep(20);
    }
    while (true);

    this.actionFailed("Panel wait timed out", moduleName + "." + panelName);
  }

  //-----------------------------------------------------------------------------
  private printViewInfo(const string & moduleName, const string & panelName)
  {
    dyn_string visibleShapes = getShapes(moduleName, panelName, "visible", true);
    throwError(makeError("", PRIO_INFO, ERR_CONTROL, 0,
                         "Module name:\n\t" + moduleName +
                         "\nPanel name:\n\t" + panelName +
                         "\nVisible shapes:\n\t" + strjoin(visibleShapes, "\n\t")));
  }

  //-----------------------------------------------------------------------------
  private string getModuleNameFromShapeAddress(const string & shapeAddress)
  {
    return substr(shapeAddress, 0, strpos(shapeAddress, "."));
  }

  //-----------------------------------------------------------------------------
  private string getShapeRelativeAddressFromShapeAddress(const string & shapeAddress)
  {
    return substr(shapeAddress, strpos(shapeAddress, ":") + 1);
  }

  //-----------------------------------------------------------------------------
  private string getPanelNameFromShapeAddress(const string & shapeAddress)
  {
    string panelName = substr(shapeAddress, strlen(getModuleNameFromShapeAddress(shapeAddress)) + 1);
    panelName = substr(panelName, 0, strpos(panelName, ":"));
    return panelName;
  }
};

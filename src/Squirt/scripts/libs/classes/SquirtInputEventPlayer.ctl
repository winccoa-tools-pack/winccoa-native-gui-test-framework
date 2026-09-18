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

  //-----------------------------------------------------------------------------
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

  //-----------------------------------------------------------------------------
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

  //-----------------------------------------------------------------------------
  /**
    @brief Simulates a mouse click on a specific shape.

    The function optionally moves the visible cursor, sends a press event,
    waits briefly, and then sends the matching release event.

    @param sh Target shape.
    @param x Relative x coordinate inside the target shape.
    @param y Relative y coordinate inside the target shape.
    @param buttons Mouse button bitmask to press.
    @param modifiers Keyboard modifier bitmask.
  */
  public mouseClickOnShape(shape sh, int x, int y, int buttons, int modifiers = 0)
  {
    if ( moveCursor )
    {
      if ( sh )
      {
        int gx, gy;
        getValue(sh, "mapToGlobal", x, y, gx, gy);
        setCursorPosition(gx, gy, true);
      }
    }

    // press mouse button(s)
    sendMouseEvent(sh, x, y, buttons, modifiers);
    // wait a little for the UI to react
    delay(0, 50);
    // release mouse button(s)
    sendMouseEvent(sh, x, y, 0, modifiers);
  }

  //-----------------------------------------------------------------------------
  /**
    @brief Performs a right mouse double click on the current shape.
    @param x Relative x coordinate inside the current shape.
    @param y Relative y coordinate inside the current shape.
    @param modifiers Keyboard modifiers pressed during the click.
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
    if ( moveCursor )
    {
      if ( sh )
      {
        int gx, gy;
        getValue(sh, "mapToGlobal", x, y, gx, gy);
        setCursorPosition(gx, gy, true);
      }
    }

    // click 1
    // press mouse button(s)
    sendMouseEvent(sh, x, y, buttons, modifiers);
    // wait a little for the UI to react
    delay(0, 50);
    // release mouse button(s)
    sendMouseEvent(sh, x, y, 0, modifiers);

    // wait a little for the UI to react
    delay(0, 50);
    
    // click 2
    // press mouse button(s)
    sendMouseEvent(sh, x, y, buttons, modifiers);
    // wait a little for the UI to react
    delay(0, 50);
    // release mouse button(s)
    sendMouseEvent(sh, x, y, 0, modifiers);
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

//@protected members
  /** Current panel tracked for screenshots and diagnostics. */
  protected shape/*<"PANEL">*/ currentPanel;

  /**
    @brief Captures the current panel into a standard screenshot path.
    @param suffix Suffix appended to the output file name.
  */
  protected void takeScreen(const string &suffix)
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
  //-----------------------------------------------------------------------------
  private printViewInfo(const string &moduleName, const string &panelName)
  {
    dyn_string visibleShapes = getShapes(moduleName, panelName, "visible", true);
    throwError(makeError("", PRIO_INFO, ERR_CONTROL, 0,
                         "Module name:\n\t" + moduleName +
                         "\nPanel name:\n\t" + panelName +
                         "\nVisible shapes:\n\t" + strjoin(visibleShapes, "\n\t")));
  }

  //-----------------------------------------------------------------------------
  private string getModuleNameFromShapeAddress(const string &shapeAddress)
  {
    return substr(shapeAddress, 0, strpos(shapeAddress, "."));
  }

  //-----------------------------------------------------------------------------
  private string getShapeRelativeAddressFromShapeAddress(const string &shapeAddress)
  {
    return substr(shapeAddress, strpos(shapeAddress, ":") + 1);
  }

  //-----------------------------------------------------------------------------
  private string getPanelNameFromShapeAddress(const string &shapeAddress)
  {
    string panelName = substr(shapeAddress, strlen(getModuleNameFromShapeAddress(shapeAddress)) + 1);
    panelName = substr(panelName, 0, strpos(panelName, ":"));
    return panelName;
  }
};

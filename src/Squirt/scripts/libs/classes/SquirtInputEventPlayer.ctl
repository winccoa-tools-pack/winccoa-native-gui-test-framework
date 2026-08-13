#uses "classes/TimeOut"
#uses "classes/json/JsonFile"
#uses "classes/InputEventPlayer"

/** class to simulate user input for test automation
*/
class SquirtInputEventPlayer : InputEventPlayer
{
  public bool enablePrintWievInfoOnPanelSwtich = true;
  /** make the given object the current one and ensure it exists
      When the object does not exist when the function starts,
      it will wait up to @timeout milliseconds until the object appears.
      If it will not appear, an exception is thrown
    @param shapeName
    @param timeout timeout in milliseconds
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

  protected string getCurrentPanelPath()
  {
    return this.currentPanel.panelFileName();
  }



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
//       DebugTN(getShape(shapeName));
//       DebugTN(getShape(moduleName, panelName, getShapeRelativeAddressFromShapeAddress(shapeName)));
//       DebugTN(getShape(moduleName, panelName, getShapeRelativeAddressFromShapeAddress(shapeName)));
//       DebugTN(getShapeStrict(moduleName, panelName, getShapeRelativeAddressFromShapeAddress(shapeName)));
      throwError(makeError("", PRIO_INFO, ERR_CONTROL, 0, lastReason));
      this.printViewInfo(moduleName, panelName);


      throw (makeError("uim", PRIO_SEVERE, ERR_PARAM, 13, // no such object
                       __FILE__, __FUNCTION__, shapeName));
    }

    return getShape(shapeName);
  }

  private printViewInfo(const string &moduleName, const string &panelName)
  {
    dyn_string visibleShapes = getShapes(moduleName, panelName, "visible", true);
    throwError(makeError("", PRIO_INFO, ERR_CONTROL, 0,
                         "Module name:\n\t" + moduleName +
                         "\nPanel name:\n\t" + panelName +
                         "\nVisible shapes:\n\t" + strjoin(visibleShapes, "\n\t")));
  }

  private string getModuleNameFromShapeAddress(const string &shapeAddress)
  {
    return substr(shapeAddress, 0, strpos(shapeAddress, "."));
  }

  private string getShapeRelativeAddressFromShapeAddress(const string &shapeAddress)
  {
    return substr(shapeAddress, strpos(shapeAddress, ":") + 1);
  }

  private string getPanelNameFromShapeAddress(const string &shapeAddress)
  {
    string panelName = substr(shapeAddress, strlen(getModuleNameFromShapeAddress(shapeAddress)) + 1);
    panelName = substr(panelName, 0, strpos(panelName, ":"));
    return panelName;
  }



  public shape getCurrentPanel() { return currentPanel; }
  public shape getCurrentShape() { return currentShape; }

  protected shape/*<"PANEL">*/ currentPanel;

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
};

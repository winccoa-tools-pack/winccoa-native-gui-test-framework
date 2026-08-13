
#uses "classes/splash/OaGuiTest" // load all necessary classes
#uses "classes/splash/shapes/GuiTestShape"


//ShapeTypes Lib

#uses "classes/splash/shapes/GuiTestArc"
#uses "classes/splash/shapes/GuiTestCascadeButton"
#uses "classes/splash/shapes/GuiTestCheckBox"
#uses "classes/splash/shapes/GuiTestClock"
#uses "classes/splash/shapes/GuiTestComboBox"
#uses "classes/splash/shapes/GuiTestDpTree"
#uses "classes/splash/shapes/GuiTestDpType"
#uses "classes/splash/shapes/GuiTestEllipse"
#uses "classes/splash/shapes/GuiTestEmbeddedModule"
#uses "classes/splash/shapes/GuiTestFrame"
#uses "classes/splash/shapes/GuiTestGeneric"
#uses "classes/splash/shapes/GuiTestLabel"
#uses "classes/splash/shapes/GuiTestLcd"
#uses "classes/splash/shapes/GuiTestLine"
#uses "classes/splash/shapes/GuiTestPipe"
#uses "classes/splash/shapes/GuiTestPolygon"
#uses "classes/splash/shapes/GuiTestPrimitiveText"
#uses "classes/splash/shapes/GuiTestProgressBar"
#uses "classes/splash/shapes/GuiTestPushButton"
#uses "classes/splash/shapes/GuiTestRadioBox"
#uses "classes/splash/shapes/GuiTestRectangle"
#uses "classes/splash/shapes/GuiTestSelectionList"
#uses "classes/splash/shapes/GuiTestSlider"
#uses "classes/splash/shapes/GuiTestSpinButton"
#uses "classes/splash/shapes/GuiTestTab"
#uses "classes/splash/shapes/GuiTestTable"
#uses "classes/splash/shapes/GuiTestTextEdit"
#uses "classes/splash/shapes/GuiTestTextField"
#uses "classes/splash/shapes/GuiTestThumbWheel"
#uses "classes/splash/shapes/GuiTestTree"
#uses "classes/splash/shapes/GuiTestTrend"
#uses "classes/splash/shapes/GuiTestZoomNavigator"


const int cStop = 0;
const int cRecord = 1;
const int cPlay = 2;
const int cPause = 3;


//------------------------------------------------------------------------------
public shared_ptr<GuiTestShape> getTestObject(const shape &testShape)
{
  string shapeType;
  getValue(testShape, "shapeType", shapeType);

  switch (shapeType)
  {

    case "ARC" : return new GuiTestArc(testShape);

    case "CASCADE_BUTTON" : return new GuiTestCascadeButton(testShape);

    case "CHECK_BOX" : return new GuiTestCheckBox(testShape);

    case "CLOCK" : return new GuiTestClock(testShape);

    case "COMBO_BOX" : return new GuiTestComboBox(testShape);

    case "DP_TREE" : return new GuiTestDpTree(testShape);

    case "DPTYPE" : return new GuiTestDpType(testShape);

    case "ELLIPSE" : return new GuiTestEllipse(testShape);

    case "EMBEDDED_MODULE" : return new GuiTestEmbeddedModule(testShape);

    case "FRAME" : return new GuiTestFrame(testShape);

    case "GENERIC" : return new GuiTestGeneric(testShape);

    case "LABEL" : case "Label": return new GuiTestLabel(testShape);

    case "LCD" : return new GuiTestLcd(testShape);

    case "LINE" : return new GuiTestLine(testShape);

    case "PIPE" : return new GuiTestPipe(testShape);

    case "POLYGON" : return new GuiTestPolygon(testShape);

    case "PRIMITIVE_TEXT" : return new GuiTestPrimitiveText(testShape);

    case "PROGRESS_BAR" : return new GuiTestProgressBar(testShape);

    case "PUSH_BUTTON" : return new GuiTestPushButton(testShape);

    case "RADIO_BOX" : return new GuiTestRadioBox(testShape);

    case "RECTANGLE" : return new GuiTestRectangle(testShape);

    case "SELECTION_LIST" : return new GuiTestSelectionList(testShape);

    case "SLIDER" : return new GuiTestSlider(testShape);

    case "SPIN_BUTTON" : return new GuiTestSpinButton(testShape);

    case "TAB" : return new GuiTestTab(testShape);

    case "TABLE" : return new GuiTestTable(testShape);

    case "TEXT_EDIT" : return new GuiTestTextEdit(testShape);

    case "TEXT_FIELD" : return new GuiTestTextField(testShape);

    case "THUMB_WHEEL" : return new GuiTestThumbWheel(testShape);

    case "TREE" : return new GuiTestTree(testShape);

    case "TREND" : return new GuiTestTrend(testShape);

    case "ZOOM_NAVIGATOR" : return new GuiTestZoomNavigator(testShape);

    default:
    {
      throw (makeError("", PRIO_SEVERE, ERR_CONTROL, 54, tr("The TestShape* class for '$1' is not implemented now").subst(shapeType)));
      break;
    }
  }
}

public mapping guiTestGetCurrentAttributes(const shape &realShape)
{
  shared_ptr<GuiTestShape> testShape = getTestObject(realShape);
  return testShape.getCurrentAttributes();
}

public string getNamePathOfShape(const shape &_shape)
{
  string res = _shape.namePath;

  // this is bug in the UI, you will catch wrong refNamePath like
  // ["Group114...Border2"]["vs"]["Border2"]
//    DebugTN(__FUNCTION__, res, "vs", _shape.name);
//   while(strreplace(res, "..", ".") > 0);

//   DebugTN(__FUNCTION__, "after", res);

  if (res.contains(".."))
  {
    this.currentShape = 0;
    throwError(makeError("", PRIO_SEVERE, ERR_CONTROL, 54, "Probably the reference / shape name is not defined.", _shape.namePath));
    return res;
  }

  if (res.isEmpty())
    return _shape.name;

  return res;
}

/// seems to be not used. We have similar function GuiTestShape.ctl
public void showAttention2(string module, shape shPanel, int x, int y)
{
  shape shEwo = addShape(shPanel, 8, "AttentionEffect_ewo", "recordInspection");
  int w, h;
  getValue(shEwo, "size", w, h);
  float f;
  getZoomFactor(f, module);
  shEwo.position((x / f) - (w / 2), (y / f) - (h / 2));
  shEwo.start();
  delay(0, 500);
  removeShape(shEwo);
}

public void showRecordReplayBorder(uint mode = cRecord)
{
  DebugTN("function correctly called", mode);
  string sModule = "SplashCover";

  if (mode == cRecord /* || mode == eSplash::play*/)
  {
    DebugTN("Calling module");
    ModuleOn(sModule, 0, 0, 5, 5, 1, 1);

    while (!isModuleOpen(sModule))
    {
      delay(0, 100);
    }

    stayOnTop(true, sModule);
    RootPanelOnModule("splash/cover", sModule, sModule, makeDynString("$MODEREC:" + (int)(mode == cRecord)));
  }
  else if (isModuleOpen(sModule))
  {
//    DebugTN(">>>>>>>>>>>>>>>>>>>>>>>>>>>> moduel off", mode);
    ModuleOff(sModule);
  }

  DebugTN("end of function reached");
}

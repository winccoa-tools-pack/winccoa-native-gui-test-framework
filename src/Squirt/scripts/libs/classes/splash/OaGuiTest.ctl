// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author atw12ru2
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/SquirtInputEventPlayer"
#uses "classes/SquirtVp"
#uses "classes/oaTest/OaTest"

#uses "classes/splash/OaGuiTestScreenCapture"

#uses "classes/splash/shapes/GuiTestShape"




//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
*/
class OaGuiTest : OaTest
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public OaGuiTest()
  {
  }

  //------------------------------------------------------------------------------
  public int setUp()
  {
    if (OaTest::setUp())
      return -1;

    waitForPanelInit();

    this.player.setMoveCursor(true);
//     this.player.setTimeFactor(0.1);

    return 0;
  }

  //------------------------------------------------------------------------------
  public int beforeTc(const string &testCaseId)
  {
    string tcRelDir;
    int idx = strpos(rootTestFileName, SCRIPTS_REL_PATH + "splash/");

    if (idx > 0)
    {
      tcRelDir = substr(rootTestFileName, idx + strlen(SCRIPTS_REL_PATH + "splash/"));
    }
    else
    {
      tcRelDir = testCaseId;
    }

    if (testCaseId != "play")
      tcRelDir += "/" + testCaseId;

    capture = OaGuiTestScreenCapture(tcRelDir);
    capture.clearCaptures();


    return OaTest::beforeTc(testCaseId);
  }

  //------------------------------------------------------------------------------
  public int tearDown()
  {
    int rc = OaTest::tearDown();

    if (myModuleName() == "_QuickTest_") // started in Gedi
    {
      PanelOff();
    }
    else
      exit();

    return rc; // probably defensive
  }


  protected setVpPrefix(const string &vpPrefix) { this.vpPrefix = vpPrefix; }

  protected int assertVP(const string &vpId, const vector<shape> &shapes, const string note = "", float timeout = 2.0)
  {
//     DebugN(classInfo(this));
    SquirtVp vp = SquirtVp(vpPrefix + vpId, shapes);

    if (vp.init())
    {
      this.abort(tr("The VP $1 can not be initialized!").subst(vpId));
    }

    mapping vpShapes = vp.getShapesAndAttributes();

    if (vpShapes.count() == 0)
    {
      this.abort(tr("The VP $1 does not contain any shapes!").subst(vpId));
    }

    if (vpShapes.count() != shapes.count())
    {
      this.abort(tr("The VP $1 does not contain the same number of shapes as the current panel!").subst(vpId));
    }

    for (uint i = 0; i < vpShapes.count(); i++)
    {
      const string shapeName = vpShapes.keyAt(i);

      if (assertAttributes(shapeName, vpShapes.value(shapeName), note, timeout))
        return -1;
    }

    return 0;
  }

  //------------------------------------------------------------------------------
  public int assertAttributes(const string &shapeName, const mapping &testAttributes, const string note = "", float timeout = 2.0)
  {
    this._fillTcData(note);
    this.tcData.setMethod(__FUNCTION__);

    if (shapeName.isEmpty())
    {
      string errorMsg = tr("The shape name is empty, $1").subst(getStackTrace());
      this.tcData.setErrMsg(errorMsg);
      return oaUnitAbort(getCurrentTestCaseId(), getTestCaseData());
    }

    if (shapeName.contains(".."))
    {
      string errorMsg = tr("Probably the reference / shape name is not defined, $1").subst(shapeName);
      this.tcData.setErrMsg(errorMsg);
      return oaUnitAbort(getCurrentTestCaseId(), getTestCaseData());
    }

    shape/*<"PANEL">*/ currentPanel = player.getCurrentPanel();

    const string fullShapeAddress = currentPanel.moduleName() + "." + currentPanel.name() + ":" + shapeName;

    shape realShape = getShape(fullShapeAddress);

    if (!shapeExists(realShape))
    {
      string errorMsg = tr("The shape does not exists, $1").subst(fullShapeAddress);
      this.tcData.setErrMsg(errorMsg);
      return oaUnitAbort(getCurrentTestCaseId(), getTestCaseData());
    }

    // verify attributes
    shared_ptr<GuiTestShape> testShape = getTestObject(realShape);
    dyn_string fails;


    int rc = -1;
    time timeOut = getCurrentTime() + timeout;

    while (timeOut > getCurrentTime())
    {
      fails.clear();
      rc = testShape.assertAttributes(testAttributes, fails);

      if (rc == 0)
        break;

      delay(0, 50);
    }

    // print result
    capture.currentPanel = player.getCurrentPanel();

    if (fails.count() == 0)
    {
      capture.takeScreen("latest-success");
      testShape.showAttention("OK");
      rc = this.pass(tr("The shape $1 looks good.").subst(testShape.toString()));
    }
    else
    {
      capture.takeScreen("latest-failed");
      capture.printLastLocation();
      testShape.showAttention("FAIL");

      this.tcData.setCurrentValue(testShape.getCurrentAttributes());
      this.tcData.setReferenceValue(testAttributes);

      string errorMsg = tr("We found some mismatches by chekcing the shape $1\n$2").subst(testShape.toString(), strjoin(fails, "\n"));

      this.tcData.setErrMsg(errorMsg);

      oaUnitFail(getCurrentTestCaseId(), getTestCaseData());

      if (isEvConnOpen() && isDbgFlag("CTRL_DEBUGBREAK"))
      {
        throwError(makeError("", PRIO_INFO, ERR_CONTROL, 0, tr("The test code will be paused, please start Ctrl-Debugger to debug the fail.")));
        DebugBreak(TRUE); // you can debug only panels with active event connection
      }

      throw (makeError("", PRIO_SEVERE, ERR_CONTROL, 54, tr("Test case aborted due previous fails")));
    }

    return rc;
  }

  public void setFileScript(string rootTestFileName)
  {
    if (rootTestFileName.startsWith("["))
    {
      // for some reson the constant __FILE__ contains []
      rootTestFileName = substr(rootTestFileName, 1, strlen(rootTestFileName) - 2);
    }

    this.rootTestFileName = rootTestFileName;
  }

  //------------------------------------------------------------------------------
  public int play() = 0;

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------
  protected SquirtInputEventPlayer player;
  protected OaGuiTestScreenCapture capture;
  protected string rootTestFileName;
  protected string vpPrefix;

  //------------------------------------------------------------------------------
  protected bool isTestFunction(const mapping &func)
  {
    return func.value("name", "").startsWith("play") && (func.value("access", "") == "public") && (func.value("returns", "") == "int");
  }

  //------------------------------------------------------------------------------
  protected waitForPanelInit()
  {
    delay(2);
  }

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------

};

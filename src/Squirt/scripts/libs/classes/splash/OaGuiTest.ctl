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
  @brief Base class for Splash GUI test cases.
  @details Provides common setup and shape attribute assertions for panel tests.
  @AIgeneratedHelpContent
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
  /**
    @brief Initializes the test runtime before each test suite.
    @return 0 on success, -1 on setup failure.
  */
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
  /**
    @brief Prepares per-test-case capture output and delegates to OaTest hook.
    @param testCaseId Logical test case identifier.
    @return Return code from OaTest::beforeTc().
  */
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
  /**
    @brief Finalizes the test runtime after each test suite.
    @return Return code from OaTest::tearDown().
  */
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


  /**
    @brief Sets a VP prefix used for reference lookup.
    @param vpPrefix Prefix prepended to VP identifiers.
  */
  protected void setVpPrefix(const string &vpPrefix) { this.vpPrefix = vpPrefix; }

  /**
    @brief Validates all panel shapes against a stored VP reference.
    @param vpId VP identifier relative to configured prefix.
    @param shapes Shapes expected on the current panel.
    @param note Optional assertion note for reporting.
    @param timeout Maximum wait time per shape verification.
    @return 0 if all shapes match, -1 on first mismatch.
  */
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
  /**
    @brief Verifies one panel shape against expected attributes.
    @param shapeName Relative name path of the shape.
    @param testAttributes Expected attribute/value map.
    @param note Optional assertion note for reporting.
    @param timeout Maximum wait time for delayed UI updates.
    @return 0 if attributes match, otherwise abort/fail handling is triggered.
  */
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

  /**
    @brief Stores the root script path used to resolve per-test assets.
    @param rootTestFileName Absolute script file name.
  */
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
  /**
    @brief Executes the concrete test logic.
    @return 0 on success.
  */
  public int play() = 0;

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------
  /** Player wrapper used to drive GUI input events. */
  protected SquirtInputEventPlayer player;
  /** Screen capture helper for evidence on pass/fail. */
  protected OaGuiTestScreenCapture capture;
  /** Path to the source script file for this test instance. */
  protected string rootTestFileName;
  /** Prefix used for VP identifiers. */
  protected string vpPrefix;

  //------------------------------------------------------------------------------
  /**
    @brief Checks whether a function descriptor matches a runnable test method.
    @param func Reflection metadata entry from class inspection.
    @return TRUE for public int functions starting with "play".
  */
  protected bool isTestFunction(const mapping &func)
  {
    return func.value("name", "").startsWith("play") && (func.value("access", "") == "public") && (func.value("returns", "") == "int");
  }

  //------------------------------------------------------------------------------
  /**
    @brief Waits for initial panel state to be ready before assertions run.
  */
  protected void waitForPanelInit()
  {
    delay(2);
  }

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------

};

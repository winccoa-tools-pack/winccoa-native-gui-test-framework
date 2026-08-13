/// @cond ETM_Internal
// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @brief Project view for the oaTest extension.
  @details Show and update the project view tree (in GEDI).

  @since Version 3.16 FP2
  @author mPokorny
  @copyright $copyright
*/

/**
TODO
"stolen" from WinCC OA, please provide changes only for GUI tests
*/

int dummyInt = DebugN(__FILE__, __FUNCTION__, __LINE__, "DO NOT PUBLISH THIS FILE");


//--------------------------------------------------------------------------------
// Libraries used (#uses)

#uses "classes/hsp/HspGediExt"
#uses "classes/oaTest/OaTestResultStatistic"
#uses "classes/ctrlCoverage/CtrlCoverage"

//--------------------------------------------------------------------------------
// Variables and Constants
//--------------------------------------------------------------------------------

/**
  @brief Project view for oaTest extension
  @details Show, update ... project view tree ( in gedi)

  @since Version 3.16 FP2
  @author mPokorny
*/
class OaTestProjectView
{
  //--------------------------------------------------------------------------------
  //@public members
  //--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /**
    @brief The default constructor.
  */
  public OaTestProjectView()
  {
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function creates a GEDI menu. GEDI menu is the sub structure for RMclick pop-ups.
  */
  public void makeGediMenu()
  {
    mapping menu;

    //PopUp for unit tests.
    menu = makeMapping("icon", "" , "inSubproject", TRUE, "category", "CAT_LIBS|CAT_SCRIPTS");
    pvAddSubMenu(getCatStr(HspGediExt::MSG_CAT, "unitTests"), "unitTests", menu);
    pvConnect("startTest",          getCatStr(HspGediExt::MSG_CAT, "startTest"),          makeMapping("parent", "unitTests", "filesOnly", TRUE, "category", "CAT_LIBS", "inSubproject", true));
    pvConnect("startTest",          getCatStr(HspGediExt::MSG_CAT, "startTest"),          makeMapping("parent", "unitTests", "filesOnly", TRUE, "category", "CAT_SCRIPTS", "inSubproject", true));
    pvConnect("navigateToTest",     getCatStr(HspGediExt::MSG_CAT, "navigateToTest"),     makeMapping("parent", "unitTests", "filesOnly", TRUE, "category", "CAT_LIBS", "inSubproject", true));
    pvConnect("startTestRecursive", getCatStr(HspGediExt::MSG_CAT, "startTestRecursive"), makeMapping("parent", "unitTests", "filesOnly", FALSE, "category", "CAT_LIBS|CAT_SCRIPTS", "inSubproject", true));

    //PopUp for GUI tests
    menu = makeMapping("icon", "" , "inSubproject", TRUE, "category", "CAT_PANELS");
    pvAddSubMenu(getCatStr("squirt/hsp", "guiTests"), "guiTests", menu);
    pvConnect("startGuiTest",          getCatStr("squirt/hsp", "startGuiTest"),          makeMapping("parent", "guiTests", "filesOnly", TRUE, "category", "CAT_PANELS", "inSubproject", true));
    pvConnect("navigateToGuiTest",     getCatStr("squirt/hsp", "navigateToGuiTest"),     makeMapping("parent", "guiTests", "filesOnly", TRUE, "category", "CAT_PANELS", "inSubproject", true));
    pvConnect("startGuiTestRecursive", getCatStr("squirt/hsp", "startGuiTestRecursive"), makeMapping("parent", "guiTests", "filesOnly", FALSE, "category", "CAT_PANELS", "inSubproject", true));

    moduleAddDockModule("splash",
                        "splash/splash.pnl",
                        makeDynString(),
                        makeMapping("area", "RightDockWidgetArea"));

    pvAddSeparator();
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function creates test columns in GEDI file-tree (passed/failed/coverage ...)
  */
  public void makeTestColumns()
  {
    mapping opts;
    opts = makeMapping("icon", "wf/buttons/apply_all.png", "resizeMode", "Interactive");
    colIdxLineCoverage = pvAddColumn(getCatStr(HspGediExt::MSG_CAT, "lineCov"), opts);
    opts = makeMapping("icon", "wf/buttons/list.png", "resizeMode", "Interactive");
    colIdxFuncCoverage = pvAddColumn(getCatStr(HspGediExt::MSG_CAT, "funcCov"), opts);


    opts = makeMapping("icon", "", "resizeMode", "Interactive", "width", 120);
    colIdxResultState = pvAddColumn(getCatStr(HspGediExt::MSG_CAT, "state"), opts);
    opts = makeMapping("icon", "oaTest/pvPass.png", "resizeMode", "Interactive", "width", 41);
    pvAddColumn(getCatStr(HspGediExt::MSG_CAT, "pvPass"), opts);
    opts = makeMapping("icon", "oaTest/pvFail.png", "resizeMode", "Interactive", "width", 41);
    pvAddColumn(getCatStr(HspGediExt::MSG_CAT, "pvFail"), opts);
    opts = makeMapping("icon", "oaTest/pvAbort.png", "resizeMode", "Interactive", "width", 41);
    pvAddColumn(getCatStr(HspGediExt::MSG_CAT, "pvAbort"), opts);
    opts = makeMapping("icon", "oaTest/pvKnownBug.png", "resizeMode", "Interactive", "width", 41);
    pvAddColumn(getCatStr(HspGediExt::MSG_CAT, "pvKnownBug"), opts);
  }

  //------------------------------------------------------------------------------
  /**
    @brief Shows a SystemUnderTest warning.
    @param scriptPath Path to the script.
  */
  public static showSUT(string scriptPath)
  {
    dpSet("_CtrlCommandInterface_oaTestPv.Command",
          jsonEncode(makeMapping("cmd", "showSUT",
                                 "path", scriptPath)));
  }

  //------------------------------------------------------------------------------
  /**
    @brief  Hides the SystemUnderTest warning.
    @param scriptPath Path to the script
  */
  public static hideSUT(string scriptPath)
  {
    dpSet("_CtrlCommandInterface_oaTestPv.Command",
          jsonEncode(makeMapping("cmd", "hideSUT",
                                 "path", scriptPath)));
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function updates the test result statistic in GEDI file tree.
    @param path Path to the file for which the GEDI tree is updated.
    @param json Statistic in json format.
    @param covFilePath Path to file with coverage meta data.
  */
  public static updateStatisic(string path, string json, string covFilePath)
  {
    dpSet("_CtrlCommandInterface_oaTestPv.Command",
          jsonEncode(makeMapping("cmd", "updateStatisic",
                                 "path", path,
                                 "covFilePath", covFilePath,
                                 "stat", jsonDecode(json))));
  }

  //------------------------------------------------------------------------------
  /**
    @brief Callback function.
    @param dpe Data point for the callback.
    @param json Decoded variable.
  */
  public synchronized reloadCb(const string dpe, const string json)
  {
    mapping map = jsonDecode(json);
    const string cmd = map["cmd"];
    string path = makeNativePath(map["path"]);

    switch(cmd)
    {
      case "showSUT":
      {
        if ( dynContains(sutThreads, path) <= 0 )
        {
          dynAppend(sutThreads, path);
          startThread("showSUT_cb", path);
        }
        break;
      }
      case "hideSUT":
      {
        int idx = dynContains(sutThreads, path);
        if ( idx > 0 )
          dynRemove(sutThreads, idx);
        break;
      }
      case "updateStatisic":
      {
        OaTestResultStatistic stat;
        stat.fromMapping(map["stat"]);
        pvSetItemText(path, colIdxResultState + 1, stat.getPassed());

        // get Failed, Skipped and Instable tests
        pvSetItemText(path, colIdxResultState + 2, stat.getAll() - stat.getPassed() - stat.getAborted() - stat.getKnownBugs());
        pvSetItemText(path, colIdxResultState + 3, stat.getAborted());
        pvSetItemText(path, colIdxResultState + 4, stat.getKnownBugs());

        string covRepPaht = PROJ_PATH + LOG_REL_PATH + map["covFilePath"];
        CtrlCoverage cov;
        cov.calculateCoverage(path, covRepPaht);
        pvSetItemText(path, colIdxLineCoverage, getPrc(cov.lineCoverage.coverable, cov.lineCoverage.covered));
        pvSetItemText(path, colIdxFuncCoverage, getPrc(cov.funcCoverage.coverable, cov.funcCoverage.covered));

        break;
      }
    }
  }

  //------------------------------------------------------------------------------
  public static void updateScriptState(string scriptPath, bool state)
  {
    if ( state )
    {
      string points;
      for (int i = 1; i <= 10; i++)
      {
        points += ".";
        pvSetItemText(scriptPath, colIdxResultState, STATE_TEXT + " " + points);
        delay(0, 100);
      }
    }
    else
    {
      time t = getCurrentTime();
      string state = formatTime("%Y.%m.%d %H:%M:%S", t);
      pvSetItemText(scriptPath, colIdxResultState, state);
    }
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------
  protected static int colIdxLineCoverage;
  protected static int colIdxFuncCoverage;
  protected static int colIdxResultState;
  protected static dyn_string sutThreads;

  //------------------------------------------------------------------------------
  protected showSUT_cb(string scriptPath)
  {
    while( dynContains(sutThreads, scriptPath) > 0 )
    {
      string points;
      for( int i = 1; i <= 10; i++ )
      {
        points += ".";
        pvSetItemText(scriptPath, colIdxResultState, STATE_TEXT + " " + points);
        delay(0, 100);
      }
    }
    time t = getCurrentTime();
    string state = formatTime("%Y.%m.%d %H:%M:%S", t);
    pvSetItemText(scriptPath, colIdxResultState, state);
  }

  //--------------------------------------------------------------------------------
  //@private members
  //--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  private static string getPrc(float f1, float f2)
  {
    if( f2 == 0 )
      return "0%";

    float f = f1 / f2;

    f = ( float )100 / f;

    string str;

    sprintf(str, "%d", f);
    return str + "%";
  }

  private static const string STATE_TEXT = getCatStr(HspGediExt::MSG_CAT, "running");
};
/// @endcond

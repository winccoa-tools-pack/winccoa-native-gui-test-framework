// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author atw121x7
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "ascii"


//--------------------------------------------------------------------------------
// Variables and Constants
/**
  @brief Splash runtime mode used for record/playback coordination.
*/
enum eSplash
{
  stop,
  record,
  play,
  pause
};


//--------------------------------------------------------------------------------
/**
  @brief Controls recording and playback orchestration for Splash test scripts.
  @AIgeneratedHelpContent
*/
class Splash
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------
  /** Root directory where generated Splash scripts are stored. */
  public static string sTestScriptPath; // = getPath(SCRIPTS_REL_PATH, "tests/splash"); will be set in constuctor to have option of creating folder

  /**
    @brief Initializes Splash datapoints when missing.
    @return 0 on success.
  */
  public static int initInterface()
  {
    if (!dpExists("_Splash"))
      asciiImport("Splash.dpl");
  }

  //------------------------------------------------------------------------------
  /** The Default Constructor.
    @param bPlayback Enables playback command handling.
    @param bRecord Enables recording command handling.
  */
  public Splash(bool bPlayback = FALSE, bool bRecord = FALSE)
  {
    getScriptPath();

    if (bPlayback || bRecord) // not used on panel command buttons to controll recording or playback
    {
      dpConnectUserData(this, this.reactOnCommands, bPlayback ? eSplash::play : eSplash::record, true, "_Splash.command", "_Splash.response");
    }
  }

  /**
    @brief Returns and creates the Splash script directory if needed.
    @return Absolute script directory path.
  */
  public synchronized string getScriptPath()
  {
    if (sTestScriptPath == "")
    {
      if (getPath(SCRIPTS_REL_PATH, "tests/splash", -1, 1) == "") //folder does not exist in our project
      {
        //create
        if (getPath(SCRIPTS_REL_PATH, "tests", -1, 1) == "")
          mkdir(getPath(SCRIPTS_REL_PATH) + "tests");

        mkdir(getPath(SCRIPTS_REL_PATH) + "tests/splash");
      }

      sTestScriptPath = getPath(SCRIPTS_REL_PATH, "tests/splash");
    }

    return sTestScriptPath;
  }

  /**
    @brief Handles incoming Splash commands for play and record workflows.
    @param splashMode Current command mode.
    @param sDP Triggering datapoint.
    @param sCommand Received command payload.
    @param sDP2 Response datapoint.
    @param sResponse Response payload.
  */
  reactOnCommands(eSplash splashMode, string sDP, string sCommand, string sDP2, string sResponse)
  {
    DebugTN("wait for command", splashMode);

    if (splashMode == eSplash::play)
    {
      if (isAnswer())
      {
        delay(1); //wait after manag

        setCommandOnDP(sCmdReadyPlay);
      }
    }
    else //recording
    {
      DebugTN("wait for command ''''''' ", isAnswer());

      if (isAnswer())
      {
        delay(0, 300);
        setCommandOnDP(sCmdReadyRec);
      }
      else
      {
        DebugTN("recorrding command", sCommand);

        if (patternMatch(sCmdRec + "*", sCommand) && !inputRecorderIsRecording())  //record now
        {
          splashState = eSplash::record;
          inputRecorderStart();
          DebugTN("start recording");
        }
        else if (patternMatch(sCmdPause + "*", sCommand))  //pause record
        {
          splashState = eSplash::pause;
          inputRecorderPause();
        }
        else if (patternMatch(sCmdResume + "*", sCommand))  //continue recording now
        {
          splashState = eSplash::record;
          inputRecorderResume();
        }
        else if (patternMatch(sCmdStop + "*", sCommand))  //stop recording now
        {
          dyn_string dsSplit = strsplit(sCommand, " ");
          DebugN("split::", dsSplit);
          string sFilename = substr(sCommand, strlen(sCmdStop) + 1);

          if (dynlen(dsSplit) < 2)
          {
            sFilename = this.sPanel;
            strreplace(sFilename, ".pnl", "");
            sFilename += "/" + this.sTestCase;
          }
          else
          {
            sFilename = dsSplit[2] + "/" + dsSplit[3];
          }

          string sParams;

          //
          dyn_string items;

          for (int i = 4; i <= dynlen(dsSplit); i++)
          {
            if (i > 4)
              sParams += " ";

            sParams += dsSplit[i];
          }

          if (!patternMatch("*.ctl", sFilename))
            sFilename += ".ctl";

          dyn_string dsFolders = strsplit(sFilename, "/");
          string sDir = getScriptPath();

          for (int i = 1; i < dynlen(dsFolders); i++)
          {
            sDir += "/";
            sDir += dsFolders[i];

            if (!isdir(sDir)) //create
            {
              mkdir(sDir);
            }
          }



          splashState = eSplash::stop;
          DebugTN("finished recording", sFilename);

          inputRecorderStop();

          string script = inputRecorderGetScript();
          strreplace(script, "InputEventPlayer player;", "");
          strreplace(script, "#uses \"classes/InputEventPlayer\"", "");

          script.trim();

          // make methhod play() public
          script = "public int " + script;
          script.remove(script.length() - 1, 1); // remove last }
          // and add return 0; }
          script += "return 0;\n}";

          // to make the code a little bit better readeable:
          // + add new line and comment on shape change
//           strreplace(script, " player.makeCurrent(", "Splash::showRecordReplayBorder();\n    // switch shape\n player.makeCurrent(");
          strreplace(script, " player.makeCurrent(", "\n    // switch shape\n player.makeCurrent(");
          // + add comment before each verifiaction point
          strreplace(script, " assertAttributes(", "\n    // verify attributes\n assertAttributes(");

          // TODO, see also HspScript::makeScriptFromTemlate() how to handle with script templates
          // and replace keywords like author ...
          string sContent;
          fileToString(getPath(DATA_REL_PATH, "hsp/templates/scriptEditor/newSplash.ctl"), sContent);
          strreplace(sContent, sParameterPlaceholder, sParameterPlaceholder + sParams);
          strreplace(sContent, "public play(){}", script);

          strreplace(sFilename, ".pnl", ".ctl");

          // TODO clarify, Why not to use File class ?
          const string newGuiTestScriptPath = getScriptPath() + "/" + sFilename;
          file fScript = fopen(newGuiTestScriptPath, "w");
          fputs(sContent, fScript);
          fclose(fScript);
          DebugTN("finished recording saved script", sFilename);

          // format code by astyle
          dyn_string args;
          args[1] = getPath(BIN_REL_PATH, _WIN32 ? "astyle.exe" : "astyle");
          args[2] = "--options=" + makeNativePath(getPath(CONFIG_REL_PATH, "astyle.config"));
          args[3] = newGuiTestScriptPath;
          system(args);

          // remove the astyle backup file
          if (isfile(newGuiTestScriptPath + ".orig"))
            remove(newGuiTestScriptPath + ".orig");

          setCommandOnDP(sCmdFinished);
          delay(0, 200);
          exit(0); // TODO clarify, it might looks like a crash, exit() will be better
        }
      }
    }
  }

  /**
    @brief Starts recording mode and launches UI process.
    @param sTestCase Test case identifier.
    @param sPanelFile Panel to record.
    @param sParams Additional startup parameters.
  */
  public record(string sTestCase, string sPanelFile, string sParams = "")
  {
    splashState = eSplash::play;

    this.sTestCase = sTestCase;
    this.sPanel = sPanelFile;


    string sScriptFile = getPath(SCRIPTS_REL_PATH, "splash/splashRecord.ctl");
    string sUi = getComponentName(UI_COMPONENT);
    sUi += _WIN32 ? ".exe" : "";
    string sCmd = getPath(BIN_REL_PATH, sUi);

    DebugTN("run system cmd for recording", sCmd);

    dyn_string dsParams = makeDynString("-s", sScriptFile, "-p", sPanelFile, "-PROJ", PROJ);
    dynAppend(dsParams, strsplit(sParams, " "));

    mapping options = makeMapping("program", sCmd,  "arguments", dsParams, "timeout", -1);

    system(options);

    DebugTN("run system cmd for recording - finished", sCmd, dsParams);

    //toDo wait for started UI
    dyn_anytype daRet;
    bool bExp;

    dpWaitForValue(makeDynString("_Splash.command:_original.._value"), makeDynAnytype(sCmdReadyRec), makeDynString(), daRet, 60, bExp);

    if (!bExp)
    {
      setCommandOnDP(sCmdRec + " " + sPanelFile + " " + sTestCase + " " + sParams);
      DebugTN("recording triggered");
    }
  }

  /**
    @brief Stops recording and optionally writes script to panel/testcase path.
    @param sTestCase Test case identifier.
    @param sPanel Panel file name.
    @param sParams Additional command parameters.
  */
  public stop(string sTestCase, string sPanel, string sParams)
  {
    string sCommand = sCmdStop;

    if (sPanel != "")
    {
      strreplace(sPanel, ".pnl", "");
      sCommand += " " + sPanel + " " + sTestCase + " " + sParams;

    }
    else if (sTestCase != "") //squirt_test_panel_1_tc#1111.ctl
    {
      sCommand += " " + sTestCase;
    }

    setCommandOnDP(sCommand);

//     splashState = eSplash::stop;
  }
//squirt_test_panel_1_tc#1111.ctl", "squirt_test_panel_1.pnl", "");

  //start UI and playTestCase
  /**
    @brief Starts playback by launching the UI manager.
    @param sTestCase Test case script.
    @param sPanelFile Panel file to open.
    @param startParams Optional playback parameters.
  */
  public play(string sTestCase, string sPanelFile, string startParams = "")
  {
    startManager(sTestCase, sPanelFile, startParams);
    // playTestCase(sTestCase, sPanelFile);
  }

//   //wait for UI to be ready to perform the test and start test
//   public playTestCase(string sTestCase, string sPanelFile)
//   {
//     //toDo wait for started UI
//     dyn_anytype daRet;
//     bool bExp;
// // DebugTN("########### wait to be ready for playback");
//     dpWaitForValue(makeDynString("_Splash.command:_original.._value"), makeDynAnytype(sCmdReadyPlay), makeDynString(), daRet, 60, bExp);

// // DebugTN("########### ffffff playback");
//     if (!bExp)
//     {
//       dpSet("_Splash.command", sCmdPlay + " " + sPanelFile + " " + sTestCase,
//             "_Splash.response", "");
//       DebugTN("replay triggered");
//     }
//   }

  //start playback ui, test script will give inform us wit sCmdReadyPlay and will wait for our command sCmdPlay
  /**
    @brief Starts UI process for playback execution.
    @param sTestCase Test case script.
    @param sPanelFile Panel file to open.
    @param startParams Optional startup parameters.
  */
  public startManager(string sTestCase, string sPanelFile, string startParams = "")
  {
    splashState = eSplash::play;

    string sScriptFile = getScriptPath();

    if (!patternMatch("*/", getScriptPath()) && !patternMatch("/*", sPanelFile))
      sScriptFile += "/";

    sScriptFile += sPanelFile;

    strreplace(sScriptFile, ".pnl", "");
    sScriptFile += "/" + sTestCase;

    if (!patternMatch("*.ctl", sTestCase))
      sScriptFile  + ".ctl";

    //start parameters from first row of lib
    if (startParams == "")
      startParams = getParamsFromScript(sScriptFile);

    dyn_string dsParams = makeDynString("-s", sScriptFile, "-p", sPanelFile, "-PROJ", PROJ);
    dynAppend(dsParams, strsplit(startParams, " "));

    //start UI process
    string sUi = getComponentName(UI_COMPONENT);
    sUi += _WIN32 ? ".exe" : "";
    string sCmd = getPath(BIN_REL_PATH, sUi);
    mapping options = makeMapping("program", sCmd,  "arguments", dsParams/*,  "timeout", -1*/);
    DebugTN("run system cmd for test", options);
    system(options);
//     DebugTN("run system cmd for test - finished", options);
  }

  private static setCommandOnDP(string sCommand)
  {
    // wait, because for possible exit command
    dpSetWait("_Splash.command", sCommand,
              "_Splash.response", "");
  }
  private static string getCommandFromDP()
  {
    string sCommand;
    dpGet("_Splash.command", sCommand);

    return sCommand;
  }
  public static onClose()
  {
    string sCommand = getCommandFromDP();

    if (patternMatch(sCmdRec + "*", sCommand)) //still recording
    {
      strreplace(sCommand, sCmdRec, sCmdStop);
      DebugTN("save script on close");
      setCommandOnDP(sCommand);
    }
  }

  /**
    @brief Converts textual Splash command to enum state.
    @param sCommand Command payload string.
    @return Matching splash state.
  */
  public static eSplash getStateFromString(const string &sCommand)
  {
    eSplash splashState = eSplash::stop;;

//     if (patternMatch(spSplash.sCmdFinished + "*", sCommand))
//       splashState = eSplash::stop;
    if (patternMatch(spSplash.sCmdPlay + "*", sCommand))
      splashState = eSplash::play;
    else if (patternMatch(spSplash.sCmdPause + "*", sCommand))
      splashState = eSplash::pause;
    else if (patternMatch(spSplash.sCmdResume + "*", sCommand))
      splashState = eSplash::record;
    else if (patternMatch(spSplash.sCmdRec + "*", sCommand))
      splashState = eSplash::record;
//     else if (patternMatch(spSplash.sCmdStop + "*", sCommand))
//       splashState = eSplash::stop;
    else if (patternMatch(spSplash.sCmdReadyPlay + "*", sCommand))
      splashState = eSplash::play;
    else if (patternMatch(spSplash.sCmdReadyRec + "*", sCommand))
      splashState = eSplash::record;


    return splashState;
  }


  /**
    @brief Reads optional parameter line from a test script header.
    @param sScriptFile Script file path.
    @return Extracted parameter string or empty string.
  */
  public string getParamsFromScript(string sScriptFile)
  {
    string sParams;

    if (patternMatch("*.ctl", sScriptFile))
    {
      if (access(sScriptFile, R_OK) != 0) //file not found
        sScriptFile = getScriptPath() + sScriptFile;

      file f = fopen(sScriptFile, "r");
      DebugTN("file open for reading", f, sScriptFile, getLastError());

      fgets(sParams, 500, f);
      fclose(f);

      strreplace(sParams, "\n", "");


      if (patternMatch(sParameterPlaceholder + "*", sParams))
      {
        sParams = substr(sParams, strlen(sParameterPlaceholder));
      }
      else
      {
        sParams = "";
      }
    }

    return sParams;
  }
  //this is the test script (will be generated on recording and overwritting in derived class)
  // public void replayScript() {}

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------

  private string sPanel;
  private string sTestCase;
  private dyn_string dsParms;
  private eSplash splashState;
  private int iUiNr;

  private static int iPlaybackNr;

  public static const string sCmdPlay = "play";
  public static const string sCmdRec = "record";
  public static const string sCmdPause = "pause";
  public static const string sCmdResume = "resume";
  public static const string sCmdStop = "stop";
  public static const string sCmdFinished = "finished";
  public static const string sCmdReadyPlay = "ready for play";
  public static const string sCmdReadyRec = "ready for recording";

  private static const string sParameterPlaceholder = "//params:";
};

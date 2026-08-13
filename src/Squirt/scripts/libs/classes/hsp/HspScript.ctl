// $License: NOLICENSE

/**
  @file $relPath
  @brief A HSP script.
  @details HSP actions for a script.
  /// @cond ETM_Internal
  @author mPokorny
  /// @endcond
  @copyright $copyright
*/
/**
TODO
"stolen" from HspScript.ctl, please provide changes only for GUI tests
*/

int dummyIntHsp = DebugN(__FILE__, __FUNCTION__, __LINE__, "DO NOT PUBLISH THIS FILE");

#uses "std"
#uses "classes/oaTest/OaTestProjectView"
#uses "classes/hsp/HspSettings"
#uses "CTRLdebugger"
#uses "classes/systemEnvironment/SysEnvCpuMon"

/**
  @brief HspScript is a class for the CTRL script actions.
*/
class HspScript
{
  //--------------------------------------------------------------------------------
  //@public members
  //--------------------------------------------------------------------------------
  public bool guiTest;

  /**
    @brief A default constructor.
  */
  public HspScript()
  {
  }

  //------------------------------------------------------------------------------
  /**
    @brief The Function sets the content of a CTRL script.
    @details The function does not save the script. It only sets the content in this object.
    The script must not be parsable.
    @param script Script content.
  */
  public void setScript(const string &script)
  {
    this.script = strltrim(script);;
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function returns the content of a CTRL script.
    @warning The script must not be parsable.
    @return string script Content of a script.
  */
  public string getScript()
  {
    return script;
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function checks if a CTRL script is empty.
    @return bool script Returns TRUE when a CTRL script is empty and otherwise FALSE.
  */
  public bool isEmpty()
  {
    return script == "";
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function returns the file name of a CTRL script.
D    @return string file A CTRL script file name with an extension.
  */
  public string getFileName()
  {
    return baseName(scriptFilePath);
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function returns the relative path to a CTRL script.
    @details The absolute path is cut and the relative
    path is returned.
    @return string path The full path to a script.
  */
  public string getFilePath()
  {
    return makeUnixPath(scriptFilePath);
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function returns the relative path to a CTRL script in a native format.
    @details The path is relative to the project.
    @return string path A relative path to a CTRL script.
  */
  public string getFileRelPath()
  {
    return relPath;
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function sets a path to this CTRL script.
    @param path The full path to this CTRL script.
    @return int val The function returns 0 if it was successfully
    executed and otherwise an errorCode:
    Error code:
    Value | Description
    ------|------------
    0     | Success
    -1    | An invalid path
  */
  public int setFilePath(const string &path)
  {
    if ( (path == ""))
      return -1;

    scriptFilePath = path;
    relPath = ctrlDbgPu_getRelPath(scriptFilePath);

    if (isPartOf(SCRIPTS_REL_PATH))
    {
      if (!path.endsWith(".ctl"))
      {
        scriptFilePath.clear();
        relPath.clear();
        return -1;
      }
    }
    else if (isPartOf(PANELS_REL_PATH))
    {
      if (path.endsWith(".bak"))
      {
        scriptFilePath.clear();
        relPath.clear();
        return -1;
      }
    }

    return 0;
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function creates a new CTRL script from the given template.
    @param templateRelPath A relative (or full) path to the template.
    @return int Error code. The function returns 0 when it
    was successfully executed and otherwise -1.
  */
  public int makeScriptFromTemlate(const string &templateRelPath)
  {
    script = "";

    string templFile = getPath("", templateRelPath);

    if ( (templFile == "") && isfile(templateRelPath) )
    {
      templFile = templateRelPath;
    }

    if( ( templFile != "" ) && isfile(templFile) )
    {
      fileToString(templFile, script);

      replaceKey("newClassTemplate", fileNameToClassName());
      replaceKey("newTestTemplate", "Tst" + fileNameToClassName());

      replaceKey("$libRelPathWithoutExtension", makeUnixPath(delExt(getFileRelPath())));
      replaceKey("$libRelPath", makeUnixPath(getFileRelPath()));
      replaceKey("$libName", delExt(getFileName()));

      string subStr = "";

      if ( isPartOf(SCRIPTS_REL_PATH + "examples/libs/") )
        subStr = SCRIPTS_REL_PATH + "examples/libs/";
      else if ( isPartOf(SCRIPTS_REL_PATH + "tests/libs/") )
        subStr = SCRIPTS_REL_PATH + "tests/libs/";

      if ( subStr != "" )
      {
        replaceKey("$origLibRelPathWithoutExtension", substr(makeUnixPath(delExt(getFileRelPath())), strlen(subStr)));
        replaceKey("$origLibRelPath", substr(makeUnixPath(getFileRelPath()), strlen(subStr)));
        replaceKey("$origLibName", delExt(getFileName()));
      }

      replaceKey("$author", HspSettings::getAuthorName());
      replaceKey("$date", HspSettings::getDateString());
      replaceKey("$time", HspSettings::getTimeString());
      replaceKey("$version", HspSettings::getVersionString());
      return 0;
    }

    return -1;
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function creates a mini header for a CTRL script.
    @details The header is used if a template is not found.
    See also makeScriptFromTemplate()
  */
  public void makeFileHeader()
  {
    string header;

    header += "// used libraries (#uses)\n";
    header += "\n";
    header += "// declare variables and constans\n";

    this.script = header + this.script;
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function replaces given keys by value in a CTRL script.
    @details The function only changes the content of a cTRL script. The function does not
    save the script.
    @param key Key for the search.
    @param value Value to be replaced.
    @return int Count Count of replaced keys.
  */
  public int replaceKey(const string &key, const string &value)
  {
    return strreplace(script, key, value);
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function checks the CTRL script part of the given relative path.
    @param scriptType Script type. The relative path such as:
      + SCRIPTS_REL_PATH
      + LIBS_REL_PATH
    @return bool path The function returns TRUE when the path matches the relative path and otherwise FALSE.
  */
  public bool isPartOf(const string &scriptType)
  {
    string location = makeNativePath(this.getFilePath());
    return strpos(location, makeNativePath(scriptType) ) > 0;
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function removes all trailing spaces from the lines in a CTRL script.
    @return int lines The function returns the count of changed lines.
  */
  public int trimTrailingSpace()
  {
    dyn_string lines = strsplit(script, "\n");
    int scriptLen = dynlen(lines);
    int count;

    for (int i = 1; i <= scriptLen; i++)
    {
      string line = lines[i];
      string purifedLine = strrtrim(line, " ");
      if ( purifedLine == line )
        continue;

      lines[i] = purifedLine;
      count++;
    }

    script = strjoin(lines, "\n");
    return count;
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function removes all leading spaces from the lines in a CTRL script.
    @return int count The count of changed lines.
  */
  public int trimLeadingSpace()
  {
    dyn_string lines = strsplit(script, "\n");
    int scriptLen = dynlen(lines);
    int count;

    for (int i = 1; i <= scriptLen; i++)
    {
      string line = lines[i];
      string purifedLine = strltrim(line, " ");
      if ( purifedLine == line )
        continue;

      lines[i] = purifedLine;
      count++;
    }

    script = strjoin(lines, "\n");
    return count;
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function returns a line delimiter
    with a fixed length.
    @param spaces <B>Spaces</B> on the left of the delimiter.
    @return string delimeter The line delimiter.
  */
  public static string getDelim(int spaces = 0)
  {
    string delim = "//--------------------------------------------------------------------------------";

    if ( spaces <= 0 )
      return delim;

    return substr(delim, 0, strlen(delim) - spaces);
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function returns the relative path to the example of the specified CTRL script.
    @details The path is returned in unix format.
    @note The function does not check if the given CTRL script or example script exists.
    @return string path The relative path to the example script.
  */
  public string getExampleRelPath()
  {
    return makeUnixPath("examples/" + stripFromProjPath(getFilePath(), SCRIPTS_REL_PATH));
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function returns the full path to the example
    of the specified CTRL script.
    @return string path The full path to the example.
    @exception Empty string- if an example does not exist.
  */
  public string getExampleFullPath()
  {
    if ( isfile(getPath(SCRIPTS_REL_PATH, getExampleRelPath())) )
      return getPath(SCRIPTS_REL_PATH, getExampleRelPath());
    else
      return "";
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function checks if an example for a CTRL script exists.
    @return bool example The function returns TRUE
    if an example exists and otherwise FALSE.
  */
  public bool exampleExist()
  {
    return (getExampleFullPath() != "");
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function creates an example for a library.
    @return int errorCode The function returns 0 if it
    was successfully executed and otherwise an error code.
    Error code.
    Value | Description
    ------|------------
    0     | Success
    -1    | An example cannot be created since it already exists.
    -2    | An example cannot be created since this script is not a library.
    -3    | An example cannot be created since the user does not have the neccessary permission.
  */
  public int createExample()
  {
    if ( exampleExist() )
    {
      showErrMsg(makeError("", PRIO_WARNING, ERR_CONTROL, 0, "Exmaple exist : " + getExampleFullPath()) );
      return -1;
    }

    const string relPath = getExampleRelPath();
    if ( strpos(relPath, "examples/libs/") != 0 )
    {
      showErrMsg(makeError("", PRIO_WARNING, ERR_CONTROL, 0, "The examples can be created only for scripts located in " + LIBS_REL_PATH + " directory.") );
      return -2;
    }

    const string fullPath = PROJ_PATH + SCRIPTS_REL_PATH + relPath;
    string dir = dirName(fullPath);
    mkdir(dir);

    fclose(fopen(fullPath, "wb+") );

    if ( !isfile(fullPath) )
    {
      showErrMsg(makeError("", PRIO_WARNING, ERR_CONTROL, 0, "Could not create example, check the permissions in : " + fullPath) );
      return -3;
    }
    else
    {
      showErrMsg(makeError("", PRIO_INFO, ERR_CONTROL, 0, "Succesfully created example: " + fullPath) );
    }

    return 0;
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function returns the relative path to the unit test of the specified CTRL script.
    @details The Path is returned in unix format.
    @note The function does not check if the given CTRL script or test script exists.
    @return string path The relative path to the test script.
  */
  public string getUnitTestRelPath()
  {
    return makeUnixPath("tests/" + stripFromProjPath(getFilePath(), SCRIPTS_REL_PATH));
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function returns the full path to the example of the specified script.
    @return string path The full path to the example.
    @exception Empty string - if an example does not exist.
  */
  public string getUnitTestFullPath()
  {
    if ( isfile(getPath(SCRIPTS_REL_PATH, getUnitTestRelPath())) )
      return getPath(SCRIPTS_REL_PATH, getUnitTestRelPath());
    else
      return "";
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function checks if a uni test exists.
    @return bool test Returns TRUE when the test exists and otherwise FALSE.
  */
  public bool unitTestExist()
  {
    return (getUnitTestFullPath() != "");
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function creates a unit test for the library.
    @return int errorCode  The function returns 0 if it
    was successfully executed and otherwise an error code.
    Error code.
    Value | Description
    ------|------------
    0     | Success
    -1    | A unit test cannot be created since it already exists.
    -2    | A unit test cannot be created since the script is not a library.
    -3    | A unit test cannot be created since the user does not have the neccessary permission.
  */
  public int createUnitTest()
  {
    if ( unitTestExist() )
    {
      showErrMsg(makeError("", PRIO_WARNING, ERR_CONTROL, 0, "Unit-test exist : " + getUnitTestFullPath()) );
      return -1;
    }

    const string relPath = getUnitTestRelPath();
    if ( !relPath.startsWith("tests/libs/") )
    {
      showErrMsg(makeError("", PRIO_WARNING, ERR_CONTROL, 0, "The unit-test can be created only for scripts located in " + LIBS_REL_PATH + " directory.") );
      return -2;
    }

    const string fullPath = PROJ_PATH + SCRIPTS_REL_PATH + relPath;
    string dir = dirName(fullPath);
    mkdir(dir);

    fclose(fopen(fullPath, "wb+") );

    if ( !isfile(fullPath) )
    {
      showErrMsg(makeError("", PRIO_WARNING, ERR_CONTROL, 0, "Could not create unit-test, check the permissions in : " + fullPath) );
      return -3;
    }
    else
    {
      showErrMsg(makeError("", PRIO_INFO, ERR_CONTROL, 0, "Succesfully created unit-test: " + fullPath) );
    }

    return 0;
  }



  //------------------------------------------------------------------------------
  /**
    TBD
  */
  public string getGuiTestRelPath()
  {
    string path = makeUnixPath("tests/splash/" + stripFromProjPath(getFilePath(), PANELS_REL_PATH));

    if (path.endsWith(".pnl") || path.endsWith(".xml"))
      path = substr(path, 0, strlen(path) - 4);

    return path + "/";
  }

  //------------------------------------------------------------------------------
  /**
    TBD
  */
  public dyn_string getGuiTestFullPaths()
  {
    DebugTN(__FUNCTION__, getGuiTestRelPath());
    string dir = getPath(SCRIPTS_REL_PATH, getGuiTestRelPath());

    if (dir.isEmpty())
      return makeDynString();

    dyn_string files = getFileNames(dir);
    dyn_string ret;

    for(int i = 0; i < files.count(); i++)
    {
      ret.append(dir + files.at(i));
    }

    DebugTN(__FUNCTION__, ret);
    return ret;
  }

  //------------------------------------------------------------------------------
  /**
    TBD
  */
  public bool guiTestExist()
  {
    return (getGuiTestFullPaths().count() > 0);
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function starts an example for the library.
    @param relPath The path to the example script file. If
    the path is not specified, it will be defined by using
    the getExampleRelPath() function.
    @param addOptions The options you want to start your example with.
    @return int errorCode  The function returns 0 if it
    was successfully executed and otherwise an error code.
    Error code.
    Value | Description
    ------|------------
    0     | Success
    -1    | An example cannot be started since a new process could not be created.
  */
  public int startExample(string relPath = "", string addOptions = "")
  {
    if ( relPath == "" )
      relPath = getExampleRelPath();

    if ( !isfile(relPath) && !isfile(getPath(SCRIPTS_REL_PATH, relPath)) )
      return -1;

    const string covFilePath = getCoverageReportPath();
    const string covDir = dirName(PROJ_PATH + LOG_REL_PATH + covFilePath);
    if ( !isdir(covDir) )
      mkdir(covDir);

    addOptions = covFilePath + " " + addOptions;
    int threadId;
    if ( (myManType() == UI_MAN) && dynContains(getGediNames(), myModuleName()) )
      threadId = startThread("updateScriptState", relPath);

    int errors = start(relPath, addOptions, TRUE);

    if ( (myManType() == UI_MAN) && dynContains(getGediNames(), myModuleName()) )
    {
      stopThread(threadId);
      OaTestProjectView::updateScriptState(( isfile(relPath) ? relPath : getPath(SCRIPTS_REL_PATH, relPath) ), FALSE);
    }

    return errors;
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function starts a unit test for the library.
    @param relPath The path to the unit test script file.
    If the path is not specified, it will be defined
    by using the function getUnitTestRelPath().
    @param addOptions The options you want to start your unit test with.
    @return int errorCode The function returns 0 if it
    was successfully executed and otherwise an error code.
    Error code.
    Value | Description
    ------|------------
    0     | Success
    -1    | A unit test cannot be started since a new process could not be created.
  */
  public int startUnitTest(string relPath = "", string addOptions = "")
  {
    if ( relPath == "" )  // Use default relPath
      relPath = getUnitTestRelPath();

    const string covFilePath = getCoverageReportPath();
    const string covDir = dirName(PROJ_PATH + LOG_REL_PATH + covFilePath);
    if ( !isdir(covDir) )
      mkdir(covDir);

    OaTestProjectView::showSUT(getFilePath());
    fclose(fopen(PROJ_PATH + "quickResult.json", "wb+"));
    fclose(fopen(PROJ_PATH + "fullResult.json", "wb+"));


    addOptions = covFilePath + " " + addOptions;
    int rc = start(relPath, addOptions, TRUE);
    string str;
    fileToString(PROJ_PATH + "quickResult.json", str);
    OaTestProjectView::updateStatisic(getFilePath(), str, covFilePath);
    remove(PROJ_PATH + "quickResult.json");
    remove(PROJ_PATH + "fullResult.json");
    OaTestProjectView::hideSUT(getFilePath());
    return rc;
  }

  //------------------------------------------------------------------------------
  /**
    TBD
  */
  public int startGuiTests(string relPath = "", string addOptions = "")
  {
    dyn_string fullPathes;
    if ( relPath.isEmpty())  // Use default relPath
      fullPathes = getGuiTestFullPaths();
    else
      fullPathes = getPath("", relPath);

DebugTN(__FUNCTION__, fullPathes);
    int rc;
    for(int i = 0; i < fullPathes.count(); i++)
    {
      rc = startGuiTest(fullPathes.at(i), addOptions);

      if (rc)
        break;
    }

    return rc;
  }

  //------------------------------------------------------------------------------
  private int startGuiTest(string relPath, string addOptions)
  {
    const string covFilePath = getCoverageReportPath();
    const string covDir = dirName(PROJ_PATH + LOG_REL_PATH + covFilePath);
    if ( !isdir(covDir) )
      mkdir(covDir);

    OaTestProjectView::showSUT(getFilePath());
    fclose(fopen(PROJ_PATH + "quickResult.json", "wb+"));
    fclose(fopen(PROJ_PATH + "fullResult.json", "wb+"));


    addOptions = covFilePath + " " + addOptions;
    int rc = start(relPath, addOptions, TRUE);
    string str;
    fileToString(PROJ_PATH + "quickResult.json", str);
    OaTestProjectView::updateStatisic(getFilePath(), str, covFilePath);
    remove(PROJ_PATH + "quickResult.json");
    remove(PROJ_PATH + "fullResult.json");
    OaTestProjectView::hideSUT(getFilePath());
    return rc;
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function returns the relative path to the coverage report.
    @return string path The path to the coverage report as a string.
  */
  public string getCoverageReportPath()
  {
    string relPath = getFileRelPath();
    return "coverage/"+ relPath + ".xml";
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function shows a message in the CTRL script editor.
    @param msg The Message to be shown.
  */
  public void showErrMsg(const anytype &msg)
  {
    if ( isA(msg, DYN_DYN_ERRCLASS_VAR) || isA(msg, DYN_ERRCLASS_VAR) || isA(msg, ERRCLASS_VAR) )
      throwError(msg);
    else
      ModuleOnWithPanel("WARNING", -1, -1, 0, 0, 1, 1, "",
                        "vision/MessageWarning",
                        getCatStr("general","warning"), makeDynString(msg));
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function checks if a CTRL script file is empty (0 byte).
    @return The function returns TRUE when it is empty and otherwise FALSE.
  */
  public bool isNewFile()
  {
    return getFileSize(getFilePath()) == 0;
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function checks if the given script is running.
    @param path The script path (could be a relative or a full path).

    @return TRUE when a script is running or the script path is empty
    and otherwise FALSE.
  */
  public bool isRunning(const string path)
  {
    dyn_string runningScripts;
    dpGet(OA_TEST_DPE + "Result", runningScripts);

    // Check if the list contains the script.
    if ( dynContains(runningScripts, makeUnixPath(path)) > 0 )
    {
      hspProcess = Process(getComponentName(guiTest ? UI_COMPONENT : CTRL_COMPONENT), makeUnixPath(path));
      if ( hspProcess.isRunning() )
        return TRUE;
      else
        removeScriptFromRunning(path);  // script is not running -> remove it from the list
    }

    return FALSE;
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function stops the given script.
    @param path The script path (can be a relative or a full path).

    @return Return Error code.
    Error code.
    Value | Description
    ------|------------
    0     | Successful.
    -1    | The script cannot be stopped. Its path is empty or it is not running.
  */
  public int stopRunningScript(const string path)
  {
    if ( path.isEmpty() )
      return -1;

    int rc;
    hspProcess = Process(getComponentName(guiTest ? UI_COMPONENT : CTRL_COMPONENT), makeUnixPath(path));
    if ( !hspProcess.isRunning() )
      return -1;

    rc = hspProcess.kill();

    // remove stopped script from the list
    if ( rc >= 0 )
      removeScriptFromRunning(path);
    else
      throwError(makeError("hsp_errors", PRIO_WARNING, ERR_CONTROL, 7, makeUnixPath(path)));

    return rc;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /**
    @brief The function returns a relative path.
    @details A full path must be specified as a parameter.
    The function cuts the relative path out of the full path.
    @param fullPath The full path to be cut.
    @param relPath The relative path.
    @return The function returns a relative path.
  */
  protected string stripFromProjPath(string fullPath, const string &relPath)
  {
    string path = ctrlDbgPu_getRelPath(fullPath, relPath);
    if ( path == "" )
      return "";

    return substr(path, strlen(makeUnixPath(relPath)));
  }

  /**
    @brief The function returns the CTRL class name by the file name.
    @details The function removes invalid chars (only alphanumeric are allowed).
    @return The changed string.
  */
  protected string fileNameToClassName()
  {
    string str = getFileName();
    int dotPos = strpos(str, ".");
    if ( dotPos > 0 )
      str = substr(str, 0, dotPos);

    string ret;
    const int _LEN = strlen(str);
    bool validStr;

    for (int i = 0; i < _LEN; i++)
    {
      char _char = str[i];
      if ( ( _char >= '0' && _char <= '9' ) || // digits
           ( _char >= 'A' && _char <= 'Z' ) || // big Chars
           ( _char >= 'a' && _char <= 'z' ) )  // small Chars
      {
        if ( !validStr )
          _char = strtoupper(_char); // Start each word with an UpperCase.

        ret += _char;
        validStr = TRUE;
      }
      else
      {
        validStr = FALSE;
      }
    }

    return ret;
  }
  //------------------------------------------------------------------------------
  /**
    @brief The function starts the system call with the given script path and options.
    @details The system call contains a WCCOActrl.exe, 'given script path'
    and 'given options'.
    @return int rc The function returns 0 on success.
    The function returns -1 if no argument was specified,
    a new process could not be created or if the started process was
    not finished normally.
  */
  protected int start(const string &relPath, const string addOptions = "", bool doCoverage = FALSE)
  {
    string stdOut, stdErr;
    string cmd = makeNativePath(WINCCOA_BIN_PATH) + getComponentName(guiTest ? UI_COMPONENT : CTRL_COMPONENT);
    if ( _WIN32 )
      cmd += ".exe";

    dyn_string arguments = makeDynString("-proj", PROJ);

    if (guiTest)
    {
      arguments.append("-s");
      arguments.append(relPath);

      // string panelPath = stripFromProjPath(relPath, SCRIPTS_REL_PATH + "tests/splash/"); 
      // // substr(relPath, strlen("tests/splash/"));
      // panelPath = dirName(panelPath);
      // panelPath = substr(panelPath,0, strlen(panelPath) - 1); // remove last /   
      arguments.append("-p");
      arguments.append(getFilePath());
    }
    else
    {
      arguments.append(relPath);
    }

    if (!addOptions.isEmpty() && doCoverage)
    {
      dynAppend(arguments, "-dbg");
      dynAppend(arguments, "CTRL_COVERAGE");
      dynAppend(arguments, "-coveragereportfile");
    }

    // store each extra option as a separate element
    dyn_string extraOptions = addOptions.split(" ");
    dynAppend(arguments, extraOptions);

    mapping options = makeMapping("program", cmd,  "arguments", arguments,  "timeout", -1);
    int rc = system(options, stdOut, stdErr);

    if ( rc < 0 )  // script is not started -> throw error
    {
      throwError(makeError("hsp_errors", PRIO_WARNING, ERR_CONTROL, 6, makeUnixPath(relPath)));
      if ( !stdErr.isEmpty() )
        throwError(makeError("", PRIO_WARNING, ERR_CONTROL, 0, stdErr));

      if ( !stdOut.isEmpty() )
        throwError(makeError("", PRIO_INFO, ERR_CONTROL, 0, stdOut));
    }
    else  // script is started -> wait until it is finished
    {
      hspProcess = Process(rc);
      addScriptToRunning(relPath);
      while ( hspProcess.isRunning() )
        delay(0, 100);
    }

    removeScriptFromRunning(relPath);
    return ( rc < 0 ? -1 : 0);
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function adds a CTRL script and its PID to a list of running scripts.
    @param path The given script full path.
  */
  protected void addScriptToRunning(const string &path) synchronized(mutex)
  {
    dyn_string runningScripts;
    dpGet(OA_TEST_DPE + "Result", runningScripts);
    if ( !dynContains(runningScripts, makeUnixPath(path)) )
    {
      dynAppend(runningScripts, makeUnixPath(path));
      dpSetWait(OA_TEST_DPE + "Result", runningScripts);
    }
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function removes a CTRL script from the list of running scripts.
    @param path The path of the script to be removed.
  */
  protected void removeScriptFromRunning(const string &path) synchronized(mutex)
  {
    dyn_string runningScripts;
    dpGet(OA_TEST_DPE + "Result", runningScripts);
    dynRemove(runningScripts, dynContains(runningScripts, makeUnixPath(path)));
    dpSetWait(OA_TEST_DPE + "Result", runningScripts);
  }

  //------------------------------------------------------------------------------
  /**
    @brief The function updates the script state in the GEDI project view.
    @param relPath The path of the script to be updated.
  */
  protected void updateScriptState(string relPath)
  {
    while ( TRUE )
      OaTestProjectView::updateScriptState(( isfile(relPath) ? relPath : getPath(SCRIPTS_REL_PATH, relPath) ), isRunning(relPath));
  }

  //--------------------------------------------------------------------------------
  //@private members
  //--------------------------------------------------------------------------------

  string script; /**< A CTRL script content. */
  string scriptFilePath; /**< A CTRL script file name. */
  string relPath; /**< The relative path to the CTRL script. */
  int mutex;  /**< The synchronization index */
  const string OA_TEST_DPE = "_CtrlCommandInterface_scriptsState.";  /**< Holds running scripts list. */
  Process hspProcess;
};

//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright Copyright 2023 SIEMENS AG
             SPDX-License-Identifier: GPL-3.0-only
*/

//--------------------------------------------------------------------------------
// used libraries (#uses)
#uses "classes/systemEnvironment/SysEnvCpuMon"
#uses "classes/systemEnvironment/SysEnvOsInfo"
#uses "classes/testFramework/TfTestRunner"

//--------------------------------------------------------------------------------
// declare variables and constants


//--------------------------------------------------------------------------------
/**
 * @brief This class is hook for TfTestRunner
 */
class HookTfTestRunner : TfTestRunner
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /**
   * @brief Function setups the test environment.
   * @details Customized version of TfTestRunner::setupEnvironment()
   * We need to register all installed no deploy packages here and set the helper result path
   * @return Error code. Returns 0 when successful. Otherwise -1.
   */
  public int setupEnvironment()
  {
    if (TfTestRunner::setupEnvironment())
      return -1;

    string currentTestSuite = getenv("CURRENT_TEST_SUITE");

    if (currentTestSuite == "")
      currentTestSuite = "__TF__";

    string resDir = TfFileSys::getTestInstallPath(TfFileSysPath::ResultsPartly) + makeNativePath("/" + currentTestSuite + "/" + PROJ + "/");

    if (!isdir(resDir))
      mkdir(resDir);

    if (currentTestSuite != "__TF__")
    {
      oaUnitSetup(resDir + "result.json", makeMapping("Format", (int)OaTestResultFileFormat::JsonFull));
      TfErrHdl::outputFormat = OaTestResultFileFormat::JsonFull;
    }

    // in case oyu are running somehwere else than in 0our CI/CD piepeline, you need to register the Squirt sub project to be able to use its libraries
    if (squirtSubProj.isRegistered())
    {
      return 0;
    }

    // Register Squirt sub project to be able to use its libraries
    squirtSubProj.setInstallDir(dirName(dirName(TfFileSys::getTestInstallPath())) + makeNativePath("/src/"));
    squirtSubProj.setRunnable(false);
    const int rc = squirtSubProj.registerProj();

    return rc;
  }

  //------------------------------------------------------------------------------
  public void onExit(const anytype &exitCode)
  {
    squirtSubProj.unregisterProj();
    oaUnitAssertEqual("WinCC_OA_Test_Validation", (int)exitCode, 0, "verify exit code");
    oaUnitTearDown();
    TfTestRunner::onExit(exitCode);
  }



  //------------------------------------------------------------------------------
  public int start()
  {
    string str = "";
    str += "\nPlatform     : " + OsInfo::getPlatformName();
    str += "\nHost         : " + getHostname();

    mapping releaseInfo = OsInfo::getReleaseInfo();

    if (!releaseInfo.isEmpty())
    {
      str += "\nRelease-info  :";
    }

    for (int i = 0; i < releaseInfo.count(); i++)
    {
      const string key = releaseInfo.keyAt(i);
      str += "\n\t" + key + ":" + releaseInfo[key];
    }

    string sysCmdOut;
    system("whoami", sysCmdOut);
    strreplace(sysCmdOut, "\r", "");
    strreplace(sysCmdOut, "\n", "");
    str += "\nOS user      : " + sysCmdOut;

    system("uname -a", sysCmdOut);
    strreplace(sysCmdOut, "\r", "");
    strreplace(sysCmdOut, "\n", "");
    str += "\nUname        : " + sysCmdOut;

    str += "\nCPU:";
    str += "\n\tcores : " + CpuMon::getNoOfCores();

    str += "\nInput options:";

    str += "\n\tcreateDefaultWs      : " + this.createDefaultWs;
    str += "\n\tcleanOldResults      : " + this.cleanOldResults;
    str += "\n\tcleanStoredProjects  : " + this.cleanStoredProjects;
    str += "\n\tregisterGlobalProject: " + this.registerGlobalProject;
    str += "\n\tregisterAllTools     : " + this.registerAllTools;
    str += "\n\tregisterAllTemplates : " + this.registerAllTemplates;
    str += "\n\tenableHttpClient     : " + this.enableHttpClient;
    str += "\n\tenableNotifications  : " + this.enableNotifications;
    str += "\n\tshowLogViewer        : " + this.showLogViewer;
    str += "\n\ttestRunId            : " + this.testRunId;
    str += "\n\tusersToNotify        : " + strjoin(this.usersToNotify, ", ");

    for (int i = 1; i <= mappinglen(this._options); i++)
    {
      const string key = mappingGetKey(this._options, i);
      str += "\n\t" + key + ":" + this._options[key];
    }

    throwError(makeError("", PRIO_INFO, ERR_CONTROL, 0, "Test-runner starts", str));

    str = "\nDisplay diagnostics:";

    dyn_string envKeys = makeDynString(
                           "DISPLAY",
                           "XAUTHORITY",
                           "XDG_RUNTIME_DIR",
                           "QT_QPA_PLATFORM",
                           "QT_PLUGIN_PATH",
                           "HOME",
                           "USER",
                           "LOGNAME",
                           "HOSTNAME",
                           "PWD",
                           "PATH",
                           "LD_LIBRARY_PATH",
                           "LANG",
                           "LC_ALL",
                           "TMPDIR",
                           "TMP",
                           "TEMP",
                           "PVSS_II",
                           "PVSS_II_PROJ",
                           "CURRENT_TEST_SUITE",
                           "WINCC_OA_CTRL_TF_CURRENT_TEST_SUITE_ID",
                           "WINCC_OA_CTRL_TF_CURRENT_TEST_MANAGER_IDX");

    for (int i = 1; i <= dynlen(envKeys); i++)
    {
      string envValue = getenv(envKeys[i]);

      if (envValue == "")
        envValue = "<unset>";

      str += "\n\t" + envKeys[i] + "=" + envValue;
    }

    string diagStdOut;
    string diagStdErr;
    int diagRc = 0;

    if (_UNIX)
    {
      string shellCmd =
        "echo '=== identity ==='; "
        + "id; whoami; hostname; pwd; "
        + "echo; echo '=== x11 ==='; "
        + "echo DISPLAY=$DISPLAY; "
        + "xauth list 2>&1 || true; "
        + "xdpyinfo -display \"$DISPLAY\" 2>&1 | head -40; "
        + "echo; echo '=== fs ==='; "
        + "ls -ld \"$HOME\" /tmp .; "
        + "touch /tmp/wccoa_diag_$$ 2>&1; "
        + "ls -l /tmp/wccoa_diag_$$ 2>&1; "
        + "rm -f /tmp/wccoa_diag_$$ 2>&1; "
        + "echo; echo '=== processes ==='; "
        + "ps -ef | grep -E 'Xvfb|WCCOAui' | grep -v grep || true";

      mapping cmd = makeMapping(
                      "program", "/bin/sh",
                      "arguments", makeDynString("-lc", shellCmd),
                      "timeout", 30);
      diagRc = system(cmd, diagStdOut, diagStdErr);
    }
    else
    {
      string shellCmd =
        "echo === identity === & "
        + "whoami & hostname & cd & "
        + "echo. & echo === env === & "
        + "set DISPLAY & set XAUTHORITY & set XDG_RUNTIME_DIR & "
        + "set QT_ & set HOME & set USER & set LOGNAME & set PATH & "
        + "set TEMP & set TMP & set PVSS_II & set CURRENT_TEST_SUITE";

      mapping cmd = makeMapping(
                      "program", "cmd.exe",
                      "arguments", makeDynString("/c", shellCmd),
                      "timeout", 30);
      diagRc = system(cmd, diagStdOut, diagStdErr);
    }

    strreplace(diagStdOut, "\r", "");
    strreplace(diagStdErr, "\r", "");

    str += "\n\tcommandRc=" + diagRc;

    if (diagStdOut != "")
      str += "\n\tstdout:\n" + diagStdOut;

    if (diagStdErr != "")
      str += "\n\tstderr:\n" + diagStdErr;

    throwError(makeError("", PRIO_INFO, ERR_CONTROL, 0,
                         "Display diagnostics", str));

    return TfTestRunner::start();
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  //------------------------------------------------------------------------------
  ProjEnvProject squirtSubProj = ProjEnvProject("Squirt");
};

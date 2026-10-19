/**
  @file $relPath
  @brief Command-line interface for Splash recording and playback sessions.
  @copyright MIT
  @AIgeneratedHelpContent
*/

#uses "classes/CommandLineArguments"
#uses "classes/projectEnvironment/ProjEnvComponent"
#uses "classes/splash/ErrorHdl/OaLogger"
#uses "classes/splash/Splash"
#uses "classes/splash/SplashCliValidation"

/**
  @brief Parses the sq-cli command and runs the requested Splash operation.
*/
void main(...)
{
  va_list args;
  int argCount = va_start(args);
  CommandLineArguments cli = CommandLineArguments("winccoa-tools-pack", "squirt");
  cli.readArguments(args, argCount);
  va_end(args);

  dyn_string flags = cli.getFlags();

  if (dynlen(flags) != 1)
  {
    printUsage();
    exit(2);
  }

  string command = flags[1];
  Splash::initInterface();

  if (!dpExists("_Splash.currentPanel") ||
      !dpExists("_Splash.currentTestScript"))
  {
    logWarning(tr("sq-cli: Splash metadata DPEs are missing; import Splash.dpl"));
    exit(2);
  }

  if (command == "record")
    startRecording(cli);
  else if (command == "pause")
    sendSessionCommand("pause");
  else if (command == "resume")
    sendSessionCommand("resume");
  else if (command == "stop")
    stopRecording(cli);
  else if (command == "status")
    printStatus();
  else
  {
    logWarning(tr("sq-cli: unsupported command: $1").subst(command));
    printUsage();
    exit(2);
  }
}

/**
  @brief Starts a recorder UI for a panel and stores its script metadata.
  @param cli Parsed command-line arguments.
*/
void startRecording(CommandLineArguments cli)
{
  SplashCliValidation validation = SplashCliValidation();

  if (!cli.hasSetting("panel.path") ||
      !cli.hasSetting("testScript.path") ||
      !cli.hasSetting("testScript.force"))
  {
    logWarning(tr("sq-cli record requires panel.path, testScript.path, and testScript.force"));
    exit(2);
  }

  string panelPath = cli.getSettingsValue("panel.path", "");
  string testScriptPath = cli.getSettingsValue("testScript.path", "");
  string forceText = cli.getSettingsValue("testScript.force", "");
  bool force;

  if (forceText == "true")
    force = TRUE;
  else if (forceText == "false")
    force = FALSE;
  else
  {
    logWarning(tr("sq-cli: testScript.force must be true or false"));
    exit(2);
  }

  if (!validation.isSafePanelPath(panelPath) ||
      !validation.isSafeTestScriptPath(testScriptPath))
  {
    logWarning(tr("sq-cli: panel and script paths must be safe project-relative paths"));
    exit(2);
  }

  mapping activePanel;
  mapping activeScript;

  if (getCurrentSession(activePanel, activeScript))
  {
    logWarning(tr("sq-cli: a Splash session is already active for panel $1 and script $2")
               .subst(activePanel.value("path", ""),
                      activeScript.value("path", "")));
    exit(1);
  }

  string outputPath = getPath(SCRIPTS_REL_PATH, testScriptPath);

  if (isfile(outputPath) && !force)
  {
    logWarning(tr("sq-cli: refusing to overwrite existing test script: $1")
               .subst(outputPath));
    exit(1);
  }

  mapping panelInfo = makeMapping("path", panelPath, "project", PROJ);
  mapping scriptInfo = makeMapping("path", testScriptPath, "force", force);
  string currentPanelJson = jsonEncode(panelInfo);
  string currentTestScriptJson = jsonEncode(scriptInfo);
  dpSetWait("_Splash.currentPanel", currentPanelJson,
            "_Splash.currentTestScript", currentTestScriptJson,
            "_Splash.response", "",
            "_Splash.command", "");

  dyn_string uiOptions = makeDynString(
                           "-p", panelPath.startsWith("/") ? substr(panelPath, 1) : panelPath,
                           "-log", "+stderr",
                           "-s", "splash/splashRecord.ctl");
  ProjEnvComponent ui = ProjEnvComponent(UI_COMPONENT);
  ui.setProj(PROJ);
  ui.setOptions(uiOptions);
  ui.setAsync(TRUE);
  ui.setDetached(TRUE);
  ui.setMaxDuration(-1);

  if (ui.start() != 0)
  {
    dpSetWait("_Splash.currentPanel", "{}",
              "_Splash.currentTestScript", "{}");
    logWarning(tr("sq-cli: failed to start recorder UI: $1")
               .subst(ui.getStdErr()));
    exit(1);
  }

  dyn_anytype result;
  bool timedOut;
  dpWaitForValue(
    makeDynString("_Splash.command:_original.._value"),
    makeDynAnytype("ready for recording"), makeDynString(),
    result, 60, timedOut);

  if (timedOut)
  {
    logWarning(tr("sq-cli: recorder UI did not become ready within 60 seconds"));
    exit(1);
  }

  dpSetWait("_Splash.command", "record", "_Splash.response", "");
  logInfo(tr("sq-cli: recording started for panel $1 with script $2")
          .subst(panelPath, testScriptPath));
}

/**
  @brief Sends pause or resume to the active recorder session.
  @param command Splash session command.
*/
void sendSessionCommand(const string command)
{
  mapping panelInfo;
  mapping scriptInfo;
  string currentCommand;

  if (!getCurrentSession(panelInfo, scriptInfo))
  {
    logWarning(tr("sq-cli: there is no current Splash session"));
    exit(1);
  }

  dpGet("_Splash.command", currentCommand);

  if ((command == "pause" && currentCommand != "record" &&
       currentCommand != "resume") ||
      (command == "resume" && currentCommand != "pause"))
  {
    logWarning(tr("sq-cli: command $1 is invalid in session state $2")
               .subst(command, currentCommand));
    exit(1);
  }

  dpSetWait("_Splash.command", command, "_Splash.response", "");
  logInfo(tr("sq-cli: command $1 sent for panel $2")
          .subst(command, panelInfo.value("path", "")));
}

/**
  @brief Stops the current recording and validates the requested output path.
  @param cli Parsed command-line arguments.
*/
void stopRecording(CommandLineArguments cli)
{
  SplashCliValidation validation = SplashCliValidation();

  if (!cli.hasSetting("testScript.path") ||
      !cli.hasSetting("testScript.force"))
  {
    logWarning(tr("sq-cli stop requires testScript.path and testScript.force"));
    exit(2);
  }

  mapping panelInfo;
  mapping scriptInfo;

  if (!getCurrentSession(panelInfo, scriptInfo))
  {
    logWarning(tr("sq-cli: there is no current Splash session to stop"));
    exit(1);
  }

  string requestedPath = cli.getSettingsValue("testScript.path", "");
  string forceText = cli.getSettingsValue("testScript.force", "");

  if (!validation.isSafeTestScriptPath(requestedPath) ||
      requestedPath != scriptInfo.value("path", ""))
  {
    logWarning(tr("sq-cli: stop path must match the current session script"));
    exit(2);
  }

  if (forceText != "true" && forceText != "false")
  {
    logWarning(tr("sq-cli: testScript.force must be true or false"));
    exit(2);
  }

  bool force = (forceText == "true");
  string outputPath = getPath(SCRIPTS_REL_PATH, requestedPath);

  if (isfile(outputPath) && !force)
  {
    logWarning(tr("sq-cli: refusing to overwrite existing test script: $1")
               .subst(outputPath));
    exit(1);
  }

  scriptInfo["force"] = force;
  dpSetWait("_Splash.currentTestScript", jsonEncode(scriptInfo),
            "_Splash.command", "stop", "_Splash.response", "");

  dyn_anytype result;
  bool timedOut;
  dpWaitForValue(
    makeDynString("_Splash.command:_original.._value"),
    makeDynAnytype("finished"), makeDynString(),
    result, 60, timedOut);

  if (timedOut)
  {
    logWarning(tr("sq-cli: timed out waiting for Splash to finish writing the script"));
    exit(1);
  }

  logInfo(tr("sq-cli: recording saved to $1").subst(requestedPath));
}

/**
  @brief Reads the metadata for the active panel and test script.
  @param panelInfo Parsed panel metadata.
  @param scriptInfo Parsed test-script metadata.
  @return true when both paths identify a valid current session.
*/
bool getCurrentSession(mapping &panelInfo, mapping &scriptInfo)
{
  SplashCliValidation validation = SplashCliValidation();
  string panelJson;
  string scriptJson;
  dpGet("_Splash.currentPanel", panelJson,
        "_Splash.currentTestScript", scriptJson);

  if (panelJson == "" || scriptJson == "")
    return FALSE;

  panelInfo = jsonDecode(panelJson);
  scriptInfo = jsonDecode(scriptJson);

  return validation.isSafePanelPath(panelInfo.value("path", "")) &&
         validation.isSafeTestScriptPath(scriptInfo.value("path", ""));
}

/**
  @brief Prints current Splash state as a JSON object.
*/
void printStatus()
{
  mapping panelInfo;
  mapping scriptInfo;
  string command;
  string response;
  dpGet("_Splash.command", command, "_Splash.response", response);

  if (!getCurrentSession(panelInfo, scriptInfo))
  {
    logInfo(jsonEncode(makeMapping("state", "idle", "command", command,
                                   "response", response)));
    return;
  }

  logInfo(jsonEncode(makeMapping("state", command,
                                 "panel", panelInfo,
                                 "testScript", scriptInfo,
                                 "response", response)));
}

/**
  @brief Prints the supported sq-cli command syntax.
*/
void printUsage()
{
  logInfo(tr("Usage: sq-cli <project> <record|pause|resume|stop|status>"));
  logInfo(tr("Settings: -winccoa-tools-pack.squirt.<key>=<value>"));
}

/**
  @brief Logs an informational sq-cli message through OaLogger.
  @param message Translatable message text.
  @param note Optional first substitution value.
  @param note2 Optional second substitution value.
*/
void logInfo(const string message,
             const anytype note = NULL,
             const anytype note2 = NULL)
{
  OaLogger logger = OaLogger();
  logger.info(message, note, note2);
}

/**
  @brief Logs a warning sq-cli message through OaLogger.
  @param message Translatable message text.
  @param note Optional first substitution value.
  @param note2 Optional second substitution value.
*/
void logWarning(const string message,
                const anytype note = NULL,
                const anytype note2 = NULL)
{
  OaLogger logger = OaLogger();
  logger.warning(message, note, note2);
}
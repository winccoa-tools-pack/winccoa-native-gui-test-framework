/**
  @file $relPath
  @brief Records a guided UI interaction as a reusable macro.
  @copyright MIT
  @AIgeneratedHelpContent
*/

#uses "classes/InputEventPlayer"

/**
  @brief Coordinates input recording with the generic tc_quide panel.
  @details The caller starts recording before opening the UI interaction,
           then opens the guide at the appropriate point. The guide's stop
           command stops recording and appends a reusable function to the
           configured scripts/libs library.
  @AIgeneratedHelpContent
*/
class SplashGuidedMacroRecorder
{
//@public members

//@protected members
  /** Whether the guide has sent its stop command. */
  protected bool recordingStopped;
  /** Whether the temporary macro and library were written successfully. */
  protected bool recordingSaved;
  /** Absolute path to the temporary macro file. */
  protected string recordedMacroPath;
  /** Configured macro function name. */
  protected string macroName;
  /** Configured absolute CTRL library path. */
  protected string libraryPath;
  /** Error from setup or stop-command processing. */
  protected string errorMessage;

//@private members

//@protected functions

  /**
    @brief Handles the guide stop command and persists the recorded macro.
    @param userData Callback user data.
    @param dpe Changed Splash command datapoint.
    @param command New Splash command value.
  */
  protected void onSplashRecordingCommand(anytype userData,
                                          string dpe,
                                          string command)
  {
    if (!command.startsWith("stop|") || this.recordingStopped)
      return;

    if (inputRecorderIsRecording())
      inputRecorderStop();

    dyn_string commandParts = strsplit(command, "|");

    if (dynlen(commandParts) != 3)
    {
      this.errorMessage = "Stop command must include macro name and path.";
      this.recordingStopped = TRUE;
      return;
    }

    if (commandParts[2] != this.macroName ||
        commandParts[3] != this.libraryPath)
    {
      this.errorMessage = "Stop command does not match the configured macro.";
      this.recordingStopped = TRUE;
      return;
    }

    string recordedScript = inputRecorderGetScript();
    strreplace(recordedScript, "#uses \"classes/InputEventPlayer\"", "");
    strreplace(recordedScript, "InputEventPlayer player;", "");
    strreplace(recordedScript, "play()",
               this.macroName + "(InputEventPlayer &player)");
    recordedScript.trim();
    recordedScript = "int " + recordedScript;
    recordedScript.remove(recordedScript.length() - 1, 1);
    recordedScript += "return 0;\n}\n";

    file output = fopen(this.recordedMacroPath, "w");
    fputs(recordedScript, output);
    fclose(output);

    const string libraryFilePath = makeNativePath(this.libraryPath);
    const string libraryDirectory = PROJ_PATH + "scripts/libs";

    if (!isdir(libraryDirectory))
    {
      this.errorMessage = "The project scripts/libs directory does not exist.";
      this.recordingStopped = TRUE;
      return;
    }

    bool createLibrary = !isfile(libraryFilePath);
    file library = fopen(libraryFilePath, createLibrary ? "w" : "a");

    if (createLibrary)
      fputs("#uses \"classes/InputEventPlayer\"\n\n", library);

    fputs("\n", library);
    fputs(recordedScript, library);
    fclose(library);
    this.recordingSaved = isfile(this.recordedMacroPath) &&
                          isfile(libraryFilePath);

    if (!this.recordingSaved)
      this.errorMessage = "Failed to save the recorded macro.";

    this.recordingStopped = TRUE;
  }

//@public functions

  /**
    @brief Starts input recording and subscribes to the guide stop command.
    @param outputRelativePath Temporary file path under data/tmp.
    @param macroName Function name to write into the target library.
    @param libraryPath Full native path under the project scripts/libs.
    @return 0 when recording starts; -1 when validation or setup fails.
  */
  public int startRecording(const string &outputRelativePath,
                            const string &macroName,
                            const string &libraryPath)
  {
    this.recordingStopped = FALSE;
    this.recordingSaved = FALSE;
    this.errorMessage = "";
    this.macroName = macroName;
    this.libraryPath = libraryPath;

    if (!outputRelativePath.startsWith("data/tmp/") ||
        !outputRelativePath.endsWith(".ctl") ||
        outputRelativePath.contains("..") ||
        outputRelativePath.contains("\\"))
    {
      this.errorMessage = "Macro output must be a data/tmp/*.ctl path.";
      return -1;
    }

    string normalizedLibraryPath = libraryPath;
    strreplace(normalizedLibraryPath, "\\", "/");
    string scriptsLibsPath = PROJ_PATH + "scripts/libs";
    strreplace(scriptsLibsPath, "\\", "/");
    const string validMacroCharacters =
      "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_";
    bool validMacroName = macroName.startsWith("macro_");

    for (int charIndex = 0; charIndex < strlen(macroName); charIndex++)
    {
      if (strpos(validMacroCharacters, substr(macroName, charIndex, 1)) < 0)
        validMacroName = FALSE;
    }

    if (!validMacroName ||
        !normalizedLibraryPath.startsWith(scriptsLibsPath + "/") ||
        !normalizedLibraryPath.endsWith(".ctl") ||
        normalizedLibraryPath.contains("/../") ||
        normalizedLibraryPath.endsWith("/..") ||
        normalizedLibraryPath.contains("|"))
    {
      this.errorMessage = "Invalid macro name or scripts/libs library path.";
      return -1;
    }

    if (inputRecorderIsRecording())
    {
      this.errorMessage = "The input event recorder is already active.";
      return -1;
    }

    const string tempDir = PROJ_PATH + "data/tmp";

    if (!isdir(tempDir))
      mkdir(tempDir);

    this.recordedMacroPath = PROJ_PATH + outputRelativePath;

    if (isfile(this.recordedMacroPath))
    {
      this.errorMessage = "Refusing to overwrite recorded macro.";
      return -1;
    }

    dpSetWait("_Splash.command", "", "_Splash.response", "");
    dpConnectUserData(this, this.onSplashRecordingCommand, "", FALSE,
                      "_Splash.command");
    inputRecorderStart();
    return 0;
  }

  /**
    @brief Writes the guide configuration and launches its UI manager.
    @param guidePanel Panel path relative to the Squirt panels directory.
    @param quide Instructions shown to the user; key spelling is retained.
    @return 0 when the guide process is launched; -1 if setup fails.
  */
  public int startGuide(const string &guidePanel, const string &quide)
  {
    mapping guideConfig = makeMapping("macroName", this.macroName,
                                      "libraryPath", this.libraryPath,
                                      "quide", quide);
    const string guideConfigPath = PROJ_PATH + ".tcQuide.json";
    file configFile = fopen(guideConfigPath, "w");
    fputs(jsonEncode(guideConfig), configFile);
    fclose(configFile);

    if (!isfile(guideConfigPath))
    {
      this.errorMessage = "Failed to write test guide configuration.";
      return -1;
    }

    string uiExecutable = getComponentName(UI_COMPONENT);

    if (_WIN32)
      uiExecutable += ".exe";

    const string uiPath = getPath(BIN_REL_PATH, uiExecutable);
    dyn_string arguments = makeDynString("-PROJ", PROJ, "-p", guidePanel);
    mapping options = makeMapping("program", uiPath,
                                  "arguments", arguments);
    system(options);
    return 0;
  }

  /**
    @brief Reports whether the guide stop command has been received.
    @return TRUE after stop processing and macro persistence have completed.
  */
  public bool isRecordingStopped()
  {
    return this.recordingStopped;
  }

  /**
    @brief Reports whether both recorded macro files were saved.
    @return TRUE when the temporary script and CTRL library exist.
  */
  public bool isRecordingSaved()
  {
    return this.recordingSaved;
  }

  /**
    @brief Returns the most recent setup or save error.
    @return Empty string on success, otherwise an actionable error message.
  */
  public string getErrorMessage()
  {
    return this.errorMessage;
  }
};
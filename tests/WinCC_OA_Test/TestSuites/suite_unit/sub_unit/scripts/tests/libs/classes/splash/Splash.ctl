/**
  @file scripts/tests/libs/classes/splash/Splash.ctl
  @test Unit tests for classes/splash/Splash without process launches.
  @copyright MIT
  @AIgeneratedHelpContent
*/

#uses "classes/oaTest/OaTest"
#uses "classes/splash/Splash"

/**
  @brief Global expected by Splash::getStateFromString; no callbacks enabled.
  @AIgeneratedHelpContent
*/
Splash spSplash;

/**
  @brief Tests Splash state decoding, script parameters and path caching.
  @AIgeneratedHelpContent
*/
class TstSplash : OaTest
{
  //@public members

  /**
    @test Decode commands and command payloads into their Splash states.
    @AIgeneratedHelpContent
  */
  public int testCommandStates()
  {
    dyn_string commands = makeDynString("play", "pause", "resume", "record",
                                        "ready for play", "ready for recording");
    dyn_int states = makeDynInt((int)eSplash::play, (int)eSplash::pause,
                                (int)eSplash::record, (int)eSplash::record, (int)eSplash::play,
                                (int)eSplash::record);

    for (int index = 1; index <= dynlen(commands); index++)
    {
      this.assertEqual((int)Splash::getStateFromString(commands[index]),
                       states[index], commands[index]);
      this.assertEqual((int)Splash::getStateFromString(
                         commands[index] + " panel testcase"),
                       states[index], commands[index] + " with payload");
    }

    return 0;
  }

  /**
    @test Stop, finished, empty and unrecognized commands map to stop.
    @AIgeneratedHelpContent
  */
  public int testStoppedAndUnknownStates()
  {
    dyn_string commands = makeDynString("stop", "stop panel testcase",
                                        "finished", "", "unknown", "PLAY", " record", "not play");

    for (int index = 1; index <= dynlen(commands); index++)
      this.assertEqual((int)Splash::getStateFromString(commands[index]),
                       (int)eSplash::stop, commands[index]);

    return 0;
  }

  /**
    @test Constructors and repeated reads preserve the cached script path.
    @AIgeneratedHelpContent
  */
  public int testCachedScriptPath()
  {
    Splash splash;
    string savedPath = splash.sTestScriptPath;
    string cachedPath = getPath(SCRIPTS_REL_PATH);
    splash.sTestScriptPath = cachedPath;
    Splash secondSplash;
    string firstPath = splash.getScriptPath();
    string secondPath = secondSplash.getScriptPath();
    splash.sTestScriptPath = savedPath;

    this.assertEqual(firstPath, cachedPath, "Constructor keeps cached path");
    this.assertEqual(secondPath, cachedPath, "Repeated read is stable");
    return 0;
  }

  /**
    @test Parse only a leading parameter marker on the first script line.
    @AIgeneratedHelpContent
  */
  public int testScriptParameters()
  {
    string fixturePath = getPath(DATA_REL_PATH) + "oaTest_Splash_params.ctl";
    this.assertFalse(isfile(fixturePath), "Do not overwrite an existing file");

    if (isfile(fixturePath))
      return -1;

    Splash splash;
    string savedPath = splash.sTestScriptPath;
    splash.sTestScriptPath = getPath(SCRIPTS_REL_PATH);
    dyn_string contents = makeDynString(
                            "//params:-user root: -lang en_US.utf8\nvoid main() {}\n",
                            "//params:  -flag value  \n",
                            "//params:\n", "//params:-last value",
                            "//ordinary header\n//params:-ignored\n",
                            " //params:-ignored\n", "//Params:-ignored\n", "",
                            "//params:-relative value\n");
    dyn_string expected = makeDynString("-user root: -lang en_US.utf8",
                                        "  -flag value  ", "", "-last value", "", "", "", "",
                                        "-relative value");

    for (int index = 1; index <= dynlen(contents); index++)
    {
      file fixture = fopen(fixturePath, "w");

      if (fixture == 0)
      {
        splash.sTestScriptPath = savedPath;
        this.assertTrue(false, "Cannot create parameter fixture");
        return -1;
      }

      fputs(contents[index], fixture);
      fclose(fixture);
      this.assertEqual(splash.getParamsFromScript(fixturePath),
                       expected[index], "Header variant " + index);
    }

    splash.sTestScriptPath = getPath(DATA_REL_PATH);
    this.assertEqual(splash.getParamsFromScript("oaTest_Splash_params.ctl"),
                     "-relative value", "Resolve relative to cached path");
    splash.sTestScriptPath = savedPath;
    this.assertEqual(remove(fixturePath), 0, "Remove owned fixture");
    return 0;
  }

  /**
    @test Non-CTL paths are ignored without attempting to open them.
    @AIgeneratedHelpContent
  */
  public int testNonScriptPaths()
  {
    Splash splash;
    string savedPath = splash.sTestScriptPath;
    splash.sTestScriptPath = getPath(SCRIPTS_REL_PATH);
    dyn_string paths = makeDynString("", "missing.txt", "missing.CTL",
                                     "missing.ctl.backup");

    for (int index = 1; index <= dynlen(paths); index++)
      this.assertEqual(splash.getParamsFromScript(paths[index]), "",
                       "Ignore non-script path: " + paths[index]);

    splash.sTestScriptPath = savedPath;
    return 0;
  }

  //@protected members

  //@private members
};

void main(...)
{
  va_list list;
  int count = va_start(list);
  TstSplash test;
  test.cla.readArguments(list, count);
  va_end(list);

  test.startAll();
}
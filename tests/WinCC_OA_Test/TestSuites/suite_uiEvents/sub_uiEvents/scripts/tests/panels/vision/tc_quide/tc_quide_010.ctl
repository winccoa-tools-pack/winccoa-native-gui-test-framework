/**
  @file tests/panels/vision/tc_quide/tc_quide_010.ctl
  @copyright MIT
  @brief Verify the configurable test guide panel UI and stop command.
  @details The caller creates .tcQuide.json before starting the UI manager.
           The guide is opened from the framework panel resources.
  @AIgeneratedHelpContent
*/

#uses "classes/splash/OaGuiTest"
#uses "panel"

class TcQuideUi010 : OaGuiTest
{
//@public members

//@protected members

//@private members

//@protected functions

//@public functions

  /**
    @brief Opens the guide in an isolated UI module.
    @return 0 when the guide panel is ready.
  */
  public int setUp()
  {
    if (OaGuiTest::setUp())
      return -1;

    ModuleOnWithPanel("TcQuideUiTest", -1, -1, 800, 600, 1, 1, "None",
                      "vision/tc_quide.pnl", "tc_quide", makeDynString());

    int waitMs = 0;

    while (!isPanelOpen("tc_quide", "TcQuideUiTest") && waitMs < 5000)
    {
      delay(0, 100);
      waitMs += 100;
    }

    if (!isPanelOpen("tc_quide", "TcQuideUiTest"))
      this.abort("The guide panel did not open in the test module.");

    return 0;
  }

  /**
    @test The guide displays caller-provided config and sends its stop payload.
    @return 0 after all guide UI assertions pass.
  */
  public int play()
  {
    const string configPath = PROJ_PATH + ".tcQuide.json";
    string configJson;

    if (!isfile(configPath))
      this.abort("The caller must create .tcQuide.json before starting tc_quide.pnl.");

    fileToString(configPath, configJson);
    mapping guideConfig = jsonDecode(configJson);
    const string macroName = guideConfig.value("macroName", "");
    const string libraryPath = guideConfig.value("libraryPath", "");
    const string guideText = guideConfig.value("quide", "");
    const string expectedCommand = "stop|" + macroName + "|" + libraryPath;

    const string guidePanelAddress = "TcQuideUiTest.tc_quide";
    player.makeCurrent(guidePanelAddress + ":macroNameInput");
    shape macroNameInput = player.getShapeWait(
                             guidePanelAddress + ":macroNameInput");
    shape libraryPathInput = player.getShapeWait(
                               guidePanelAddress + ":libraryPathInput");
    shape guideTextInput = player.getShapeWait(
                             guidePanelAddress + ":guideText");

    this.assertTrue(macroNameInput.text == macroName,
                    "Guide macro name matches .tcQuide.json");
    this.assertTrue(libraryPathInput.text == libraryPath,
                    "Guide library path matches .tcQuide.json");
    this.assertTrue(guideTextInput.text == guideText,
                    "Guide instructions match .tcQuide.json");

    dpSetWait("_Splash.command", "", "_Splash.response", "");
    player.clickShape(guidePanelAddress + ":finishButton");

    string actualCommand;
    dpGet("_Splash.command", actualCommand);
    int waitMs = 0;

    while (actualCommand != expectedCommand && waitMs < 2000)
    {
      delay(0, 50);
      dpGet("_Splash.command", actualCommand);
      waitMs += 50;
    }

    this.assertEqual(actualCommand, expectedCommand,
                     "Finish sends the configured Splash stop payload");
    return 0;
  }
};

void main()
{
  TcQuideUi010 test;
  test.setFileScript(__FILE__);
  test.startAll();
  exit(0);
}
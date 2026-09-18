/**
  @copyright Copyright 2026 winccoa-tools-pack
  SPDX-License-Identifier: MIT
*/

/**
  @file $relPath
*/

#uses "classes/splash/OaGuiTest" // load all necessary classes
#uses "oaGuiTestShapes"


/**
  @brief Record/replay state for inactive border display.
  @AIgeneratedHelpContent
*/
const int cStop = 0;

/**
  @brief Record/replay state for recording mode.
  @AIgeneratedHelpContent
*/
const int cRecord = 1;

/**
  @brief Record/replay state for playback mode.
  @AIgeneratedHelpContent
*/
const int cPlay = 2;

/**
  @brief Record/replay state for paused playback.
  @AIgeneratedHelpContent
*/
const int cPause = 3;


/**
  @brief Shows or hides the record/replay border overlay.
  @param mode Border mode to display; defaults to recording mode.
  @AIgeneratedHelpContent
*/
public void showRecordReplayBorder(uint mode = cRecord)
{
  DebugTN("function correctly called", mode);
  string sModule = "SplashCover";

  if (mode == cRecord /* || mode == eSplash::play*/)
  {
    DebugTN("Calling module");
    ModuleOn(sModule, 0, 0, 5, 5, 1, 1);

    while (!isModuleOpen(sModule))
    {
      delay(0, 100);
    }

    stayOnTop(true, sModule);
    RootPanelOnModule("splash/cover", sModule, sModule, makeDynString("$MODEREC:" + (int)(mode == cRecord)));
  }
  else if (isModuleOpen(sModule))
  {
//    DebugTN(">>>>>>>>>>>>>>>>>>>>>>>>>>>> moduel off", mode);
    ModuleOff(sModule);
  }

  DebugTN("end of function reached");
}

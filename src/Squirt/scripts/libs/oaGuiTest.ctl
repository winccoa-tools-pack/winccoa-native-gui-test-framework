/**
  @copyright Copyright 2026 winccoa-tools-pack
  SPDX-License-Identifier: MIT
*/


#uses "classes/splash/OaGuiTest" // load all necessary classes
#uses "oaGuiTestShapes"


const int cStop = 0;
const int cRecord = 1;
const int cPlay = 2;
const int cPause = 3;


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

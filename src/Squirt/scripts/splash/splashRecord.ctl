// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author atw121x7
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/splash/Splash"
//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
*/

global shared_ptr<Splash> spSplash;

void main()
{
  startThread("threadGetRootPanel");
  sysConnect("workCB_exit", "exitRequested");
  spSplash  = new Splash(FALSE, TRUE); //ready for recording
  DebugTN("spSplash prepared for recording", spSplash);
}

threadGetRootPanel()
{
  string sLastModuleName, sLastPanelName;
  delay(0,300);
  while(1)
  {
    dyn_string dsModules = getVisionNames();
    bool bFinish;
    for (int i = 1; i <= dynlen(dsModules) && !bFinish; i++)
    {
    /*
      "Vision_1"
      "WinCC_OA_1"
      "mainModule_1"
      "naviModule_1"
      "infoModule_1"
  */
      //on screen one
      if (patternMatch("Vision_1", dsModules[i]) ||
          patternMatch("WinCC_OA_1", dsModules[i]))
      {
        string sPanel = rootPanel(dsModules[i]);
        if (sLastModuleName != dsModules[i] || sLastPanelName != sPanel)
        {
          const string sCommand = "Splash::onClose();";
          sLastModuleName =  dsModules[i];
          sLastPanelName = sPanel;
          shape sh = getShape(sLastModuleName + "." + sLastPanelName + ":");

          string sScript;
          getValue(sh, "script", "Close", sScript);

          if (strpos(sScript, sCommand) < 1)
          {
            int iPos = strpos(sScript, "{");
            if (iPos<1)
            {
              //no script
              sScript = "main(){}"; //exit(0);
              iPos = strpos(sScript, "{");
            }

            string sNewScript = substr(sScript, 0, iPos+1) + sCommand + substr(sScript, iPos+1);
            setValue(sh, "script", "Close", sNewScript);
            DebugTN("close script updated!!!!!!!!!!!!", sNewScript);
          }
        }
        bFinish = TRUE;
      }
    }
    delay(1);
  }
}

workCB_exit(string event, int exitCode)
{
  DebugN("exit requested **************************+");
}

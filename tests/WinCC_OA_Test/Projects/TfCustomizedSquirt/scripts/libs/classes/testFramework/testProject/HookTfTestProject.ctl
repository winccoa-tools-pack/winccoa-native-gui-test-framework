//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright Copyright 2023 SIEMENS AG
             SPDX-License-Identifier: GPL-3.0-only
*/

//--------------------------------------------------------------------------------
// used libraries (#uses)
#uses "classes/testFramework/testProject/TfTestProject"

//--------------------------------------------------------------------------------
/*!
 * Hook class of TfTestProject:
   Changes here overrides TfTestProject workflow
 */
class HookTfTestProject : TfTestProject
{
//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

  protected dyn_string _getDefaultSubProjects()
  {
    dyn_string list = TfTestProject::_getDefaultSubProjects();
    dynAppend(list, "Squirt");
    return list;
  }

  protected int _afterCreate()
  {
    int rc = TfTestProject::_afterCreate();

    if (rc)
      return rc;

    if (this._forcePmonStart)
    {
      if (this.startPmon(/*autoStart*/ false) || this.waitUntilPmonIsRunning())
      {
        this._errorHandler.warning(tr("Cannot start pmon $2:$3 on the project '$1'").subst(this.getId(), this.getPmonHost(), this.getPmonPort()));
        return -1;
      }

      this._errorHandler.verbose(tr("Make project gedi less"));

      dyn_anytype managersData = getListOfManagerOptions();

      for (int i = 1; i <= managersData.count(); i++)
      {
        ProjEnvManagerOptions manager = managersData[i];

        // the default WinCC OA project contains gedi (IDE) which will login automatically
        // we need to disable this automatic login for test projects, otherwise the project will never reach
        // the monitoring state.

        // only in UI manager
        if ((manager.component == getComponentName(UI_COMPONENT)) &&
            // the manager is NOT already set to manual
            (manager.startMode != ProjEnvManagerStartMode::Manual) &&
            // has NO login options like '-user root:'
            (!manager.startOptions.contains("-user ")) &&
            // manager with -n option does not need login
            (!manager.startOptions.contains("-n")) &&
            // Gedi and Para promt login
            (manager.startOptions.contains("-m gedi") || manager.startOptions.contains("-m para"))
           )
        {
          manager.startMode = ProjEnvManagerStartMode::Manual;
          this._errorHandler.info(tr("Change manager start mode at index $2 to $3 on the project '$1'").subst(this.getId(), i + 1, manager.toStdOut()));
          this.changeManagerOptions(i - 1, manager);
        }

        // add -num 1 to ctrl manager '-f pvss_scripts.lst' start options
        if ((manager.component == getComponentName(CTRL_COMPONENT)) &&
            (manager.startOptions.contains("-f pvss_scripts.lst") && !manager.startOptions.contains("-num ")))
        {
          // this is more or less a issue in test code (configs)
          // to make the test projects more stable we add here -num 1, because the teams will not do it by themselves
          // later (in next versions) we can throw an error here to force the teams to fix their test projects in feature branches
          manager.startOptions += " -num 1";

          const string errText = tr("Add -num 1 to manager index $2 to $3 on the project '$1'").subst(this.getId(), i + 1, manager.toStdOut());

          // in both feature and production branches we log a warning and set test-assertion to fail to force the teams to fix their test projects
          this._errHdl.throwErr(makeError("", PRIO_WARNING, ERR_CONTROL, 54, errText));
          

          this.changeManagerOptions(i - 1, manager);
        }
      }

      if (this.stopPmon())
        return -1;
    }

    return 0;
  }
};

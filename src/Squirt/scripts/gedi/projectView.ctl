#uses "classes/oaTest/OaTestProjectView"
#uses "classes/hsp/HspScript"
#uses "classes/hsp/HspGediExt"
#uses "CTRLdebugger"
#uses "CtrlPv2Admin"

/**
TODO
"stolen" from HspScript.ctl, please provide changes only for GUI tests
*/

int dummyIntProjView = DebugN(__FILE__, __FUNCTION__, __LINE__, "DO NOT PUBLISH THIS FILE");


string sPanelsPath, sOldPath, sNewPath;
dyn_string dsDeviceClasses, dsIcons;
mapping mDeviceClassColumn, mDeviceClassInfo, deviceClassData;
dyn_bool dbShowColumn;

OaTestProjectView oaTestPv;

//--------------------------------------------------------------------------------

main()
{
  mapping mMenu;
  //***
  // popUp for file operations
  // add an option to the contextmenu to copy path to clipboard - setClipboardText()
  mMenu = makeMapping("icon", "", "inSubproject", TRUE, "filesOnly", FALSE);
  pvConnect("copyPathToClipboardText", getCatStr("gedi", "copyPathToClipboardText"), mMenu);

  // add an option to the contextmenu to copy path to clipboard - setClipboardText()
  mMenu = makeMapping("icon", "", "inSubproject", TRUE, "filesOnly", FALSE);
  pvConnect("copyRelPathToClipboardText", getCatStr("gedi", "copyRelPathToClipboardText"), mMenu);

  pvAddSeparator();

  if (isEvConnOpen())
  {
    oaTestPv.makeGediMenu();
    oaTestPv.makeTestColumns();
  }

  //***
  // popUp for examples
  mMenu = makeMapping("icon", "", "inSubproject", true, "filesOnly", TRUE, "category", "CAT_LIBS");
  pvAddSubMenu(getCatStr(HspGediExt::MSG_CAT, "examples"), "examples", mMenu);
  pvConnect("startScriptExample", getCatStr(HspGediExt::MSG_CAT, "startExample"), makeMapping("parent", "examples", "inSubproject", true));
  pvConnect("navigateToExample", getCatStr(HspGediExt::MSG_CAT, "navigateToExample"), makeMapping("parent", "examples", "category", "CAT_LIBS", "inSubproject", true));

  pvAddSeparator();

  pvConnect("startScript", getCatStr(HspGediExt::MSG_CAT, "startScript"), makeMapping("inSubproject", true, "filesOnly", TRUE, "category", "CAT_SCRIPTS"));

  if (!isEvConnOpen())
    return;

  if (!dpExists("_CtrlCommandInterface_oaTestPv"))
    dpCreate("_CtrlCommandInterface_oaTestPv", "_CtrlCommandInterface");

  if (!dpExists("_CtrlCommandInterface_scriptsState"))
    dpCreate("_CtrlCommandInterface_scriptsState", "_CtrlCommandInterface");

  dpConnect(oaTestPv, oaTestPv.reloadCb, FALSE, "_CtrlCommandInterface_oaTestPv.Command");

  // reload Project View when new deviceclass is available
  dpConnect("reload", "_UiDeviceMgmt.Name");

  //mapping for pvConnect
  mMenu = makeMapping("icon", "devicemanagement/new_panel_for_devices_plus_icon_20.png", "inSubproject", TRUE, "category", "CAT_PANELS", "filesOnly", TRUE);

  // add an option to the contextmenu to copy panels to a deviceclass
  pvConnect("DeviceClass_addPanel", getCatStr("deviceManager", "deviceclass_MenuEntry"), mMenu);

  //Add two uiConnect to detect renamings and rename device class panls
  uiConnect("renamePanels_newPath", "fileAdded");
  uiConnect("renamePanels_oldPath", "fileRemoved");
}


int startTest(string fileName, bool noWarnings = FALSE)
{
  return _startTest(fileName, noWarnings, false);
}

int startGuiTest(string fileName, bool noWarnings = FALSE)
{
  return _startTest(fileName, noWarnings, true);
}

//------------------------------------------------------------------------------
/**
 * @brief Function start the unit test for currently openned ctrl-script.
 * @param fileName full path to selected file.
 * @param noWarnings if warning messages should be suppressed, default: FALSE
 * @return Error code. Returns 0 when successfull. Otherwise -1.
 */
private int _startTest(string fileName, bool noWarnings, bool guiTest)
{
  DebugTN(__FUNCTION__, fileName, noWarnings, guiTest);
  HspScript myScript;
  myScript.guiTest = guiTest;
  myScript.setFilePath(makeNativePath(fileName));

  // is not a script or has 0 size
  if ((myScript.getFilePath() == "") || myScript.isNewFile())
  {
    if (!noWarnings)
      warningPopup(makeError("hsp_errors", PRIO_WARNING, ERR_CONTROL, 1, getCatStr(HspGediExt::MSG_CAT, guiTest ? "guiTests" : "unitTests")));

    return -1;
  }

  // check and remove extra "tests/"
  string unitTestPath = guiTest ? myScript.getGuiTestRelPath() : makeDynString(myScript.getUnitTestRelPath());


    if (unitTestPath.startsWith("tests/tests/") && getPath(SCRIPTS_REL_PATH, unitTestPath) == "")
      unitTestPath.remove(0, strlen("tests/"));

    // stop script if it is running
    if (myScript.isRunning(unitTestPath))
    {
      myScript.stopRunningScript(unitTestPath);
      return 0;
    }


  int err;


  if (guiTest)
  {
    if (myScript.guiTestExist())
    {
      err = myScript.startGuiTests();
      return err;
    }
    else if (myScript.isPartOf(PANELS_REL_PATH))
    {
      if (!noWarnings)
        warningPopup(makeError("hsp_errors", PRIO_WARNING, ERR_CONTROL, 2, getCatStr(HspGediExt::MSG_CAT, "guiTests")));

      return -1;
    }

    // if test script is in the scripts/tests/ repo
    if (myScript.isPartOf(SCRIPTS_REL_PATH + "tests/splash/"))
    {
      err = myScript.startGuiTests(makeDynString(substr(myScript.getFileRelPath(), strlen(SCRIPTS_REL_PATH))));
    }
    else if (!noWarnings)
    {
      err = -1;
      warningPopup(makeError("hsp_errors", PRIO_WARNING, ERR_CONTROL, 3, getCatStr(HspGediExt::MSG_CAT, "guiTests"), "scripts/tests/"));
    }
  }

  else
  {
    // if test script exists for the file
    if (myScript.unitTestExist())
    {
      err = myScript.startUnitTest();
      return err;
    }
    else if (myScript.isPartOf(LIBS_REL_PATH))
    {
      if (!noWarnings)
        warningPopup(makeError("hsp_errors", PRIO_WARNING, ERR_CONTROL, 2, getCatStr(HspGediExt::MSG_CAT, guiTest ? "guiTests" : "unitTests")));

      return -1;
    }

    // if test script is in the scripts/tests/ repo
    if (myScript.isPartOf(SCRIPTS_REL_PATH + "tests/"))
    {
      err = myScript.startUnitTest(substr(myScript.getFileRelPath(), strlen(SCRIPTS_REL_PATH)));
    }
    else if (!noWarnings)
    {
      err = -1;
      warningPopup(makeError("hsp_errors", PRIO_WARNING, ERR_CONTROL, 3, getCatStr(HspGediExt::MSG_CAT, guiTest ? "guiTests" : "unitTests"), "Scripts/tests/"));
    }
  }

  return err;
}


void startTestRecursive(string dirPath)
{
  _startTestRecursive(dirPath, false);
}

void startGuiTestRecursive(string dirPath)
{
  _startTestRecursive(dirPath, true);
}

//------------------------------------------------------------------------------
/**
 * @brief Function start the unit test recursive to the directory.
 * @param dirPath full path to selected file.
 */
void _startTestRecursive(string dirPath, const bool guiTest)
{
  // if function is called from the directory
  if (!isdir(dirPath))
  {
    warningPopup(makeError("hsp_errors", PRIO_WARNING, ERR_CONTROL, 4, getCatStr(HspGediExt::MSG_CAT, guiTest ? "guiTests" : "unitTests")));
    return;
  }

  OaTestProjectView::showSUT(dirPath);
  dyn_string dirs = getFileNames(dirPath, "*", FILTER_DIRS);
  dyn_string files = getFileNames(dirPath,  "*", FILTER_FILES);

  int err;

  for (int i = 1; i <= dynlen(files); i++)
  {
    err = _startTest(dirPath + "/" + files[i], false, guiTest);

    if (err)
    {
      OaTestProjectView::hideSUT(dirPath);
      return;
    }
  }

  for (int i = 1; i <= dynlen(dirs); i++)
  {
    const string dir = dirs[i];

    if ((dir == "") || (dir == ".") || (dir == ".."))
      continue;

    _startTestRecursive(dirPath + "/" + dir, guiTest);
  }

  OaTestProjectView::hideSUT(dirPath);
}


//------------------------------------------------------------------------------
/**
 * @brief Function navigate user to the unit test script for currently openned ctrl-script.
 *
 * Creates new unit test in when does not exist.
 * @param fileName full path to selected file.
 */
void navigateToTest(string fileName)
{
  HspScript myScript;
  myScript.setFilePath(makeNativePath(fileName));

  if (myScript.getFilePath() == "")
    return; // is not script (panel??? or invalid call)

  if (!myScript.unitTestExist())
    myScript.createUnitTest();

  if (!myScript.unitTestExist())
    return;

  string s;
  scriptEditor(s, myScript.getUnitTestFullPath());
}



//------------------------------------------------------------------------------
/**
 * @brief Function navigate user to the unit test script for currently openned ctrl-script.
 *
 * Creates new unit test in when does not exist.
 * @param fileName full path to selected file.
 */
void navigateToGuiTest(string fileName)
{
  HspScript myScript;
  myScript.setFilePath(makeNativePath(fileName));

  if (myScript.getFilePath() == "")
    return; // is not script (panel??? or invalid call)

//   if (!myScript.guiTestExist())
//     myScript.createGuiTest();

  if (!myScript.guiTestExist())
    return;

  dyn_string pathes = myScript.getGuiTestFullPaths();

  for(int i = 0; i < pathes.count(); i++)
  {
    startThread("_scriptEditor", pathes.at(i));
  }
}

//------------------------------------------------------------------------------
private void _scriptEditor(const string &path)
{
  string s;
  scriptEditor(s, path);
}

//------------------------------------------------------------------------------
/**
 * @brief Function start the example for currently openned ctrl-script.
 * @param fileName full path to selected file.
 */
void startScriptExample(string fileName)
{
  HspScript myScript;
  myScript.setFilePath(makeNativePath(fileName));

  if (myScript.getFilePath() == "")
    return; // is not script (panel??? or invalid call)

  // if this is an empty file
  if (myScript.isNewFile())
  {
    warningPopup(makeError("hsp_errors", PRIO_WARNING, ERR_CONTROL, 1, getCatStr(HspGediExt::MSG_CAT, "examples")));
    return;
  }

  // stop script if it is running
  if (myScript.isRunning(myScript.getExampleRelPath()))
  {
    myScript.stopRunningScript(myScript.getExampleRelPath());
    return;
  }

  // if an example exist
  if (myScript.exampleExist())
  {
    myScript.startExample();
    return;
  }
  else if (myScript.isPartOf(LIBS_REL_PATH))
  {
    warningPopup(makeError("hsp_errors", PRIO_WARNING, ERR_CONTROL, 2, getCatStr(HspGediExt::MSG_CAT, "examples")));
    return;
  }
}

//------------------------------------------------------------------------------
/**
 * @brief Function navigate user to the example script for currently openned ctrl-script.
 *
 * Creates new example in when does not exist.
 * @param fileName full path to selected file.
 */
void navigateToExample(string fileName)
{
  HspScript myScript;
  myScript.setFilePath(makeNativePath(fileName));

  if (myScript.getFilePath() == "")
    return; // is not script (panel??? or invalid call)

  if (!myScript.exampleExist())
    myScript.createExample();

  if (!myScript.exampleExist())
    return;

  string s;
  scriptEditor(s, myScript.getExampleFullPath());
}

//------------------------------------------------------------------------------
/**
 * @brief Function starts the main script routine for the selected ctrl-script file.
 * @param fileName full path to selected file.
 */
void startScript(string fileName)
{
  HspScript myScript;
  myScript.setFilePath(makeNativePath(fileName));

  if ((myScript.getFilePath() == "") || !myScript.isPartOf(SCRIPTS_REL_PATH))
    return;  // is not a script or not in the scripts/

  // stop script if it is running
  if (myScript.isRunning(fileName))
  {
    myScript.stopRunningScript(fileName);
    return;
  }

  // if this is an empty file
  if (myScript.isNewFile())
  {
    warningPopup(makeError("hsp_errors", PRIO_WARNING, ERR_CONTROL, 5));
    return;
  }

  myScript.startExample(myScript.getFilePath());
}

//--------------------------------------------------------------------------------
/** @brief Function copyed selected path to clipboard text

 * @param fileName full path to selected file.
*/
void copyPathToClipboardText(string fileName)
{
  setClipboardText(makeNativePath(fileName));
}

//--------------------------------------------------------------------------------
/** @brief Function copyed selected relative path to clipboard text

 * @param fileName full path to selected file.
*/
void copyRelPathToClipboardText(string fileName)
{
  setClipboardText(ctrlDbgPu_getRelPath(fileName));
}

//-------------------------------------------------------------------

DeviceClass_addPanel(string filename)
{
  openDialog("vision/CreateDeviceClassPanel.pnl", makeDynString("$bCopy:TRUE", "$sFile:" + filename));
}

//-------------------------------------------------------------------

checkDeviceClassPanels(string sPanelPath, string sFolder = "")
{
  dyn_string dsDeviceClasses, dsPanels, dsDeviceClassPanels, dsFolder;
  string sPanelsPath;

  // get Panels and Folder
  dsPanels = getFileNamesRev(sPanelPath, "*.bak");
  dsFolder = getFileNamesRev(sPanelPath, ".*", FILTER_DIRS);

  sPanelsPath = getPath(PANELS_REL_PATH);

  if (!mappingHasKey(deviceClassData, "deviceClassName"))
  {
    reloadDeviceClassDataMap("", "");
  }

  dsDeviceClasses = deviceClassData["deviceClassName"];
  dsIcons = deviceClassData["deviceClassIcon"];
  dbShowColumn = deviceClassData["shownColumn"];

  // check for each panel if it is aviable for the deviceclasses
  for (int j = 1; j <= dynlen(dsDeviceClasses); j++)
  {
    dynClear(dsDeviceClassPanels);
    dsDeviceClassPanels = getFileNamesRev(sPanelsPath + "deviceClass/" + dsDeviceClasses[j] + "/portrait/" + sFolder, "*.bak");
    dynAppend(dsDeviceClassPanels, getFileNamesRev(sPanelsPath + "deviceClass/" + dsDeviceClasses[j] + "/landscape/" + sFolder, "*.bak"));
    dynAppend(dsDeviceClassPanels, getFileNamesRev(sPanelsPath + "deviceClass/" + dsDeviceClasses[j] + sFolder, "*.bak"));

    for (int i = 1; i <= dynlen(dsPanels); i++)
    {
      if (dynContains(dsDeviceClassPanels, dsPanels[i]) == 0)
      {
        pvSetItemText(sPanelPath + dsPanels[i], mDeviceClassColumn[dsDeviceClasses[j]], "");
        continue; // probably here we need to remove the content (set "")
      }

      //Case: At least on Panel avialable -> Set Icon in Class Column
      pvSetItemText(sPanelPath + dsPanels[i], mDeviceClassColumn[dsDeviceClasses[j]], "", dsIcons[j]);
    }
  }

  //do it recursive
  for (int i = 1; i <= dynlen(dsFolder); i++)
  {
    if (dsFolder[i] == "deviceClass")
      continue;

    checkDeviceClassPanels(sPanelPath + dsFolder[i] + "/", sFolder + "/" + dsFolder[i]);
  }
}

//-------------------------------------------------------------------

void updatePvColumns()
{
  // IM 119737: Do not remove the user columns
  // pvRemoveAllUserColumns();

  mapping m;
  int count = 1;
  sPanelsPath = getPath(PANELS_REL_PATH);

  dsDeviceClasses = deviceClassData["deviceClassName"];
  dsIcons = deviceClassData["deviceClassIcon"];
  dbShowColumn = deviceClassData["shownColumn"];

  for (int i = 1; i <= dynlen(dsDeviceClasses); i++)
  {
    if (dsIcons[i] != "---")
    {
      //Case: Wenn kein icon vorhanden ist
      m = makeMapping("icon", dsIcons[i], "doubleClicked", "DeviceClass_openPanel", "rightMousePressed", "DeviceClass_contextMenu", "visualIndex", count, "resizeMode", "ResizeToContents");

      //IM 119737: check before inserting
      if (!mappingHasKey(mDeviceClassColumn, dsDeviceClasses[i]))
        mDeviceClassColumn[dsDeviceClasses[i]] = pvAddColumn("", m);  // Fehlermeldung jedoch kein Fehlergrund
    }
    else
    {
      m = makeMapping("doubleClicked", "DeviceClass_openPanel", "rightMousePressed", "DeviceClass_contextMenu", "visualIndex", count);

      //IM 119737: check before inserting
      if (!mappingHasKey(mDeviceClassColumn, dsDeviceClasses[i]))
        mDeviceClassColumn[dsDeviceClasses[i]] = pvAddColumn(dsDeviceClasses[i], m);
    }

    count++;
  }

  // Since it is not possible to remove single columns, use visibility instead.
  // This has to be done after the last call to pvAddColumn(), because the projectView
  // tries to restore its settings (including column visibility) after each call to
  // pvAddColumn()
  for (int i = 1; i <= dynlen(dsDeviceClasses); i++)
  {
    m = makeMapping("visible", dbShowColumn[i]);
    pvSetColumnProperties(mDeviceClassColumn[dsDeviceClasses[i]], m);
  }
}

//-------------------------------------------------------------------

synchronized reload(string userData, string val)
{
  // always reload device data (had a separate dpConnect before)
  reloadDeviceClassDataMap("", "");
  updatePvColumns();
  checkDeviceClassPanels(sPanelsPath);
}

//-------------------------------------------------------------------

DeviceClass_contextMenu(string filename, int column = 2)
{
  string  sClassname, sPanelPath, sPanelPath_r, sPanelPath_l, sPanelPath_p;
  dyn_string dsMenuText, dsPathSplit, dsFileName;
  int x, y, iAnswer;
  int il = 0, ip = 0;

  strreplace(filename, "\\", "/");
  dsPathSplit = strsplit(filename, "/");

  for (int i = 1; i <= dynlen(dsDeviceClasses); i++)
  {
    if (mDeviceClassColumn[dsDeviceClasses[i]] == column)
    {
      sClassname = dsDeviceClasses[i];
    }
  }

  sPanelPath_l = DeviceClass_getPath(filename, sClassname, "landscape");
  sPanelPath_p = DeviceClass_getPath(filename, sClassname, "portrait");

  // check if selected panel is available for the deviceclass

  if (sPanelPath_l != "")
    il = 1;

  if (sPanelPath_p != "")
    ip = 1;

  getCursorPosition(x, y, TRUE);

  if ((il + ip) != 0)
  {
    // create Context(Popup) Menu for the deviceclass Icons
    popupMenuXY(makeDynString("PUSH_BUTTON, " + getCatStr("deviceManager", "deviceclass_open") + " landscape, 1," + il,
                              "PUSH_BUTTON, " + getCatStr("deviceManager", "deviceclass_open") + " portrait, 2," + ip,
                              "SEPARATOR",
                              "PUSH_BUTTON, " + getCatStr("deviceManager", "deviceclass_delete") + " landscape, 3," + il,
                              "PUSH_BUTTON, " + getCatStr("deviceManager", "deviceclass_delete") + " portrait, 4," + ip,
                              "PUSH_BUTTON, " + getCatStr("deviceManager", "deviceclass_deleteall") + ", 5, 1"), x, y, iAnswer);

    switch (iAnswer)
    {
      // open Panel
      case 1: sPanelPath = getPath(PANELS_REL_PATH) + sPanelPath_l;
        RootPanelOnModule(sPanelPath, "2", "Gedi_" + myUiNumber(), makeDynString());
        break;

      case 2: sPanelPath = getPath(PANELS_REL_PATH) + sPanelPath_p;
        RootPanelOnModule(sPanelPath, "2", "Gedi_" + myUiNumber(), makeDynString());
        break;

      // delete Panel
      case 3: sPanelPath = getPath(PANELS_REL_PATH) + sPanelPath_l;
        remove(sPanelPath);
        break;

      case 4: sPanelPath = getPath(PANELS_REL_PATH) + sPanelPath_p;
        remove(sPanelPath);
        break;

      // delete all Panels
      case 5: sPanelPath_l = getPath(PANELS_REL_PATH) + sPanelPath_l;
        sPanelPath_p = getPath(PANELS_REL_PATH) + sPanelPath_p;

        if (isfile(sPanelPath_l))
        {
          remove(sPanelPath_l);
        }

        if (isfile(sPanelPath_p))
        {
          remove(sPanelPath_p);
        }

        break;

      default: break;
    }
  }
}

//-------------------------------------------------------------------

DeviceClass_openPanel(string filename, int column = 2)
{
  dyn_string dsPathSplit;
  string sPanelPath_l, sPanelPath_p, sPanelPath_f, sClassname;

  // get selected deviceclass
  for (int i = 1; i <= dynlen(dsDeviceClasses); i++)
  {
    if (mDeviceClassColumn[dsDeviceClasses[i]] == column)
    {
      sClassname = dsDeviceClasses[i];
    }
  }

  // add classname to the path ( also landscape or portrait )
  sPanelPath_l = sPanelPath_l + "deviceClass/" + sClassname + "/landscape";
  sPanelPath_p = sPanelPath_p + "deviceClass/" + sClassname + "/portrait";
  sPanelPath_f = sPanelPath_f + "deviceClass/" + sClassname ;

  strreplace(filename, "\\", "/");
  dsPathSplit = strsplit(filename, "/");

  //create remaining Path
  for (int i = dynlen(dsPathSplit); i >= 1; i--)
  {
    if (dsPathSplit[i] == "landscape" || dsPathSplit[i] == "portrait")
    {
      for (int j = i + 1; j <= dynlen(dsPathSplit); j++)
      {
        sPanelPath_l = sPanelPath_l + "/" + dsPathSplit[j];
        sPanelPath_p = sPanelPath_p + "/" + dsPathSplit[j];
        sPanelPath_f = sPanelPath_f + "/" + dsPathSplit[j];
      }

      break;
    }

    if (dsPathSplit[i] == "deviceClass")
    {
      for (int j = i + 2; j <= dynlen(dsPathSplit); j++)
      {
        sPanelPath_l = sPanelPath_l + "/" + dsPathSplit[j];
        sPanelPath_p = sPanelPath_p + "/" + dsPathSplit[j];
        sPanelPath_f = sPanelPath_f + "/" + dsPathSplit[j];
      }

      break;
    }

    if (dsPathSplit[i] == "panels")
    {
      for (int j = i + 1; j <= dynlen(dsPathSplit); j++)
      {
        sPanelPath_l = sPanelPath_l + "/" + dsPathSplit[j];
        sPanelPath_p = sPanelPath_p + "/" + dsPathSplit[j];
        sPanelPath_f = sPanelPath_f + "/" + dsPathSplit[j];
      }

      break;
    }
  }

  // open panels if availabel
  if (isfile(getPath(PANELS_REL_PATH) + sPanelPath_l))
    RootPanelOnModule(sPanelPath_l, "2", myModuleName(), makeDynString());

  if (isfile(getPath(PANELS_REL_PATH) + sPanelPath_p))
    RootPanelOnModule(sPanelPath_p, "3", myModuleName(), makeDynString());

  if (isfile(getPath(PANELS_REL_PATH) + sPanelPath_f))
    RootPanelOnModule(sPanelPath_f, "3", myModuleName(), makeDynString());
}

//-------------------------------------------------------------------

string DeviceClass_getPath(string filename, string sClassname, string location)
{
  dyn_string dsPathSplit;
  string sPanelPath_l, sPanelPath_p, sPanelPath_f;

  sPanelPath_l = sPanelPath_l + "deviceClass/" + sClassname + "/landscape";
  sPanelPath_p = sPanelPath_p + "deviceClass/" + sClassname + "/portrait";
  sPanelPath_f = sPanelPath_f + "deviceClass/" + sClassname;

//   strreplace(filename,"\\","/");
  dsPathSplit = strsplit(filename, "/");

  for (int i = dynlen(dsPathSplit); i >= 1; i--)
  {
    if (dsPathSplit[i] == "landscape" || dsPathSplit[i] == "portrait")
    {
      for (int j = i + 1; j <= dynlen(dsPathSplit); j++)
      {
        sPanelPath_l = sPanelPath_l + "/" + dsPathSplit[j];
        sPanelPath_p = sPanelPath_p + "/" + dsPathSplit[j];
        sPanelPath_f = sPanelPath_f + "/" + dsPathSplit[j];
      }

      break;
    }

    if (dsPathSplit[i] == "deviceClass")
    {
      for (int j = i + 2; j <= dynlen(dsPathSplit); j++)
      {
        sPanelPath_l = sPanelPath_l + "/" + dsPathSplit[j];
        sPanelPath_p = sPanelPath_p + "/" + dsPathSplit[j];
        sPanelPath_f = sPanelPath_f + "/" + dsPathSplit[j];
      }

      break;
    }

    if (dsPathSplit[i] == "panels")
    {
      for (int j = i + 1; j <= dynlen(dsPathSplit); j++)
      {
        sPanelPath_l = sPanelPath_l + "/" + dsPathSplit[j];
        sPanelPath_p = sPanelPath_p + "/" + dsPathSplit[j];
        sPanelPath_f = sPanelPath_f + "/" + dsPathSplit[j];
      }

      break;
    }
  }

  switch (location)
  {
    case "root":
      if (isfile(getPath(PANELS_REL_PATH) + sPanelPath_f))
        return sPanelPath_f;
      else
        return "";

    case "landscape":
      if (isfile(getPath(PANELS_REL_PATH) + sPanelPath_l))
        return sPanelPath_l;
      else
        return "";

    case "portrait":
      if (isfile(getPath(PANELS_REL_PATH) + sPanelPath_p))
        return sPanelPath_p;
      else
        return "";
  }
}

//-------------------------------------------------------------------

void startDialog(dyn_string dsPathElements, int iPos)
{
  string sText = getCatStr("deviceManager", "delete_rootpanel");
  strreplace(sText, "$1", dsPathElements[dynlen(dsPathElements)]);
  strreplace(sText, "$2", dsPathElements[iPos + 1]);

  openDialog("vision/MessageDevice", makeDynString("$1:" + sText,
             "$2:" + getCatStr("general", "yes"),
             "$3:" + getCatStr("general", "no")));
}

//-------------------------------------------------------------------

synchronized renamePanels_newPath(string Path)
{
  sNewPath = Path;

  if (sOldPath != "")
  {
    int iPos = 0;
    sNewPath = makeUnixPath(sNewPath);

    iPos = strpos(sNewPath, "deviceClass");

    if (iPos == -1)
    {
      renameDeviceclassPanels(baseName(sOldPath), baseName(sNewPath));
      renameDeviceclassImagesFolders(baseName(sOldPath), baseName(sNewPath));
    }

    sNewPath = "";
    sOldPath = "";
  }

  reloadItem(Path, "add");
}

//-------------------------------------------------------------------

synchronized renamePanels_oldPath(string Path)
{
  sOldPath = Path;

  if (sNewPath != "")
  {
    int iPos = 0;
    sNewPath = makeUnixPath(sNewPath);

    iPos = strpos(sNewPath, "deviceClass");

    if (iPos == -1)
    {
      renameDeviceclassPanels(baseName(sOldPath), baseName(sNewPath));
      renameDeviceclassImagesFolders(baseName(sOldPath), baseName(sNewPath));
    }
  }

  sNewPath = "";
  sOldPath = "";

  reloadItem(Path, "del");
}

//-------------------------------------------------------------------

dyn_string getPathsRecursive(string keyword, string filename, int langId = 1)
{
  dyn_string dsFilePaths, dsFolder, dsTemp;
  dsFolder = getFileNamesRev(getPath(keyword), ".*", FILTER_DIRS);

  dsTemp = getPath(keyword, filename);

  if (dsTemp != "") dynAppend(dsFilePaths, dsTemp);

  for (int i = 1; i <= dynlen(dsFolder); i++)
  {
    dsTemp = getPathsRecursive(keyword + dsFolder[i] + "/", filename, langId);

    if (dsTemp != "") dynAppend(dsFilePaths, dsTemp);
  }

  return dsFilePaths;
}

//-------------------------------------------------------------------

int renameDeviceclassPanels(string oldFileName, string newFileName)
{
  dyn_string dsFilePaths;
  string sNewFilePath;

  dsFilePaths = getPathsRecursive(PANELS_REL_PATH + "deviceClass/", newFileName);

  if (dynlen(dsFilePaths) < 0)
    return -1;

  dsFilePaths = getPathsRecursive(PANELS_REL_PATH + "deviceClass/", oldFileName);

  for (int i = 1; i <= dynlen(dsFilePaths); i++)
  {
    sNewFilePath = dsFilePaths[i];
    strreplace(sNewFilePath, oldFileName, newFileName);
    rename(dsFilePaths[i], sNewFilePath);
  }

  return dynlen(dsFilePaths);
}

//-------------------------------------------------------------------

int renameDeviceclassImagesFolders(string oldFileName, string newFileName)
{
  dyn_string dsFilePaths;
  string sNewFilePath;

  dsFilePaths = getPathsRecursive(IMAGES_REL_PATH + "deviceClass/", newFileName);

  if (dynlen(dsFilePaths) < 0)
    return -1;

  dsFilePaths = getPathsRecursive(IMAGES_REL_PATH + "deviceClass/", oldFileName);

  for (int i = 1; i <= dynlen(dsFilePaths); i++)
  {
    sNewFilePath = dsFilePaths[i];
    strreplace(sNewFilePath, oldFileName, newFileName);
    rename(dsFilePaths[i], sNewFilePath);
  }

  return dynlen(dsFilePaths);
}

//-------------------------------------------------------------------

synchronized reloadDeviceClassDataMap(string userData, string val)
{
  dyn_string dsDeviceClasses, dsIcons;
  dyn_bool dbShowColumn;

  int iReturn = dm_updateDeviceClasses(dsDeviceClasses, dsIcons, dbShowColumn);

  deviceClassData = makeMapping("deviceClassName", dsDeviceClasses, "deviceClassIcon", dsIcons, "shownColumn", dbShowColumn);
}


/*------------------------------------------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  @name   : dm_updateDeviceClasses()
  @author : Leopold Knipp
  @Desc   : TFS 57325
  @Notes  : update original values for _UiDeviceMgmt.ShowColumn
  @return : OK = 0, Error = -1
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/
int dm_updateDeviceClasses(dyn_string &dsClassNames, dyn_string &dsIcons, dyn_bool &dbVisibleColumns)
{
  dyn_errClass decError;
  int i;

  // get the current configuration for device classes and visible columns
  dpGet("_UiDeviceMgmt.Name", dsClassNames,
        "_UiDeviceMgmt.Icon", dsIcons,
        "_UiDeviceMgmt.ShowColumn", dbVisibleColumns);

  // check if device classes are defined
  if (dynlen(dsClassNames) > 0)
  {
    // check if an icon is defined for every class
    if (dynlen(dsIcons) != dynlen(dsClassNames))
    {
      // set a default icon "Desktop-UI" as default if none is defined
      for (i = 1; i <= dynlen(dsClassNames); i++)
      {
        if (i > dynlen(dsIcons))
          dsIcons[i] = "wf/icons/phone_portrait_as_button.png";
      }

      dpSetWait("_UiDeviceMgmt.Icon", dsIcons);
    }

    // check the settings for the visible columns
    if (dynlen(dbVisibleColumns) != dynlen(dsClassNames))
    {
      // set all device classes visible by default
      for (i = 1; i <= dynlen(dsClassNames); i++)
      {
        if (i > dynlen(dbVisibleColumns))
          dbVisibleColumns[i] = 1;
      }

      dpSetWait("_UiDeviceMgmt.ShowColumn", dbVisibleColumns);
      decError = getLastError();

      if (dynlen(decError) > 0)
        return -1;
      else
        return 0;
    }
    else
      return 1;
  }
  else
    return 2;
}


//-------------------------------------------------------------------

checkDeviceClassItem(string sPanelPath, string operation)
{
  if (substr(sPanelPath, strlen(sPanelPath) - 4, 4) == ".bak")
    return;

  dyn_string dsDeviceClasses, dsDeviceClassPanels;
  string sPanelsPath, dsPanels, sFolder;

  sPanelPath = makeUnixPath(sPanelPath); // TFS 34281
  dsPanels = sPanelPath;
  sPanelsPath = getPath(PANELS_REL_PATH); // returns path in Unix style

  if (!mappingHasKey(deviceClassData, "deviceClassName"))
  {
    reloadDeviceClassDataMap("", "");
  }

  dsDeviceClasses = deviceClassData["deviceClassName"];
  dsIcons = deviceClassData["deviceClassIcon"];
  dbShowColumn = deviceClassData["shownColumn"];

  for (int j = 1; j <= dynlen(dsDeviceClasses); j++)
  {
    dynClear(dsDeviceClassPanels);
    string src = "deviceClass/" + dsDeviceClasses[j] + "/portrait/";

    if (strpos(dsPanels, src) == -1)
    {
      src = "deviceClass/" + dsDeviceClasses[j] + "/landscape/";
    }

    sFolder = substr(dsPanels, (strpos(dsPanels, src) + strlen(src)));
    dsDeviceClassPanels = getFileNamesRev(sPanelsPath + "deviceClass/" + dsDeviceClasses[j] + "/portrait/" + sFolder, "*.bak");
    dynAppend(dsDeviceClassPanels, getFileNamesRev(sPanelsPath + "deviceClass/" + dsDeviceClasses[j] + "/landscape/" + sFolder, "*.bak"));

    dyn_string str1 = strsplit(sFolder, "/");
    int lengthStr1 = dynlen(str1);
    string fileName = (lengthStr1 > 0) ? str1[lengthStr1] : ""; // TFS 34281

    if (isfile(sPanelsPath + sFolder) && (operation == "add"))
    {
      pvSetItemText(sPanelsPath + sFolder, mDeviceClassColumn[dsDeviceClasses[j]], "", dsIcons[j]);
    }
    else if (isfile(sPanelsPath + sFolder) &&
             (operation == "del") &&
             (dynCount(dsDeviceClassPanels, fileName) == 0))
    {
      pvSetItemText(sPanelsPath + sFolder, mDeviceClassColumn[dsDeviceClasses[j]], "");
    }
  }
}

//-------------------------------------------------------------------

synchronized reloadItem(string userData, string val)
{
  if (!mappingHasKey(deviceClassData, "deviceClassName"))
  {
    reloadDeviceClassDataMap("", "");
  }

  updatePvColumns();
  checkDeviceClassItem(userData, val);
}

//------------------------------------------------------------------------------
/**
  @brief Function which opens warning popup window
  @param err is an error to be shown
*/
private warningPopup(const errClass &err)
{
  if (getErrorText(err) == "")
    return;

  ModuleOnWithPanel(getCatStr("general", "warning"), -1, -1, 0, 0, 1, 1, "None", "vision/MessageWarning", "", makeDynString(getErrorText(err)));
}

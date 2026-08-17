//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright Copyright 2023 SIEMENS AG
             SPDX-License-Identifier: GPL-3.0-only
*/

/*!
 * @brief Tests for lib: fileSys
 *
 * @author lschopp
 */

//--------------------------------------------------------------------------------
// used libraries (#uses)
#uses "fileSys" /*!< tested object */
#uses "classes/oaTest/OaTest"

//--------------------------------------------------------------------------------
class TstFileSys : OaTest
{
  public dyn_string getAllTestCaseIds()
  {
    // list with our testcases
    return makeDynString("fileSys getFileNamesRecursive");
  }

  public int testFileSysOPerations()
  {
    fclose(fopen(PROJ_PATH + LIBS_REL_PATH + "dummy.ctl", "w"));
    this.assertEqual(getFileNamesRecursive(""), makeDynString());
    this.assertEqual(getFileNamesRecursive("non existin path"), makeDynString());
    this.assertEqual(dynlen(getFileNamesRecursive(PROJ_PATH + PANELS_REL_PATH, "panel*")), 0);
    this.assertEqual(dynlen(getFileNamesRecursive(PROJ_PATH + LIBS_REL_PATH, "*.ctl", FILTER_DIRS)), 0);
    this.assertEqual(getFileNamesRecursive(PROJ_PATH + LIBS_REL_PATH, "*.ctl"), makeDynString(makeNativePath(PROJ_PATH + LIBS_REL_PATH + "dummy.ctl")));
    return 0;
  }
};

//--------------------------------------------------------------------------------
main()
{
  TstFileSys test;
  test.startAll();
}

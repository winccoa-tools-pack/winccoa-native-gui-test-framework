//------------------------------------------------------------------------------
/*!
 */

// Libraries used (#uses)
#uses "classes/doxygen/DoxygenCtrlExt"
#uses "classes/doxygen/DoxygenGenerator"

//--------------------------------------------------------------------------------
/**
*/
main(const string &companyName)
{
  GlobalStorage storage;
  storage.setValue("doxygen/advancedConfig", 1);
  storage.setValue("company/name", companyName);

  DoxygenGenerator doxy;
  doxy.createAll();

  // // Register and open the Online Help.
  // OnlineHelp help;
  // DoxygenSettings doxySettings;
  // help.adjustReferences(doxySettings.getOutputDirectory());
  // help.generateCustomHelp(doxySettings.getOutputDirectory());

  // if (myManType() == UI_MAN)
  // {
  //   help.open(doxySettings.getVirtualFolder() + "/index.html", "", doxySettings.getQhpNameSpace());
  //   // delay(30);
  //   // exit(0);
  // }
}

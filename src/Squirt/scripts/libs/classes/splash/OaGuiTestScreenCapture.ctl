// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author atw12ru2
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)

//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  @brief Captures screenshots from the current test panel.
  @AIgeneratedHelpContent
*/
class OaGuiTestScreenCapture
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------
  /** Active panel shape used for capture requests. */
  public shape/*<"PANEL">*/ currentPanel = 0;

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public OaGuiTestScreenCapture(const string testCaseId = "")
  {
    this.testCaseId = testCaseId;
  }

  //------------------------------------------------------------------------------
  /**
    @brief Deletes all captures for the current test case.
  */
  public clearCaptures()
  {
    rmdir(this.getImagesDir(), true);

    string rootDir = dirName(this.getImagesDir());
    dyn_string rootCaptures = getFileNames(rootDir);

    for(int i = 1; i <= rootCaptures.count(); i++)
    {
      remove(rootDir + rootCaptures[i]);
    }
  }

  //------------------------------------------------------------------------------
  /**
    @brief Stores a screenshot of the current panel.
    @param suffix File name suffix, for example latest-success.
  */
  public void takeScreen(const string &suffix)
  {
    if (!shapeExists(currentPanel))
      return;

    if (!isdir(getImagesDir()))
      mkdir(getImagesDir());

    imagePath = getImagesDir() + suffix + ".png";

    if (isfile(imagePath))
      remove(imagePath);

    setValue(currentPanel, "imageToFile",  imagePath);
  }

  //------------------------------------------------------------------------------
  /**
    @brief Logs the latest capture path as an informational message.
  */
  public void printLastLocation()
  {
    throwError(makeError("", PRIO_INFO, ERR_CONTROL, 0, tr("Current panel has been captured into $1").subst(imagePath)));
  }


//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------
  /** Relative test case path used to organize captures. */
  protected string testCaseId;
  /** Absolute path of the latest created image. */
  protected string imagePath;

  //------------------------------------------------------------------------------
  /**
    @brief Returns the capture directory for the current test case.
    @return Absolute directory path.
  */
  protected string getImagesDir()
  {
    return PROJ_PATH + DATA_REL_PATH + "splash/captures/" + testCaseId + "/";
  }

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------

};

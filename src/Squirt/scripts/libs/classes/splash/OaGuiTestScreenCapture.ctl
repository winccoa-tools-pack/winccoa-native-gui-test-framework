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
*/
class OaGuiTestScreenCapture
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------
  public shape/*<"PANEL">*/ currentPanel = 0;

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public OaGuiTestScreenCapture(const string testCaseId = "")
  {
    this.testCaseId = testCaseId;
  }

  //------------------------------------------------------------------------------
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
  public void printLastLocation()
  {
    throwError(makeError("", PRIO_INFO, ERR_CONTROL, 0, tr("Current panel has been captured into $1").subst(imagePath)));
  }


//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------
  protected string testCaseId;
  protected string imagePath;

  //------------------------------------------------------------------------------
  protected string getImagesDir()
  {
    return PROJ_PATH + DATA_REL_PATH + "splash/captures/" + testCaseId + "/";
  }

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------

};

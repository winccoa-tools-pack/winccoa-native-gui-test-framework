// $License: NOLICENSE
//-----------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author $author
*/

//-----------------------------------------------------------------------------
// Libraries used (#uses)

//-----------------------------------------------------------------------------
// Variables and Constants

//-----------------------------------------------------------------------------
/**
*/
#uses "classes/splash/OaGuiTest"

class TestReplay : OaGuiTest
{

  //----------------------------------------------------------------------------
  public play(){}
};


//------------------------------------------------------------------------------
/**
  @note Start this script with -dbg CTRL_DEBUGBREAK to allow pause the testscript
        on fails.
*/
void main()
{
	TestReplay test;
  test.setFileScript(__FILE__);
  test.startAll();
  exit(0);
}
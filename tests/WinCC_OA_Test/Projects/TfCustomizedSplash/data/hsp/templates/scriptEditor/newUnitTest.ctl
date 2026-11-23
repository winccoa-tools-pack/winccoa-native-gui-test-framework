// $License: NOLICENSE
/** Tests for the library: scripts/libs/$origLibRelPath.

  @file $relPath
  @test Unit tests for the library: scripts/libs/$origLibRelPath
 */

//-----------------------------------------------------------------------------
// Libraries used (#uses)
#uses "$origLibRelPathWithoutExtension" // tested object
#uses "classes/oaTest/OaTest" // oaTest basic class


//-----------------------------------------------------------------------------
/** Tests for $origLibName.ctl
*/
class newTestTemplate : OaTest
{
  //---------------------------------------------------------------------------
  /**
    @test Describe the test scenario here.
   */
  public int testSetAssertionState()
  {
    // type your test script here like
    this.assertEqual("currentValue1", "currentValue1");

    return 0;
  }
};

//-----------------------------------------------------------------------------
void main(...)
{
  va_list list;
  int count = va_start(list);
  newTestTemplate test;
  test.cla.readArguments(list, count);
  va_end(list);

  test.startAll();
}

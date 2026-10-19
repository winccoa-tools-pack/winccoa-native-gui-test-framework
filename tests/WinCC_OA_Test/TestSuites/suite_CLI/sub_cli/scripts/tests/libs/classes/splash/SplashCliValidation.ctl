/**
  @file scripts/tests/libs/classes/splash/SplashCliValidation.ctl
  @test Headless tests for project-relative Splash CLI paths.
  @copyright MIT
  @AIgeneratedHelpContent
*/

#uses "classes/oaTest/OaTest"
#uses "classes/splash/SplashCliValidation"

/**
  @brief Tests path validation used by the Splash command-line interface.
  @AIgeneratedHelpContent
*/
class TstSplashCliValidation : OaTest
{
  //@public members

  SplashCliValidation validation = SplashCliValidation();

  /**
    @test Accept root-level and nested project-relative panel paths.
    @AIgeneratedHelpContent
  */
  public int testAcceptedPanelPaths()
  {
    this.assertTrue(validation.isSafePanelPath("about.pnl"),
                    "Accept panel at panels root");
    this.assertTrue(validation.isSafePanelPath("vision/login.pnl"),
                    "Accept nested panel path");
    this.assertTrue(validation.isSafePanelPath("/vision/login.pnl"),
                    "Accept one leading slash");
    return 0;
  }

  /**
    @test Reject absolute, traversing, malformed and non-panel paths.
    @AIgeneratedHelpContent
  */
  public int testRejectedPanelPaths()
  {
    dyn_string paths = makeDynString(
                         "", "../outside.pnl", "vision/../outside.pnl",
                         "C:/outside.pnl", "\\\\server\\outside.pnl",
                         "vision\\login.pnl", "vision//login.pnl",
                         "vision/login.xml", "/vision/login.pnl/extra");

    for (int index = 1; index <= dynlen(paths); index++)
      this.assertFalse(validation.isSafePanelPath(paths[index]),
                       "Reject panel path: " + paths[index]);

    return 0;
  }

  /**
    @test Accept nested script paths under scripts/tests.
    @AIgeneratedHelpContent
  */
  public int testAcceptedTestScriptPaths()
  {
    this.assertTrue(
      validation.isSafeTestScriptPath("tests/vision/login/tc1.ctl"),
      "Accept nested test path");
    this.assertTrue(
      validation.isSafeTestScriptPath("tests/smoke/cli_check.ctl"),
      "Accept test path with another suite folder");
    return 0;
  }

  /**
    @test Reject paths escaping scripts/tests or naming a non-CTL file.
    @AIgeneratedHelpContent
  */
  public int testRejectedTestScriptPaths()
  {
    dyn_string paths = makeDynString(
                         "", "tc1.ctl", "examples/tests/vision/tc1.ctl",
                         "tests_evil/vision/tc1.ctl",
                         "tests/../outside/tc1.ctl",
                         "tests/vision/../../outside.ctl",
                         "tests/vision/tc1.txt",
                         "tests/vision/tc1.ctl.bak",
                         "tests/vision\\tc1.ctl",
                         "tests//vision/tc1.ctl",
                         "C:/tests/vision/tc1.ctl",
                         "/tests/vision/tc1.ctl",
                         "tests/tc1.ctl");

    for (int index = 1; index <= dynlen(paths); index++)
      this.assertFalse(validation.isSafeTestScriptPath(paths[index]),
                       "Reject test script path: " + paths[index]);

    return 0;
  }

  //@protected members

  //@private members
};

void main(...)
{
  va_list list;
  int count = va_start(list);
  TstSplashCliValidation test;
  test.cla.readArguments(list, count);
  va_end(list);

  test.startAll();
}
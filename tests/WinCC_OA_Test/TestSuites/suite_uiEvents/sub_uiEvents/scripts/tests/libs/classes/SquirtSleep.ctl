/**
  @file $relPath
  @brief Regression checks for safe scaled player delays.
  @copyright MIT
  @AIgeneratedHelpContent
*/
#uses "classes/SquirtInputEventPlayer"
#uses "classes/oaTest/OaTest"

/**
  @brief Exercises the sleep override without a panel fixture.
  @AIgeneratedHelpContent
*/
class TstSquirtSleep : OaTest
{
//@public members
  /**
    @test Nonpositive inputs and factors return without scheduling a wait.
    @return Zero after assertions.
    @AIgeneratedHelpContent
  */
  public int testNonpositiveWaits()
  {
    SquirtInputEventPlayer player;
    time started = getCurrentTime();
    player.sleep(-1000);
    player.sleep(0);
    player.setTimeFactor(0);
    player.sleep(10000);
    player.setTimeFactor(-1);
    player.sleep(10000);
    player.sleep(-10000);
    assertTrue(getCurrentTime() - started < 1,
               "Invalid waits finish within a generous one-second bound");
    assertEqual(player.getTimeFactor(), -1.0,
                "Sleeping does not alter the configured time factor");
    return 0;
  }

  /**
    @test Scaled sub-millisecond requests are skipped, not rounded up.
    @return Zero after assertions.
    @AIgeneratedHelpContent
  */
  public int testSubMillisecondWaits()
  {
    SquirtInputEventPlayer player;
    player.setTimeFactor(0.0001);
    time started = getCurrentTime();

    for (int index = 0; index < 2000; index++)
      player.sleep(1);

    assertTrue(getCurrentTime() - started < 1,
               "Sub-millisecond requests do not accumulate rounded waits");
    return 0;
  }

  /**
    @test Positive effective waits retain scaling and the one-ms boundary.
    @return Zero after assertions.
    @AIgeneratedHelpContent
  */
  public int testPositiveWaits()
  {
    SquirtInputEventPlayer player;
    player.setTimeFactor(0.5);
    player.sleep(2);
    time started = getCurrentTime();
    player.sleep(100);
    assertTrue(getCurrentTime() - started >= 0.04,
               "A scaled 50-ms request still waits at least 40 ms");
    assertEqual(player.getTimeFactor(), 0.5,
                "Positive waits preserve the time factor");
    return 0;
  }

//@protected members
//@private members
};

/**
  @brief Runs the standalone sleep regression in a dedicated UI manager.
  @AIgeneratedHelpContent
*/
void main(...)
{
  va_list arguments;
  int count = va_start(arguments);
  TstSquirtSleep test;
  test.cla.readArguments(arguments, count);
  va_end(arguments);
  test.startAll();
  exit(0);
}
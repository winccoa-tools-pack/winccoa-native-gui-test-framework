/**
  @file $relPath
  @brief Deterministic touch frame contracts, not gesture recognition tests.
  @copyright MIT
  @AIgeneratedHelpContent
*/
#uses "classes/SquirtInputEventPlayer"
#uses "classes/oaTest/OaTest"

/**
  @brief Records dispatches and injects a one-shot dispatch failure.
  @AIgeneratedHelpContent
*/
class RecordingTouchPlayer : SquirtInputEventPlayer
{
//@public members
  /** @brief Ordered dispatch attempts. @AIgeneratedHelpContent */
  public dyn_mapping frames;
  /** @brief One-based dispatch attempt that throws; zero disables it.
      @AIgeneratedHelpContent */
  public int failAt = 0;

  /** @brief Clears recorded frames and fault injection.
      @AIgeneratedHelpContent */
  public void reset()
  {
    frames.clear();
    failAt = 0;
  }

//@protected members
  /**
    @brief Records rather than injects; fails once at the configured frame.
    @param target Resolved target.
    @param points Complete frame.
    @AIgeneratedHelpContent
  */
  protected void dispatchTouchFrame(const shape &target,
                                    const dyn_mapping &points)
  {
    dynAppend(frames, makeMapping("points", points));

    if (dynlen(frames) == failAt)
      throw (makeError("uim", PRIO_SEVERE, ERR_PARAM, 13,
                       "Injected touch dispatch failure"));
  }

//@private members
};

/**
  @brief Checks framing, preflight rejection and best-effort release.
  @AIgeneratedHelpContent
*/
class TstSquirtTouchFrames : OaTest
{
//@public members
  /** @brief Opens a test-owned panel for native shape geometry.
      @return Zero on success. @AIgeneratedHelpContent */
  public int setUp()
  {
    OaTest::setUp();
    ModuleOnWithPanel("squirt_touch_contract", -1, -1, 900, 800, 2, 2, "",
                      "UiEventTestPanels/ToolVerification.pnl", "main_pnl",
                      makeDynString());
    player.waitForPanelOpen("squirt_touch_contract", "main_pnl", 5000);
    player.setTimeFactor(0.01);
    return 0;
  }

  /** @test Tap has one persistent contact and a terminal release.
      @AIgeneratedHelpContent */
  public int testTap()
  {
    player.reset();
    player.tapShape(address);
    assertEqual(dynlen(player.frames), 2, "Tap frame count");
    expectContact(1, 1, 1, "pressed");
    expectContact(2, 1, 1, "released");
    return 0;
  }

  /** @test Double tap sends two separate press/release sequences.
      @AIgeneratedHelpContent */
  public int testDoubleTap()
  {
    player.reset();
    player.doubleTapShape(address);
    assertEqual(dynlen(player.frames), 4, "Double-tap frame count");
    expectContact(1, 1, 1, "pressed");
    expectContact(2, 1, 1, "released");
    expectContact(3, 1, 1, "pressed");
    expectContact(4, 1, 1, "released");
    return 0;
  }

  /** @test Long press preserves its center through release.
      @AIgeneratedHelpContent */
  public int testLongPress()
  {
    player.reset();
    player.longPressShape(address, 1200);
    assertEqual(dynlen(player.frames), 2, "Long-press frame count");
    dyn_mapping first = player.frames[1]["points"];
    dyn_mapping last = player.frames[2]["points"];
    expectContact(1, 1, 1, "pressed");
    expectContact(2, 1, 1, "released");
    assertEqual((int)first[1]["x"], (int)last[1]["x"], "Stable x");
    assertEqual((int)first[1]["y"], (int)last[1]["y"], "Stable y");
    return 0;
  }

  /** @test Swipe interpolation reaches exact endpoints in order.
      @AIgeneratedHelpContent */
  public int testSwipe()
  {
    player.reset();
    player.swipeShape(address, 10, 10, 50, 30, 4, 40);
    assertEqual(dynlen(player.frames), 6, "Press, four moves, release");

    for (int frame = 1; frame <= 6; frame++)
    {
      expectContact(frame, 1, 1, frame == 1 ? "pressed" :
                    (frame == 6 ? "released" : "moved"));
      dyn_mapping points = player.frames[frame]["points"];
      int step = frame == 6 ? 4 : frame - 1;
      assertEqual((int)points[1]["x"], 10 + 10 * step, "Interpolated x");
      assertEqual((int)points[1]["y"], 10 + 5 * step, "Interpolated y");
    }

    return 0;
  }

  /** @test Pinch and spread keep both persistent IDs in every frame.
      @AIgeneratedHelpContent */
  public int testTwoContacts()
  {
    dyn_mapping wide = makeDynMapping(makeMapping("id", 1, "x", 10, "y", 30),
                                      makeMapping("id", 2, "x", 90, "y", 30));
    dyn_mapping narrow = makeDynMapping(makeMapping("id", 1, "x", 40, "y", 30),
                                        makeMapping("id", 2, "x", 60, "y", 30));

    for (int direction = 1; direction <= 2; direction++)
    {
      player.reset();
      player.twoContactGesture(address, direction == 1 ? wide : narrow,
                               direction == 1 ? narrow : wide, 3, 30);
      assertEqual(dynlen(player.frames), 5, "Two-contact frame count");

      for (int frame = 1; frame <= 5; frame++)
      {
        dyn_mapping points = player.frames[frame]["points"];
        assertEqual(dynlen(points), 2, "Both contacts in every frame");

        for (int contact = 1; contact <= 2; contact++)
          expectContact(frame, contact, contact, frame == 1 ? "pressed" :
                        (frame == 5 ? "released" : "moved"));
      }

      dyn_mapping last = player.frames[5]["points"];
      dyn_mapping expected = direction == 1 ? narrow : wide;
      assertEqual((int)last[1]["x"], (int)expected[1]["x"], "First endpoint");
      assertEqual((int)last[2]["x"], (int)expected[2]["x"], "Second endpoint");
    }

    return 0;
  }

  /** @test A fixed second contact remains stationary during movement.
      @AIgeneratedHelpContent */
  public int testStationaryContact()
  {
    player.reset();
    dyn_mapping starts = makeDynMapping(makeMapping("id", 4, "x", 10, "y", 30),
                                        makeMapping("id", 8, "x", 90, "y", 30));
    dyn_mapping ends = starts;
    ends[1]["x"] = 40;
    player.twoContactGesture(address, starts, ends, 1, 0);
    expectContact(2, 1, 4, "moved");
    expectContact(2, 2, 8, "stationary");
    return 0;
  }

  /** @test Malformed frames fail without any dispatch.
      @AIgeneratedHelpContent */
  public int testInvalidFrames()
  {
    for (int scenario = 1; scenario <= 8; scenario++)
    {
      player.reset();
      dyn_mapping points = makeDynMapping(makeMapping(
                                            "id", 1, "state", "pressed", "x", 10, "y", 10));

      switch (scenario)
      {
        case 1: points.clear(); break;

        case 2: points[1]["state"] = "cancelled"; break;

        case 3: points[1]["x"] = -1; break;

        case 4: points[1]["y"] = 100000; break;

        case 5: dynAppend(points, points[1]); break;

        case 6:
          points[1] = makeMapping("id", "1", "state", "pressed", "x", 10, "y", 10);
          break;

        case 7: points[1] = makeMapping("id", 1); break;

        case 8:
          points[1] = makeMapping("id", 1, "state", "pressed", "x", 1.5, "y", 10);
          break;
      }

      bool rejected = false;

      try { player.touchFrame(address, points); }
      catch { rejected = true; }

      assertTrue(rejected, "Invalid frame rejected: " + scenario);
      assertEqual(dynlen(player.frames), 0, "No partial dispatch");
    }

    return 0;
  }

  /** @test Bad movement arguments and endpoints fail before pressing.
      @AIgeneratedHelpContent */
  public int testInvalidGestures()
  {
    for (int scenario = 1; scenario <= 7; scenario++)
    {
      player.reset();
      bool rejected = false;
      dyn_mapping starts = makeDynMapping(makeMapping("id", 1, "x", 10, "y", 30),
                                          makeMapping("id", 2, "x", 90, "y", 30));
      dyn_mapping ends = starts;

      try
      {
        switch (scenario)
        {
          case 1: player.swipeShape(address, 10, 10, 20, 20, 0); break;

          case 2: player.swipeShape(address, 10, 10, 20, 20, 2, -1); break;

          case 3: player.swipeShape(address, 10, 10, -1, 20); break;

          case 4: player.longPressShape(address, -1); break;

          case 5:
            ends[2]["id"] = 3;
            player.twoContactGesture(address, starts, ends);
            break;

          case 6:
            ends[2]["x"] = 100000;
            player.twoContactGesture(address, starts, ends);
            break;

          case 7:
            ends.clear();
            player.twoContactGesture(address, starts, ends);
            break;
        }
      }
      catch { rejected = true; }

      assertTrue(rejected, "Invalid gesture rejected: " + scenario);
      assertEqual(dynlen(player.frames), 0, "No press before validation");
    }

    return 0;
  }

  /** @test Dispatch errors release the latest positions and propagate.
      @AIgeneratedHelpContent */
  public int testFailureCleanup()
  {
    for (int scenario = 1; scenario <= 3; scenario++)
    {
      player.reset();
      player.failAt = scenario == 1 ? 1 : 2;
      bool caught = false;

      try
      {
        if (scenario == 1)
          player.longPressShape(address, 0);
        else if (scenario == 2)
          player.swipeShape(address, 10, 10, 50, 30, 4, 0);
        else
          player.twoContactGesture(address,
                                   makeDynMapping(makeMapping("id", 1, "x", 10, "y", 30),
                                                  makeMapping("id", 2, "x", 90, "y", 30)),
                                   makeDynMapping(makeMapping("id", 1, "x", 40, "y", 30),
                                                  makeMapping("id", 2, "x", 60, "y", 30)), 3, 0);
      }
      catch
      {
        dyn_errClass exception = getLastException();
        caught = jsonEncode(exception).contains("Injected touch dispatch failure");
      }

      assertTrue(caught, "Original dispatch failure propagated");
      assertEqual(dynlen(player.frames), player.failAt + 1,
                  "One best-effort cleanup attempt");
      dyn_mapping failed = player.frames[player.failAt]["points"];
      dyn_mapping released = player.frames[dynlen(player.frames)]["points"];
      assertEqual(dynlen(released), dynlen(failed), "Release all contacts");

      for (int contact = 1; contact <= dynlen(released); contact++)
      {
        expectContact(dynlen(player.frames), contact,
                      failed[contact]["id"], "released");
        assertEqual((int)released[contact]["x"], (int)failed[contact]["x"],
                    "Cleanup uses latest x");
        assertEqual((int)released[contact]["y"], (int)failed[contact]["y"],
                    "Cleanup uses latest y");
      }
    }

    return 0;
  }

//@protected members

//@private members
  private RecordingTouchPlayer player;
  private string address = "squirt_touch_contract.main_pnl:PUSH_BUTTON_CLICK";

  private void expectContact(int frame, int contact, int id, const string &state)
  {
    dyn_mapping points = player.frames[frame]["points"];
    assertEqual((int)points[contact]["id"], id, "Persistent contact ID");
    assertEqual((string)points[contact]["state"], state, "Contact state");
  }
};

void main(...)
{
  va_list arguments;
  int count = va_start(arguments);
  TstSquirtTouchFrames test;
  test.cla.readArguments(arguments, count);
  va_end(arguments);
  test.startAll();
  exit(0);
}
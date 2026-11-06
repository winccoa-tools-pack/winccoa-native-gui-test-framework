/**
  @file $relPath
  @copyright MIT
  @test Standalone text input checks using an isolated dynamic editor.
  @AIgeneratedHelpContent
*/

#uses "classes/SquirtInputEventPlayer"
#uses "classes/oaTest/OaTest"
#uses "panel"

/**
  @brief Isolated whole-string text input tests.
  @AIgeneratedHelpContent
*/
class TstSquirtStandaloneTextInput : OaTest
{
//@public members
  /**
    @brief Opens the owned panel and creates a text field.
    @return Zero on success, minus one if base setup fails.
    @AIgeneratedHelpContent
  */
  public int setUp()
  {
    if (OaTest::setUp() != 0)
      return -1;

    ModuleOnWithPanel("squirtStandaloneText", -1, -1, 700, 500, 2, 2, "",
                      "about.pnl", "standaloneText", makeDynString());
    player.waitForPanelOpen("squirtStandaloneText", "standaloneText");
    editor = addShape("squirtStandaloneText", "standaloneText", 1,
                      "TEXT_FIELD", "textEditor");
    setValue(editor, "position", 20, 20, "size", 300, 35,
             "visible", true, "enabled", true);
    return 0;
  }

  /**
    @test One whole-string event preserves multibyte and supplementary Unicode.
    @return Zero after assertions.
    @AIgeneratedHelpContent
  */
  public int testWholeStringUnicode()
  {
    string sample = "Grüße 漢字 😀";
    player.writeText(address, sample);
    player.waitForAttribute(address, "text", sample);
    this.assertEqual(editor.text, sample, "Whole Unicode string round-trips");
    return 0;
  }

  /**
    @test Clearing populated and already empty editors leaves an empty string.
    @return Zero after assertions.
    @AIgeneratedHelpContent
  */
  public int testClearEmpty()
  {
    player.writeText(address, "clear this text");
    player.clearText(address);
    this.assertEqual(editor.text, "", "Populated editor clears");
    player.clearText(address);
    this.assertEqual(editor.text, "", "Clearing empty text is idempotent");
    return 0;
  }

  /**
    @test Replacement removes old content, including replacement with empty.
    @return Zero after assertions.
    @AIgeneratedHelpContent
  */
  public int testReplacement()
  {
    player.writeText(address, "initial value");
    player.replaceText(address, "replacement");
    this.assertEqual(editor.text, "replacement", "Replacement removes old text");
    player.replaceText(address, "");
    this.assertEqual(editor.text, "", "Empty replacement clears old text");
    return 0;
  }

  /**
    @test Explicit Return commits without altering the edited value.
    @return Zero after assertions.
    @AIgeneratedHelpContent
  */
  public int testExplicitCommit()
  {
    player.replaceText(address, "commit this value");
    this.assertEqual(editor.text, "commit this value", "Text exists before commit");
    player.commitText(address);
    this.assertEqual(editor.text, "commit this value", "Commit retains input");
    return 0;
  }

  /**
    @brief Closes only this script's owned module.
    @return Base teardown result.
    @AIgeneratedHelpContent
  */
  public int tearDown()
  {
    moduleOff("squirtStandaloneText");
    player.waitForPanelClosed("squirtStandaloneText", "standaloneText");
    return OaTest::tearDown();
  }

//@protected members
//@private members
  private SquirtInputEventPlayer player;
  private shape editor;
  private string address = "squirtStandaloneText.standaloneText:textEditor";
};

/**
  @brief Parses OaTest arguments, runs all cases and exits the UI manager.
  @AIgeneratedHelpContent
*/
void main(...)
{
  va_list arguments;
  int count = va_start(arguments);
  TstSquirtStandaloneTextInput test;
  test.cla.readArguments(arguments, count);
  va_end(arguments);
  test.startAll();
  exit(0);
}
/**
  @file $relPath
  @brief One assertion-based Squirt showcase for the DPE monitor panel.
  @copyright MIT
  @AIgeneratedHelpContent
*/

#uses "classes/splash/OaGuiTest"

/**
  @brief Demonstrates targeting and asserting a named panel shape.
  @AIgeneratedHelpContent
*/
class DpeMonitorShowcase : OaGuiTest
{
  //@public members

  /**
    @test Toggle comment display, refresh the empty table, restore the toggle,
          then compare the stable panel frame to a stored VP.
    @AIgeneratedHelpContent
  */
  public int play()
  {
    player.makeCurrent(
      "Vision_1.Datenpunktelement-Monitor:cbOnlyComment");
    shape commentMode = player.getCurrentShape();
    int shapeWidth, shapeHeight;
    getValue(commentMode, "size", shapeWidth, shapeHeight);
    player.leftMouseClickOnShape(commentMode, shapeWidth / 2,
                                 shapeHeight / 2);
    player.sleep(150);

    player.makeCurrent(
      "Vision_1.Datenpunktelement-Monitor:actualizeTable");
    shape refreshButton = player.getCurrentShape();
    getValue(refreshButton, "size", shapeWidth, shapeHeight);
    player.leftMouseClickOnShape(refreshButton, shapeWidth / 2,
                                 shapeHeight / 2);
    player.sleep(150);

    player.makeCurrent(
      "Vision_1.Datenpunktelement-Monitor:cbOnlyComment");
    commentMode = player.getCurrentShape();
    getValue(commentMode, "size", shapeWidth, shapeHeight);
    player.leftMouseClickOnShape(commentMode, shapeWidth / 2,
                                 shapeHeight / 2);
    player.sleep(150);

    SquirtVpPanel panelVp = SquirtVpPanel(
                              "dpe_monitor_showcase_panel", player.getCurrentPanel());

    if (panelVp.init())
      this.abort("The DPE monitor panel VP could not be initialized.");

    if (panelVp.getShapesAndAttributes().count() == 0)
      this.abort("The DPE monitor panel VP contains no visible shapes.");

    vector<shape> referenceShapes;
    referenceShapes.append(
      getShape("Vision_1.Datenpunktelement-Monitor:FRAME1"));

    return this.assertVP("dpe_monitor_showcase", referenceShapes,
                         "DPE monitor frame after reversible UI actions");
  }

  //@protected members

  //@private members
};

void main(...)
{
  va_list args;
  int count = va_start(args);
  DpeMonitorShowcase test;
  test.cla.readArguments(args, count);
  va_end(args);

  test.setFileScript(__FILE__);
  test.startAll();
}
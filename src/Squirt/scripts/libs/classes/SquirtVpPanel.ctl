/**
  @file $relPath
  @copyright MIT
  @brief Panel-wide visual reference point implementation.
  @AIgeneratedHelpContent
*/

#uses "classes/SquirtVp"
#uses "classes/InputEventPlayer"
#uses "oaGuiTestShapes"
#uses "panel"

/**
  @brief Panel VP containing visible shapes except non-interactive SPACER items.
  @AIgeneratedHelpContent
*/
class SquirtVpPanel : SquirtVp
{
  //@public members

  //@protected members
  /** Panel whose visible shapes are captured in the VP. */
  protected shape panel;

  //@private members

  //@public functions
  /**
    @brief Creates a panel-wide VP from the visible shapes in a panel.
    @param vpId Identifier of the panel VP JSON file.
    @param panel Current panel whose visible shapes form the reference.
  */
  public SquirtVpPanel(const string &vpId, const shape &panel)
  {
    this.panel = panel;
    this.id = vpId;
    this.shapes = this.getPanelShapes();
  }

  /**
    @brief Returns the number of capturable visible panel shapes.
    @return Number of visible shapes collected, excluding SPACER items.
  */
  public int getCurrentShapeCount()
  {
    return this.shapes.count();
  }

  //@protected functions
  /**
    @brief Returns the panel VP metadata path relative to DATA_REL_PATH.
    @return Relative JSON path for the panel VP.
  */
  protected string getMetaRelPath()
  {
    return "splash/VPs/panels/" + this.id + ".json";
  }

  /**
    @brief Resolves all visible shapes from the current panel.
    @return Vector of visible panel shapes used by the VP.
  */
  protected vector<shape> getPanelShapes()
  {
    dyn_string dsShapes = getShapes(this.panel.moduleName,
                                    this.panel.name(), "visible", TRUE);
    vector<shape> retShapes;

    for (int index = 1; index <= dynlen(dsShapes); index++)
    {
      const shape panelShape = getShape(this.panel.moduleName,
                                        this.panel.name(), dsShapes[index]);

      retShapes.append(panelShape);
    }

    return retShapes;
  }

  //@private functions
};
#uses "classes/splash/shapes/GuiTestShape"

//-----------------------------------------------------------------------------
/** DpTree shape
*/
class GuiTestDpTree : GuiTestShape
{
//-----------------------------------------------------------------------------
//@public members
//-----------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  /**
    @brief Creates a wrapper for one panel shape instance.
    @param testShape Shape object to inspect and validate.
  */
  public GuiTestDpTree(const shape/*<"???">*/ &testShape)
  {
    this.testShape = testShape;
  }

  //---------------------------------------------------------------------------
  /** Returns current values of usefull attributes.
    @return Mapping with current shape attributes.
    @note key must be string and values string|number|bools
  */
  public mapping getCurrentAttributes()
  {

    bool visible, enabled;
    int x, y, w, h;
    int cursor = this.testShape.cursor();
    string selectedItem = this.testShape.selectedItem();
    string layoutDirection = this.testShape.layoutDirection();
    bool updatesEnabled = this.testShape.updatesEnabled();
    bool enabled = this.testShape.enabled();
    bool headerHidden = this.testShape.headerHidden();
    bool itemsExpandable = this.testShape.itemsExpandable();
    bool headerHidden = this.testShape.headerHidden();
    bool itemsExpandable = this.testShape.itemsExpandable();

    getValue(this.testShape,
             "visible", visible,
             "enabled", enabled,
             "position", x, y,
             "size", w, h);

    return makeMapping(
             "visible", visible,
             "enabled", enabled,
             "position.x", x,
             "position.y", y,
             "size.w", w,
             "size.h", h,
             "selectedItem", selectedItem,
             "cursor", cursor,
             "updatesEnabled", updatesEnabled,
             "enabled", enabled,
             "layoutDirection", layoutDirection,
             "headerHidden", headerHidden,
             "itemsExpandable", itemsExpandable,
             "lineWidth", lineWidth,
             "midLineWidth", midLineWidth,
             "rootIsDecorated", rootIsDecorated,
             "selectionBehavior", selectionBehavior,
             "selectionMode", selectionMode,
             "sortingEnabled", sortingEnabled,
             "uniformRowHeights", uniformRowHeights
           );
  }

};

#uses "classes/splash/shapes/GuiTestShape"

//-----------------------------------------------------------------------------
/** Tree shape
*/
class GuiTestTree : GuiTestShape
{
//-----------------------------------------------------------------------------
//@public members
//-----------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  public GuiTestTree(const shape/*<"???">*/ &testShape)
  {
    this.testShape = testShape;
  }

  //---------------------------------------------------------------------------
  /** Returns current values of usefull attributes.
    @note key must be string and values string|number|bools
  */
  public mapping getCurrentAttributes()
  {

    bool visible, enabled;
    int x, y, w, h;
    int cursor, lineWidth, midLineWidth, treeStepSize;
    bool updatesEnabled, itemsExpandable, headerHidden, rootIsDecorated, sortingEnabled; //, uniformRowHeights;
    float uniformRowHeights;
    string layoutDirection, selectionBehavior, selectionMode;

    getValue(this.testShape,
             "visible", visible,
             "enabled", enabled,
             "position", x, y,
             "size", w, h,
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
             "treeStepSize", treeStepSize,
             "uniformRowHeights", uniformRowHeights);

    return makeMapping(
             "visible", visible,
             "enabled", enabled,
             "position.x", x,
             "position.y", y,
             "size.w", w,
             "size.h", h,
             "cursor", cursor,
             "updatesEnabled", updatesEnabled,
             "layoutDirection", layoutDirection,
             "headerHidden", headerHidden,
             "itemsExpandable", itemsExpandable,
             "lineWidth", lineWidth,
             "midLineWidth", midLineWidth,
             "rootIsDecorated", rootIsDecorated,
             "selectionBehavior", selectionBehavior,
             "selectionMode", selectionMode,
             "sortingEnabled", sortingEnabled,
             "treeStepSize", treeStepSize,
             "uniformRowHeights", uniformRowHeights
           );
  }

};

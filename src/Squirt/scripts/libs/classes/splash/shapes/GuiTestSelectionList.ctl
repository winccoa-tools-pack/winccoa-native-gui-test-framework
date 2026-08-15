#uses "classes/splash/shapes/GuiTestShape"

//-----------------------------------------------------------------------------
/** Selection List shape
*/
class GuiTestSelectionList : GuiTestShape
{
//-----------------------------------------------------------------------------
//@public members
//-----------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  /**
    @brief Creates a wrapper for one panel shape instance.
    @param testShape Shape object to inspect and validate.
  */
  public GuiTestSelectionList(const shape/*<"???">*/ &testShape)
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

    bool visible, enabled, updatesEnabled, alternatingRowColors;
    int x, y, w, h, itemCount, selectedPos, cursor;

    getValue(this.testShape,
             "visible", visible,
             "enabled", enabled,
             "position", x, y,
             "size", w, h,
             "itemCount", itemCount,
             "selectedPos", selectedPos,
             "cursor", cursor,
             "updatesEnabled", updatesEnabled,
             "alternatingRowColors", alternatingRowColors,
             "selectedText", selectedText);

    return makeMapping(
             "visible", visible,
             "enabled", enabled,
             "position.x", x,
             "position.y", y,
             "size.w", w,
             "size.h", h,
             "itemCount", itemCount,
             "selectedPos", selectedPos,
             "cursor", cursor,
             "updatesEnabled", updatesEnabled,
             "alternatingRowColors", alternatingRowColors,
             "selectedText", selectedText
           );
  }

};

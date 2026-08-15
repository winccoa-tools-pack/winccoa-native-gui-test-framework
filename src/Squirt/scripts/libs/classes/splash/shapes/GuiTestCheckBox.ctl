#uses "classes/splash/shapes/GuiTestShape"

//-----------------------------------------------------------------------------
/** Check Box shape
*/
class GuiTestCheckBox : GuiTestShape
{
//-----------------------------------------------------------------------------
//@public members
//-----------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  /**
    @brief Creates a wrapper for one panel shape instance.
    @param testShape Shape object to inspect and validate.
  */
  public GuiTestCheckBox(const shape/*<"???">*/ &testShape)
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

    bool visible, enabled, updatesEnabled;
    int x, y, w, h, itemCount;
    string text;

    getValue(this.testShape,
             "visible", visible,
             "enabled", enabled,
             "position", x, y,
             "size", w, h,
             "text", text,
             "updatesEnabled", updatesEnabled,
             "itemCount", itemCount);

    return makeMapping(
             "visible", visible,
             "enabled", enabled,
             "position.x", x,
             "position.y", y,
             "size.w", w,
             "size.h", h,
             "text", text,
             "updatesEnabled", updatesEnabled,
             "itemCount", itemCount
           );
  }

};

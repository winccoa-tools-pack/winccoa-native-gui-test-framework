#uses "classes/splash/shapes/GuiTestShape"

//-----------------------------------------------------------------------------
/** Radio Box shape
*/
class GuiTestRadioBox : GuiTestShape
{
//-----------------------------------------------------------------------------
//@public members
//-----------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  /**
    @brief Creates a wrapper for one panel shape instance.
    @param testShape Shape object to inspect and validate.
  */
  public GuiTestRadioBox(const shape/*<"???">*/ &testShape)
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
    int x, y, w, h, cursor, number;

    getValue(this.testShape,
             "visible", visible,
             "enabled", enabled,
             "position", x, y,
             "size", w, h,
             "cursor", cursor,
             "number", number,
             "updatesEnabled", updatesEnabled);

    return makeMapping(
             "visible", visible,
             "enabled", enabled,
             "position.x", x,
             "position.y", y,
             "size.w", w,
             "size.h", h,
             "cursor", cursor,
             "number", number,
             "updatesEnabled", updatesEnabled
           );
  }

};

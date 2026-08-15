#uses "classes/splash/shapes/GuiTestShape"

//-----------------------------------------------------------------------------
/** Line shape
*/
class GuiTestLine : GuiTestShape
{
//-----------------------------------------------------------------------------
//@public members
//-----------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  /**
    @brief Creates a wrapper for one panel shape instance.
    @param testShape Shape object to inspect and validate.
  */
  public GuiTestLine(const shape/*<"???">*/ &testShape)
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

    bool visible, enabled, armed, selected;;
    int x, y, w, h;
    float rotation;
    string border, dashBackCol;

    getValue(this.testShape,
             "visible", visible,
             "enabled", enabled,
             "position", x, y,
             "size", w, h,
             "armed", armed,
             "border", border,
             "dashBackCol", dashBackCol,
             "rotation", rotation,
             "selected", selected);

    return makeMapping(
             "visible", visible,
             "enabled", enabled,
             "position.x", x,
             "position.y", y,
             "size.w", w,
             "size.h", h,
             "armed", armed,
             "border", border,
             "dashBackCol", dashBackCol,
             "rotation", rotation,
             "selected", selected
           );
  }

};

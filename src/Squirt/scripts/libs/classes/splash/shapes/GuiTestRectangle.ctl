#uses "classes/splash/shapes/GuiTestShape"

//-----------------------------------------------------------------------------
/** Rectangule shape
*/
class GuiTestRectangle : GuiTestShape
{
//-----------------------------------------------------------------------------
//@public members
//-----------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  /**
    @brief Creates a wrapper for one panel shape instance.
    @param testShape Shape object to inspect and validate.
  */
  public GuiTestRectangle(const shape/*<"???">*/ &testShape)
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

    bool visible, enabled, armed, selected;
    int x, y, w, h;
    string border, borderStyle, dashBackCol, fill;

    getValue(this.testShape,
             "visible", visible,
             "enabled", enabled,
             "position", x, y,
             "size", w, h,
             "armed", armed,
             "border", border,
             "borderStyle", borderStyle,
             "dashBackCol", dashBackCol,
             "fill", fill,
             "selected", selected);

    if (fill.startsWith("[pattern"))
    {
      fill = makeUnixPath(fill);

      strreplace(fill, makeUnixPath(WINCCOA_PATH), "WINCCOA_PATH/");
      strreplace(fill, makeUnixPath(PROJ_PATH), "PROJ_PATH/"); // sub projects ignored
    }

    return makeMapping(
             "visible", visible,
             "enabled", enabled,
             "position.x", x,
             "position.y", y,
             "size.w", w,
             "size.h", h,
             "armed", armed,
             "border", border,
             "borderStyle", borderStyle,
             "dashBackCol", dashBackCol,
             "fill", fill,
             "selected", selected
           );
  }

};

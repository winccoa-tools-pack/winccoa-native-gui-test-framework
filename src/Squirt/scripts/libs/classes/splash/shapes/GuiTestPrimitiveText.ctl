#uses "classes/splash/shapes/GuiTestShape"

//-----------------------------------------------------------------------------
/** Primitive Text shape
*/
class GuiTestPrimitiveText : GuiTestShape
{
//-----------------------------------------------------------------------------
//@public members
//-----------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  public GuiTestPrimitiveText(const shape/*<"PRIMITIVE_TEXT">*/ &testShape)
  {
    this.testShape = testShape;
  }

  //---------------------------------------------------------------------------
  /** Returns current values of usefull attributes.
    @note key must be string and values string|number|bools
  */
  public mapping getCurrentAttributes()
  {

    bool visible, enabled, armed, selected;;
    int x, y, w, h;
    string border, dashBackCol, fill, format, text;

    getValue(this.testShape,
             "visible", visible,
             "enabled", enabled,
             "position", x, y,
             "size", w, h,
             "armed", armed,
             "border", border,
             "dashBackCol", dashBackCol,
             "fill", fill,
             "format", format,
             "selected", selected,
             "text", text);

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
             "fill", fill,
             "format", format,
             "selected", selected,
             "text", text
           );
  }

};

#uses "classes/splash/shapes/GuiTestShape"

//-----------------------------------------------------------------------------
/** Frame shape
*/
class GuiTestFrame : GuiTestShape
{
//-----------------------------------------------------------------------------
//@public members
//-----------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  public GuiTestFrame(const shape/*<"???">*/ &testShape)
  {
    this.testShape = testShape;
  }

  //---------------------------------------------------------------------------
  /** Returns current values of usefull attributes.
    @note key must be string and values string|number|bools
  */
  public mapping getCurrentAttributes()
  {

    bool visible, enabled, armed, selected;
    int x, y, w, h;
    string border, dashBackCol, fill;

    getValue(this.testShape,
             "visible", visible,
             "enabled", enabled,
             "position", x, y,
             "size", w, h,
             "armed", armed,
             "selected", selected,
             "border", border,
             "dashBackCol", dashBackCol,
             "fill", fill);

    return makeMapping(
             "visible", visible,
             "enabled", enabled,
             "position.x", x,
             "position.y", y,
             "size.w", w,
             "size.h", h,
             "armed", armed,
             "selected", selected,
             "border", border,
             "dashBackCol", dashBackCol,
             "fill", fill
           );
  }

};

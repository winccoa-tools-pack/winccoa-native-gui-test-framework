#uses "classes/splash/shapes/GuiTestShape"

//-----------------------------------------------------------------------------
/** Text Filed shape
*/
class GuiTestTextField : GuiTestShape
{
  public GuiTestTextField(const shape/*<"TEXT_FIELD">*/ &testShape)
  {
    this.testShape = testShape;
  }

  public mapping getCurrentAttributes()
  {

    bool visible, enabled;
    int x, y, w, h;

    string font;
    string max, min, text;
    string borderStyle, format;
    bool updatesEnabled, editable;

    getValue(this.testShape,
             "visible", visible,
             "enabled", enabled,
             "position", x, y,
             "size", w, h,

             "max", max,
             "min", min,
             "text", text,
             "updatesEnabled", updatesEnabled,
             "borderStyle", borderStyle,
             "editable", editable,
             "font", font,
             "format", format);

    return makeMapping(
             "visible", visible,
             "enabled", enabled,
             "position.x", x,
             "position.y", y,
             "size.w", w,
             "size.h", h,

             "max", max,
             "min", min,
             "text", text,
             "updatesEnabled", updatesEnabled,
             "borderStyle", borderStyle,
             "editable", editable,
             "font", font,
             "format", format
           );
  }
};

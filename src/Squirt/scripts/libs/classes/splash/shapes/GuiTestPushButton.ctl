#uses "classes/splash/shapes/GuiTestShape"

//-----------------------------------------------------------------------------
/** Push Button shape
*/
class GuiTestPushButton : GuiTestShape
{
//-----------------------------------------------------------------------------
//@public members
//-----------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  /**
    @brief Creates a wrapper for one panel shape instance.
    @param testShape Shape object to inspect and validate.
  */
  public GuiTestPushButton(const shape/*<"PUSH_BUTTON">*/ &testShape)
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

    bool toggleState, updatesEnabled;
    int buttonType, cursor;
    string borderStyle, fill, textPosition;
    string font;
    string text;

    getValue(this.testShape,
             "visible", visible,
             "enabled", enabled,
             "position", x, y,
             "size", w, h,

             "toggleState", toggleState,
             "updatesEnabled", updatesEnabled,
             "buttonType", buttonType,
            // "cursor", cursor,
             "borderStyle", borderStyle,
             "fill", fill,
             "textPosition", textPosition,
             "font", font,
             "text", text);

    if (fill.startsWith("[pattern"))
    {
      fill = makeUnixPath(fill);

      strreplace(fill, makeUnixPath(WINCCOA_PATH), "WINCCOA_PATH/");
      strreplace(fill, makeUnixPath(PROJ_PATH), "PROJ_PATH/");
      // TODO check if we shall ignore sub projects too
    }

    return makeMapping(
             "visible", visible,
             "enabled", enabled,
             "position.x", x,
             "position.y", y,
             "size.w", w,
             "size.h", h,

             "toggleState", toggleState,
             "updatesEnabled", updatesEnabled,
             "buttonType", buttonType,
             "cursor", cursor,
             "borderStyle", borderStyle,
             "fill", fill,
             "textPosition", textPosition,
             "font", font,
             "text", text
           );
  }

};

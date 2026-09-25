/**
  @copyright Copyright 2026 winccoa-tools-pack
  SPDX-License-Identifier: MIT
*/

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

    anytype visible, enabled, x, y, w, h,

     toggleState, updatesEnabled,
     buttonType,
     borderStyle, fill, textPosition,
     font,
     text;

    getValue(this.testShape,
             "visible", visible,
             "enabled", enabled,
             "position", x, y,
             "size", w, h,

             "toggleState", toggleState,
             "updatesEnabled", updatesEnabled,
             "buttonType", buttonType,
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
             "borderStyle", borderStyle,
             "fill", fill,
             "textPosition", textPosition,
             "font", font,
             "text", text
           );
  }

};

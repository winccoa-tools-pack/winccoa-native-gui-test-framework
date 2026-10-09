/**
  @copyright Copyright 2026 winccoa-tools-pack
  SPDX-License-Identifier: MIT
*/

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
  /**
    @brief Creates a wrapper for one panel shape instance.
    @param testShape Shape object to inspect and validate.
  */
  public GuiTestFrame(const shape/*<"???">*/ &testShape)
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

    anytype visible, enabled, armed, selected;
    anytype x, y, w, h;
    anytype border, dashBackCol, fill;

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

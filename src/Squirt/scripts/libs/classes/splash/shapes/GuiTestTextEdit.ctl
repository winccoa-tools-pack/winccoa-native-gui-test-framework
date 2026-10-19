/**
  @copyright Copyright 2026 winccoa-tools-pack
  SPDX-License-Identifier: MIT
*/

#uses "classes/splash/shapes/GuiTestShape"

//-----------------------------------------------------------------------------
/** Text Edit shape
*/
class GuiTestTextEdit : GuiTestShape
{
  public GuiTestTextEdit(const shape/*<"TEXT_EDIT">*/ &testShape)
  {
    this.testShape = testShape;
  }

  public mapping getCurrentAttributes()
  {

    anytype visible, enabled;
    anytype x, y, w, h;
    anytype text;


    getValue(this.testShape,
             "visible", visible,
             "enabled", enabled,
             "position", x, y,
             "size", w, h,

//TODO TBD all other attributes
             "text", text
            )
    ;

    return makeMapping(
             "visible", visible,
             "enabled", enabled,
             "position.x", x,
             "position.y", y,
             "size.w", w,
             "size.h", h,

             "text", text
           );
  }

};

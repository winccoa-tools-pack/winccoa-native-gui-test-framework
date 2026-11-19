/**
  @copyright Copyright 2026 winccoa-tools-pack
  SPDX-License-Identifier: MIT
*/

#uses "classes/splash/shapes/GuiTestShape"

//-----------------------------------------------------------------------------
/** Table shape
*/
class GuiTestTable : GuiTestShape
{
//-----------------------------------------------------------------------------
//@public members
//-----------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  /**
    @brief Creates a wrapper for one panel shape instance.
    @param testShape Shape object to inspect and validate.
  */
  public GuiTestTable(const shape/*<"TABLE">*/ &testShape)
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

    anytype visible, enabled;
    anytype x, y, w, h;

    getValue(this.testShape,
             "visible", visible,
             "enabled", enabled,
             "position", x, y,
             "size", w, h);

    return makeMapping(
             "visible", visible,
             "enabled", enabled,
             "position.x", x,
             "position.y", y,
             "size.w", w,
             "size.h", h
           );
  }

  /**
    @brief Returns the value of one table cell.
    @param row Row index of the cell.
    @param column Column name of the cell.
    @return The value stored at the specified row and column.
    @AIgeneratedHelpContent
  */
  public anytype getRC(int row, const string &column)
  {
    anytype value;
    getValue(this.testShape,
             "cellValueRC", row, column, value);
    return value;
  }


};

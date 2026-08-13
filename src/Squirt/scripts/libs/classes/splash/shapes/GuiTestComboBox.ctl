#uses "classes/splash/shapes/GuiTestShape"

//-----------------------------------------------------------------------------
/** ComboBox shape
*/
class GuiTestComboBox : GuiTestShape
{
//-----------------------------------------------------------------------------
//@public members
//-----------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  public GuiTestComboBox(const shape/*<"???">*/ &testShape)
  {
    this.testShape = testShape;
  }

  //---------------------------------------------------------------------------
  /** Returns current values of usefull attributes.
    @note key must be string and values string|number|bools
  */
  public mapping getCurrentAttributes()
  {

    bool visible, enabled, updatesEnabled, editable, updatesEnabled;
    int x, y, w, h, cursor, itemCount, selectedPos;
    string selectedText, text;

    getValue(this.testShape,
             "visible", visible,
             "enabled", enabled,
             "position", x, y,
             "size", w, h,
             "updatesEnabled", updatesEnabled,
             "cursor", cursor,
             "itemCount", itemCount,
             "selectedPos", selectedPos,
             "editable", editable,
             "updatesEnabled", updatesEnabled,
             "selectedText", selectedText,
             "text", text);

    return makeMapping(
             "visible", visible,
             "enabled", enabled,
             "position.x", x,
             "position.y", y,
             "size.w", w,
             "size.h", h,
             "updatesEnabled", updatesEnabled,
             "cursor", cursor,
             "itemCount", itemCount,
             "selectedPos", selectedPos,
             "editable", editable,
             "updatesEnabled", updatesEnabled,
             "selectedText", selectedText,
             "text", text
           );
  }

};

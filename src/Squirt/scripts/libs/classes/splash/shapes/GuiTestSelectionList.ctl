/**
  @copyright Copyright 2026 winccoa-tools-pack
  SPDX-License-Identifier: MIT
*/

#uses "classes/splash/shapes/GuiTestShape"

//-----------------------------------------------------------------------------
/** Selection List shape
*/
class GuiTestSelectionList : GuiTestShape
{
//-----------------------------------------------------------------------------
//@public members
//-----------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  /**
    @brief Creates a wrapper for one panel shape instance.
    @param testShape Shape object to inspect and validate.
  */
  public GuiTestSelectionList(const shape/*<"???">*/ &testShape)
  {
    this.testShape = testShape;
  }

  /**
    @brief Selects one item by its displayed text or one-based position.
    @param item Exact item text or one-based item position.
    @return 0 when selected, -1 when the shape is missing, -2 when the list
            is empty or the position is out of range, -3 for an unsupported
            argument type, or -4 when text selection did not match.
  */
  public int selectItem(const anytype &item)
  {
    if (!shapeExists(this.testShape))
      return -1;

    const int itemCount = this.testShape.itemCount();

    if (itemCount == 0)
      return -2;

    if (getType(item) == STRING_VAR)
    {
      const string expectedText = item;
      const dyn_string items = this.testShape.items();

      if (expectedText.isEmpty())
        return -2;

      for (int position = 1; position <= dynlen(items); position++)
      {
        if (items[position] == expectedText)
        {
          this.testShape.selectedPos(position);
          return 0;
        }
      }

      return -4;
    }

    if (getType(item) == INT_VAR)
    {
      if (item < 1 || item > itemCount)
        return -2;

      this.testShape.selectedPos(item);
      return 0;
    }

    return -3;
  }

  //---------------------------------------------------------------------------
  /** Returns current values of usefull attributes.
    @return Mapping with current shape attributes.
    @note key must be string and values string|number|bools
  */
  public mapping getCurrentAttributes()
  {

    anytype visible, enabled, font, updatesEnabled, alternatingRowColors;
    anytype x, y, w, h, itemCount, selectedPos, cursor;
    anytype items, selectedItems, selectedText;

    getValue(this.testShape,
             "visible", visible,
             "enabled", enabled,
             "position", x, y,
             "size", w, h,
             "font", font,
             "itemCount", itemCount,
             "selectedPos", selectedPos,
             "cursor", cursor,
             "updatesEnabled", updatesEnabled,
             "items", items,
             "selectedItems", selectedItems,
             "alternatingRowColors", alternatingRowColors,
             "selectedText", selectedText);

    return makeMapping(
             "visible", visible,
             "enabled", enabled,
             "position.x", x,
             "position.y", y,
             "size.w", w,
             "size.h", h,
             "font", font,
             "itemCount", itemCount,
             "selectedPos", selectedPos,
             "cursor", cursor,
             "updatesEnabled", updatesEnabled,
             "items", items,
             "selectedItems", selectedItems,
             "alternatingRowColors", alternatingRowColors,
             "selectedText", selectedText
           );
  }

};

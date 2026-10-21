/**
  @copyright Copyright 2026 winccoa-tools-pack
  SPDX-License-Identifier: MIT
*/

#uses "classes/splash/shapes/GuiTestShape"

//-----------------------------------------------------------------------------
/** DpTree shape
*/
class GuiTestDpTree : GuiTestShape
{
//@public members

  //---------------------------------------------------------------------------
  /**
    @brief Creates a wrapper for one panel shape instance.
    @param testShape Shape object to inspect and validate.
  */
  public GuiTestDpTree(const shape/*<"???">*/ &testShape)
  {
    this.testShape = testShape;
  }

  /**
    @brief Expands a DPE-tree item and navigates to the requested element.
    @param element DPE or config path to expand.
    @return 0 when selected, -1 when the shape is missing, -2 for an invalid
            element, or -3 when the requested item cannot be selected.
  */
  public int expandElement(const string &element)
  {
    if (!shapeExists(this.testShape))
      return -1;

    const string dpe = dpSubStr(element, DPSUB_SYS_DP_EL);
    const string config = dpSubStr(element, DPSUB_CONF);

    if (dpe.isEmpty())
      return -2;

    this.testShape.ExpandElements(element);

    string selectedElement;

    for (int attempt = 0; attempt < 25; attempt++)
    {
      sendKeyClick(this.testShape, "", KEY_DOWN, 0);
      selectedElement = this.testShape.selectedItem();

      if (selectedElement == dpe)
        break;
    }

    if (!config.isEmpty())
    {
      sendKeyClick(this.testShape, "", KEY_RIGHT, 0);

      for (int attempt = 0; attempt < 25; attempt++)
      {
        sendKeyClick(this.testShape, "", KEY_DOWN, 0);
        selectedElement = this.testShape.selectedItem();

        if (selectedElement == dpe + config)
          break;
      }
    }

    const string expectedElement = dpe + config;
    return selectedElement == expectedElement ? 0 : -3;
  }

  //---------------------------------------------------------------------------
  /** Returns current values of usefull attributes.
    @return Mapping with current shape attributes.
    @note key must be string and values string|number|bools
  */
  public mapping getCurrentAttributes()
  {

    anytype visible, enabled, x, y, w, h;
    anytype font, cursor, selectedItem, layoutDirection, updatesEnabled;
    anytype headerHidden, itemsExpandable, lineWidth, midLineWidth;
    anytype rootIsDecorated, selectionBehavior, selectionMode;
    anytype sortingEnabled, uniformRowHeights;

    getValue(this.testShape,
             "visible", visible,
             "enabled", enabled,
             "position", x, y,
             "size", w, h,
             "font", font,
             "cursor", cursor,
             "selectedItem", selectedItem,
             "layoutDirection", layoutDirection,
             "updatesEnabled", updatesEnabled,
             "headerHidden", headerHidden,
             "itemsExpandable", itemsExpandable,
             "lineWidth", lineWidth,
             "midLineWidth", midLineWidth,
             "rootIsDecorated", rootIsDecorated,
             "selectionBehavior", selectionBehavior,
             "selectionMode", selectionMode,
             "sortingEnabled", sortingEnabled,
             "uniformRowHeights", uniformRowHeights);

    return makeMapping(
             "visible", visible,
             "enabled", enabled,
             "position.x", x,
             "position.y", y,
             "size.w", w,
             "size.h", h,
             "font", font,
             "selectedItem", selectedItem,
             "cursor", cursor,
             "updatesEnabled", updatesEnabled,
             "layoutDirection", layoutDirection,
             "headerHidden", headerHidden,
             "itemsExpandable", itemsExpandable,
             "lineWidth", lineWidth,
             "midLineWidth", midLineWidth,
             "rootIsDecorated", rootIsDecorated,
             "selectionBehavior", selectionBehavior,
             "selectionMode", selectionMode,
             "sortingEnabled", sortingEnabled,
             "uniformRowHeights", uniformRowHeights
           );
  }

//@protected members

//@private members
};

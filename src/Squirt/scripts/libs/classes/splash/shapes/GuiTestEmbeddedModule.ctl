#uses "classes/splash/shapes/GuiTestShape"

//-----------------------------------------------------------------------------
/** Embedded Module shape
*/
class GuiTestEmbeddedModule : GuiTestShape
{
//-----------------------------------------------------------------------------
//@public members
//-----------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  public GuiTestEmbeddedModule(const shape/*<"???">*/ &testShape)
  {
    this.testShape = testShape;
  }

  //---------------------------------------------------------------------------
  /** Returns current values of usefull attributes.
    @note key must be string and values string|number|bools
  */
  public mapping getCurrentAttributes()
  {

    bool visible, enabled, focus, isActiveWindow, newPanelAnimateOpacity, newPanelAnimateSize, oldPanelAnimateOpacity, oldPanelAnimateSize, updatesEnabled,
         windowModified;
    int x1, y1, w, h;
    int        contentsHeight, contentsWidth, contentsX, contentsY, cursor, frameWidth, height, lineWidth, midLineWidth, newPanelAnimDuration,
               oldPanelAnimDuration, toolTipDuration, visibleHeight, visibleWidth, width, x, y;
    float      windowOpacity;
    string     accessibleDescription, accessibleName, alignment, frameShadow, frameShape, horizontalScrollBarPolicy,
               inputMethodHints, ModuleName, newPanelAnimType, newPanelEasingCurve, oldPanelAnimType, oldPanelEasingCurve, sizeAdjustPolicy,
               statusTip, styleSheet, verticalScrollBarPolicy, vScrollBarMode, whatsThis, hScrollBarMode;

    getValue(this.testShape,
             "visible", visible,
             "enabled", enabled,
             "position", x1, y1,
             "size", w, h,
             "focus", focus,
             "isActiveWindow", isActiveWindow,
             "newPanelAnimateOpacity", newPanelAnimateOpacity,
             "newPanelAnimateSize", newPanelAnimateSize,
             "oldPanelAnimateOpacity", oldPanelAnimateOpacity,
             "oldPanelAnimateSize", oldPanelAnimateSize,
             "updatesEnabled", updatesEnabled,
             "windowModified", windowModified,
             "windowOpacity", windowOpacity,
             "contentsHeight", contentsHeight,
             "contentsWidth", contentsWidth,
             "contentsX", contentsX,
             "contentsY", contentsY,
             "cursor", cursor,
             "frameWidth", frameWidth,
             "height", height,
             "lineWidth", lineWidth,
             "midLineWidth", midLineWidth,
             "newPanelAnimDuration", newPanelAnimDuration,
             "oldPanelAnimDuration", oldPanelAnimDuration,
             "toolTipDuration", toolTipDuration,
             "visibleHeight", visibleHeight,
             "visibleWidth", visibleWidth,
             "width", width,
             "x", x,
             "y", y,
             "accessibleDescription", accessibleDescription,
             "accessibleName", accessibleName,
             "alignment", alignment,
             "frameShadow", frameShadow,
             "frameShape", frameShape,
             "horizontalScrollBarPolicy", horizontalScrollBarPolicy,
             "inputMethodHints", inputMethodHints,
             "ModuleName", ModuleName,
             "newPanelAnimType", newPanelAnimType,
             "newPanelEasingCurve", newPanelEasingCurve,
             "oldPanelAnimType", oldPanelAnimType,
             "oldPanelEasingCurve", oldPanelEasingCurve,
             "sizeAdjustPolicy", sizeAdjustPolicy,
             "statusTip", statusTip,
             "styleSheet", styleSheet,
             "verticalScrollBarPolicy", verticalScrollBarPolicy,
             "vScrollBarMode", vScrollBarMode,
             "whatsThis", whatsThis,
             "hScrollBarMode", hScrollBarMode);

    return makeMapping(
             "visible", visible,
             "enabled", enabled,
             "position.x", x,
             "position.y", y,
             "size.w", w,
             "size.h", h,
             "focus", focus,
             "isActiveWindow", isActiveWindow,
             "newPanelAnimateOpacity", newPanelAnimateOpacity,
             "newPanelAnimateSize", newPanelAnimateSize,
             "oldPanelAnimateOpacity", oldPanelAnimateOpacity,
             "oldPanelAnimateSize", oldPanelAnimateSize,
             "updatesEnabled", updatesEnabled,
             "windowModified", windowModified,
             "windowOpacity", windowOpacity,
             "contentsHeight", contentsHeight,
             "contentsWidth", contentsWidth,
             "contentsX", contentsX,
             "contentsY", contentsY,
             "cursor", cursor,
             "frameWidth", frameWidth,
             "height", height,
             "lineWidth", lineWidth,
             "midLineWidth", midLineWidth,
             "newPanelAnimDuration", newPanelAnimDuration,
             "oldPanelAnimDuration", oldPanelAnimDuration,
             "toolTipDuration", toolTipDuration,
             "visibleHeight", visibleHeight,
             "visibleWidth", visibleWidth,
             "width", width,
             "x", x,
             "y", y,
             "accessibleDescription", accessibleDescription,
             "accessibleName", accessibleName,
             "alignment", alignment,
             "frameShadow", frameShadow,
             "frameShape", frameShape,
             "horizontalScrollBarPolicy", horizontalScrollBarPolicy,
             "inputMethodHints", inputMethodHints,
             "ModuleName", ModuleName,
             "newPanelAnimType", newPanelAnimType,
             "newPanelEasingCurve", newPanelEasingCurve,
             "oldPanelAnimType", oldPanelAnimType,
             "oldPanelEasingCurve", oldPanelEasingCurve,
             "sizeAdjustPolicy", sizeAdjustPolicy,
             "statusTip", statusTip,
             "styleSheet", styleSheet,
             "verticalScrollBarPolicy", verticalScrollBarPolicy,
             "vScrollBarMode", vScrollBarMode,
             "whatsThis", whatsThis,
             "hScrollBarMode", hScrollBarMode
           );
  }

};

#uses "classes/splash/shapes/GuiTestShape"

//-----------------------------------------------------------------------------
/** Slider shape
*/
class GuiTestSlider : GuiTestShape
{
//-----------------------------------------------------------------------------
//@public members
//-----------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  public GuiTestSlider(const shape/*<"???">*/ &testShape)
  {
    this.testShape = testShape;
  }

  //---------------------------------------------------------------------------
  /** Returns current values of usefull attributes.
    @note key must be string and values string|number|bools
  */
  public mapping getCurrentAttributes()
  {

    bool visible, enabled;
    bool invertedAppearance, invertedControls, isActiveWindow, sliderDown, tracking, updatesEnabled, windowModified, focus;
    int x1, y1, w, h;
    int cursor, height, lineStep, maximum, maxValue, minimum, minValue, pageStep, singleStep, sliderPosition, tickInterval, toolTipDuration,
    value, Value, width, x, y, BorderWidth;
    string accessibleDescription, accessibleName, contextMenuPolicy, inputMethodHints, layoutDirection, orientation, statusTip,
           styleSheet, tickPosition;
    float windowOpacity;

    getValue(this.testShape,
             "visible", visible,
             "enabled", enabled,
             "position", x1, y1,
             "size", w, h,
             "accessibleDescription", accessibleDescription,
             "accessibleName", accessibleName,
             "contextMenuPolicy", contextMenuPolicy,
             "inputMethodHints", inputMethodHints,
             "layoutDirection", layoutDirection,
             "orientation", orientation,
             "statusTip", statusTip,
             "styleSheet", styleSheet,
             "tickPosition", tickPosition,
             "cursor", cursor,
             "focus", focus,
             "height", height,
             "lineStep", lineStep,
             "maximum", maximum,
             "maxValue", maxValue,
             "minimum", minimum,
             "minValue", minValue,
             "pageStep", pageStep,
             "singleStep", singleStep,
             "sliderPosition", sliderPosition,
             "tickInterval", tickInterval,
             "toolTipDuration", toolTipDuration,
             "value", value,
             "width", width,
             "x", x,
             "y", y,
             "BorderWidth", BorderWidth,
             "Value", Value,
             "invertedAppearance", invertedAppearance,
             "invertedControls", invertedControls,
             "isActiveWindow", isActiveWindow,
             "sliderDown", sliderDown,
             "tracking", tracking,
             "updatesEnabled", updatesEnabled,
             "windowModified", windowModified,
             "BorderWidth", BorderWidth,
             "windowOpacity", windowOpacity);

    return makeMapping(
             "visible", visible,
             "enabled", enabled,
             "position.x", x1,
             "position.y", y1,
             "size.w", w,
             "size.h", h,
             "accessibleDescription", accessibleDescription,
             "accessibleName", accessibleName,
             "contextMenuPolicy", contextMenuPolicy,
             "inputMethodHints", inputMethodHints,
             "layoutDirection", layoutDirection,
             "orientation", orientation,
             "statusTip", statusTip,
             "styleSheet", styleSheet,
             "tickPosition", tickPosition,
             "cursor", cursor,
             "focus", focus,
             "height", height,
             "lineStep", lineStep,
             "maximum", maximum,
             "maxValue", maxValue,
             "minimum", minimum,
             "minValue", minValue,
             "pageStep", pageStep,
             "singleStep", singleStep,
             "sliderPosition", sliderPosition,
             "tickInterval", tickInterval,
             "toolTipDuration", toolTipDuration,
             "value", value,
             "width", width,
             "x", x,
             "y", y,
             "BorderWidth", BorderWidth,
             "Value", Value,
             "invertedAppearance", invertedAppearance,
             "invertedControls", invertedControls,
             "isActiveWindow", isActiveWindow,
             "sliderDown", sliderDown,
             "tracking", tracking,
             "updatesEnabled", updatesEnabled,
             "windowModified", windowModified,
             "BorderWidth", BorderWidth,
             "windowOpacity", windowOpacity
           );
  }

};

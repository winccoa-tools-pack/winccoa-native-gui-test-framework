/**
  @copyright Copyright 2026 winccoa-tools-pack
  SPDX-License-Identifier: MIT
*/

#uses "classes/splash/shapes/GuiTestShape"

/**
  @brief Wrapper for a WinCC OA SPACER shape.
  @AIgeneratedHelpContent
*/
class GuiTestSpacer : GuiTestShape
{
//@public members

//@protected members

//@private members

//@public functions

  /**
    @brief Creates a wrapper for one panel spacer.
    @param testShape Live SPACER shape to inspect.
  */
  public GuiTestSpacer(const shape &testShape)
  {
    this.testShape = testShape;
  }

  /**
    @brief Returns the spacer's visibility and geometry.
    @return Mapping containing the supported SPACER attributes.
  */
  public mapping getCurrentAttributes()
  {
    bool visible;
    int x, y, width, height;

    getValue(this.testShape,
             "visible", visible,
             "position", x, y,
             "size", width, height);

    return makeMapping("visible", visible,
                       "position.x", x,
                       "position.y", y,
                       "size.w", width,
                       "size.h", height);
  }
};

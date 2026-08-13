#uses "classes/splash/shapes/GuiTestShape"

//-----------------------------------------------------------------------------
/** Polygon shape
*/
class GuiTestPolygon : GuiTestShape
{
//-----------------------------------------------------------------------------
//@public members
//-----------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  public GuiTestPolygon(const shape/*<"POLYGON">*/ &testShape)
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
//     int x, y, w, h;
//     dyn_dyn_int points;
    string foreCol, backCol;

    getValue(this.testShape,
             "visible", visible,
             "enabled", enabled,
             /*"position", x, y,
             "size", w, h*/
//              "points", points,
             "foreCol", foreCol,
             "backCol", backCol);


    return makeMapping(
             "visible", visible,
             "enabled", enabled,
//              "position.x", x,
//              "position.y", y,
//              "size.w", w,
//              "size.h", h,
//              "points", jsonEncode(points, true),
             "foreCol", foreCol,
             "backCol", backCol
           );
  }

};



//-----------------------------------------------------------------------------
/** Abstract class to test shapes in a panel.
  @AIgeneratedHelpContent
*/
class GuiTestShape
{

//-----------------------------------------------------------------------------
//@public members
//-----------------------------------------------------------------------------

  //---------------------------------------------------------------------------
  /**
    @brief Checks whether current shape attributes match reference attributes.
    @param referenceAttributes Expected shape attributes.
    @param fails Collected mismatch messages.
    @return 0 when all attributes match, otherwise -1.
  */
  public int assertAttributes(const mapping &referenceAttributes, dyn_string &fails)
  {
    throwError(makeError("", PRIO_INFO, ERR_CONTROL, 0, tr("Validate shape $1 of type $2").subst(toString(), testShape.shapeType)));



    // because some shape getters writes only warning in the log, but the gteValue() function still returns 0
    setThrowErrorAsException(true);

    const mapping currentAttributes = this.getCurrentAttributes();

    vector <string> attributes = referenceAttributes.keys();

    for (int i = 0; i < attributes.count(); i++)
    {
      const string attribute = attributes.at(i);

      if (!currentAttributes.contains(attribute))
      {
        fails.append(tr("The shape $1 does not contains atribute $2").subst(this.toString(), attribute));
      }

      const anytype currentValue = currentAttributes.value(attribute);
      const anytype referencetValue = referenceAttributes.value(attribute);

      if (currentValue != referencetValue)
      {
        fails.append("    + " + tr("Current value on the atribute '$1' does not equals with reference value\n").subst(attribute) +
                     "        " + tr("Current: $1").subst(currentValue) + "\n" +
                     "        " + tr("Reference: $1").subst(referencetValue));
      }

    }

    setThrowErrorAsException(false);

    return fails.count() == 0 ? 0 : -1;
  }

  //---------------------------------------------------------------------------
  /**
    @brief Returns a readable shape identifier for logs and assertions.
    @return Shape name with optional name path.
  */
  public string toString()
  {
    string str = this.testShape.name;

    if (!this.testShape.namePath.isEmpty())
      str += "(" + this.testShape.namePath + ")";

    return str;
  }

  //---------------------------------------------------------------------------
  /**
    @brief Shows a temporary visual attention marker for the test shape.
    @param state Visual state indicator, e.g. OK or FAIL.
  */
  public void showAttention(const string &state)
  {

    int x, y;
    getValue(this.testShape, "position", x, y);

    DebugTN("position", x, y);

//      DebugN("ÖÖÖÖÖÖÖÖÖÖÖÖÖÖÖÖÖÖÖÖÖÖ pos 120/100 ?????",x,y);

    getValue(this.testShape, "refPoint", x, y);
    DebugTN("refPoint", x, y);

//      DebugN("ÖÖÖÖÖÖÖÖÖÖÖÖÖÖÖÖÖÖÖÖÖÖ pos 120/100 ????? ref",x,y);
//     center of the shape
    int w, h;
    getValue(this.testShape, "size", w, h);
    DebugTN("size", w, h);
    x += w / 2;
    y += h / 2;
//  DebugN("ÖÖÖÖÖÖÖÖÖÖÖÖÖÖÖÖÖÖÖÖÖÖ pos 120/100",x,y);
//     getValue(this.testShape, "mapFromGlobal", x,y,x,y);
//     getValue(this.testShape, "mapToGlobal", x,y,x,y);
//   this.mapToGlobal(x,y, gx,gy)


    shape panel = this.testShape.shapeType == "PANEL" ? this.testShape : this.testShape.panel;
    shape shEwo = addShape(panel, 8, "AttentionEffect_ewo", "recordInspection");

    if (state == "OK")
      shEwo.color1 = "green";


    int w, h;
    getValue(shEwo, "size", w, h);

    DebugTN("size ewo", w, h);
    float f;
    getZoomFactor(f, panel.moduleName);
    shEwo.position(x, y);
    shEwo.start();

    if (state == "OK")
      delay(0, 500);
    else
      delay(2);

    removeShape(shEwo);
  }


  //---------------------------------------------------------------------------
  /**
    @brief Returns the current attributes of the wrapped shape.
    @return Mapping containing current shape attributes.
  */
  public mapping getCurrentAttributes() = 0;

//-----------------------------------------------------------------------------
//@protected members
//-----------------------------------------------------------------------------

  /// Holder to real shape.
  protected shape testShape;

};

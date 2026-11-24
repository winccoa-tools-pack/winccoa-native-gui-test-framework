/**
  @copyright Copyright 2026 winccoa-tools-pack
  SPDX-License-Identifier: MIT
*/



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
    if (firstTimeCheck)
    {
      throwError(makeError("", PRIO_INFO, ERR_CONTROL, 0, tr("Validate shape $1 of type $2").subst(toString(), testShape.shapeType)));
      firstTimeCheck = false;
    }



    // because some shape getters writes only warning in the log, but the gteValue() function still returns 0
    setThrowErrorAsException(true);

    const mapping currentAttributes = this.getCurrentAttributes();

    vector <string> attributes = referenceAttributes.keys();

    for (int i = 0; i < attributes.count(); i++)
    {
      const string attribute = attributes.at(i);

      if (!currentAttributes.contains(attribute))
      {
        fails.append(tr("The shape $1 does not contains atribute $2.").subst(this.toString(), attribute));
        continue;
      }

      mixed currentValue = currentAttributes.value(attribute);
      const anytype referencetValue = referenceAttributes.value(attribute);

      if (this.isNull(currentValue) != this.isNull(referencetValue))
      {
        // when current and reference nullity differs
        if (this.isNull(currentValue))
        {
          fails.append(tr("The shape $1 has a null value for attribute $2").subst(this.toString(), attribute));
          continue;
        }

        if (this.isNull(referencetValue))
        {
          fails.append(tr("The reference value for attribute $2 is null on shape $1").subst(attribute, this.toString()));
          continue;
        }
      }

      // Handle special cases for language string types before comparison
      // WinCC OA lang string in saved in JSON as mapping <language, text>
      if (getType(currentValue) == LANGSTRING_VAR && getType(referencetValue) == MAPPING_VAR)
      {
        currentValue = jsonDecode(jsonEncode(currentValue, /*compactMode*/ false))[1];
      }
      else if (getType(currentValue) == DYN_LANGSTRING_VAR && getType(referencetValue) == DYN_ANYTYPE_VAR)
      {
        currentValue = jsonDecode(jsonEncode(currentValue, /*compactMode*/ false));
      }

      if (currentValue != referencetValue)
      {
        // DebugTN(currentValue, referencetValue, currentValue != referencetValue);
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

    getValue(this.testShape, "refPoint", x, y);
    int w, h;
    getValue(this.testShape, "size", w, h);
    x += w / 2;
    y += h / 2;

    shape panel = this.testShape.shapeType == "PANEL" ? this.testShape : this.testShape.panel;
    shape shEwo = addShape(panel, 8, "AttentionEffect_ewo", "recordInspection");

    if (state == "OK")
      shEwo.color1 = "green";

    int w, h;
    getValue(shEwo, "size", w, h);

    float f;
    getZoomFactor(f, panel.moduleName);
    shEwo.position(x, y);
    shEwo.start();

    if (state == "OK")
      delay(0, 100);
    else
      delay(5);

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

//-----------------------------------------------------------------------------
//@private members
//-----------------------------------------------------------------------------
  bool firstTimeCheck = true;

  //------------------------------------------------------------------------------
  private bool isNull(const anytype &value)
  {
    const int exprType = getType(value);

    switch (exprType)
    {
      case ANYTYPE_VAR:
      case MIXED_VAR:
        return TRUE;

      default:
        return FALSE;
    }
  }
};

/**
  @copyright Copyright 2026 winccoa-tools-pack
  SPDX-License-Identifier: MIT
*/

// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author mPokorny
*/


/**
  @brief Creates localized WinCC OA error messages and logs them at a chosen priority.
  @details Severe messages are thrown as exceptions; other priorities are sent
           through throwError(). String messages are wrapped in the configured
           message catalog, while existing error objects are passed through.
  @AIgeneratedHelpContent
*/
class OaLogger
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /**
    @brief Creates a logger using an optional message catalog.
    @param msgCatalog Message catalog used when constructing errors from text.
  */
  public OaLogger(const string msgCatalog = "")
  {
    this.msgCatalog = msgCatalog;
  }

  //------------------------------------------------------------------------------
  /**
    @brief Logs or throws an informational message.
    @param codeOrError Message text, error code, or existing error object.
    @param note Optional first substitution value or error note.
    @param note2 Optional second substitution value or error note.
    @param note3 Optional third substitution value or error note.
  */
  public void info(const anytype &codeOrError,
                   const anytype note = NULL,
                   const anytype note2 = NULL,
                   const anytype note3 = NULL)
  {
    _throw(codeOrError, PRIO_INFO, note, note2, note3);
  }

  //------------------------------------------------------------------------------
  /**
    @brief Logs or throws a warning message.
    @param codeOrError Message text, error code, or existing error object.
    @param note Optional first substitution value or error note.
    @param note2 Optional second substitution value or error note.
    @param note3 Optional third substitution value or error note.
  */
  public void warning(const anytype &codeOrError,
                      const anytype note = NULL,
                      const anytype note2 = NULL,
                      const anytype note3 = NULL)
  {
    _throw(codeOrError, PRIO_WARNING, note, note2, note3);
  }

  //------------------------------------------------------------------------------
  /**
    @brief Throws a severe error message.
    @param codeOrError Message text, error code, or existing error object.
    @param note Optional first substitution value or error note.
    @param note2 Optional second substitution value or error note.
    @param note3 Optional third substitution value or error note.
  */
  public void severe(const anytype &codeOrError,
                     const anytype note = NULL,
                     const anytype note2 = NULL,
                     const anytype note3 = NULL)
  {
    _throw(codeOrError, PRIO_SEVERE, note, note2, note3);
  }

  //------------------------------------------------------------------------------
  /**
    @brief Logs or throws a fatal message.
    @param codeOrError Message text, error code, or existing error object.
    @param note Optional first substitution value or error note.
    @param note2 Optional second substitution value or error note.
    @param note3 Optional third substitution value or error note.
  */
  public void fatal(const anytype &codeOrError,
                    const anytype note = NULL,
                    const anytype note2 = NULL,
                    const anytype note3 = NULL)
  {
    _throw(codeOrError, PRIO_FATAL, note, note2, note3);
  }
  /** Message catalog used when constructing errors from plain text. */
  protected string msgCatalog;
  //------------------------------------------------------------------------------
  /**
    @brief Constructs and emits an error using the requested priority.
    @param codeOrError Message text, error code, or existing error object.
    @param prio WinCC OA error priority.
    @param note Optional first substitution value or error note.
    @param note2 Optional second substitution value or error note.
    @param note3 Optional third substitution value or error note.
  */
  protected _throw(const anytype &codeOrError,
                   const int prio,
                   const anytype &note,
                   const anytype &note2,
                   const anytype &note3)
  {
    dyn_errClass err;

    if (isA(codeOrError, STRING_VAR))
    {
      err = makeError(msgCatalog, prio, ERR_CONTROL, 0, codeOrError);
    }
    else if (isA(codeOrError, ERRCLASS_VAR) || isA(codeOrError, DYN_ERRCLASS_VAR))
    {
      err = codeOrError;
    }
    else if (!this.isNull(note3))
    {
      err = makeError(msgCatalog, prio, ERR_CONTROL, (int)codeOrError, note, note2, note3);
    }
    else if (!this.isNull(note2))
    {
      err = makeError(msgCatalog, prio, ERR_CONTROL, (int)codeOrError, note, note2);
    }
    else if (!this.isNull(note))
    {
      err = makeError(msgCatalog, prio, ERR_CONTROL, (int)codeOrError, note);
    }
    else
    {
      err = makeError(msgCatalog, prio, ERR_CONTROL, (int)codeOrError);
    }

    if (prio == PRIO_SEVERE)
      throw(err);
    else
      throwError(err);
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------

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
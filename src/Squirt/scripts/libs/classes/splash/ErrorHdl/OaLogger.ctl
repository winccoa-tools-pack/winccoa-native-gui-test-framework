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


class OaLogger
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /**
  */
  public OaLogger(const string msgCatalog = "")
  {
    this.msgCatalog = msgCatalog;
  }

  //------------------------------------------------------------------------------
  /**
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
  */
  public void fatal(const anytype &codeOrError,
                    const anytype note = NULL,
                    const anytype note2 = NULL,
                    const anytype note3 = NULL)
  {
    _throw(codeOrError, PRIO_FATAL, note, note2, note3);
  }


  protected string msgCatalog;
  //------------------------------------------------------------------------------
  /**
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
//-----------------------------------------------------------------------------
/**
  @file $relPath
  @copyright Copyright 2026 winccoa-tools-pack
             SPDX-License-Identifier: MIT
  @AIgeneratedHelpContent
*/

#uses "classes/file/File"
#uses "fileSystem"

//-----------------------------------------------------------------------------
/**
  Check and optionally update copyright headers in CTL files.

  @param sourcePath Path to recursively scanned CTL files.
  @param owner Expected copyright owner string.
  @param spdx Expected SPDX identifier.
  @param updateIfNeeded If true, replace previous-year and legacy vendor headers.
*/
main(string sourcePath, string owner = "winccoa-tools-pack", string spdx = "MIT", bool updateIfNeeded = FALSE)
{
  dyn_string files = getFileNamesRecursive(sourcePath, "*.ctl");
  dyn_string filesToCheck;

  for (int i = 1; i <= dynlen(files); i++)
  {
    const string path = makeUnixPath(files[i]);

    dynAppend(filesToCheck, path);
  }

  const uint now = year(getCurrentTime());
  const string correct = "Copyright " + now + " " + owner;
  const string previous = "Copyright " + (now - 1) + " " + owner;

  int mismatchCount = 0;

  for (int i = 1; i <= dynlen(filesToCheck); i++)
  {
    const File ctlFile = File(filesToCheck[i]);
    string content;

    if (ctlFile.read(content))
      continue;

    bool changed = FALSE;
    const string expectedLicense = "SPDX-License-Identifier: " + spdx;
    bool hasExpectedLicense = content.contains(expectedLicense);
    bool hasExpectedCopyright = content.contains(correct);

    if (updateIfNeeded)
    {
      if (strreplace(content, previous, correct) > 0)
        changed = TRUE;

      if (strreplace(content, "SIEMENS AG", owner) > 0)
        changed = TRUE;

      if (strreplace(content, "SPDX-License-Identifier: GPL-3.0-only",
             expectedLicense) > 0)
        changed = TRUE;

      // Try replacing a range of older copyright years (reasonable recent range)
      for (int y = now - 10; y <= now; y++)
      {
        const string oldYear = "Copyright " + y + " " + owner;
        if (strreplace(content, oldYear, correct) > 0)
          changed = TRUE;
      }

      // Fallback: if still missing the expected copyright, prepend a minimal header
      if (!content.contains(correct) && !content.contains(previous) && !content.contains("Copyright") )
      {
        const string hdr = "/**\n  @copyright " + correct + "\n  " + expectedLicense + "\n*/\n\n";
        content = hdr + content;
        changed = TRUE;
      }

      if (changed && ctlFile.write(content) != 0)
        throwError(makeError("", PRIO_INFO, ERR_CONTROL, 0,
                             "Cannot update copyright", ctlFile.getPath()));

      hasExpectedLicense = content.contains(expectedLicense);
      hasExpectedCopyright = content.contains(correct);
    }

    if (!hasExpectedLicense || !hasExpectedCopyright)
    {
      mismatchCount++;
      throwError(makeError("", PRIO_WARNING, ERR_CONTROL, 0,
                           "Unexpected copyright or license header",
                           ctlFile.getPath()));
    }
  }

  DebugTN("copyright mismatches", mismatchCount);
}

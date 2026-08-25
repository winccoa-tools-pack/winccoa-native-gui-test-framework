//-----------------------------------------------------------------------------
/**
  @file $relPath
  @copyright Copyright 2026 winccoa-tools-pack
             SPDX-License-Identifier: MIT
  @AIgeneratedHelpContent
*/

#uses "fileSystem"

//-----------------------------------------------------------------------------
/**
  Run astyle for all CTL files below the given source path.

  @param sourcePath Directory to scan recursively for CTL files.
  @param applyChanges If true, format files in place. If false, dry-run only.
*/
main(string sourcePath, bool applyChanges = FALSE)
{
  dyn_string args;
  string stdErr;
  string stdOut;

  dyn_string files = getFileNamesRecursive(sourcePath, "*.ctl");
  dyn_string filesToCheck;

  for (int i = 1; i <= dynlen(files); i++)
  {
    const string path = makeUnixPath(files[i]);

    dynAppend(filesToCheck, makeNativePath(path));
  }

  if (dynlen(filesToCheck) == 0)
  {
    DebugTN("No .ctl files found below", sourcePath);
    exit(1);
  }

  args[1] = getPath(BIN_REL_PATH, _WIN32 ? "astyle.exe" : "astyle");
  args[2] = "--options=" + makeNativePath(getPath(CONFIG_REL_PATH, "astyle.config"));
  args[3] = "--suffix=none";
  if (!applyChanges)
    args[4] = "--dry-run";

  dynAppend(args, "--formatted");
 // dynAppend(args, "--quiet");
  dynAppend(args, filesToCheck);
  // DebugTN("Running astyle with args", args);
  int rc = system(args, stdOut, stdErr);

  strreplace(stdOut, "\r", "");
  strreplace(stdErr, "\r", "");

  if (stdOut != "")
  {
    // DebugTN("astyle stdout", stdOut);
    rc = 1; // astyle returns 0 even if files are not formatted correctly
    DebugTN("astyle found unformatted $1 files, return code set to".subst(dynlen(strsplit(stdOut, "\n"))), rc);
  }
  if (stdErr != "")
    DebugTN("astyle stderr", stdErr);
  
  if (rc != 0)
  {
    DebugTN("astyle failed with return code", rc);
    exit(rc);
  }
}

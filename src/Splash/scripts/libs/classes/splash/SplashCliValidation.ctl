/**
  @file $relPath
  @brief Validate project-relative paths accepted by the Splash CLI.
  @copyright MIT
  @AIgeneratedHelpContent
*/

/**
  @brief Validates a panel path rooted below the project's panels directory.
  @AIgeneratedHelpContent
*/
class SplashCliValidation
{
  //@public members

  /**
    @brief Checks a relative .pnl path; one leading slash is optional.
    @param path Panel path relative to the panels directory.
    @return true when the path is safe and names a panel file.
  */
  public bool isSafePanelPath(const string path)
  {
    string relativePath = path;

    if (relativePath.startsWith("/"))
      relativePath = substr(relativePath, 1);

    if (!relativePath.endsWith(".pnl") || relativePath.contains("\\") ||
        relativePath.contains(":") || relativePath.contains(".."))
      return FALSE;

    dyn_string parts = strsplit(relativePath, "/");

    for (int index = 1; index <= dynlen(parts); index++)
    {
      if (parts[index] == "" || parts[index] == ".")
        return FALSE;
    }

    return dynlen(parts) >= 1;
  }

  /**
    @brief Checks a test script path rooted below scripts/tests.
    @param path Project-relative path to a generated CTRL test script.
    @return true when the path is safe and names a nested .ctl file.
  */
  public bool isSafeTestScriptPath(const string path)
  {
    if (!path.startsWith("tests/") || !path.endsWith(".ctl") ||
        path.contains("\\") || path.contains(":") || path.contains(".."))
      return FALSE;

    dyn_string parts = strsplit(path, "/");

    for (int index = 1; index <= dynlen(parts); index++)
    {
      if (parts[index] == "" || parts[index] == ".")
        return FALSE;
    }

    return dynlen(parts) >= 3;
  }

  //@protected members

  //@private members
};
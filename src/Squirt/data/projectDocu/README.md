# projectDocu (runtime merge target)

WinCC OA discovers Doxygen extras next to
`data/projectDocu/advanced_doxygenConfig.txt` on the **worker** project.

Source assets live outside this tree and are merged here at docs-build time:

- `.documentation-theme/` (theme / HTML extras)
- `.winccoa-docu-builder/` (project advanced Doxygen config)

Do not commit generated `doxygenConfig.txt` or merged copies from CI.

---

<center>Made with ❤️ for and by the WinCC OA community</center>
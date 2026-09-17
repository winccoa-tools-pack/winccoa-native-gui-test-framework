# Project Docu Builder overrides

Project-local Doxygen advanced config and related assets for
`@winccoa-tools-pack/npm-winccoa-docu-builder`.

Merged into `src/Squirt/data/projectDocu` at docs-build time via
`--project-docu` / action input `project-docu-paths` (later paths override
earlier for non-advanced files; advanced configs concatenate).

## Contents

- `advanced_doxygenConfig.txt` — project advanced Doxygen fragment
  (WARN_LOGFILE, GENERATE_TODOLIST/BUGLIST, etc.)

Layer after org/theme sources, for example:

```yaml
project-docu-paths: |
  .doxygen-awesome-css
  .winccoa-docu-builder
```

---

<center>Made with ❤️ for and by the WinCC OA community</center>

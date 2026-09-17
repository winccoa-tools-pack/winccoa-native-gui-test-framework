# Project Docu Builder overrides

Project-local advanced documentation config and related assets for
`@winccoa-tools-pack/npm-winccoa-docu-builder`.

Merged into `src/Squirt/data/projectDocu` at docs-build time via
`--project-docu` / action input `project-docu-paths` (later paths override
earlier for non-advanced files; advanced configs concatenate).

## Contents

- Advanced documentation fragment
  (warning logfile, todo/bug lists, etc.)

Layer after org/theme sources, for example:

```yaml
project-docu-paths: |
  .documentation-theme
  .winccoa-docu-builder
```

---

<center>Made with ❤️ for and by the WinCC OA community</center>

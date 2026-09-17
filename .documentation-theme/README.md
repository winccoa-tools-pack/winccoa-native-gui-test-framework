# Documentation theme / extras

Temporary home for HTML extras used by the Squirt docs build.
Intended later as org-wide theme assets.

Top-level files in this directory are merged into
`src/Squirt/data/projectDocu` before `buildHelp.ctl` runs.

## Current files

- `extra_header.html`
- `extra_footer.html`
- `extra_stylesheet.css`

Pass this directory first in `project-docu-paths`, then project overrides:

```yaml
project-docu-paths: |
  .documentation-theme
  .winccoa-docu-builder
```

---

<center>Made with ❤️ for and by the WinCC OA community</center>

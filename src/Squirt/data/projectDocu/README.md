# Project Docu Builder overrides

Project-local advanced documentation config and related assets for
`@winccoa-tools-pack/npm-winccoa-docu-builder`.

Merged into `src/Squirt/data/projectDocu` at docs-build time via
`--project-docu` / action input `project-docu-paths` (later paths override
earlier for non-advanced files; advanced configs concatenate).

## Contents

- `advanced_doxygenConfig.txt`
  - warning logfile, todo/bug lists, aliases
  - **Doxygen Awesome** wiring (`HTML_EXTRA_STYLESHEET` / `HTML_EXTRA_FILES`,
    treeview, light color style)
- `scripts/` - local CLI helpers to fetch/sync the theme and merge sources
  (see [scripts/README.md](scripts/README.md))

Shared theme CSS/JS and header/footer live in the org repo
[`winccoa-tools-pack/docu-builder-theme`](https://github.com/winccoa-tools-pack/docu-builder-theme)
(checked out by the action when `theme-repository` is set, or prepared
locally by the helpers).

## Local prepare / build

```powershell
# Merge theme + this folder into src/Squirt/data/projectDocu
.\.winccoa-docu-builder\scripts\prepare-project-docu.ps1

# Optional: full CLI build (requires WinCC OA + Node)
.\.winccoa-docu-builder\scripts\run-docu-builder.ps1
```

```bash
bash .winccoa-docu-builder/scripts/prepare-project-docu.sh
bash .winccoa-docu-builder/scripts/run-docu-builder.sh build
```

With a multi-root workspace, the helper auto-picks sibling
`../docu-builder-theme`. Otherwise it clones into `.docu-builder-theme/`.

## CI layering

```yaml
theme-repository: winccoa-tools-pack/docu-builder-theme
theme-ref: main
project-docu-paths: |
  .winccoa-docu-builder
```

Optional pre-step when you want merged `data/projectDocu` on disk for
artifacts (action still merges again via the npm package):

```yaml
- name: Prepare projectDocu
  env:
    SKIP_THEME_FETCH: "1"  # theme already checked out to .docu-builder-theme
  run: bash .winccoa-docu-builder/scripts/prepare-project-docu.sh
```

Generated copies under `.docu-builder-theme/` and
`src/Squirt/data/projectDocu/*` (except README) are gitignored.

---

<!-- markdownlint-disable-next-line MD033 -->
<center>Made with ❤️ for and by the WinCC OA community</center>

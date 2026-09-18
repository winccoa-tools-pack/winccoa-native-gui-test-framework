# Contributing documentation

## Where content belongs

| Content type | Put it here |
| --- | --- |
| Public / protected API behavior | Doxygen blocks in `.ctl` next to the symbol |
| How-to guides, concepts, roadmaps | `docs/*.md` |
| Short project orientation | `README.md` (help main page) |
| Theme / Doxygen chrome only | shared `docu-builder-theme` + `.winccoa-docu-builder` |

## Markdown conventions

- Prefer short pages with a single top-level `#` title.
- Link between pages with relative paths (`usage.md`, `../README.md`).
- Keep lines readable; avoid duplicating full API reference in Markdown.
- End community Markdown docs with the repository footer block used elsewhere.

## Doxygen input

Advanced config appends:

- `$PROJ_PATH/README.md` as `USE_MDFILE_AS_MAINPAGE`
- `$PROJ_PATH/docs` for additional Markdown sources

After adding a page, rebuild help (local `run-docu-builder` or CI docs workflow)
and confirm the page appears in the tree view.

---

<center>Made with ❤️ for and by the WinCC OA community</center>

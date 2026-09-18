# Docu-builder local helpers

Shell helpers to prepare the shared documentation theme and run
`@winccoa-tools-pack/npm-winccoa-docu-builder` from this repository.

## What they do

1. Resolve the org theme (`winccoa-tools-pack/docu-builder-theme`)
2. Copy **top-level** theme files into `.docu-builder-theme/` when needed
3. Merge theme + `.winccoa-docu-builder` into `src/Squirt/data/projectDocu`
4. Optionally invoke `winccoa-docu-builder build|register`

Merge rules match the npm package:

- top-level files only
- `advanced_doxygenConfig.txt` is concatenated
- other files last-wins

## Scripts

| Script | Role |
| --- | --- |
| `prepare-project-docu.sh` / `.ps1` | Fetch/sync theme + merge into worker `data/projectDocu` |
| `merge-project-docu.sh` / `.ps1` | Pure merge of given source dirs |
| `run-docu-builder.sh` / `.ps1` | prepare + CLI build/register |

## Local usage (Windows)

From the repository root:

```powershell
# Merge only (uses sibling ../docu-builder-theme when present)
.\.winccoa-docu-builder\scripts\prepare-project-docu.ps1

# Full build (installs npm package into repo root if CLI missing)
.\.winccoa-docu-builder\scripts\run-docu-builder.ps1
.\.winccoa-docu-builder\scripts\run-docu-builder.ps1 prepare
```

Explicit local theme path:

```powershell
$env:THEME_SOURCE = "C:\ws\winccoa-tools-pack\docu-builder-theme"
.\.winccoa-docu-builder\scripts\run-docu-builder.ps1 prepare
```

## Local usage (bash / GitHub Actions)

```bash
# Merge only
bash .winccoa-docu-builder/scripts/prepare-project-docu.sh

# Full build
bash .winccoa-docu-builder/scripts/run-docu-builder.sh build
```

Optional env:

| Variable | Default | Meaning |
| --- | --- | --- |
| `THEME_PATH` | `.docu-builder-theme` | Checkout / sync destination |
| `THEME_REPOSITORY` | `winccoa-tools-pack/docu-builder-theme` | GitHub repo |
| `THEME_REF` | `main` | Git ref |
| `THEME_SOURCE` | empty | Local theme tree (preferred over clone) |
| `SKIP_THEME_FETCH` | `0` | Fail if theme missing instead of cloning |
| `WORKER_PATH` | `src/Squirt` | Worker project |
| `WINCCOA_VERSION` | `3.21` | Passed to CLI |
| `COMPANY_NAME` | `winccoa-tools-pack` | Passed to build |
| `PACKAGE_VERSION` | `0.2.1` | npm bootstrap version |
| `SKIP_PREPARE` | `0` | Skip merge (CLI still gets `--project-docu`) |

## GitHub workflow note

The composite action already checks out `theme-repository` and passes
`project-docu-paths` into the npm package (which merges again). You can still
call `prepare-project-docu.sh` before the action when you want the merged
`data/projectDocu` tree on disk for debugging/artifacts:

```yaml
- name: Prepare projectDocu (theme + overrides)
  env:
    THEME_PATH: .docu-builder-theme
    # Theme already checked out by a prior step, or:
    # THEME_SOURCE: path/to/theme
    SKIP_THEME_FETCH: "1"   # when theme is already present
  run: bash .winccoa-docu-builder/scripts/prepare-project-docu.sh
```

When using `theme-repository` on the action, prefer letting the action own
checkout+merge unless you need the prepared tree as an artifact.

## Generated paths (gitignored)

- `.docu-builder-theme/` - local theme checkout/sync
- `src/Squirt/data/projectDocu/*` except `README.md` - merged runtime files
- `node_modules/` - optional local CLI bootstrap from `run-docu-builder.*`

---

<!-- markdownlint-disable-next-line MD033 -->
<center>Made with ❤️ for and by the WinCC OA community</center>

# Architecture

Squirt is a WinCC OA **subproject** that provides a native GUI test framework
for panels.

## Main areas

| Area | Location | Role |
| --- | --- | --- |
| Core libraries | `scripts/libs` | Shared CTL helpers and test plumbing |
| Shape wrappers | `scripts/libs/classes/splash/shapes` | Shape-specific test APIs |
| Panels | `panels` | Framework UI and helpers |
| Images / messages | `images`, `msg` | Assets and localization |
| Narrative docs | `docs` | Guides and concepts (this tree) |
| Generated help | `help` | Doxygen HTML / QHP output |

## Documentation split

- **CTL Doxygen comments** document public and protected APIs next to the code.
- **`docs/*.md`** documents workflows, architecture, and conventions that are
  awkward or noisy as in-source comments.
- **`README.md`** is the help **main page** (overview and quick orientation).

## Build pipeline (summary)

1. Theme and project overrides merge into `data/projectDocu`.
2. WCCOActrl runs `buildHelp.ctl` with advanced Doxygen config enabled.
3. Doxygen scans CTL sources plus Markdown listed in advanced config
   (`README.md` and `docs/`).

---

<center>Made with ❤️ for and by the WinCC OA community</center>

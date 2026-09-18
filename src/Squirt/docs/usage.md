# Usage

Squirt GUI tests follow the WinCC OA `OaTest` concept.

## Typical workflow

1. Record macros and verification points against native panels (`.pnl` / `.xml`).
2. Replay tests locally (GEDI + HSP) or from the command line.
3. Run the same suites under WinCC OA TestFramework in CI/CD.
4. Review assertion logs and screenshots on failures.

## Execution modes

| Mode | When to use |
| --- | --- |
| GEDI + HSP | Interactive development and local debugging |
| Command line | Repeatable local runs without the IDE UI |
| TestFramework / CI | Automated gates and release validation |

## Shape addressing constraints

- Do not use `:` in panel names.
- Do not leave shape names empty.
- Prefer unique shape names (especially inside Tab shapes).
- Avoid randomly generated module, panel, or shape names.

Only WinCC OA shapes can be recorded and replayed (no file selectors,
printers, and similar OS dialogs).

---

<center>Made with ❤️ for and by the WinCC OA community</center>

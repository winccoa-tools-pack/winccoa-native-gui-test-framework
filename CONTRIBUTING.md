# Contributing

Thank you for contributing to this repository.

## Before you start

- Create a focused branch for your change.
- Keep pull requests small and reviewable.
- Prefer changes that are easy to test and revert.

## Coding guidelines

- Follow existing CTL style and naming conventions in the touched files.
- Avoid unrelated refactors in the same pull request.
- Add short comments only where logic is non-obvious.

## Tests and validation

- Run relevant GUI tests for impacted panels/shapes.
- For behavior changes, include at least one reproducible validation step.
- When possible, update or add VP data and screenshots for changed behavior.

## Commit and PR guidance

- Use clear commit messages describing what and why.
- In PR descriptions, include:
  - scope of change
  - risk or compatibility notes
  - test evidence (steps, logs, screenshots)

## Reporting issues

When reporting a bug, include:

- WinCC OA version
- panel/module name
- reproduction steps
- expected vs actual behavior
- relevant logs or screenshots

## License

By contributing, you agree that your contributions are licensed under the MIT License in [LICENSE](LICENSE).

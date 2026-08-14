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

## CI/CD maintainer setup (Docs workflow)

The Docs workflow pulls a WinCC OA helper image from GHCR and deploys help to
GitHub Pages. Maintainers must configure repository secrets before first use.

Required repository secrets:

- `GHCR_USERNAME`: service account username used to read the GHCR package.
- `GHCR_READ_TOKEN`: PAT for that account.

Required PAT scope:

- `read:packages`

Recommended token strategy:

- Use a dedicated bot/service account instead of personal accounts.
- If your organization enforces SSO, authorize the PAT for the org.

GHCR package access requirements:

- Grant read access for the service account on package
  `ghcr.io/winccoa-tools-pack/winccoa`.
- If package visibility is private/internal, verify org and repository access
  alignment in package settings.

Pages deployment requirements:

- Repository Pages must be enabled.
- The workflow uses the built-in `GITHUB_TOKEN` for Pages deploy.
- Required workflow permissions are set in
  `.github/workflows/docs.yml` (`pages: write`, `id-token: write`,
  `contents: read`, `packages: read`).

Typical failure and fix:

- Error: `docker pull ... denied`
- Fix: verify `GHCR_USERNAME` / `GHCR_READ_TOKEN`, PAT scope, and package read
  permissions for the service account.

## Reporting issues

When reporting a bug, include:

- WinCC OA version
- panel/module name
- reproduction steps
- expected vs actual behavior
- relevant logs or screenshots

## License

By contributing, you agree that your contributions are licensed under the MIT License in [LICENSE](LICENSE).

---

<!-- markdownlint-disable-next-line MD033 -->
<center>Made with ❤️ for and by the WinCC OA community</center>

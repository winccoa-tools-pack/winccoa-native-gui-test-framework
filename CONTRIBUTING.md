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
- Pull requests are expected to pass the Doxygen warning gate without
  introducing new warnings compared to the base branch.

## Commit and PR guidance

- Use clear commit messages describing what and why.
- In PR descriptions, include:
  - scope of change
  - risk or compatibility notes
  - test evidence (steps, logs, screenshots)

## CI/CD maintainer setup (Docs workflow)

The Docs workflow pulls a WinCC OA helper image from GHCR and deploys help to
GitHub Pages.

IMPORTANT - most frequent time sink:

- If GHCR login succeeds but `docker pull` fails with `denied`, the problem is
  usually package authorization, not workflow syntax.
- Repository `GITHUB_TOKEN` is repository-scoped. It can log in, but still
  cannot pull a package unless that repository has package read access.
- This access is managed in the package settings of
  `ghcr.io/winccoa-tools-pack/winccoa` (organization package settings).
- Symptom differences:
  - `manifest ... latest not found`: wrong or missing image tag.
  - `denied` after successful login: token/repository has no package read
    authorization.

Current expected setup:

- The workflow resolves image from `DOCKER_IMAGE` secret first.
- If `DOCKER_IMAGE` is not set, it falls back to
  `ghcr.io/winccoa-tools-pack/winccoa:v3.21.3-debian12-all`.
- If the published image tag changes, update the fallback value in
  `.github/workflows/docs.yml`.

Repository secrets:

- `DOCKER_USER` and `DOCKER_PASSWORD` are used when present for GHCR login.
- `DOCKER_IMAGE` can be used to centrally manage the image reference.
- If `DOCKER_USER` and `DOCKER_PASSWORD` are not set, the workflow falls back
  to `GITHUB_TOKEN` login.

Pages deployment requirements:

- Repository Pages must be enabled.
- The workflow uses the built-in `GITHUB_TOKEN` for Pages deploy.
- Required workflow permissions are set in `.github/workflows/docs.yml`
  (`pages: write`, `id-token: write`, `contents: read`).

Image/runtime requirements:

- The image must contain a WinCC OA 3.21 installation at
  `/opt/WinCC_OA/3.21`.
- The workflow installs `doxygen` inside the container if `apt-get` is
  available.
- The workflow creates a temporary WinCC OA config and initializes SQLite
  before running `doxygen.ctl`.

Typical failures and fixes:

- Error: `docker pull ... denied`
- Fix: verify package access for the token/account used by GHCR login, and
  ensure `DOCKER_USER` / `DOCKER_PASSWORD` are available when private package
  access is required.

- Error: `doxygen: command not found`
- Fix: ensure the image supports `apt-get`, or preinstall `doxygen` in the
  published WinCC OA image.

- Error: WinCC OA tools fail due to missing project DB/config
- Fix: verify the workflow still creates the temporary config and runs
  `WCCOAtoolCreateDbSQLite` before `WCCOActrl`.

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

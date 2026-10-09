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
- Pull requests are expected to pass the documentation warning gate without
  introducing new warnings compared to the base branch.

## Commit and PR guidance

- Use clear commit messages describing what and why.
- In PR descriptions, include:
  - scope of change
  - risk or compatibility notes
  - test evidence (steps, logs, screenshots)

## CI/CD maintainer setup (Docs workflow)

The Docs workflow (`.github/workflows/docs.yml`) is the **single** documentation
build path for:

- pull requests: Doxygen warning gate, PR annotations/comment, HTML preview
  artifact
- `main` push / manual dispatch: the same build, then GitHub Pages deploy

It pulls a WinCC OA helper image from GHCR, builds help once via
`winccoa-docu-builder`, and (on `main` only) deploys HTML to GitHub Pages.
There is no separate documentation-warning-gate workflow; that avoided a second
full image pull and Doxygen run.

IMPORTANT - most frequent time sink:

- If GHCR login succeeds but `docker pull` fails with `denied`, the problem is
  usually package authorization, not workflow syntax.
- Repository `GITHUB_TOKEN` is repository-scoped. It can log in, but still
  cannot pull a package unless that repository has package read access.
- Do not use a shared organization token in consumer workflows. Each consumer
  repository must use its own `GITHUB_TOKEN` and receive package read access
  individually.
- To request access, open an issue in
  [`winccoa-tools-pack/.infra`](https://github.com/winccoa-tools-pack/.infra/issues)
  with the exact consumer repository (`owner/repo`), package name, and reason.
  An administrator will review the request and grant Actions access manually
  in the package settings for `ghcr.io/winccoa-tools-pack/winccoa-images`.
- Keep `packages: read` in the consuming workflow's permissions. This is
  necessary but does not itself grant package access.
- Symptom differences:
  - `manifest ... latest not found`: wrong or missing image tag.
  - `denied` after successful login: token/repository has no package read
    authorization.
- For a step-based job, a denied `docker pull` should report the image reference,
  confirm login succeeded, and point to the `.infra` access request process.
  Container jobs pull their image before workflow steps start, so their runner
  log is controlled by GitHub; use the same package-access checks there.

Current expected setup:

- The workflow resolves image from `DOCKER_IMAGE` secret first.
- If `DOCKER_IMAGE` is not set, it falls back to
  `ghcr.io/winccoa-tools-pack/winccoa-images:3.21.6-debian12-amd64-all`.
- If the published image tag changes, update the fallback value in
  `.github/workflows/docs.yml`.

Repository secrets:

- `DOCKER_USER` and `DOCKER_PASSWORD` are used when present for GHCR login.
- `DOCKER_IMAGE` can be used to centrally manage the image reference.
- If `DOCKER_USER` and `DOCKER_PASSWORD` are not set, the workflow falls back
  to `GITHUB_TOKEN` login.

Pages deployment requirements:

- Repository Pages must be enabled.
- In repository settings, open `Settings -> Pages`.
- Under `Build and deployment`, set `Source` to `GitHub Actions`.
- The first docs deployment can fail with `Get Pages site failed` until this
  repository-level Pages setting is enabled.
- The workflow uses the built-in `GITHUB_TOKEN` for Pages deploy.
- Required workflow permissions are set in `.github/workflows/docs.yml`
  (`pages: write`, `id-token: write`, `contents: read`, `pull-requests: write`).

Shared action requirements:

- Docs workflows now use the shared action
  `winccoa-tools-pack/github-actions-winccoa/actions/winccoa-docu-builder@main`.
- If the shared action repository is private or internal, allow this repository
  to use actions from that repository in org/repository Actions settings.
- If workflow validation reports "repository or version not found" for that
  action, verify:
  - the action path exists on `main` in `github-actions-winccoa`
  - this repository has access to run actions from that repository

Image/runtime requirements:

- The image must contain a WinCC OA 3.21 installation at
  `/opt/WinCC_OA/3.21`.
- The workflow installs required documentation tooling inside the container if `apt-get` is
  available.
- The workflow creates a temporary WinCC OA config and initializes SQLite
  before running `buildHelp.ctl`.

Typical failures and fixes:

- Error: `docker pull ... denied`
- Fix: verify package access for the token/account used by GHCR login, and
  ensure `DOCKER_USER` / `DOCKER_PASSWORD` are available when private package
  access is required.

- Error: documentation tooling is not available in the image
- Fix: ensure the image supports `apt-get`, or preinstall the required tooling in the
  published WinCC OA image.

- Error: WinCC OA tools fail due to missing project DB/config
- Fix: verify the workflow still creates the temporary config and runs
  `WCCOAtoolCreateDbSQLite` before `WCCOActrl`.

- Error: `Get Pages site failed` or Pages API returns `Not Found`
- Fix: enable repository Pages and configure the source as `GitHub Actions`
  under `Settings -> Pages`.

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

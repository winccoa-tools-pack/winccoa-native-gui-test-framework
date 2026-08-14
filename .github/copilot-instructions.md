# Copilot Instructions for winccoa-native-gui-test-framework

## Goal

Support and evolve the WinCC OA native GUI test framework in this repository, with focus on reliability, clear test intent, maintainable CTL code, and predictable automation.

## Repository scope

- Main framework lives in [src/Squirt](../src/Squirt).
- Core CTL libraries are in [src/Squirt/scripts/libs](../src/Squirt/scripts/libs).
- Shape-specific wrappers are in [src/Squirt/scripts/libs/classes/splash/shapes](../src/Squirt/scripts/libs/classes/splash/shapes).
- Panel resources are in [src/Squirt/panels](../src/Squirt/panels).
- VP and template data are in [src/Squirt/data](../src/Squirt/data).
- Automation and published docs belong under [.github](.).

## Working principles

- Keep changes minimal and focused on the requested behavior.
- Preserve existing CTL APIs unless a breaking change is explicitly requested.
- Avoid unrelated refactoring in the same change.
- Prefer deterministic behavior for tests and assertions.
- Keep error messages actionable for GUI test debugging.
- Prefer repository conventions over ad hoc patterns.

## CTL documentation and code style

- Every `.ctl` file must use Doxygen-style documentation similar to C or C++.
- Every `.ctl` file must include the required file header with `@file $relPath` and `@copyright MIT`.
- Do not add `@author`; Git history is the source of contribution history.
- Every class must keep the three section markers `//@public members`, `//@protected members`, and `//@private members`, even when a section is empty.
- In each section, declare members first and functions afterward.
- Every public and protected member and function must be documented.
- Private functions do not need documentation when the name is self-explanatory.
- Use `@noExternalUse` for internal-only public API.
- Use `@deprecated` for deprecated behavior.
- Use `@test` to describe test scenarios.
- Use `@todo`, `@fixme`, and `@clarify` sparingly.
- Keep `#uses` directives sorted in alphanumerical order.
- Keep lines at or below 80 characters where practical.
- Do not add trailing spaces or trailing blank lines.
- Use `astyle.exe` from the WinCC OA installation to format `.ctl` files when appropriate.
- Do not use `astyle` for `.pnl` files.

## Code quality gates

- Keep code complexity low and avoid unnecessary McCabe complexity growth.
- Favor small, readable functions over deeply nested control flow.
- Static analysis should be enabled when possible, preferably with CtrlPPCheck.
- Treat static-analysis warnings as actionable design feedback, not post-hoc noise.

## Localization

- Supported locales are `de_AT.utf8` and `en_US.utf8`.
- Additional translations are welcome but not required.
- Localizable strings in `.ctl` and `.pnl` files must be wrapped in `tr()`.

## Test and execution context

- Tests are based on the WinCC OA `OaTest` concept.
- Supported execution modes:
  - GEDI with HSP for local user tests in the WinCC OA IDE
  - command line
  - WinCC OA TestFramework in CI/CD
- Prefer changes that work in all three modes.
- For `.ctl` changes, prefer automated tests whenever possible.
- For PRs that touch test logic, preserve or improve coverage.

## Pull request expectations

- Changes must be documented.
- Changes must be tested by automated tests.
- For `.ctl` changes, target coverage above 95 percent where practical.
- Coverage above 80 percent is only acceptable when the change does not reduce existing coverage and further improvement is not practical.
- At least one reviewer is required.
- Use GitHub issue references as `#XXXXX` when applicable.
- Use closing keywords such as `Fixes #XXXXX` when a PR fully resolves an issue.
- Minor improvements do not require a tracking issue.
- Bug fixes should have a tracking issue when practical.
- Major new features must have a tracking issue.
- Write PR titles in imperative mood because the title is the changelog entry.
- Keep a simple, useful PR template and use it consistently.

## Documentation expectations

When behavior or workflows change, update relevant docs in the same change:

- [README.md](../README.md)
- [src/Squirt/README.md](../src/Squirt/README.md)
- [CONTRIBUTING.md](../CONTRIBUTING.md)
- Every Markdown documentation file (`*.md`) must end with this footer:

  ```markdown
  ---

  <center>Made with ❤️ for and by the WinCC OA community</center>
  ```

## CI, release, and packaging direction

- GitHub Actions are intended to automate tests, documentation, and packaging steps.
- All build, test, documentation, and packaging jobs should run in Docker containers based on a WinCC OA Debian installation.
- Supported WinCC OA versions are 3.21 and 3.22 when available. 3.20 shall work but is not a primary target.
- TODO: Add repository settings as code via `.github/repository.settings.yml`
  and manage branch protections through versioned GitHub rulesets.
- TODO: Add a workflow to apply repository settings and rulesets from YAML,
  using a dry-run mode and an authenticated apply mode.
- TODO: Replace the placeholder CI workflow with CTL-focused quality gates,
  including CtrlPPCheck, Markdown footer validation, docs validation, and
  automated test execution where practical.
- TODO: Migrate `devTools/ctlCoverageReport` from
  https://github.com/siemens/CtrlppCheck/tree/main/devTools/ctlCoverageReport
  into a dedicated external repository, then integrate it in this repository
  to check CTL code coverage in local workflows and CI.
- TODO: Add markdownlint to validate Markdown documentation style and
  formatting in local workflows and CI.
- TODO: Add Dependabot or Renovate configuration for GitHub Actions and other
  maintainable dependency ecosystems used by this repository.
- TODO: Add automated changelog generation and validation for releases,
  including checks that release-targeted changes update the expected
  changelog content.
- TODO: Add GitFlow-oriented release automation for feature branches merging
  into `develop`, promotion from `develop` to `main`, and required back-merges
  from `main` or release/hotfix branches back into `develop`.
- TODO: Replace Markdown issue templates with structured GitHub issue forms
  that capture WinCC OA version, execution mode, environment, and
  reproduction details.
- TODO: Review whether dedicated pull request templates are needed for
  feature and release changes, instead of a single generic template.
- TODO: Replace the placeholder packaging workflow with WinCC OA release
  automation that builds and publishes the subproject artifact and bundled
  documentation.
- The final package is a WinCC OA subproject artifact published as a standard GitHub Release.
- Built help is published in two places: inside the package for local use and to GitHub Pages from the latest `main` branch.
- The branch `main` should be protected.
- Dependency automation should be handled by Dependabot or Renovate.

## Community and repository health

- Repository discussions should be enabled.
- Community promotion and visibility are part of the project direction.

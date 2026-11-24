# winccoa-native-gui-test-framework

<div align="center">

<img src="src/Splash/docs/images/splash-logo.svg" alt="Splash native GUI test framework for WinCC OA" width="560">

![Version](https://img.shields.io/github/v/release/winccoa-tools-pack/winccoa-native-gui-test-framework?label=version)
![License](https://img.shields.io/github/license/winccoa-tools-pack/winccoa-native-gui-test-framework)
[![Quality gate](https://github.com/winccoa-tools-pack/winccoa-native-gui-test-framework/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/winccoa-tools-pack/winccoa-native-gui-test-framework/actions/workflows/ci-cd.yml)
[![Released](https://github.com/winccoa-tools-pack/winccoa-native-gui-test-framework/actions/workflows/release.yml/badge.svg)](https://github.com/winccoa-tools-pack/winccoa-native-gui-test-framework/actions/workflows/release.yml)

</div>

GUI test automation utilities for WinCC OA native panels.

This repository currently contains the Splash framework in [src/Splash](src/Splash), used to record, replay, and validate UI behavior for WinCC OA panels (.pnl/.xml).

---

## What Splash provides

- Macro recording of GUI interactions for native WinCC OA panels
- Replay of recorded GUI actions
- Verification points (VPs) for shape attributes
- Assertion logging with screenshots on failures
- Integration hooks for WinCC OA test flows

---

## Test concept and execution modes

Splash GUI tests are based on the WinCC OA `OaTest` class and therefore follow the WinCC OA Test concept.

Tests can be executed in multiple ways:

- Inside GEDI using HSP (High-Speed Programming) for local user tests in the WinCC OA IDE
- From command line
- Fully automated in WinCC OA TestFramework for CI/CD pipelines

**Current GitHub Actions limitation:** GUI test runs such as `shapes` are not
supported in GitHub automation because a working display is not available.
Run the GUI tests locally before merging a pull request. See the
[test execution guide](tests/WinCC_OA_Test/README.md#gui-tests-and-github-automation)
for the current status and local execution instructions.

---

## Repository layout

- [src/Splash](src/Splash): Main framework source
- [src/Splash/scripts](src/Splash/scripts): CTL scripts and classes
- [src/Splash/panels](src/Splash/panels): Test and helper panels
- [src/Splash/data](src/Splash/data): Templates, captured data, and VP metadata

---

## Getting started

1. Open this repository in VS Code.
2. Use your WinCC OA project environment to load and run the Splash scripts.
3. Read project-specific details in [src/Splash/README.md](src/Splash/README.md).
4. For TestFramework regression tests, see [tests/WinCC_OA_Test/README.md](tests/WinCC_OA_Test/README.md).

---

## Activate Splash as WinCC OA sub-project

Register [src/Splash](src/Splash) as a (non-runnable) WinCC OA sub-project
from the repository root. Requires Node.js (`npx`) and a WinCC OA installation.

```powershell
scripts\activateMe.cmd
```

```bash
./scripts/activateMe.sh
```

Set `WINCCOA_VERSION` (e.g. `3.22`) if more than one WinCC OA version is
installed. See [scripts/README.md](scripts/README.md) for details.

---

## AI skills

Splash provides two independently installable APM skill groups:

- [Usage](.apm/skills/usage/splash-test-authoring/SKILL.md): write product or
  project tests with Splash, including fixtures, recording, and unattended replay.
- [Maintenance](.apm/skills/maintenance/splash-maintenance/SKILL.md): develop
  Splash itself, including its guide panel and shape-wrapper tests.

With [APM](https://microsoft.github.io/apm/) installed and this repository
checked out locally, run the appropriate command from your consumer project:

```powershell
$splashSkills = 'C:/ws/winccoa-tools-pack/winccoa-native-gui-test-framework/.apm/skills'

# Use Splash to write tests (one skill).
apm install "$splashSkills/usage" --only apm --target copilot

# Maintain Splash itself (three skills).
apm install "$splashSkills/maintenance" --only apm --target copilot
```

Choose one group, or run both commands when you need both roles. Adjust the
checkout path for your machine. These local-checkout installations were tested
separately with APM 0.35.0; remote installation and packed distribution are not
verified. Edit authored skills under `.apm/skills`, not deployed copies under
`.agents/skills`. See the [skill layout guide](.apm/README.md) for details.

---

## Check and format CTL sources

Use the published package
[`@winccoa-tools-pack/npm-winccoa-ctrl-code-style`](https://www.npmjs.com/package/@winccoa-tools-pack/npm-winccoa-ctrl-code-style)
(CLI bin: `winccoa-ctrl-style`). CI currently pins **0.1.2**.

Requires a local WinCC OA install (`WCCOActrl`) and Node.js/npm. Run from the
repository root:

```powershell
# dry-run: fail if CTL files need formatting
npx --yes @winccoa-tools-pack/npm-winccoa-ctrl-code-style@0.1.2 check ./src/Splash -v 3.21

# format CTL files in place
npx --yes @winccoa-tools-pack/npm-winccoa-ctrl-code-style@0.1.2 format ./src/Splash -v 3.21
```

Optional: register once, then reuse without re-registration:

```powershell
npx --yes @winccoa-tools-pack/npm-winccoa-ctrl-code-style@0.1.2 register ./src/Splash -v 3.21
npx winccoa-ctrl-style check ./src/Splash -v 3.21 --no-register
npx winccoa-ctrl-style format ./src/Splash -v 3.21 --no-register
```

Scan the tests tree (or another subtree) with `-s`:

```powershell
npx winccoa-ctrl-style check ./src/Splash -v 3.21 -s ./tests/WinCC_OA_Test
npx winccoa-ctrl-style format ./src/Splash -v 3.21 -s ./tests/WinCC_OA_Test
```

More local QA notes (tests, copyright CI): [tests/WinCC_OA_Test/README.md](tests/WinCC_OA_Test/README.md).

---

## Roadmap

- VS Code integration is coming soon.
- AI repository instructions are available in [.github/copilot-instructions.md](.github/copilot-instructions.md).
- GitHub Actions integration is coming soon.
- GitHub Actions overview plan:
  - Phase 1: repository checks (lint/format checks and basic documentation validation).
  - Phase 2: automated test execution (WinCC OA test runs and result publishing).
  - Phase 3: release packaging of the final WinCC OA subproject artifact.
  - Phase 4: publish package through standard GitHub Releases.
  - Phase 5: publish built help in two targets: inside the package for local use and on GitHub Pages from the latest main branch.

---

## Contributing

Contribution guidelines are in [CONTRIBUTING.md](CONTRIBUTING.md).

Maintainers setting up docs publishing should also enable repository GitHub
Pages with `Source = GitHub Actions` as documented in [CONTRIBUTING.md](CONTRIBUTING.md).

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).

---

## ⚠️ Disclaimer

**WinCC OA** and **Siemens** are trademarks of Siemens AG. This project is not affiliated with, endorsed by, or sponsored by Siemens AG. This is a community-driven open source project created to enhance the development experience for WinCC OA developers.

---

## Huge thanks to

To following team to prepare the first draft during a hot week in Greece.

- @DaKaiZar — support behind the cpp core libraries
- @mtrummer-ETM Markus Trummer — the Gedi integration
- @LuisMiRey — early reviews and testing
- @mPokornyETM — things behind OaTest integration and DevOps automation in this repository

---

<!-- markdownlint-disable-next-line MD033 -->
<center>Made with ❤️ for and by the WinCC OA community</center>

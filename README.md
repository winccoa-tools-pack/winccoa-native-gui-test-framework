# winccoa-native-gui-test-framework

<div align="center">

![Version](https://img.shields.io/github/v/release/winccoa-tools-pack/winccoa-native-gui-test-framework?label=version)
![License](https://img.shields.io/github/license/winccoa-tools-pack/winccoa-native-gui-test-framework)
[![Quality gate](https://github.com/winccoa-tools-pack/winccoa-native-gui-test-framework/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/winccoa-tools-pack/winccoa-native-gui-test-framework/actions/workflows/ci-cd.yml)
[![Released](https://github.com/winccoa-tools-pack/winccoa-native-gui-test-framework/actions/workflows/release.yml/badge.svg)](https://github.com/winccoa-tools-pack/winccoa-native-gui-test-framework/actions/workflows/release.yml)

</div>

GUI test automation utilities for WinCC OA native panels.

This repository currently contains the Squirt framework in [src/Squirt](src/Squirt), used to record, replay, and validate UI behavior for WinCC OA panels (.pnl/.xml).

---

## What Squirt provides

- Macro recording of GUI interactions for native WinCC OA panels
- Replay of recorded GUI actions
- Verification points (VPs) for shape attributes
- Assertion logging with screenshots on failures
- Integration hooks for WinCC OA test flows

---

## Test concept and execution modes

Squirt GUI tests are based on the WinCC OA `OaTest` class and therefore follow the WinCC OA Test concept.

Tests can be executed in multiple ways:

- Inside GEDI using HSP (High-Speed Programming) for local user tests in the WinCC OA IDE
- From command line
- Fully automated in WinCC OA TestFramework for CI/CD pipelines

---

## Repository layout

- [src/Squirt](src/Squirt): Main framework source
- [src/Squirt/scripts](src/Squirt/scripts): CTL scripts and classes
- [src/Squirt/panels](src/Squirt/panels): Test and helper panels
- [src/Squirt/data](src/Squirt/data): Templates, captured data, and VP metadata

---

## Getting started

1. Open this repository in VS Code.
2. Use your WinCC OA project environment to load and run the Squirt scripts.
3. Read project-specific details in [src/Squirt/README.md](src/Squirt/README.md).

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

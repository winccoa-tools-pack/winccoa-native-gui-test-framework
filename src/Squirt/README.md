# Squirt - WinCC OA GUI test framework

is a framework to test WinCC OA native panels (GUI) provided in the .pnl or .xml format.

----

## Usage

+ provide tests by macro recording
+ provide verification points by macro recording
+ replay and execute tests
+ logs all verification points (asserts)
+ create screenshots on assertions
+ bind tests into WinCC OA test frameworks
+ ...

Squirt GUI tests are based on the WinCC OA `OaTest` class and therefore follow the WinCC OA Test concept.

Execution options:

+ run in GEDI with HSP (High-Speed Programming) for local user tests in the WinCC OA IDE
+ run from command line
+ run fully automated in WinCC OA TestFramework for CI/CD

----

## Configuration

TBD

----

## Examples

TBD

----

## Roadmap

+ VS Code integration is coming soon.
+ AI repository instructions are available in [../../.github/copilot-instructions.md](../../.github/copilot-instructions.md).
+ GitHub Actions integration is coming soon.
+ GitHub Actions overview plan:
  + Phase 1: repository checks (lint/format checks and basic documentation validation).
  + Phase 2: automated test execution (WinCC OA test runs and result publishing).
  + Phase 3: release packaging of the final WinCC OA subproject artifact.
  + Phase 4: publish package through standard GitHub Releases.
  + Phase 5: publish built help in two targets: inside the package for local use and on GitHub Pages from the latest main branch.

----

## Contributing

### Code Style

TBD

### Code coverage

TBD

----

## License

MIT License. See [../../LICENSE](../../LICENSE).

## Limitation

Only WinCC OA shapes are possible to record / re-play. That means no file-selector, printers ... can be recorded.

## Do not ...

+ Do not use **:** in the panel name, otherwise it is not possible to address the shape (moduleName.panelName:shapeName).
+ Do not use empty shape name, otherwise it is not possible to address the shape (moduleName.panelName:shapeName).
+ Use unique shape name, otherwise you will have conflict in the Tab shape
+ Do not use random generated module, shape and panel names, otherwise the player can not address the shape.

## Best practice

+ Create smaller test cases instead of complex long duration tests. It will help you for analysis and you does not need
  to record whole scenario, when something changes

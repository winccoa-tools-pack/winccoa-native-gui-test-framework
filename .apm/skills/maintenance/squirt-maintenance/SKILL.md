---
name: squirt-maintenance
description: >
  Use when developing, fixing, reviewing, or testing Squirt itself: framework
  CTRL libraries, shape wrappers, input replay, guided macro recorder,
  tc_quide.pnl, visual checkpoints, framework-owned tests, or public API
  compatibility. Not for writing product tests that only consume Squirt.
---

# Maintain Squirt

## Scope

This skill is for framework maintainers. Consumer test authoring belongs to
`squirt-test-authoring`, available separately in the usage skill package.
Do not load framework implementation guidance merely because a product test
imports a Squirt class.

## Workflow

1. Start from the failing framework behavior or requested public API change.
   Inspect the owning implementation and a neighboring framework test.
2. Keep reusable behavior in Squirt, not in a product-specific test suite.
   Product selectors, fixtures, macros, and assertions remain with the consumer.
3. Preserve public CTRL APIs and existing recording/stop contracts unless a
   breaking change is explicitly requested. Keep supported execution modes
   and WinCC OA versions in mind.
4. Follow the repository's CTRL documentation, localization, formatting, and
   test conventions. Use the `winccoa-control-script` and `winccoa-qa` skills
   for the relevant language and quality checks.
5. Validate the changed behavior with focused framework tests. Execute GUI
   tests through WCCOAui; a CTRL-only checker cannot establish UI correctness.
   A zero process exit code without an OaTest summary is not a passing result.
6. Update the public documentation and the affected consumer skill when a
   supported workflow changes. Keep implementation details out of consumer
   guidance unless they are needed to use or diagnose the public API.

## Focused Maintainer Skills

- [Guide panel and stop handshake](../tc-quide-panel/SKILL.md): panel ownership,
  configuration compatibility, recorder integration, and guide contract tests.
- [GUI shape-wrapper tests](../winccoa-gui-shape-tests/SKILL.md): isolated panels,
  dynamic shapes, wrapper validation, and framework test lifecycle.

## Ownership

- Framework implementation: `src/Squirt/scripts/libs`.
- Shape wrappers: `src/Squirt/scripts/libs/classes/splash/shapes`.
- Framework panels: `src/Squirt/panels`.
- Framework tests: `tests/WinCC_OA_Test/TestSuites`.
- Published framework documentation: `src/Squirt/docs`.
- Authored AI skills: `.apm/skills`; do not edit deployed copies as sources.

---

<center>Made with ❤️ for and by the WinCC OA community</center>
---
name: tc-quide-panel
description: >
  Use when maintaining, testing, or debugging Squirt's tc_quide.pnl
  implementation, project-root .tcQuide.json configuration contract,
  SplashGuidedMacroRecorder integration, or _Splash.command stop handshake.
  For using guided recording in product tests, use squirt-test-authoring.
---

# Maintain The Squirt Test Guide

This is a focused [Squirt maintenance skill](../squirt-maintenance/SKILL.md).
Use it when changing the guide panel or testing its framework-owned contract.
The consumer recording workflow belongs to `squirt-test-authoring`, available
separately in the usage skill package.

## Ownership And Runtime

- The panel is a framework resource under `src/Squirt/panels/vision`.
- Its [GUI contract test](../../../../tests/WinCC_OA_Test/TestSuites/suite_uiEvents/sub_uiEvents/scripts/tests/panels/vision/tc_quide/tc_quide_010.ctl)
  belongs to Squirt's `suite_uiEvents`, not a product-specific test suite.
- The worker project runs it from the attached/installed Squirt subproject at
  `panels/vision/tc_quide.pnl`; do not treat the worker project as the source
  of truth for this reusable UI.
- The caller supplies guide values to `SplashGuidedMacroRecorder`; the helper
  writes project-root `.tcQuide.json` before opening the panel.
- The panel reads the file once during `Initialize` and does not create or
  refresh it.

## Configuration Contract

The JSON object uses these string properties:

- `macroName`: macro name supplied to the recording consumer.
- `libraryPath`: full native path to the CTRL library destination.
- `quide`: guide instructions. Preserve this spelling for compatibility.

Keep the panel generic. Product-specific UI interactions belong to the caller;
guide JSON generation and macro recording/save lifecycle belong to
`SplashGuidedMacroRecorder`.

## Handshake

The helper starts input recording and subscribes to `_Splash.command`. The
Finish button and panel Close event call `stopSelectorRecording()`. A guard
ensures only one command is sent. The panel writes
`stop|<macroName>|<libraryPath>` to `_Splash.command`, clears
`_Splash.response`, and the Finish button then closes the panel. The helper
stops recording, writes the temporary function, appends it to the library, and
exposes completion/save/error state to the caller.

For recorder integration tests, use
`#uses "classes/splash/SplashGuidedMacroRecorder"`. Call `startRecording()`
before the UI actions to capture, then `startGuide()` when the guide should
appear. Wait for `isRecordingStopped()` and verify `isRecordingSaved()`;
report `getErrorMessage()` on failure. Keep product-specific UI interactions
and assertions out of these framework tests.

## Guide Contract Test

Run through WCCOAui with `-p about.pnl` and
`-s tests/panels/vision/tc_quide/tc_quide_010.ctl`. Prepare project-root
`.tcQuide.json` and the framework's `_Splash` datapoint beforehand. Run without
an active recording session: the test clears `_Splash.command` and
`_Splash.response`, then checks the Finish button's stop payload. It is not
registered in the unattended suite manager list because its configuration is
currently supplied externally. A CTRL-only syntax check cannot validate its
UI APIs; require native UI execution for a runtime verdict.

See [the user guide](../../../../src/Squirt/docs/tc-quide-guide.md) for the JSON
example, startup sequence, and complete handshake details.

---

<center>Made with ❤️ for and by the WinCC OA community</center>
---
name: tc-quide-panel
description: "Use when developing, testing, or debugging Squirt's tc_quide.pnl test guide, its project-root .tcQuide.json configuration, or the _Splash.command stop handshake."
---

# Squirt Test Guide Panel

Use this skill when changing or using `src/Squirt/panels/vision/tc_quide.pnl`
or a test that opens it.

## Ownership and runtime

- The panel is a framework resource under `src/Squirt/panels/vision`.
- The worker project runs it from the attached/installed Squirt subproject at
  `panels/vision/tc_quide.pnl`; do not treat the worker project as the source
  of truth for this reusable UI.
- The caller supplies guide values to `SplashGuidedMacroRecorder`; the helper
  writes project-root `.tcQuide.json` before opening the panel.
- The panel reads the file once during `Initialize` and does not create or
  refresh it.

## Configuration contract

The JSON object uses these string properties:

- `macroName`: macro name supplied to the recording consumer.
- `libraryPath`: full native path to the CTRL library destination.
- `quide`: guide instructions. Preserve this property spelling for compatibility.

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

For GUI tests, use `#uses "classes/splash/SplashGuidedMacroRecorder"`.
Call `startRecording()` before the UI actions to capture, then call
`startGuide()` when the guide should appear. Wait for `isRecordingStopped()`
and verify `isRecordingSaved()`; report `getErrorMessage()` on failure. Keep
product-specific UI interaction and assertions in the product test.

See [the user guide](../../../src/Squirt/docs/tc-quide-guide.md) for the JSON
example, startup sequence, and complete handshake details.

---

<center>Made with ❤️ for and by the WinCC OA community</center>
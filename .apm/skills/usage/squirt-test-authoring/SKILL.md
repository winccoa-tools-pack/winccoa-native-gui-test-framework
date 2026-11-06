---
name: squirt-test-authoring
description: >
  Use when using Squirt to create, debug, or finalize WinCC OA product or
  project GUI tests: OaGuiTest, SquirtInputEventPlayer, saved macros, guided
  recording, panel visual checkpoints, DPL fixtures, restricted-user execution,
  and unattended replay. Not for changing Squirt's framework implementation.
---

# Write Tests With Squirt

## Scope

This skill is for test authors consuming Squirt's public API. Framework changes
belong to `squirt-maintenance`, available separately in the maintenance package.
Do not modify Squirt merely to hide a failing product assertion or embed
product-specific selectors in the framework.

## Test Authoring

1. Identify the product panel, documented case, fixture, and expected outcome.
   Keep the test, product macros, DPL fixtures, and baselines in its owning suite.
2. Use the `winccoa-oatest` and `winccoa-control-script` skills for test structure
   and CTRL APIs. Reuse existing Squirt player and assertion helpers.
3. Target stable module/panel/shape addresses. Use bounded waits for meaningful
   postconditions; avoid arbitrary long sleeps and unbounded user waits.
4. Assert behavior, not just completed input playback. Check expected rows,
   values, counts, or state. Use panel visual checkpoints for stable attributes;
   do not use them as a substitute for dynamic behavioral assertions.
5. Run UI-driven cases through WCCOAui with the intended panel and script in
   the test project. Do not use a CTRL-manager script launcher for UI replay.
   Require a fresh OaTest summary with its Failed and Aborted counts; an exit
   code of zero or a successful syntax check alone is not a runtime verdict.

## Datapoint Fixtures And Permissions

- Prefer suite-owned ASCII DPL files under the subproject's `dplist/` directory
  for stable datapoint types and structured fixtures.
- Reuse existing fixture datapoints. Import only when `!dpExists(TEST_DP)`;
  short-circuit evaluation must skip the import when the fixture exists.
- Do not call `dpDelete()` or `dpTypeDelete()` during restricted-user setup,
  validation failure handling, or teardown. Retain fixtures between runs and
  clear only the test UI state.
- Importing a missing fixture is not a permission bypass. Provision through an
  authorized account or privileged project setup beforehand when necessary.
  Do not silently switch the test user to root.
- Validate all expected DPEs after import or reuse. Abort with the missing DPE
  name if the fixture is incomplete; leave repair or removal to explicit
  privileged setup rather than rebuilding it inside the UI test.
- Suffix test datapoint and element names with `_test`.

With `#uses "ascii"` at the top of the script, use this inside a setup helper:

```ctl
if (!dpExists(TEST_DP) &&
    asciiImport(getPath(DPLIST_REL_PATH, "fixture.dpl")) != 0)
{
  this.abort("Failed to import the test fixture DPL.");
  return -1;
}
```

Panel cleanup through `exit()` does not delete datapoints or their types.
Keep panel lifecycle separate from database-fixture lifecycle.

## Recording Is An Authoring Step

1. While developing a case, use `SplashGuidedMacroRecorder.recordGuidedMacro()`
   to capture the interaction and save it to the intended macro library. Keep
   product-specific actions and assertions in the product test; reuse the
   helper instead of duplicating recording, guide startup, and stop polling.
2. Supply the macro name, library destination, output path, guide text, and
   target selector to the helper. It writes project-root `.tcQuide.json` and
   opens the framework guide. Preserve the JSON key spelling `quide`.
3. Verify the saved macro by replaying it through WCCOAui against the intended
   panel with behavioral assertions passing. Saving it or passing syntax checks
   alone does not prove the macro works.
4. Once replay is verified, replace the macro-exists/recording branch with:

   ```ctl
   callFunction(macroName, player);
   ```

5. Remove recording-only imports, recorder objects, output paths, guide text,
   library-destination variables, and recording-specific logging or waits.
   Keep the macro-library import, fixtures, assertions, and replay waits.

A missing macro or replay failure must fail or abort the automated case.
Never launch the guide, start recording, or wait for user input as an automatic
fallback in a finished unattended test. Re-record explicitly in an authoring
workflow when needed; do not remove Squirt's reusable recorder helper.

---

<center>Made with ❤️ for and by the WinCC OA community</center>
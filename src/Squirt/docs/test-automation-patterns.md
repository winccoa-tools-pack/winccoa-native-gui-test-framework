# Test Automation Patterns

Reusable practices for building reliable Squirt UI tests from manual test
specifications.

## Turn a Test Specification into Sessions

- Keep one session per TFS test case and preserve the original case ID.
- Translate actions and expected results into English without inventing
  acceptance criteria. Mark missing source expectations as unspecified.
- Record preconditions per case. Separate source requirements from proposed
  fixture assumptions so reviewers can validate them.
- Track automation state explicitly: `Done`, `Partial (n%)`, or `To do`. Treat
  percentages as estimates of documented steps automated, not code coverage.
- Link the TFS work item directly and keep the exported CSV as the source
  record until the team adopts a different workflow.

## Use Deterministic Fixtures

- Create uniquely named, isolated datapoint types and datapoints for UI cases.
- Define expected leaf DPEs independently of the tree query or behavior under
  test; otherwise the same defect can affect both setup and assertion.
- Validate fixture creation before opening the panel and clean up fixture data
  after assertions.
- Prefer literal test input over clipboard paste so replay does not depend on
  clipboard state left by an interactive recording session.

## Use Panel VPs for Stable UI State

- Call `player.makeCurrent()` on a stable panel shape before capturing or
  comparing a panel VP. This waits for the panel/shape and sets the player's
  current-panel context.
- Store panel references under the test project's or subproject's
  `data/splash/VPs/panels/` directory.
- Reuse a shared initial panel VP across related tests when the panel should
  have a common initial layout.
- Reuse that VP after an interaction only when visible structure and stable
  attributes should remain unchanged. Assert intended dynamic changes, such as
  row counts or selected values, separately.
- Exclude attributes that vary by locale or interaction state (for example,
  resolved font/text values and cursor position) from shared visual checks;
  keep layout, visibility, enabled state, and geometry in the VP comparison.

## Keep Replays Readable

- Run the macro simplifier in dry-run first and review each proposed change.
- Apply only same-coordinate, short press/release pairs automatically.
- Treat keyboard sequences and pointer-movement findings as advisory until
  their focus, timing, drag, and hover semantics are understood.
- Explain long sleeps with an adjacent comment and prefer a readiness check
  whenever the UI exposes one.
- Re-run the UI test after converting macros; syntax checks alone do not prove
  that a recorded interaction still drives the intended panel behavior.

## Panel VP Limits

Panel VPs help detect shared layout regressions, but they are not a substitute
for behavioral assertions. Dynamic table contents, timestamps, selected
values, and mode-dependent text should have targeted assertions or be excluded
from a general-purpose baseline. Do not regenerate a VP from an arbitrary
post-failure state and accept it without review.

---

<center>Made with ❤️ for and by the WinCC OA community</center>
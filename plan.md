# Squirt Public Release Plan and Roadmap

Research date: 2026-10-12.

Status: proposed plan, not an implementation commitment. Repository inspection
and public vendor documentation informed this plan; competitor trials and recent
CI results were not independently verified.

## Product Direction

Release Squirt as an open-source, native WinCC OA panel regression framework
with CI-ready results. The first audience is WinCC OA developers and project
teams already using CTL, GEDI, OaTest, and native panels.

Prioritize installation, deterministic execution, and actionable failure evidence
over commercial-tool feature parity. Do not delay the first release for AI,
OCR, a new IDE, or a centralized dashboard.

The potential differentiator is direct access to WinCC OA shapes and state,
including graphics that external object recognition may struggle with. Validate
this advantage using a shared demonstration panel rather than claiming universal
superiority. Attribute assertions alone do not prove rendering or user experience.

## Research Summary

| Tool | Relevance | Qualification |
| --- | --- | --- |
| Squish for Qt | Documented WinCC OA automation; rich authoring, visual verification, OCR, and cross-platform toolkit support | Match Qt, compiler, and architecture; validate current OA releases and custom shapes |
| Ranorex Studio | Qt support, recorder, object repository, reporting, data-driven testing, and selector self-healing | No OA-specific compatibility confirmation found; Windows-based Studio requirements do not establish native Linux OA automation |
| OaTest / WinCC OA TestFramework | Existing foundation for assertions, lifecycle, execution, and reporting | Complementary infrastructure, not a complete external GUI automation product |
| Playwright | Browser-based UI automation with strong CI and diagnostic tooling | Not native WCCOAui automation; canvas-based interfaces need additional handling |
| SikuliX / Oculix | Image-driven automation for otherwise inaccessible controls | Rendering-sensitive; project maintenance transition needs assessment |
| CtrlppCheck | WinCC OA static analysis and CI companion | Not a GUI-testing competitor |

No other maintained public project with exactly Squirt's native CTL-panel scope
was established in this research. This is not proof that none exists.

### Competitive Gaps

- Authoring: commercial tools provide integrated recording, object inspection,
  repositories, debugging, and data-driven workflows.
- Targeting: commercial tools offer richer property and hierarchy selectors.
  Self-healing can reduce maintenance but also conceal unintended changes.
- Visual checks: screenshots are not visual regression testing. Squish documents
  baseline comparisons, tolerances, diff reports, and OCR.
- Workflow breadth: Squirt is limited to native OA shapes, not OS dialogs or
  arbitrary applications. Other tools cover broader supported technologies.
- Reporting: commercial tools offer richer investigation interfaces, history,
  test-management integrations, and vendor support.
- AI: Squish offers script/log assistance and an MCP agent-control technology
  preview. Distinguish released assistance from experimental autonomous testing.

## Current Repository Evidence

- [CI workflow](.github/workflows/ci.yml) implements Debian/Xvfb GUI execution,
  TestFramework integration, and JUnit publishing. Implementation does not by
  itself establish recent successful execution.
- [Package workflow](.github/workflows/package.yml) remains a placeholder.
- [Project overview](src/Squirt/README.md) documents native recording/replay,
  execution modes, addressing limitations, and incomplete onboarding sections.
- [Usage guide](src/Squirt/docs/usage.md) describes local and CI workflows.
- [Test instructions](tests/WinCC_OA_Test/README.md) describe Windows prerequisites
  and Linux GUI runtime requirements.
- [Verification-point implementation](src/Squirt/scripts/libs/classes/SquirtVp.ctl)
  creates missing baselines from live state. CI needs strict verification mode.

Windows CI and native AI automation were not demonstrated by this inspection.
Version support must be backed by execution evidence, not roadmap statements.

## Phase 1: Minimal Public Preview (0.1)

Complete the following in order. Narrow support claims before expanding scope.

### Packaging and Onboarding

- [ ] Publish a versioned, downloadable WinCC OA subproject artifact.
- [ ] Document dependencies, installation, upgrade, and removal.
- [ ] Clarify WinCC OA and TestFramework licensing, availability, and access.
- [ ] Include only content that may legally be redistributed.
- [ ] Provide one runnable demonstration panel and test suite.
- [ ] Replace outdated roadmap claims and incomplete quick-start sections.
- [ ] Publish a tested OA version, OS, and locale support matrix.

### Supported Test Surface

- [ ] Guarantee a small core: button, text input, checkbox, combo box, table,
  panel navigation, condition-based waits, and assertions.
- [ ] Mark other wrappers experimental until tested and documented.
- [ ] Document naming restrictions and unsupported OS dialogs.
- [ ] Demonstrate real recorded input as well as attribute verification.
- [ ] Demonstrate delayed updates and actionable timeout diagnostics.

### Deterministic Execution and Results

- [ ] Separate baseline authoring from verification; fail on missing baselines
  in CI and never approve live state automatically.
- [ ] Provide a documented noninteractive runner entry point with timeouts,
  isolated fixtures, cleanup, and meaningful exit codes.
- [ ] Fail on zero executed tests, missing or stale results, and aborted runs.
- [ ] Preserve per-test screenshots, expected/actual attributes, and logs.
- [ ] Produce a run manifest with revision, OA version/patch, OS, locale,
  display settings, and runner identity.
- [ ] Verify that an intentionally failing test fails the CI job.
- [ ] Verify installation and smoke tests on clean Windows and Debian systems.
- [ ] Repeat Linux CI smoke runs and report unexplained failures explicitly.

### Publication and Acceptance

- [ ] Obtain feedback from two independent pilot users.
- [ ] Publish a short demo, known limitations, support policy, and contribution
  guide with the release.
- [ ] Tag and publish the 0.1 preview with package, documentation, and changelog.

Release gate: a new user can install the package, run the sample, introduce a
failure, and identify its cause from the exported evidence. Record the clean
installation results and repeated-run counts in release evidence.

If Windows is not validated in time, release a Linux preview and explicitly mark
Windows experimental. Do not claim cross-platform support without evidence.

## CI/CD Architecture

Use one runner contract rather than three separate implementations. Its inputs
should identify the suite, project, OA version, locale, timeout, and results
directory. Its outputs should include exit status, fresh JUnit results, logs,
screenshots, and the run manifest.

| System | Integration |
| --- | --- |
| GitHub Actions | Invoke the shared runner, publish JUnit summaries, upload diagnostics |
| GitLab CI | Invoke the same runner, publish JUnit report artifacts and diagnostics |
| Jenkins | Invoke the same runner, use JUnit publishing and archive diagnostics |

- Keep Debian/container CI as the primary automated path.
- Pin runner dependencies and control access to licensed images and software.
- Run fast syntax, style, and documentation gates separately from GUI suites.
- Add a dedicated Windows runner with a usable desktop session for input tests.
  Validate service execution, session locking, and RDP disconnect behavior.
- Isolate projects, result directories, and displays before parallel execution.
- Do not expose trusted runners or secrets to untrusted pull requests.
- Define Unix support as explicitly tested Linux distributions; do not imply
  support for every Unix system or macOS.
- Use separate visual baselines where OS, fonts, scaling, or rendering differ.

## Phase 2: Reliability and Adoption (0.2)

- [ ] Add automated Windows smoke execution and retain Linux regression CI.
- [ ] Provide runnable GitLab and Jenkins integration examples.
- [ ] Expand the OA version/patch and locale matrix based on available runtimes.
- [ ] Add reusable test fixtures and explicit state reset helpers.
- [ ] Add reviewed baseline-update workflows with visible changes.
- [ ] Track flakiness separately from product failures; never hide it with retries.

Acceptance: the same supported smoke scenarios run on both OS families; an
intentional failure is visible in GitHub, GitLab, and Jenkins results.

## Phase 3: Visual and Operator UX Regression (0.3)

- [ ] Add screenshot comparison using an established image-diff library.
- [ ] Support dynamic-region masks, tolerances, and reviewed baselines.
- [ ] Add keyboard navigation, focus, clipping, and display-scaling checks.
- [ ] Add operator-visible response-time budgets with defined start/end events.
- [ ] Cover alarm visibility and acknowledgement, permission-dependent controls,
  validation feedback, cancel/recovery paths, and stale-data indication.
- [ ] Cover localization and representative display sizes.

Acceptance: detect seeded visual defects, broken navigation, and delayed feedback.
Use representative operator journeys, not only isolated widget assertions.
Automated UX checks detect regressions; actual operator usability sessions remain
necessary. Functional tools do not automatically provide accessibility compliance.

## Phase 4: AI-Assisted Testing (0.4)

- [ ] Generate candidate CTL tests from requirements and panel metadata.
- [ ] Summarize failures with links to screenshots, logs, and actual assertions.
- [ ] Suggest missing scenarios and duplicate tests for human review.
- [ ] Support redacted evidence and approved local/private model configurations.

Acceptance: reviewed generated tests execute deterministically without AI.
AI explanations remain hypotheses until supported by evidence. AI must not
silently change selectors, expected results, assertions, or baseline approvals.

## Later: Controlled AI Exploration and Adapters

- [ ] Prototype an MCP interface for scoped inspection and permitted UI actions.
- [ ] Run exploration only in isolated test projects, never live plant control.
- [ ] Record action traces and turn discovered issues into reproducible tests.
- [ ] Restrict actions, authenticate access, redact secrets, and enforce budgets.
- [ ] Assess optional external-dialog and browser adapters rather than rebuilding
  general desktop or web automation engines.
- [ ] Evaluate richer reports and test-management integration after pilot demand.

Acceptance: discovered defects reproduce without AI, destructive actions remain
controlled, and all proposed test changes are reviewable.

## Research Sources

- [Qt: Automating SIMATIC WinCC OA](https://qatools.knowledgebase.qt.io/squish/qt/howto/automating-simatic-wincc-oa/)
  confirms compatibility principles; its version table ends at OA 3.17.
- [Squish visual and functional testing](https://www.qt.io/quality-assurance/squish/support-for-visual-and-functional-testing)
- [Squish AI Assistant release](https://www.qt.io/quality-assurance/blog/squish-9.1.0-and-squish-ai-assistant-released)
- [Squish MCP technology preview](https://www.qt.io/quality-assurance/blog/from-assistant-to-autonomous-tester-enable-your-ai-agent-to-understand-and-control-your-application)
- [Ranorex supported technologies](https://www.ranorex.com/supported-technologies/)
- [Ranorex software requirements](https://support.ranorex.com/hc/en-us/articles/38006192887953-Software-Requirements)
- [Ranorex self-healing](https://support.ranorex.com/hc/en-us/articles/38028419260433-Self-Healing)
- [Playwright introduction](https://playwright.dev/docs/intro)
- [SikuliX project status](https://sikulix.com/)
- [Siemens CtrlppCheck](https://github.com/siemens/CtrlppCheck)

Vendor feature descriptions are not hands-on performance measurements. Validate
OA compatibility, licensing, and operating costs with trials before procurement.

---

<center>Made with ❤️ for and by the WinCC OA community</center>
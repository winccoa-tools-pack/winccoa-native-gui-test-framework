# GitHub Actions Contract

This document describes the required GitHub Actions that the CI pipeline depends on. These actions are located in the `github-actions-winccoa` repository and must be implemented to support the CI workflow.

## Action: winccoa-create-project-config

**Location:** `winccoa-tools-pack/github-actions-winccoa/actions/winccoa-create-project-config`

**Purpose:** Create and configure a WinCC OA project configuration file.

### Inputs

| Input | Required | Type | Description |
|-------|----------|------|-------------|
| `project-path` | yes | string | Path to the WinCC OA project directory (e.g., `src/Squirt`) |
| `languages` | yes | string | Language(s) to configure, full locale name (e.g., `en_US.utf8` or `de_AT.utf8`) |
| `winccoa-version` | yes | string | WinCC OA version (e.g., `3.21`) |

### Behavior

- Create a config directory at `{project-path}/config`
- Generate a config file with:
  - `pvss_path = "/opt/WinCC_OA/{winccoa-version}"`
  - `proj_path = "{project-path}"`
  - `proj_version = "{winccoa-version}"`
  - `langs = "{languages}"` (space-separated if multiple)
  - `pmonPort = 5999`
- Register the project using `WCCILpmon -autofreg`

### Exit Code

- `0`: Success
- `!= 0`: Failure (invalid language, missing paths, etc.)

---

## Action: winccoa-run-tests

**Location:** `winccoa-tools-pack/github-actions-winccoa/actions/winccoa-run-tests`

**Purpose:** Execute WinCC OA tests using the TestFramework.

### Inputs

| Input | Required | Type | Description |
|-------|----------|------|-------------|
| `project-path` | yes | string | Path to the Squirt project (e.g., `src/Squirt`) |
| `test-project-path` | yes | string | Path to the test project (e.g., `tests/WinCC_OA_Test`) |
| `test-run-id` | yes | string | Unique test run identifier (e.g., `Squirt-regression-en_US.utf8`) |
| `language` | yes | string | Test language, full locale name (e.g., `en_US.utf8`) |
| `winccoa-version` | yes | string | WinCC OA version (e.g., `3.21`) |

### Behavior

- Set up the test project configuration (see action above for pattern)
- Execute tests using `WCCOActrl -proj TestFramework -n testRunner.ctl`
- Pass test run parameters: `{'testRunId': '{test-run-id}', ...}`
- Ensure results are written to `{test-project-path}/Results/`
- Support language via `-lang` flag

### Exit Code

- `0`: All tests passed
- `1`: Test failures detected
- `!= 0`: Setup or execution error

### Output Artifacts (expected by workflow)

- Test results: `{test-project-path}/Results/jUnit*.xml`
- Failed projects: `{test-project-path}/Projects/Stored/Failed/`

---

## Implementation Reference

See [CtrlppCheck createBundle.yml](https://github.com/mPokornyETM/CtrlppCheck/blob/b10e38d2437e360bbd37484bba95703474ad25e7/.github/workflows/createBundle.yml) for the original pattern these actions are based on.

---

<center>Made with ❤️ for and by the WinCC OA community</center>

# GitHub Actions Contract

This document describes the required GitHub Actions that the CI pipeline depends on. These actions are located in the `github-actions-winccoa` repository and must be implemented to support the CI workflow.

## Action: winccoa-create-project-config

**Location:** `winccoa-tools-pack/github-actions-winccoa/actions/winccoa-create-project-config`

**Purpose:** Create and configure a WinCC OA project configuration file.

### Inputs

| Input | Required | Type | Description |
|-------|----------|------|-------------|
| `project-path` | yes | string | Path to the WinCC OA project directory (e.g., `src/Squirt`) |
| `languages` | yes | string | Languages to configure, space-separated full locale names (e.g., `en_US.utf8 de_AT.utf8`) |
| `winccoa-version` | yes | string | WinCC OA version (e.g., `3.21`) |

### Behavior

- Create a config directory at `{project-path}/config`
- Generate a config file with:
  - `pvss_path = "/opt/WinCC_OA/{winccoa-version}"`
  - `proj_path = "{project-path}"`
  - `proj_version = "{winccoa-version}"`
  - `langs = "{languages}"` (space-separated)
  - `pmonPort = 5999`
- Register the project using `WCCILpmon -autofreg`

### Exit Code

- `0`: Success
- `!= 0`: Failure (invalid language, missing paths, etc.)

---

## Action: winccoa-run-tests

**Location:** `winccoa-tools-pack/github-actions-winccoa/actions/winccoa-run-tests`

**Purpose:** Execute WinCC OA tests using the TestFramework with all configured languages.

### Inputs

| Input | Required | Type | Description |
|-------|----------|------|-------------|
| `project-path` | yes | string | Path to the Squirt project (e.g., `src/Squirt`) |
| `test-project-path` | yes | string | Path to the test project (e.g., `tests/WinCC_OA_Test`) |
| `test-run-id` | yes | string | Unique test run identifier (e.g., `Squirt-regression`) |
| `languages` | yes | string | Test languages, space-separated full locale names (e.g., `en_US.utf8 de_AT.utf8`) |
| `winccoa-version` | yes | string | WinCC OA version (e.g., `3.21`) |
| `upload-artifacts` | no | boolean | Upload failed tests and results as artifacts (default: `true`) |
| `publish-junit-report` | no | boolean | Publish jUnit report as GitHub check (default: `true`) |

### Behavior

- Set up the test project configuration with all specified languages (see action above for pattern)
- Execute tests using `WCCOActrl -proj TestFramework -n testRunner.ctl`
- Pass test run parameters: `{'testRunId': '{test-run-id}', ...}`
- Run tests for all languages in the same project database
- Ensure results are written to `{test-project-path}/Results/`
- **Convert test results to jUnit format** using `oaTestParsers/jsonToJUnit.ctl`
- **Upload failed test projects** artifact (if `upload-artifacts: true`)
- **Upload test results** artifact (if `upload-artifacts: true`)
- **Publish jUnit report** as GitHub check via `mikepenz/action-junit-report` (if `publish-junit-report: true`)

### Exit Code

- `0`: All tests passed for all languages
- `1`: Test failures detected in any language
- `!= 0`: Setup or execution error

### Outputs

| Output | Type | Description |
|--------|------|-------------|
| `test-count` | number | Total number of tests executed |
| `failure-count` | number | Number of test failures |
| `error-count` | number | Number of test errors |
| `junit-report-file` | string | Path to generated jUnit XML file (if conversion succeeded) |
| `failed-projects-path` | string | Path to failed projects directory (if any failures exist) |

### Output Artifacts

Generated and uploaded automatically (when enabled via inputs):

- **Artifact: `test-results`** — Test results directory with jUnit XML and logs
- **Artifact: `failed-tests`** — Failed test projects directory (uploaded only if failures exist)

---

<center>Made with ❤️ for and by the WinCC OA community</center>

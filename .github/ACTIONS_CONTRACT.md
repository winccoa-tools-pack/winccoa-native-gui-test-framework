# GitHub Actions Contract

This document describes the required GitHub Actions that the CI pipeline depends on. These actions are located in the `github-actions-winccoa` repository and must be implemented to support the CI workflow.

## Action: winccoa-create-project-config

**Location:** `winccoa-tools-pack/github-actions-winccoa/actions/winccoa-create-project-config`

**Purpose:** Create and configure a WinCC OA project configuration file.

### Create Project Config Inputs

| Input | Required | Type | Description |
| ----- | -------- | ---- | ----------- |
| `project-path` | yes | string | Path to the main WinCC OA project directory (e.g., `src/Squirt`) |
| `sub-project-ids` | no | string | Optional space-separated sub-project identifiers loaded before the main project |
| `resolve-project-id-command` | no | string | Shell command template used to resolve one project ID to a project path. Use `{id}` as placeholder. Required when `sub-project-ids` is set. |
| `languages` | yes | string | Languages to configure, space-separated full locale names (e.g., `en_US.utf8 de_AT.utf8`) |
| `winccoa-version` | yes | string | WinCC OA version (e.g., `3.21`) |

### Create Project Config Behavior

- Create a config directory at `{project-path}/config`
- Generate a config file with:
  - `pvss_path = "/opt/WinCC_OA/{winccoa-version}"`
  - One `proj_path` line for each configured sub-project ID
  - A final `proj_path` line for the main project
  - `proj_version = "{winccoa-version}"`
  - One `langs` line for each configured language
- Resolve sub-project identifiers through `resolve-project-id-command`, then normalize the returned paths like `project-metadata`
- Register the project using `WCCILpmon -autofreg`

### Create Project Config Exit Code

- `0`: Success
- `!= 0`: Failure (invalid language, missing paths, etc.)

---

## Action: winccoa-run-tests

**Location:** `winccoa-tools-pack/github-actions-winccoa/actions/winccoa-run-tests`

**Purpose:** Execute WinCC OA tests using the TestFramework with all configured languages.

### Run Tests Inputs

| Input | Required | Type | Description |
| ----- | -------- | ---- | ----------- |
| `project-path` | yes | string | Path to the Squirt project (e.g., `src/Squirt`) |
| `test-project-path` | yes | string | Path to the test project (e.g., `tests/WinCC_OA_Test`) |
| `test-run-id` | yes | string | Unique test run identifier (e.g., `Squirt-regression`) |
| `languages` | yes | string | Test languages, space-separated full locale names (e.g., `en_US.utf8 de_AT.utf8`) |
| `winccoa-version` | yes | string | WinCC OA version (e.g., `3.21`) |
| `upload-artifacts` | no | boolean | Upload failed tests and results as artifacts (default: `true`) |
| `publish-junit-report` | no | boolean | Publish jUnit report as GitHub check (default: `true`) |

### Run Tests Behavior

- Set up the test project configuration with all specified languages (see action above for pattern)
- Execute tests using `WCCOActrl -proj TestFramework -n testRunner.ctl`
- Pass test run parameters: `{'testRunId': '{test-run-id}', ...}`
- Run tests for all languages in the same project database
- Ensure results are written to `{test-project-path}/Results/`
- **Convert test results to jUnit format** using `oaTestParsers/jsonToJUnit.ctl`
- **Upload failed test projects** artifact (if `upload-artifacts: true`)
- **Upload test results** artifact (if `upload-artifacts: true`)
- **Publish jUnit report** as GitHub check via `mikepenz/action-junit-report` (if `publish-junit-report: true`)

### Run Tests Exit Code

- `0`: All tests passed for all languages
- `1`: Test failures detected in any language
- `!= 0`: Setup or execution error

### Run Tests Outputs

| Output | Type | Description |
| ------ | ---- | ----------- |
| `test-count` | number | Total number of tests executed |
| `failure-count` | number | Number of test failures |
| `error-count` | number | Number of test errors |
| `junit-report-file` | string | Path to generated jUnit XML file (if conversion succeeded) |
| `failed-projects-path` | string | Path to failed projects directory (if any failures exist) |

### Run Tests Output Artifacts

Generated and uploaded automatically (when enabled via inputs):

- **Artifact: `test-results`** — Test results directory with jUnit XML and logs
- **Artifact: `failed-tests`** — Failed test projects directory (uploaded only if failures exist)

---

<!-- markdownlint-disable-next-line MD033 -->
<center>Made with ❤️ for and by the WinCC OA community</center>

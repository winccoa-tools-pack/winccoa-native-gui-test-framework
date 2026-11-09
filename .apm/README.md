# Squirt AI Skills

All Squirt-owned skills are authored under `.apm/skills`. The two audiences
have separate APM packages, entry skills, and discovery descriptions:

```text
.apm/skills/
  maintenance/
    apm.yml
    squirt-maintenance/SKILL.md
    tc-quide-panel/SKILL.md
    winccoa-gui-shape-tests/SKILL.md
  usage/
    apm.yml
    squirt-test-authoring/SKILL.md
```

## Maintain Squirt

Use these when changing the framework itself:

- [squirt-maintenance](skills/maintenance/squirt-maintenance/SKILL.md): framework ownership,
  public API compatibility, implementation changes, tests, and documentation.
- [tc-quide-panel](skills/maintenance/tc-quide-panel/SKILL.md): guide-panel implementation,
  JSON configuration contract, recorder integration, and stop handshake.
- [winccoa-gui-shape-tests](skills/maintenance/winccoa-gui-shape-tests/SKILL.md): framework
  shape-wrapper tests, isolated panels, and attribute/event validation.

## Work With Squirt

Use [squirt-test-authoring](skills/usage/squirt-test-authoring/SKILL.md) when writing
product or project tests that consume Squirt. It owns player usage, behavioral
assertions, visual checkpoints, DPL fixture reuse, restricted-user execution,
guided recording during authoring, and finalized unattended macro replay.

Do not load maintainer implementation guidance simply because a product test
imports Squirt. If a consumer investigation requires a framework change,
switch to the maintainer workflow for that change.

## Source And Deployment

Edit `.apm/skills/<group>/<name>/SKILL.md`, not deployed copies in
`.agents/skills` or legacy `.github/skills` directories. Each group manifest
explicitly declares its local skill dependencies; a plain grouping directory
without a manifest is not an installable APM package.

From a consumer project, install either group from a local checkout:

```powershell
$squirtSkills = 'C:/ws/winccoa-tools-pack/winccoa-native-gui-test-framework/.apm/skills'
apm install "$squirtSkills/usage" --only apm --target copilot
# Or, for framework development:
apm install "$squirtSkills/maintenance" --only apm --target copilot
```

To deploy both groups while working in this repository, run:

```powershell
apm install ./.apm/skills/maintenance ./.apm/skills/usage --only apm --target copilot
```

Usage installs one skill; maintenance installs three and does not implicitly
install usage. These commands were verified with APM 0.35.0 in separate fresh
consumer projects. The grouped packages use local path dependencies and are
for installation from a checkout, not `apm pack` distribution. Remote package
installation has not been verified. Do not use `--force` merely to overwrite
unmanaged or modified legacy copies; review collisions separately.

Shared WinCC OA skills remain managed by the existing APM dependency rather
than copied into Squirt's authored source directory. Changes to that shared
package belong in its owning repository.

---

<!-- markdownlint-disable-next-line MD033 -->
<center>Made with ❤️ for and by the WinCC OA community</center>

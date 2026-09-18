# devTools — WinCC OA helper CLIs

Small Node CLIs under this folder. Prefer the published org packages and
GitHub Actions for day-to-day work; these helpers remain for local experiments.

| Package | Role |
| --- | --- |
| `devTools/npm-winccoa-register` | Write runner config / register a project |
| `devTools/npm-winccoa-ctrl` | Invoke `WCCOActrl` and forward its exit code |
| `devTools/github-action-run-ctl` | Local composite-style CTL runner notes |

## Preferred replacements

| Old `OaDevTools` use | Use instead |
| --- | --- |
| CTL astyle dry-run | `@winccoa-tools-pack/npm-winccoa-ctrl-code-style` / action `winccoa-style-check` |
| Copyright header check | action `ctrl-copyright-check` (no in-repo CTL project) |
| Docs build runner | `src/Squirt` + `winccoa-docu-builder` |

The legacy **`OaDevTools`** WinCC OA mini-project was removed from this
repository. Do not register or point scripts at it.

## Quick start (local Node helpers)

```powershell
cd devTools\npm-winccoa-register
npm install

cd ..\npm-winccoa-ctrl
npm install
```

Register the **worker** project (example):

```powershell
node devTools\npm-winccoa-register\index.js `
  "C:\ws\winccoa-tools-pack\winccoa-native-gui-test-framework" `
  "C:\Program Files\Siemens\WinCC_OA\3.21" `
  "C:\ws\winccoa-tools-pack\winccoa-native-gui-test-framework\src\Squirt" `
  3.21
```

Run an arbitrary CTL script against the worker config:

```powershell
node devTools\npm-winccoa-ctrl\index.js run `
  "C:\Program Files\Siemens\WinCC_OA\3.21\bin" `
  "C:\ws\winccoa-tools-pack\winccoa-native-gui-test-framework\src\Squirt\config\config" `
  "C:\path\to\script.ctl"
```

## Notes

- Registration tries `ProjEnvProject` / `setDir()` from
  `@winccoa-tools-pack/npm-winccoa-core` when available; otherwise it falls back
  to writing the config file.
- The `run` wrapper forwards STDOUT/STDERR and the exit code from `WCCOActrl`.

---

<!-- markdownlint-disable-next-line MD033 -->
<center>Made with ❤️ for and by the WinCC OA community</center>

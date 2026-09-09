# devTools — WinCC OA Node CLIs

This folder contains small Node CLIs to register a WinCC OA runner and to invoke `WCCOActrl` from Node.

Packages:
- `devTools/npm-winccoa-register` — writes runner config and attempts programmatic project registration via `@winccoa-tools-pack/npm-winccoa-core`.
- `devTools/npm-winccoa-ctrl` — wrapper to run `WCCOActrl.exe` and forward its exit code.

Quick start

1. Install dependencies for each package (or run per-package):

```powershell
cd devTools\npm-winccoa-register
npm install

cd ..\npm-winccoa-ctrl
npm install
```

2. Register a runner (creates `runner/config/config` and attempts registration):

```powershell
node devTools\npm-winccoa-register\index.js "C:\path\to\repo" "C:\Program Files\Siemens\WinCC_OA\3.21" "C:\path\to\repo\OaDevTools" 3.21
```

3. Run a CTL script via `WCCOActrl` using the run wrapper:

```powershell
node devTools\npm-winccoa-ctrl\index.js run "C:\Program Files\Siemens\WinCC_OA\3.21\bin" "C:\path\to\repo\OaDevTools\config\config" "C:\path\to\script.ctl" [args...]
```

Notes
- Registration tries `ProjEnvProject` / `setDir()` from `@winccoa-tools-pack/npm-winccoa-core` when available; otherwise falls back to writing the config file.
- The register CLI will wait briefly for registration to complete and exit with:
  - `0` = success
  - `2` = registration did not complete in time
  - `3` = unexpected error
- The `run` wrapper forwards the exact exit code returned by `WCCOActrl.exe`.

If you want, publish these packages to npm or use `npx` wrappers for convenience in CI.

---

<center>Made with ❤️ for and by the WinCC OA community</center>
# devTools — WinCC OA helper CLIs

We replaced the PowerShell helpers with small Node CLIs located under `devTools/npm-winccoa-ctrl` and
`devTools/npm-winccoa-register`.

Prerequisites
- Node.js 14+ installed and available on PATH.

Register runner (create config and dirs)

From the repository root, run:

```powershell
node devTools/npm-winccoa-ctrl/index.js register . "C:/Program Files/Siemens/WinCC_OA/3.21" "C:/ws/winccoa-tools-pack/winccoa-native-gui-test-framework/OaDevTools" 3.21
```

Or use the standalone register CLI:

```powershell
node devTools/npm-winccoa-register/index.js . "C:/Program Files/Siemens/WinCC_OA/3.21" "C:/ws/winccoa-tools-pack/winccoa-native-gui-test-framework/OaDevTools" 3.21
```

Run a `.ctl` helper (invokes `WCCOActrl.exe` and returns its exit code)

```powershell
node devTools/npm-winccoa-ctrl/index.js run "C:/Program Files/Siemens/WinCC_OA/3.21/bin" "C:/ws/winccoa-tools-pack/winccoa-native-gui-test-framework/OaDevTools/config/config" "C:/ws/winccoa-tools-pack/winccoa-native-gui-test-framework/OaDevTools/scripts/copyright.ctl" TRUE
```

Notes
- The `run` command forwards STDOUT/STDERR from `WCCOActrl.exe` and exits with the same exit code.
- You can wrap `node` with `npx` or install the tools locally/global for convenience.

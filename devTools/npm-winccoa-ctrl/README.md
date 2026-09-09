# npm-winccoa-ctrl

Small CLI helpers to register a WinCC OA runner and invoke `WCCOActrl` from Node.

Usage:

- Register runner:

```
node ./index.js register <repoRoot> <oaPath> <runnerPath> <winccoaVersion>
```

- Run a ctl script:

```
node ./index.js run <oaBin> <configPath> <scriptPath> [args...]
```

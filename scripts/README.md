# scripts

Administration helper scripts for this repository.

## activateMe

Registers [src/Squirt](../src/Squirt) as a non-runnable WinCC OA sub-project
using [`@winccoa-tools-pack/npm-winccoa-register-project`](https://github.com/winccoa-tools-pack/npm-winccoa-register-project).

| Script | Platform |
| --- | --- |
| [activateMe.cmd](activateMe.cmd) | Windows |
| [activateMe.sh](activateMe.sh) | Linux / Git Bash |

Prerequisites: Node.js with `npx`, and an installed WinCC OA.

```powershell
# Windows
scripts\activateMe.cmd

# Pin the WinCC OA version when several are installed
$env:WINCCOA_VERSION = '3.22'; scripts\activateMe.cmd
```

```bash
# Linux
./scripts/activateMe.sh

# Pin the WinCC OA version when several are installed
WINCCOA_VERSION=3.22 ./scripts/activateMe.sh
```

The scripts resolve the Squirt path relative to their own location, so they
can be called from any working directory. The exit code of the registration is
returned, `0` means success.

---

<center>Made with ❤️ for and by the WinCC OA community</center>

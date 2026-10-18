@echo off
setlocal

where WCCOActrl.exe >nul 2>nul
if errorlevel 1 (
  echo WCCOActrl.exe was not found on PATH. 1>&2
  exit /b 2
)

if "%~2"=="" (
  echo Usage: sq-cli ^<project^> ^<record^|pause^|resume^|stop^|status^> [settings] 1>&2
  exit /b 2
)

WCCOActrl.exe -proj "%~1" -log +stderr "splash/cli.ctl" %2 %3 %4 %5 %6 %7 %8 %9
exit /b %errorlevel%
@echo off
setlocal

where WCCOActrl.exe >nul 2>nul
if errorlevel 1 (
  echo WCCOActrl.exe was not found on PATH. 1>&2
  exit /b 2
)

if "%~1"=="" (
  echo Usage: sq-cli ^<project^> ^<record^|pause^|resume^|stop^|status^> [settings] 1>&2
  exit /b 2
)

set "PROJECT=%~1"
shift
if "%~1"=="" (
  echo Usage: sq-cli ^<project^> ^<record^|pause^|resume^|stop^|status^> [settings] 1>&2
  exit /b 2
)
set "COMMAND=%~1"
shift
setlocal EnableDelayedExpansion
set "CLI_ARGS="

:collect_args
if "%~1"=="" goto run_cli
set "ARG=%~1"
echo(!ARG!| findstr /C:"=" >nul
if errorlevel 1 (
  if "%~2"=="" (
    echo Missing value for setting %~1. 1>&2
    exit /b 2
  )
  set "ARG=!ARG!=%~2"
  shift
)
set "CLI_ARGS=!CLI_ARGS! "!ARG!""
shift
goto collect_args

:run_cli
WCCOActrl.exe -proj "%PROJECT%" -log +stderr "splash/cli.ctl" "%COMMAND%" %CLI_ARGS%
exit /b %errorlevel%
@echo off
rem Registers Squirt as a WinCC OA sub-project. Optional: set WINCCOA_VERSION (e.g. 3.22).
setlocal

set "SQUIRT_PATH=%~dp0..\src\Squirt"
for %%I in ("%SQUIRT_PATH%") do set "SQUIRT_PATH=%%~fI"

if not exist "%SQUIRT_PATH%\config" (
  echo activateMe: Squirt project not found: %SQUIRT_PATH% 1>&2
  exit /b 1
)

set "VERSION_ARGS="
if defined WINCCOA_VERSION set "VERSION_ARGS=--wincc-oa-version %WINCCOA_VERSION%"

call npx --yes @winccoa-tools-pack/npm-winccoa-register-project --project-path "%SQUIRT_PATH%" --runnable false %VERSION_ARGS%
exit /b %ERRORLEVEL%

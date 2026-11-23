@echo off
rem Registers Splash as a WinCC OA sub-project. Optional: set WINCCOA_VERSION (e.g. 3.22).
setlocal

set "SPLASH_PATH=%~dp0..\src\Splash"
for %%I in ("%SPLASH_PATH%") do set "SPLASH_PATH=%%~fI"

if not exist "%SPLASH_PATH%\config" (
  echo activateMe: Splash project not found: %SPLASH_PATH% 1>&2
  exit /b 1
)

set "VERSION_ARGS="
if defined WINCCOA_VERSION set "VERSION_ARGS=--wincc-oa-version %WINCCOA_VERSION%"

call npx --yes @winccoa-tools-pack/npm-winccoa-register-project --project-path "%SPLASH_PATH%" --runnable false %VERSION_ARGS%
exit /b %ERRORLEVEL%

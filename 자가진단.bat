@echo off
setlocal
chcp 65001 >nul
title Android CLI Kit - Self Check
rem === Android CLI One-Click Kit : SELF-CHECK (installs nothing) ===
rem ASCII-only launcher. Korean UI lives in lib\selfcheck.ps1
set "HERE=%~dp0"
if not exist "%HERE%lib\selfcheck.ps1" (
  echo.
  echo [!] Cannot find: lib\selfcheck.ps1
  echo     Keep ALL files together - do not move this .bat out of the folder,
  echo     and unzip the whole kit including the lib folder.
  echo.
  pause
  exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%HERE%lib\selfcheck.ps1"
if not "%ERRORLEVEL%"=="0" (
  echo.
  echo [!] Self-check ended with an error.
  echo     Take a screenshot of this window and ask for help.
  pause
)
endlocal

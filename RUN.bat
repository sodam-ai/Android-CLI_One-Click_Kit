@echo off
setlocal
chcp 65001 >nul
title Android CLI Kit - Menu
rem === Android CLI One-Click Kit : RUN (menu) ===
rem ASCII-only launcher. Korean UI lives in lib\menu.ps1
set "HERE=%~dp0"
if not exist "%HERE%lib\menu.ps1" (
  echo.
  echo [!] Cannot find: lib\menu.ps1
  echo     Keep ALL files together - do not move this .bat out of the folder,
  echo     and unzip the whole kit including the lib folder.
  echo.
  pause
  exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%HERE%lib\menu.ps1"
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
  echo.
  echo [!] Menu ended with error code %RC%.
  echo     Take a screenshot of this window and ask for help.
  pause
)
endlocal

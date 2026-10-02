@echo off
setlocal

REM remove tmq file association from registry
reg delete "HKCU\Software\Classes\.tmq" /f >nul 2>nul
reg delete "HKCU\Software\Classes\TumorScript.File" /f >nul 2>nul

echo.
echo unregistered tmq file association successfully
echo.
pause

@echo off
setlocal

REM register tmq file association so double clicking runs in cmd
set "EXE_PATH=%~dp0bin\tumorscript.exe"

if not exist "%EXE_PATH%" (
    echo building tumorscript first...
    call "%~dp0build.bat"
)

if not exist "%EXE_PATH%" (
    echo fatal: could not find tumorscript binary at %EXE_PATH%
    pause
    exit /b 1
)

REM register file type and extension for current user
reg add "HKCU\Software\Classes\.tmq" /ve /d "TumorScript.File" /f >nul
reg add "HKCU\Software\Classes\TumorScript.File" /ve /d "TumorScript Quarantine Source" /f >nul
reg add "HKCU\Software\Classes\TumorScript.File\DefaultIcon" /ve /d "\"%EXE_PATH%\",0" /f >nul
reg add "HKCU\Software\Classes\TumorScript.File\shell\open\command" /ve /d "cmd.exe /c \"\"%EXE_PATH%\" \"%%1\" ^& pause\"" /f >nul

echo.
echo registered tmq file association successfully
echo double clicking any tmq file will now open and run it in cmd
echo.
pause

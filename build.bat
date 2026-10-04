@echo off
setlocal enabledelayedexpansion

REM verify lua source syntax with luac if available
where luac >nul 2>nul
if %errorlevel% equ 0 (
    echo [1/3] checking lua bytecode syntax with luac...
    luac -p main.lua src\lexer.lua src\parser.lua src\memory.lua src\interpreter.lua src\repl.lua src\json.lua src\capsid.lua
    if %errorlevel% neq 0 (
        echo luac syntax check failed
        exit /b 1
    )
) else (
    echo [1/3] luac not found in path, skipping syntax check...
)

REM compile native executable with cargo
echo [2/3] compiling tumorscript executable with cargo...
cargo build --release
if %errorlevel% neq 0 (
    echo compilation failed
    exit /b 1
)

REM copy binary to bin folder
echo [3/3] preparing bin output...
if not exist "bin" mkdir "bin"
copy /y "target\release\tumorscript.exe" "bin\tumorscript.exe" >nul
if not exist "tumorscript\bin" mkdir "tumorscript\bin"
copy /y "target\release\tumorscript.exe" "tumorscript\bin\tumorscript.exe" >nul

echo.
echo build complete! binary located at bin\tumorscript.exe
echo test it with: bin\tumorscript.exe examples\hospital_core.tmq

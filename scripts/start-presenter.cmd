@echo off
setlocal
where.exe pwsh.exe >nul 2>nul
if errorlevel 1 (
    echo ERROR: PowerShell 7 ^(pwsh.exe^) is required and was not found on PATH.
    echo Install your organization's approved PowerShell 7 release, then reopen your terminal.
    exit /b 1
)

rem A dedicated PowerShell 7 window keeps the walkthrough separate from Copilot.
rem NoProfile avoids profile errors; no execution-policy override is applied.
rem NoExit keeps the window open so completion messages or errors remain visible.
start "WorkIQ presenter - PowerShell 7" /D "%~dp0.." pwsh.exe -NoLogo -NoProfile -NoExit -File "%~dp0present-demo.ps1" %*
if errorlevel 1 (
    echo ERROR: Could not open the PowerShell 7 presenter window.
    exit /b 1
)

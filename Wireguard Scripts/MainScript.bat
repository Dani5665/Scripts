@echo off
:checkAdmin
:: Check for admin privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    :: If not running as admin, relaunch as admin
    echo Elevating permissions...
    PowerShell -Command "Start-Process cmd -ArgumentList '/c %~s0' -Verb RunAs"
    exit /b
)

:menu
cls
:: Display menu options
echo Select a PowerShell script to execute:
echo 1. Download Wireguard
echo 2. Setup WireGuard
echo 3. Create schedule to activate WG
echo 4. Run ActivationScript
echo 5. Exit
echo.

:: Get user input
set /p choice="Enter your choice (1, 2, 3, or 4 to exit): "

:: Set the script path based on the user's choice
set script=""

if %choice%==1 set script=%~dp0DownloadWireguard.ps1
if %choice%==2 set script=%~dp0SetupWireguard.ps1
if %choice%==3 set script=%~dp0CreateWgActivationSchedule.ps1
if %choice%==4 set script=C:\Program Files\WireGuard\WireGuardActivationScript.ps1
if %choice%==5 exit

:: If no valid choice is made, go back to menu
if "%script%"=="" (
    echo Invalid selection. Please try again.
    pause
    goto menu
)

:: Run the selected PowerShell script as admin
PowerShell -ExecutionPolicy Bypass -File "%script%"

:: After script execution, ask user if they want to continue
echo.
echo Script execution completed.
pause
goto menu

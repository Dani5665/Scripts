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
echo 1. Download WireGuard
echo 2. Setup WireGuard
echo 3. Create schedule to activate WG
echo 4. Run ActivationScript
echo 5. Exit
echo.

:: Get user input
set /p choice="Enter your choice (1, 2, 3, 4, or 5 to exit): "

:: Set GitHub URL for the scripts
set scriptUrl=""
set scriptName=""

if %choice%==1 (
    set scriptUrl=https://raw.githubusercontent.com/Dani5665/Scripts/refs/heads/main/Wireguard%20Scripts/DownloadWireguard.ps1
    set scriptName=DownloadWireguard.ps1
)
if %choice%==2 (
    set scriptUrl=https://raw.githubusercontent.com/Dani5665/Scripts/refs/heads/main/Wireguard%20Scripts/SetupWireguard.ps1
    set scriptName=SetupWireguard.ps1
)
if %choice%==3 (
    set scriptUrl=https://raw.githubusercontent.com/Dani5665/Scripts/refs/heads/main/Wireguard%20Scripts/CreateWgActivationSchedule.ps1
    set scriptName=CreateWgActivationSchedule.ps1
)
if %choice%==4 (
    set scriptUrl=https://raw.githubusercontent.com/Dani5665/Scripts/refs/heads/main/Wireguard%20Scripts/WireGuardActivationScript.ps1
    set scriptName=WireGuardActivationScript.ps1
)
if %choice%==5 exit

:: If no valid choice is made, go back to menu
if "%scriptUrl%"=="" (
    echo Invalid selection. Please try again.
    pause
    goto menu
)

:: Download the script from GitHub to a temporary folder
set tempFolder=%TEMP%\WGscripts
if not exist %tempFolder% (
    mkdir %tempFolder%
)

echo Downloading %scriptName% from GitHub...
PowerShell -Command "(New-Object System.Net.WebClient).DownloadFile('%scriptUrl%', '%tempFolder%\%scriptName%')"

:: Run the downloaded PowerShell script as admin
PowerShell -ExecutionPolicy Bypass -File "%tempFolder%\%scriptName%"

:: After script execution, ask the user if they want to continue
echo.
echo Script execution completed.
pause
goto menu

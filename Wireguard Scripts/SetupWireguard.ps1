# Define a function to check if the script is run as Administrator
function Is-RunAsAdministrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Relaunch script as Administrator if not already
if (-not (Is-RunAsAdministrator)) {
    Write-Host "Script not run as Administrator. Relaunching with elevated privileges..."
    Start-Process powershell "-ExecutionPolicy Bypass -File '$PSCommandPath'" -Verb RunAs
    exit
}

# Get the directory of the current script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Define the script file path in the current script's directory (for activation script download)
$scriptPath = Join-Path -Path $scriptDirectory -ChildPath "\WireGuardActivationScript.ps1"

# Download the activation script
Write-Host "Downloading WireGuardActivationScript to $scriptPath..."
Invoke-WebRequest -Uri https://raw.githubusercontent.com/Dani5665/Scripts/main/Wireguard%20Scripts/WireGuardActivationScript.ps1 -OutFile $scriptPath

# Define target directory
$wireGuardDir = "C:\Program Files\WireGuard"

# Check if the directory "C:\Program Files\WireGuard" exists
if (Test-Path -Path $wireGuardDir) {
    # Get the first .conf file from the script's directory (where the script is located)
    $scriptDir = $PSScriptRoot
    $confFile = Get-ChildItem -Path $scriptDir -Filter *.conf | Select-Object -First 1
    
    # Check if a .conf file was found
    if ($confFile) {
        # Copy the first .conf file to "C:\Program Files\WireGuard"
        Copy-Item -Path $confFile.FullName -Destination $wireGuardDir -Force
        Write-Host "Copied $($confFile.Name) to $wireGuardDir"
    } else {
        Write-Host "No .conf file found in the script's directory ($scriptDir)."
    }
    
    # Copy "WireGuardActivationScript.ps1" from the script's directory to "C:\Program Files\WireGuard"
    $activationScript = Join-Path -Path $scriptDir -ChildPath "WireGuardActivationScript.ps1"
    
    if (Test-Path -Path $activationScript) {
        Copy-Item -Path $activationScript -Destination $wireGuardDir -Force
        Write-Host "Copied WireGuardActivationScript.ps1 to $wireGuardDir"
    } else {
        Write-Host "WireGuardActivationScript.ps1 not found in the script's directory ($scriptDir)."
    }
}

# Pause the script and wait for user input to close
Read-Host -Prompt "Press Enter to exit"

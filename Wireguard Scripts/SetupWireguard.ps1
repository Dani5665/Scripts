# Define a function to check if the script is run as Administrator
function Is-RunAsAdministrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Relaunch script as Administrator if not already
if (-not (Is-RunAsAdministrator)) {
    Write-Host "Script not run as Administrator. Relaunching with elevated privileges..."
    
    # Relaunch the script with elevated privileges
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs

    # Exit the non-elevated instance of the script
    exit
}

# Get the directory of the current script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Define the script file paths in the current script's directory
$mainTaskScriptPath = Join-Path -Path $scriptDirectory -ChildPath "MainTaskScript.ps1"
$downloadScriptsPath = Join-Path -Path $scriptDirectory -ChildPath "DownloadScripts.ps1"

# Download the activation scripts
Write-Host "Downloading MainTaskScript.ps1 to $mainTaskScriptPath..."
Invoke-WebRequest -Uri https://raw.githubusercontent.com/Dani5665/Scripts/main/Wireguard%20Scripts/MainTaskScript.ps1 -OutFile $mainTaskScriptPath

Write-Host "Downloading DownloadScripts.ps1 to $downloadScriptsPath..."
Invoke-WebRequest -Uri https://raw.githubusercontent.com/Dani5665/Scripts/main/Wireguard%20Scripts/DownloadScripts.ps1 -OutFile $downloadScriptsPath

# Define the URL
$url = Read-Host "Please enter the URL to download the file"

# Perform the web request
$response = Invoke-WebRequest -Uri $url

# Extract the filename from the Content-Disposition header
$contentDisposition = $response.Headers["Content-Disposition"]
$filename = $contentDisposition -match 'filename="(.+)"' | Out-Null; $matches[1]
$extractedName = $matches[1]

# Save the file in the same directory as the script
$filePath = Join-Path -Path (Get-Location) -ChildPath $filename

# Write the content to the file
$response.Content | Set-Content -Path "${scriptDirectory}\${extractedName}" -Encoding Byte

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
    
    # Copy "MainTaskScript.ps1" from the script's directory to "C:\Program Files\WireGuard"
    if (Test-Path -Path $mainTaskScriptPath) {
        Copy-Item -Path $mainTaskScriptPath -Destination $wireGuardDir -Force
        Write-Host "Copied MainTaskScript.ps1 to $wireGuardDir"
    } else {
        Write-Host "MainTaskScript.ps1 not found in the script's directory ($scriptDir)."
    }

    # Copy "DownloadScripts.ps1" from the script's directory to "C:\Program Files\WireGuard"
    if (Test-Path -Path $downloadScriptsPath) {
        Copy-Item -Path $downloadScriptsPath -Destination $wireGuardDir -Force
        Write-Host "Copied DownloadScripts.ps1 to $wireGuardDir"
    } else {
        Write-Host "DownloadScripts.ps1 not found in the script's directory ($scriptDir)."
    }
}

# Pause the script and wait for user input to close
Read-Host -Prompt "Press Enter to exit"

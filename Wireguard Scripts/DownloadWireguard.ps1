# Function to check if the script is running as administrator
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# If not running as admin, re-run the script with elevated privileges
if (-Not (Test-Admin)) {
    Write-Host "The script is not running as administrator. Restarting with elevated privileges..."
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Define the URL of the WireGuard installer and the destination path
$installerUrl = "https://download.wireguard.com/windows-client/wireguard-installer.exe"
$installerPath = "$env:TEMP\wireguard-installer.exe"

# Download the WireGuard installer
Write-Host "Downloading WireGuard installer..."
Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

# Run the installer and wait for it to finish
Write-Host "Running WireGuard installer..."
Start-Process -FilePath $installerPath -Wait

# Define the WireGuard installation path
$wireGuardPath = "C:\Program Files\WireGuard"

# Check if the WireGuard directory exists, if not create it
if (-Not (Test-Path $wireGuardPath)) {
    New-Item -Path $wireGuardPath -ItemType Directory
}


Write-Host "WireGuard installation completed."

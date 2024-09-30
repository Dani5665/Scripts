$scriptUrl = "https://raw.githubusercontent.com/Dani5665/Scripts/main/Wireguard%20Scripts/WireGuardActivationScript.ps1"
$scriptPath = "C:\Program Files\WireGuard\WireGuardActivationScript.ps1"

# Download the selected script
Write-Host "Downloading $selectedScript to $scriptPath..."
Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath
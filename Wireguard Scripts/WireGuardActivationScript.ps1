# Define the directory where .conf files are stored
$confDir = "C:\Program Files\WireGuard"
$wgPath = "C:\Program Files\WireGuard\wg.exe"
$wireguardPath = "C:\Program Files\WireGuard\wireguard.exe"

# Get the first .conf file in the directory
$confFile = Get-ChildItem -Path $confDir -Filter "*.conf" | Select-Object -First 1

if ($confFile -ne $null) {
    $interfaceName = [System.IO.Path]::GetFileNameWithoutExtension($confFile.Name)

    # Check if the WireGuard interface is active
    $wgOutput = & "$wgPath" show interfaces

    if ($wgOutput -match $interfaceName) {
        Write-Output "WireGuard VPN ($interfaceName) is active."
    } else {
        Write-Output "WireGuard VPN ($interfaceName) is not active. Attempting to activate..."
        
        # Command to activate the WireGuard interface
        & "$wireguardPath" /installtunnelservice "$confDir\$interfaceName.conf"
        
        if ($?) {
            Write-Output "WireGuard VPN ($interfaceName) activated successfully."
        } else {
            Write-Output "Failed to activate WireGuard VPN ($interfaceName)."
        }
    }
} else {
    Write-Output "No .conf files found in the directory $confDir."
}

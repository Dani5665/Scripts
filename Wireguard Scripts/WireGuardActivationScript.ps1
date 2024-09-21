# Disable SSL certificate validation
Add-Type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

# API credentials
$api_key = "xm4hOT7NRq6P9p5TwnynzPjZv15rviHQypnhcqK7gyEPw8xGMHaz6jnlswQSEJLjxXwblrTOHaMJRnsl"
$api_secret = "OXcFBYNOCAHm4OX/xBhPHFTPpKG+YeBwxkwDqZsHBV9SpmZerMvc78PgFPSa/L1aQtxOfAtWciFcCwGV"
$encoded_credentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${api_key}:${api_secret}"))
$wireguard_status = 0

# Try to send the GET request and handle potential errors
try {
    # Send the GET request
    $response = Invoke-WebRequest -Uri "https://91.132.60.114/api/core/service/search" `
                                  -Method Get `
                                  -Headers @{Authorization="Basic $encoded_credentials"} `
                                  -UseBasicParsing

    # Parse the JSON response
    $json = $response.Content | ConvertFrom-Json

    # Find the WireGuard entry and check if 'running' is 1
    $wireguard = $json.rows | Where-Object { $_.id -like "wireguard*" }

    if ($wireguard.running -eq 1) {
        Write-Host "WireGuard is running."
        $wireguard_status = 1
    } else {
        Write-Host "WireGuard is not running."
    }
}
catch {
    # Check if the error is related to connecting to the remote server
    if ($_.Exception.Message -like "*Unable to connect to the remote server*") {
        Write-Host "Unable to connect to the remote server."
    } else {
        Write-Host "An error occurred: $($_.Exception.Message)"
    }
}

# Only execute the second script if WireGuard is active (i.e., $wireguard_status equals 1)
if ($wireguard_status -eq 1) {
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
} else {
    Write-Host "WireGuard is not running or an error occurred, skipping activation."
}

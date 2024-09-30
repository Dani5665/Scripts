# Define values in Script1
$api_key = ""
$api_secret = ""
$opn_url = ""

# Call ToRun1.ps1 with the variables as arguments
#& "C:\Program Files\WireGuard\DownloadScripts.ps1" 
Start-Process -FilePath "powershell.exe" -ArgumentList "-File C:\Program Files\WireGuard\DownloadScripts.ps1" -NoNewWindow -Wait

#& "C:\Program Files\WireGuard\WireGuardActivationScript.ps1" -api_key $api_key -api_secret $api_secret -opn_url $opn_url
Start-Process -FilePath "powershell.exe" -ArgumentList "-File 'C:\Program Files\WireGuard\WireGuardActivationScript.ps1' -api_key '$api_key' -api_secret '$api_secret' -opn_url '$opn_url'" -NoNewWindow -Wait
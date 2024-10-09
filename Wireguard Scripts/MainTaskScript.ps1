#Call DownloadScripts.ps1 in the background
Start-Process -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList "-File `"C:\Program Files\WireGuard\DownloadScripts.ps1`"" `
    -NoNewWindow -Wait

# Start Script2 in the background, passing the parameters
$script2Path = "C:\Program Files\WireGuard\WireGuardActivationScript.ps1"  # Modify this path to the actual location of Script2
Start-Process -FilePath "powershell.exe" -ArgumentList "-File `"$script2Path`" -key `"$key`" -secret `"$secret`" -url `"$url`"" -NoNewWindow -PassThru

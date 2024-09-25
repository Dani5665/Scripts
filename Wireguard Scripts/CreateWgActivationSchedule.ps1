# Check if the script is running with administrative privileges
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Relaunch script with admin privileges if not running as admin
if (-not (Test-Admin)) {
    Write-Host "Not running as administrator. Relaunching with elevated privileges..."
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$taskName = "WireGuardActivation"
$scriptPath = "C:\Program Files\WireGuard\WireGuardActivationScript.ps1"

# Define the action (running PowerShell with the script)
$Action = New-ScheduledTaskAction -Execute 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -Argument '-ExecutionPolicy Bypass -File "C:\Program Files\WireGuard\WireGuardActivationScript.ps1"'

# Trigger the task to run every 30 minutes
$Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 30) -RepetitionDuration (New-TimeSpan -Days 1)

# Principal to run only if the user is logged on
$Principal = New-ScheduledTaskPrincipal -UserId "yordan-desktop\yordan" -LogonType Interactive -RunLevel Highest

# Task settings
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# Register the task without the author parameter
Register-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings -TaskName $taskName -Description "Task to run PowerShell script every 30 minutes only if user is logged on"

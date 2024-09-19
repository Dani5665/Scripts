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

# Script is running with admin privileges, create the scheduled task

$taskName = "WireGuardActivation"
$scriptPath = "C:\Program Files\WireGuard\WireGuardActivationScript.ps1"

# Define the action to run the script
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""

# Define the trigger to run the task at system startup and repeat every hour indefinitely
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration (New-TimeSpan -Days 9999)

# Define the principal (run with highest privileges)
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest

# Define the task settings (allow running on batteries and don't stop if idle)
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopOnIdleEnd

# Register the scheduled task
try {
    Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -Settings $settings -TaskName $taskName
    Write-Host "Scheduled task '$taskName' created to run at startup and repeat every hour."
} catch {
    Write-Host "Error creating the scheduled task: $_"
}

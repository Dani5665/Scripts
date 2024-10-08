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

# Get the directory of the current script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Define GitHub repository URL and script names
$repoUrl = "https://raw.githubusercontent.com/Dani5665/Scripts/main/Wireguard%20Scripts"
$scriptNames = @(
    "DownloadWireguard.ps1",
    "SetupWireguard.ps1",
    "CreateWgActivationSchedule.ps1"
)

# Start a loop to allow multiple selections
while ($true) {
    # Display menu
    Write-Host "`nChoose a script to run:"
    for ($i = 0; $i -lt $scriptNames.Length; $i++) {
        Write-Host "$($i + 1): $($scriptNames[$i])"
    }
    Write-Host "0: Exit"  # Option to exit the loop

    # Get user choice
    $choice = Read-Host "Enter the number of the script you want to run (or 0 to exit)"

    # Exit if the user chooses 0
    if ($choice -eq 0) {
        Write-Host "Exiting..."
        break
    }

    # Validate choice
    if ($choice -lt 1 -or $choice -gt $scriptNames.Length) {
        Write-Host "Invalid choice. Please try again."
        continue
    }

    # Determine script to download
    $selectedScript = $scriptNames[$choice - 1]
    $scriptUrl = "$repoUrl/$selectedScript"

    # Define the script file path in the current script's directory
    $scriptPath = Join-Path -Path $scriptDirectory -ChildPath $selectedScript

    # Download the selected script
    Write-Host "Downloading $selectedScript to $scriptPath..."
    Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath

    # Run the downloaded script
    Write-Host "Running $selectedScript..."
    try {
        & $scriptPath
    } catch {
        Write-Host "Error running the script: $_"
    }

    # Prompt to run another script or exit
    Write-Host "`nScript execution finished. You can choose another script or exit."
}

Write-Host "Done."
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                

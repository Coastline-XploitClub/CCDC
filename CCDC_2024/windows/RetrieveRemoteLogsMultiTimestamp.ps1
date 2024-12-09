# Variables
$RemoteComputers = @{
    "192.168.220.111" = "CTHULU\Administrator"
    "192.168.220.245" = "VIKING\Administrator"
    "192.168.220.254" = "ALIEN\Administrator"
}
$Password = ConvertTo-SecureString "LowCostLunar1@" -AsPlainText -Force # Common password for all users
$BaseLocalSavePath = "C:\RemoteEventLogs" # Base path for saving logs
$LogNames = @("Security.evtx", "Application.evtx", "System.evtx", "Setup.evtx")

# Function to convert SecureString to plain text
function Convert-SecureStringToPlainText {
    param (
        [securestring]$SecureString
    )
    $Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
    try {
        return [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($Ptr)
    } finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($Ptr)
    }
}

# Function to map network drive
function Map-NetworkDrive {
    param (
        [string]$RemotePath,
        [string]$Username,
        [securestring]$Password
    )
    $PlainPassword = Convert-SecureStringToPlainText $Password
    $NetUseCommand = "net use $RemotePath /user:$Username $PlainPassword"
    Invoke-Expression -Command $NetUseCommand
}

# Function to check if a file exists on a remote path
function Test-RemoteFile {
    param (
        [string]$RemoteFile
    )
    try {
        if (Test-Path $RemoteFile) {
            return $true
        } else {
            Write-Error "Remote file `${RemoteFile}` does not exist."
            return $false
        }
    } catch {
        Write-Error "Failed to check remote file `${RemoteFile}`. Error: $($_.Exception.Message)"
        return $false
    }
}

# Loop through each remote computer
foreach ($RemoteComputer in $RemoteComputers.Keys) {
    $Username = $RemoteComputers[$RemoteComputer] # Retrieve the username for this computer
    $RemotePath = "\\$RemoteComputer\C$\Windows\System32\winevt\Logs"  # Remote log folder
    $Timestamp = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss") # Create a human-readable timestamp including seconds
    $LocalSavePath = Join-Path -Path $BaseLocalSavePath -ChildPath "$RemoteComputer-$Timestamp" # Folder includes timestamp

    Write-Host "Testing connection to $RemoteComputer..."
    if (!(Test-Connection -ComputerName $RemoteComputer -Count 1 -Quiet)) {
        Write-Error "Unable to reach `${RemoteComputer}`. Skipping..."
        continue
    }

    # Ensure the local directory for this machine exists
    if (!(Test-Path -Path $LocalSavePath)) {
        New-Item -ItemType Directory -Path $LocalSavePath | Out-Null
    }

    # Map network drive
    try {
        Map-NetworkDrive -RemotePath $RemotePath -Username $Username -Password $Password
    } catch {
        Write-Error "Failed to map network drive for `${RemoteComputer}`. Error: $($_.Exception.Message)"
        continue
    }

    # Retrieve logs for this machine
    foreach ($LogName in $LogNames) {
        $RemoteFile = Join-Path -Path $RemotePath -ChildPath $LogName
        $LocalFile = Join-Path -Path $LocalSavePath -ChildPath $LogName

        if (!(Test-RemoteFile -RemoteFile $RemoteFile)) {
            Write-Error "Log file `${LogName}` does not exist on `${RemoteComputer}`. Skipping..."
            continue
        }

        try {
            Write-Host "Copying ${LogName} from ${RemoteComputer}..."
            Copy-Item -Path $RemoteFile -Destination $LocalFile -Force -ErrorAction Stop
            Write-Host "$LogName successfully saved to $LocalFile"
        } catch {
            Write-Error "Failed to copy `${LogName}` from `${RemoteComputer}`. Error: $($_.Exception.Message)"
        }
    }

    # Unmap the network drive
    try {
        Invoke-Expression -Command "net use $RemotePath /delete"
    } catch {
        Write-Error "Failed to unmap network drive for `${RemoteComputer}`. Error: $($_.Exception.Message)"
    }
}

Write-Host "Log retrieval complete."



# Banner
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "                  Coastline Xploit Club                   " -ForegroundColor Green
Write-Host "             Advanced  PowerShell Framework     		  " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan

# Ensure Checklist directory exists
$checklistPath = "C:\Checklist"
if (!(Test-Path $checklistPath)) {
    New-Item -ItemType Directory -Path $checklistPath | Out-Null
}

# Function to display the menu
function Show-Menu {
    Write-Host "===================== Windows Hardening Check Menu ====================="
    Write-Host "1. Save All Data to Checklist Folder"
    Write-Host "2. System Overview"
    Write-Host "3. Show Network Interfaces and IPs"
    Write-Host "4. Show Open Ports"
    Write-Host "5. List all running services"
    Write-Host "6. Enumerating Installed Software"
    Write-Host "7. Show User and Account Information"
    Write-Host "8. Show Scheduled Tasks"
    Write-Host "9. Show Process List"
    Write-Host "10. Show Process Tree"
    Write-Host "11. Get Firewall Information"
    Write-Host "12. Show PowerShell and CMD History"
    Write-Host "13. Check .exe files running in memory"
    Write-Host "Q. Quit"
    Write-Host "================================================================================================"
}

# Function to display system information
function Show-SystemInfo {
    Write-Host "\n================= System Overview =================" -ForegroundColor Cyan
    return systeminfo | Out-String
}

# Function to display network interfaces and IPs
function Show-NetworkInterfaces {
    Write-Host "\n================= Network Interfaces and IPs =================" -ForegroundColor Cyan
    return Get-NetIPAddress | Select IpAddress, InterfaceAlias, AddressFamily | Format-Table -AutoSize | Out-String
}

# Function to display open ports
function Show-OpenPorts {
    Write-Host "\n================= Open Ports =================" -ForegroundColor Cyan
    return netstat -ano | Select-String "LISTENING" | Out-String
}

# Function to display running services
Function Show-Services {
    Write-Host "\n================= Running Services =================" -ForegroundColor Cyan
    return Get-WmiObject Win32_Service | Where-Object { $_.State -eq "Running" } | Select-Object Name, DisplayName, State, StartMode, ProcessId | Format-Table -AutoSize | Out-String
}

# Function to enumerate installed software
Function Show-SoftwareInstalled {
    Write-Host "\n================= Enumerating Installed Software =================" -ForegroundColor Cyan
    return Get-WmiObject -Class Win32_Product | Select-Object Name, Version | Format-Table -AutoSize | Out-String
}

# Function to display user and account information with extended details
function Show-UserAccounts {
    Write-Host "\n================= User and Account Information =================" -ForegroundColor Cyan
    
    $users = net user | Out-String
    $groups = net localgroup | Out-String
    $accounts = net accounts | Out-String
    
    Write-Host "$users"
    Write-Host "$groups"
    Write-Host "$accounts"
    
    Write-Host "\n[+] Listing user account details:" -ForegroundColor Yellow
    $userDetails = Get-WmiObject Win32_UserAccount | Select-Object Name, FullName, Disabled, PasswordRequired, Lockout, PasswordExpires, LocalAccount, Description | Format-Table -AutoSize | Out-String
    Write-Host "$userDetails"
    
    Write-Host "\n[+] Listing all local groups and their members:" -ForegroundColor Yellow
    $groupMemberships = Get-LocalGroup | ForEach-Object {
        $groupName = $_.Name
        $members = Get-LocalGroupMember -Group $groupName | Select-Object Name, ObjectClass | Format-Table -AutoSize | Out-String
        "Group: $groupName\n$members"
    } | Out-String
    Write-Host "$groupMemberships"
    
    Write-Host "===========================================================\n" -ForegroundColor Cyan
    return "$users\n$groups\n$accounts\n$userDetails\n$groupMemberships"
}
# Function to display scheduled tasks
function Show-ScheduledTasks {
    Write-Host "\n================= Scheduled Tasks =================" -ForegroundColor Cyan
    return Get-ScheduledTask | Select-Object TaskName, TaskPath, State | Format-Table -AutoSize | Out-String
}

# Function to display process list
Function Show-PSList {
    Write-Host "\n[+] Listing running processes..." -ForegroundColor Green
    return Get-Process | Sort-Object CPU -Descending | Format-Table Id, Name, CPU, StartTime -AutoSize | Out-String
}

# Function to display process tree
Function Show-PSTree {
    Write-Host "\n[+] Displaying process tree..." -ForegroundColor Green
    return Get-CimInstance Win32_Process | ForEach-Object {
        $parent = Get-CimInstance Win32_Process -Filter "ProcessId = $($_.ParentProcessId)" -ErrorAction SilentlyContinue
        [PSCustomObject]@{
            ProcessId         = $_.ProcessId
            Name              = $_.Name
            ParentProcessId   = $_.ParentProcessId
            ParentProcessName = $parent.Name
        }
    } | Sort-Object ParentProcessId | Format-Table -AutoSize | Out-String
}
# Function to display .exe files running in memory
Function Show-ExeFiles {
    Write-Host "\n================= .exe Files Running in Memory =================" -ForegroundColor Cyan
    $exeFiles = Get-Process | Where-Object { $_.Path -like "*.exe" } | Select-Object Name, Path, Id, CPU | Format-Table -AutoSize | Out-String
    Write-Host "$exeFiles"
    Write-Host "===========================================================\n" -ForegroundColor Cyan
    return "$exeFiles"
}
# Function to display firewall information 
Function Get-FirewallInfo {
    Write-Host "\n================= Firewall Information =================" -ForegroundColor Cyan
    Write-Host "Firewall Status:" -ForegroundColor Yellow
    $firewallProfiles = Get-NetFirewallProfile | Select-Object Name, Enabled | Format-Table -AutoSize | Out-String
    Write-Host "$firewallProfiles"
    
    Write-Host "Firewall Rules and Ports (Limited to Active Inbound/Outbound Rules):" -ForegroundColor Yellow
    
    $firewallRules = Get-NetFirewallRule | Where-Object { $_.Enabled -eq $true -and ($_.Direction -eq "Inbound" -or $_.Direction -eq "Outbound") } |
        Select-Object DisplayName,
                      @{Name='Protocol';Expression={(Get-NetFirewallPortFilter -PolicyStore $_.PolicyStore | Select-Object -ExpandProperty Protocol -First 1)}},
                      @{Name='LocalPort';Expression={(Get-NetFirewallPortFilter -PolicyStore $_.PolicyStore | Select-Object -ExpandProperty LocalPort -First 1)}},
                      @{Name='RemotePort';Expression={(Get-NetFirewallPortFilter -PolicyStore $_.PolicyStore | Select-Object -ExpandProperty RemotePort -First 1)}},
                      Enabled,
                      Direction,
                      Action |
        Format-Table -Wrap -AutoSize | Out-String
    
    if ($firewallRules) {
        Write-Host "$firewallRules"
    } else {
        Write-Host "No active firewall rules found." -ForegroundColor Red
    }
    
    Write-Host "===========================================================\n" -ForegroundColor Cyan
    return "$firewallProfiles\n$firewallRules"
}

Function Show-CommandHistory {
    Write-Host "\n================= PowerShell and CMD History =================" -ForegroundColor Cyan
    $history = Get-History | Select-Object -ExpandProperty CommandLine | Out-String
    if ($history) {
        Write-Host "$history"
    } else {
        Write-Host "No command history found." -ForegroundColor Red
    }
    Write-Host "===========================================================\n" -ForegroundColor Cyan
    return "$history"
}
# Function to save all data to Checklist folder
Function Save-AllData {
    if (!(Test-Path $checklistPath)) {
        New-Item -ItemType Directory -Path $checklistPath -Force | Out-Null
    }
    $hostname = $env:COMPUTERNAME
    Show-SystemInfo | Out-File "$checklistPath\$(hostname)_SystemInfo.txt"
    Show-NetworkInterfaces | Out-File "$checklistPath\$(hostname)_NetworkInterfaces.txt"
    Show-OpenPorts | Out-File "$checklistPath\$(hostname)_OpenPorts.txt"
    Show-Services | Out-File "$checklistPath\$(hostname)_RunningServices.txt"
    Show-UserAccounts | Out-File "$checklistPath\$(hostname)_UserAccounts.txt"
    Show-ScheduledTasks | Out-File "$checklistPath\$(hostname)_ScheduledTasks.txt"
    Show-PSList | Out-File "$checklistPath\$(hostname)_ProcessList.txt"
    Show-PSTree | Out-File "$checklistPath\$(hostname)_ProcessTree.txt"
    Show-ExeFiles | Out-File "$checklistPath\$(hostname)_ExeFiles.txt"
    Show-CommandHistory | Out-File "$checklistPath\$(hostname)_commandhistory.txt"
    Show-SoftwareInstalled | Out-File "$checklistPath\$(hostname)_InstalledSoftware.txt"
    Get-FirewallInfo | Out-File "$checklistPath\$(hostname)_FirewallInfo.txt"
    Write-Host "All data has been saved to $checklistPath" -ForegroundColor Green
}


# Main Script Loop
Do {
    Show-Menu
    $Choice = Read-Host "Enter your choice (1-13)"
    Switch ($Choice) {
        
        "1" { Save-AllData }
	"2" { Show-SystemInfo | Write-Host }
        "3" { Show-NetworkInterfaces | Write-Host }
        "4" { Show-OpenPorts | Write-Host }
        "5" { Show-Services | Write-Host }
        "6" { Show-SoftwareInstalled | Write-Host }
        "7" { Show-UserAccounts | Write-Host }
        "8" { Show-ScheduledTasks | Write-Host }
        "9" { Show-PSList | Write-Host }
        "10" { Show-PSTree | Write-Host }
        "11" { Get-FirewallInfo | Write-Host }
	"12" { Show-CommandHistory | Write-Host }
	"13" { Show-ExeFiles | Write-Host }
        "Q" { Write-Host "\nExiting... Stay safe, Coastline Xploit Club!" -ForegroundColor Green; Exit }
        Default { Write-Host "\nInvalid option! Please choose between 1-13." -ForegroundColor Red }
    }
} While ($Choice -ne "Q")

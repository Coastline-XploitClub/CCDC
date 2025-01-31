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
    Write-Host "1. System Overview"
    Write-Host "2. Show Network Interfaces and IPs"
    Write-Host "3. Show Open Ports"
    Write-Host "4. List all running services"
    Write-Host "5. Enumerating Installed Software"
    Write-Host "6. Show User and Account Information"
    Write-Host "7. Show Scheduled Tasks"
    Write-Host "8. Show Process List"
    Write-Host "9. Show Process Tree"
    Write-Host "10. Get Firewall Information"
    Write-Host "11. Show Command-Line Arguments"
    Write-Host "12. Check .exe files running in memory"
    Write-Host "Q. Quit"
    Write-Host "================================================================================================"
}

# Function to ask user whether to print or save output
function Output-Decision {
    param (
        [string]$fileName,
        [object]$data
    )
    $choice = Read-Host "Do you want to (P)rint on console or (S)ave to file? (P/S)"
    if ($choice -match "^[Ss]$") {
        $filePath = "$checklistPath\$fileName"
        $data | Out-File -FilePath $filePath -Encoding utf8
        Write-Host "Data saved to $filePath" -ForegroundColor Green
    } else {
        $data | Out-String | Write-Host
    }
}
# Function to display open ports
function Show-OpenPorts {
    Write-Host "\n================= Open Ports =================" -ForegroundColor Cyan
    $openPorts = netstat -ano | Select-String "LISTENING"
    Output-Decision -fileName "OpenPorts.txt" -data $openPorts
    Write-Host "===========================================================\n" -ForegroundColor Cyan
}

# Function to display running services
Function Show-Services {
    Write-Host "\n================= Running Services =================" -ForegroundColor Cyan
    $services = Get-WmiObject Win32_Service | Where-Object { $_.State -eq "Running" } | Select-Object Name, DisplayName, State, StartMode, ProcessId | Format-Table -AutoSize
    Output-Decision -fileName "RunningServices.txt" -data $services
    Write-Host "===========================================================\n" -ForegroundColor Cyan
}

# Function to enumerate installed software
Function Show-SoftwareInstalled {
    Write-Host "\n================= Enumerating Installed Software =================" -ForegroundColor Cyan
    $installedSoftware = Get-WmiObject -Class Win32_Product | Select-Object Name, Version | Format-Table -AutoSize
    Output-Decision -fileName "InstalledSoftware.txt" -data $installedSoftware
    Write-Host "===========================================================\n" -ForegroundColor Cyan
}

# Function to display user and account information
function Show-UserAccounts {
    Write-Host "\n================= User and Account Information =================" -ForegroundColor Cyan
    $users = net user | Out-String
    $groups = net localgroup | Out-String
    $accounts = net accounts | Out-String
    $userData = "$users\n\n$groups\n\n$accounts"
    Output-Decision -fileName "UserAccounts.txt" -data $userData
    Write-Host "===========================================================\n" -ForegroundColor Cyan
}
# Function to display system information
function Show-SystemInfo {
    Write-Host "\n================= System Overview =================" -ForegroundColor Cyan
    $sysInfo = systeminfo | Out-String
    Output-Decision -fileName "SystemInfo.txt" -data $sysInfo
}
# Function to display network interfaces and IPs
function Show-NetworkInterfaces {
    Write-Host "\n================= Network Interfaces and IPs =================" -ForegroundColor Cyan
    $interfaces = Get-NetIPAddress | Select IpAddress, InterfaceAlias, AddressFamily | Format-Table -AutoSize
    Output-Decision -fileName "NetworkInterfaces.txt" -data $interfaces
}
# Function to display firewall information
Function Get-FirewallInfo {
    Write-Host "\n================= Firewall Information =================" -ForegroundColor Cyan
    
    Write-Host "Firewall Status:" -ForegroundColor Yellow
    $firewallProfiles = Get-NetFirewallProfile | Select-Object Name, Enabled | Format-Table -AutoSize | Out-String
    
    Write-Host "Firewall Rules and Ports:" -ForegroundColor Yellow
    $firewallRules = Get-NetFirewallRule | Where-Object { $_.Enabled -eq $true } |
        Select-Object DisplayName,
                      @{Name='Protocol';Expression={(Get-NetFirewallPortFilter -AssociatedNetFirewallRule $_).Protocol}},
                      @{Name='LocalPort';Expression={(Get-NetFirewallPortFilter -AssociatedNetFirewallRule $_).LocalPort}},
                      @{Name='RemotePort';Expression={(Get-NetFirewallPortFilter -AssociatedNetFirewallRule $_).RemotePort}},
                      Enabled,
                      Direction,
                      Action |
        Format-Table -AutoSize | Out-String
    
    $firewallData = "$firewallProfiles\n\n$firewallRules"
    
    $choice = Read-Host "Do you want to (P)rint on console or (S)ave to file? (P/S)"
    if ($choice -match "^[Ss]$") {
        $filePath = "$checklistPath\FirewallInfo.txt"
        $firewallData | Out-File -FilePath $filePath -Encoding utf8
        Write-Host "Firewall information saved to $filePath" -ForegroundColor Green
    } else {
        Write-Host "$firewallData"
    }
    Write-Host "===========================================================\n" -ForegroundColor Cyan
}


# Function to display scheduled tasks
function Show-ScheduledTasks {
    Write-Host "\n================= Scheduled Tasks =================" -ForegroundColor Cyan
    $tasks = Get-ScheduledTask | Select-Object TaskName, TaskPath, State | Format-Table -AutoSize
    Output-Decision -fileName "ScheduledTasks.txt" -data $tasks
    Write-Host "===========================================================\n" -ForegroundColor Cyan
}

# Function to display process list
Function Show-PSList {
    Write-Host "\n[+] Listing running processes..." -ForegroundColor Green
    $processes = Get-Process | Sort-Object CPU -Descending | Format-Table Id, Name, CPU, StartTime -AutoSize
    Output-Decision -fileName "ProcessList.txt" -data $processes
    Write-Host "===========================================================\n" -ForegroundColor Cyan
}

# Function to display process tree
Function Show-PSTree {
    Write-Host "\n[+] Displaying process tree..." -ForegroundColor Green
    $processTree = Get-CimInstance Win32_Process | ForEach-Object {
        $parent = Get-CimInstance Win32_Process -Filter "ProcessId = $($_.ParentProcessId)" -ErrorAction SilentlyContinue
        [PSCustomObject]@{
            ProcessId         = $_.ProcessId
            Name              = $_.Name
            ParentProcessId   = $_.ParentProcessId
            ParentProcessName = $parent.Name
        }
    } | Sort-Object ParentProcessId | Format-Table -AutoSize
    Output-Decision -fileName "ProcessTree.txt" -data $processTree
}

# Function to display .exe files running in memory
Function Show_exe_commands {
    Write-Host "\n================= .exe Files Running in Memory =================" -ForegroundColor Cyan
    $exeFiles = Get-Process | Where-Object { $_.Path -like "*.exe" } | Select-Object Name, Path, Id, CPU | Format-Table -AutoSize
    Output-Decision -fileName "ExeFiles.txt" -data $exeFiles
    Write-Host "===========================================================\n" -ForegroundColor Cyan
}

# Function to display command-line arguments for running processes
Function Show-CmdLine {
    Write-Host "\n================= Command-Line Arguments for Processes =================" -ForegroundColor Cyan
    $cmdLineArgs = Get-CimInstance Win32_Process | Select-Object ProcessId, Name, CommandLine | Format-Table -AutoSize
    Output-Decision -fileName "CmdLineArgs.txt" -data $cmdLineArgs
    Write-Host "===========================================================\n" -ForegroundColor Cyan
}

# Main Script Loop
Do {
    Show-Menu
    $Choice = Read-Host "Enter your choice (1-12)"
    Switch ($Choice) {
        "1" { Show-SystemInfo }
        "2" { Show-NetworkInterfaces }
        "3" { Show-OpenPorts }
        "4" { Show-Services }
        "5" { Show-SoftwareInstalled }
        "6" { Show-UserAccounts }
        "7" { Show-ScheduledTasks }
        "8" { Show-PSList }
        "9" { Show-PSTree }
        "10" { Get-FirewallInfo }
        "11" { Show-CmdLine }
        "12" { Show_exe_commands }
        "Q" { Write-Host "\nExiting... Stay safe, Coastline Xploit Club!" -ForegroundColor Green; Exit }
        Default { Write-Host "\nInvalid option! Please choose between 1-12." -ForegroundColor Red }
    }
} While ($Choice -ne "Q")

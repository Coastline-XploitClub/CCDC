
# Banner
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "                  Coastline Xploit Club                   " -ForegroundColor Green
Write-Host "             Advanced  PowerShell Framework     		  " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan

# Function to display the menu
function Show-Menu {
    Write-Host "===================== Windows Hardening Check Menu ====================="
    Write-Host "1. System Overview"
    Write-Host "2. Show Network Interfaces and IPs"
    Write-Host "3. Show-OpenPorts"
    Write-Host "4. List all running services"
    Write-Host "5. Show User and Account Information"
    Write-Host "6. Show Scheduled Tasks"
    Write-Host "7. Show-PSList"
    Write-Host "8. Show-PSTree"
    Write-Host "9. Get-FirewallInfo"
    Write-Host "10. Show-command-line"
    Write-Host "11. Check .exe files running in memory"
    Write-Host "Q. Quit"
    Write-Host "================================================================================================"
}

# Function to display system information
function Show-SystemInfo {
    Write-Host "\n================= System Overview =================" -ForegroundColor Cyan
    systeminfo | Out-String | Write-Host
    Write-Host "===========================================================\n" -ForegroundColor Cyan
}

# Function to display scheduled tasks
function Show-ScheduledTasks {
    Write-Host "\n================= Scheduled Tasks =================" -ForegroundColor Cyan
    Get-ScheduledTask | Select-Object TaskName, TaskPath, State | Format-Table -AutoSize
    Write-Host "===========================================================\n" -ForegroundColor Cyan
}

# Function to display network interfaces and IPs
function Show-NetworkInterfaces {
    Write-Host "\n================= Network Interfaces and IPs =================" -ForegroundColor Cyan
    $interfaces = Get-NetIPAddress | Select IpAddress, InterfaceAlias, AddressFamily
    $interfaces | Format-Table -AutoSize
    $interfaces | Export-CSV "$(hostname)_interfaces.csv" -NoTypeInformation
    Write-Host "Network interface information saved to $(hostname)_interfaces.csv"
    Write-Host "===========================================================\n" -ForegroundColor Cyan
}
# Function to display all running services
Function Show-Services {
    Write-Host "\n================= Running Services =================" -ForegroundColor Cyan
    Get-WmiObject Win32_Service | Where-Object { $_.State -eq "Running" } |
    Select-Object Name, DisplayName, State, StartMode, ProcessId |
    Format-Table -AutoSize
    Write-Host "===========================================================\n" -ForegroundColor Cyan
}
Function Show-PSList {
    Write-Host "\n[+] Listing running processes..." -ForegroundColor Green
    Get-Process | Sort-Object CPU -Descending | Format-Table Id, Name, CPU, StartTime -AutoSize
    Write-Host "===========================================================\n" -ForegroundColor Cyan
}
# Function to display process tree
Function Show-PSTree {
    Write-Host "\n[+] Displaying process tree..." -ForegroundColor Green
    Get-CimInstance Win32_Process | ForEach-Object {
        $parent = Get-CimInstance Win32_Process -Filter "ProcessId = $($_.ParentProcessId)" -ErrorAction SilentlyContinue
        [PSCustomObject]@{
            ProcessId         = $_.ProcessId
            Name              = $_.Name
            ParentProcessId   = $_.ParentProcessId
            ParentProcessName = $parent.Name
        }
    } | Sort-Object ParentProcessId | Format-Table -AutoSize
}
# Function to display user and account information
function Show-UserAccounts {
    Write-Host "\n================= User and Account Information =================" -ForegroundColor Cyan
    Write-Host "\n[+] Listing all users:" -ForegroundColor Yellow
    net user | Out-String | Write-Host
    Write-Host "\n[+] Listing all local groups:" -ForegroundColor Yellow
    net localgroup | Out-String | Write-Host
    Write-Host "\n[+] Listing account policies:" -ForegroundColor Yellow
    net accounts | Out-String | Write-Host
    Write-Host "===========================================================\n" -ForegroundColor Cyan
}

# Function to display open ports and services
function Show-OpenPorts {
    Write-Host "\n================= Open Ports and Services =================" -ForegroundColor Cyan
    $netstatOutput = netstat -ano | Select-String "LISTENING"
    $portInfoList = @()
    $netstatOutput | ForEach-Object {
        $line = $_.ToString().Trim()
        $parts = $line -split '\s+'
        if ($parts.Count -ge 5) {
            $localEndpoint = $parts[1]
            $port = ($localEndpoint -split ':')[-1]
            $processId = $parts[-1]
            $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
            $service = Get-WmiObject -Query "SELECT * FROM Win32_Service WHERE ProcessId = $processId" -ErrorAction SilentlyContinue
            $portInfoList += [PSCustomObject]@{
                "Port"      = $port
                "PID"       = $processId
                "Process"   = if ($process) { $process.ProcessName } else { "N/A" }
                "Service"   = if ($service) { $service.Name } else { "N/A" }
            }
        }
    }
    if ($portInfoList.Count -gt 0) {
        $portInfoList | Format-Table -AutoSize
    } else {
        Write-Host "No open listening ports detected." -ForegroundColor Yellow
    }
    Write-Host "===========================================================================================================================\n" -ForegroundColor Cyan
}
Function Get-FirewallInfo {
    Write-Host "Firewall Status:" -ForegroundColor Yellow
    Get-NetFirewallProfile | Select-Object Name, Enabled | Format-Table -AutoSize
    Write-Host "Firewall Rules and Ports:" -ForegroundColor Yellow
    Get-NetFirewallRule | Where-Object { $_.Enabled -eq $true } |
    Format-Table -Property DisplayName,
    @{Name='Protocol';Expression={($_ | Get-NetFirewallPortFilter).Protocol}},
    @{Name='LocalPort';Expression={($_ | Get-NetFirewallPortFilter).LocalPort}},
    @{Name='RemotePort';Expression={($_ | Get-NetFirewallPortFilter).RemotePort}},
    Enabled,
    Direction,
    Action -AutoSize
}
Function Show_exe_commands {
    Write-Host "\n[+] Displaying .exe Files Running in Memory..." -ForegroundColor Green
    Get-Process | Where-Object { $_.Path -like "*.exe" } | Select-Object Name, Path, Id, CPU
}

Function Show-CmdLine {
    Write-Host "\n[+] Displaying command-line arguments for processes..." -ForegroundColor Green
    Get-CimInstance Win32_Process | Select-Object ProcessId, Name, CommandLine | Format-Table -AutoSize
}


# Main Script Loop
Do {
    Show-Menu
    $Choice = Read-Host "Enter your choice (1-11)"
    Switch ($Choice) {
        "1" { Show-SystemInfo }
        "2" { Show-NetworkInterfaces }
        "3" { Show-OpenPorts }
        "4" { Show-Services }
        "5" { Show-UserAccounts }
        "6" { Show-ScheduledTasks }
        "7" { Show-PSList }
        "8" { Show-PSTree }
        "9" { Get-FirewallInfo }
        "10" { Show-CmdLine }
        "11" { Show_exe_commands }
        "Q" { Write-Host "\nExiting... Stay safe, Coastline Xploit Club!" -ForegroundColor Green; Exit }
        Default { Write-Host "\nInvalid option! Please choose between 1-11." -ForegroundColor Red }
    }
} While ($Choice -ne "Q")

# ===============================
# Coastline Xploit Club - Windows 7 Compatible Version
# ===============================

# Banner
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "                  Coastline Xploit Club                   " -ForegroundColor Green
Write-Host "       Windows 7 Compatible Security & Hardening Tool    " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan

# Function to display the menu
function Show-Menu {
    Write-Host "===================== Windows Hardening Check Menu ====================="
    Write-Host "1. System Overview"
    Write-Host "2. Show Network Interfaces and IPs"
    Write-Host "3. Show Open Ports"
    Write-Host "4. List all running services"
    Write-Host "5. Show User and Account Information"
    Write-Host "6. Show Scheduled Tasks"
    Write-Host "7. Show Running Processes"
    Write-Host "8. Show Firewall Rules"
    Write-Host "9. Check Running .exe Files"
    Write-Host "Q. Quit"
    Write-Host "======================================================================="
}

# Function to display system information
function Show-SystemInfo {
    Write-Host "`n================= System Overview =================" -ForegroundColor Cyan
    systeminfo | Out-String | Write-Host
    Write-Host "===========================================================`n" -ForegroundColor Cyan
}

# Function to display network interfaces and IPs (For Windows 7)
function Show-NetworkInterfaces {
    Write-Host "`n================= Network Interfaces and IPs =================" -ForegroundColor Cyan
    Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true } | 
    Select-Object Description, IPAddress, MACAddress | Format-Table -AutoSize
    Write-Host "===========================================================`n" -ForegroundColor Cyan
}

# Function to list all running services
function Show-Services {
    Write-Host "`n================= Running Services =================" -ForegroundColor Cyan
    Get-WmiObject Win32_Service | Where-Object { $_.State -eq "Running" } |
    Select-Object Name, DisplayName, StartMode, ProcessId | Format-Table -AutoSize
    Write-Host "===========================================================`n" -ForegroundColor Cyan
}

# Function to display running processes
function Show-Processes {
    Write-Host "`n================= Running Processes =================" -ForegroundColor Cyan
    Get-Process | Sort-Object CPU -Descending | Format-Table Id, Name, CPU, StartTime -AutoSize
    Write-Host "===========================================================`n" -ForegroundColor Cyan
}

# Function to display scheduled tasks (Windows 7 compatible)
function Show-ScheduledTasks {
    Write-Host "`n================= Scheduled Tasks =================" -ForegroundColor Cyan
    schtasks /query /fo LIST | Out-String | Write-Host
    Write-Host "===========================================================`n" -ForegroundColor Cyan
}

# Function to show user and account information
function Show-UserAccounts {
    Write-Host "`n================= User and Account Information =================" -ForegroundColor Cyan
    Write-Host "`n[+] Listing all users:" -ForegroundColor Yellow
    net user | Out-String | Write-Host
    Write-Host "`n[+] Listing all local groups:" -ForegroundColor Yellow
    net localgroup | Out-String | Write-Host
    Write-Host "`n[+] Listing account policies:" -ForegroundColor Yellow
    net accounts | Out-String | Write-Host
    Write-Host "===========================================================`n" -ForegroundColor Cyan
}

# Function to display open ports and associated processes (Windows 7 netstat workaround)
function Show-OpenPorts {
    Write-Host "`n================= Open Ports and Services =================" -ForegroundColor Cyan
    netstat -ano | Select-String "LISTENING" | ForEach-Object {
        $line = $_.ToString().Trim()
        $parts = $line -split '\s+'
        if ($parts.Count -ge 5) {
            $localEndpoint = $parts[1]
            $port = ($localEndpoint -split ':')[-1]
            $processId = $parts[-1]
            $process = Get-WmiObject Win32_Process -Filter "ProcessId=$processId" -ErrorAction SilentlyContinue
            Write-Host "Port: $port - PID: $processId - Process: $($process.Name)"
        }
    }
    Write-Host "===========================================================`n" -ForegroundColor Cyan
}

# Function to display Windows Firewall Rules (Windows 7 Compatible)
function Show-FirewallRules {
    Write-Host "`n================= Windows Firewall Rules =================" -ForegroundColor Cyan
    netsh advfirewall firewall show rule name=all | Out-String | Write-Host
    Write-Host "===========================================================`n" -ForegroundColor Cyan
}

# Function to check running .exe files
function Show-ExeProcesses {
    Write-Host "`n================= Running .exe Processes =================" -ForegroundColor Cyan
    Get-Process | Where-Object { $_.Path -like "*.exe" } | Select-Object Name, Path, Id, CPU | Format-Table -AutoSize
    Write-Host "===========================================================`n" -ForegroundColor Cyan
}

# Main Menu Loop
Do {
    Show-Menu
    $Choice = Read-Host "Enter your choice (1-9)"
    Switch ($Choice) {
        "1" { Show-SystemInfo }
        "2" { Show-NetworkInterfaces }
        "3" { Show-OpenPorts }
        "4" { Show-Services }
        "5" { Show-UserAccounts }
        "6" { Show-ScheduledTasks }
        "7" { Show-Processes }
        "8" { Show-FirewallRules }
        "9" { Show-ExeProcesses }
        "Q" { Write-Host "`nExiting... Stay safe, Coastline Xploit Club!" -ForegroundColor Green; Exit }
        Default { Write-Host "`nInvalid option! Please choose between 1-9." -ForegroundColor Red }
    }
} While ($Choice -ne "Q")

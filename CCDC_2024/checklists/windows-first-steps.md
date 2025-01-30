# CCDC Checklist Windows Version

## Machine info

- [] Document both internal and external IPs. (Windows: `ipconfig /all`, Linux: `ifconfig` OR `ip a`)
### Powershell 3 and up
```powershell
$interfaces =Get-NetIPAddress | Select IpAddress,InterfaceAlias,AddressFamily
$interfaces | Export-CSV "$(hostname)_interfaces.csv"
```
### non powershell
```cmd
ipconfig /all > "$(hostname)_ipconfig.txt"
```
- [] Record the name of each machine. (Windows: `hostname`, Linux: `hostname`)
- [] Document the operating system. (Windows: `systeminfo`, Linux `cat /etc/os-release` OR `lsb_release -a`)
## system info local and remote
```cmd
#local
systeminfo > "$(hostname)_systeminfo.txt"
#remote
systeminfo /S <computer name or ip> >> <computername>_systeminfo.txt
```
## powershell with AD module (Install-Module Active Directory)
```powershell
$computers = Get-ADComputer -Filter * | select name
foreach($computer in $computers){systeminfo /S $computer.Name >> domain_computers_systeminfo.txt}
```
---

## Users
- [] Save a list of all user accounts, including service accounts. (Windows: `net users`, Linux: `cat /etc/passwd`)
### Powershell AD Domain Users
```powershell
Get-ADUser -Filter * | select SamAccountName,SID,Enabled,PasswordNotRequired,DoesNotRequirePreAuth,AllowReversiblePasswordEncryption | Export-CSV "$(hostname)_domain_users.csv"
```
### no AD module Domain Users
```cmd
net user /domain
```
### powershell 3+ local users
```powershell
Get-LocalUser | select Name,Description,LastLogon,PasswordRequired,Enabled | Export-Csv "$(hostname)_localusers.csv"
```
### no powershell
```cmd
net user
```


- [] Identify accounts with elevated privileges. (Windows: `net localgroup administrators`, Linux: `grep '^sudo:' /etc/group`)
### Powershell AD
```powershell
Get-ADGroup -Filter * | select Name, @{name="members";expression={(Get-ADGroupMember -Identity $_.Name).Name}} | Export-CSV domain_groups.csv
```
- get local groups and members
```powershell
Get-LocalGroup | select Name,@{name="GroupMembers";expression={Get-LocalGroupMember -Name $_.Name}} | Export-CSV "$(hostname)_groups_and_members.csv"
```
- [] Change passwords for adminsitrative users. (Windows: `#TODO`, Linux: `sudo passwd`)
- Use pasword script for AD Domain Users
```powershell
# plain text
$pw = ConvertTo-SecureString -AsPlainText -Force 'password'
New-ADUser -Name bob -Enabled $true -AccountPassword $pw -ChangePasswordAtLogon $false
Clear-history
# secure string
$pw = Read-Host -AsSecureString
New-ADUser -Name bob -Enabled $true -AccountPassword $pw -ChangePasswordAtLogon $false
```
- Use New-LocalUser with same structure
### net user
```cmd
# hide password
net user /add bob * /domain
net user /add bob *
```
---

## Open Ports/Services

- [] Note all open TCP and UDP ports. (Windows: `netstat -an`, Linux: `netstat -tuln`)
### powershell 5+
```powershell
Get-NetTcpConnection | ? {$_.State -eq "Listen"} | Select LocalAddress,LocalPort,@{name="processname";expression={(Get-Process -Id $_.OwningProcess).ProcessName}} | Sort-Object LocalPort | Export-CSV "$(hostname)_openports.csv"
```
- [] Document services running on each port. (Windows: `netstat -anob`, Linux: `netstat -tulpn` OR `ps -ef`)

---

## Backup Status

- [] Check if backups exist and their last update. Create backups of important files, logs, etc. (Windows: `Compress-Archive -Path "C:\path\to\directory" -DestinationPath "C:\path\to\backup.zip"`, Linux `tar -czvf backup.tar.gz /path/to/directory`)

---

## Installed Software

List all software, including versions. (Windows: `wmic product get name,version`, Linux: `dpkg -l`)

---
## Running Services
```powershell
Get-Service | ? {$_.Status -eq "Running"} | Export-Csv "$(hostname)_running_services.csv"
```
- cmd services started
```cmd
net start > "$(hostname)_running_services.txt"
```
---

## Critical Data Locations

Identify where sensitive data is stored.

---

## Scheduled Tasks/Cron Jobs

Review for any unusual or unauthorized tasks. (Windows: `schtasks`, Linux: `crontab -l`)
```cmd
schtasks /query /fo CSV > "$(hostname)_schtasks.csv"
```
---

## Firewall Rules

Document current rules and settings. (Varies by firewall software)
### powershell 5+
```powershell
Get-NetFirewallRule -Enabled True -Action Allow -Direction Inbound | select DisplayName,Direction,@{name="local port"; expression={($_ | Get-NetFirewallPortfilter).LocalPort}}  | Sort-Object "local port" | Export-CSV "$(hostname)_firewallrules_inbound_enabled.csv"
```
### netsh
```cmd
netsh advfirewall firewall show rule name=all
```
---

## Patch Management

Record recent patches and pending updates. (Windows: `wmic qfe list`, Linux: `apt list --upgradable`)
TODO: add instructions on wusa.exe commands to update from downloaded patch files

---

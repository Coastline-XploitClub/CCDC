## disable SMBv1 "Eternal Blue"
### check
```powershell
Get-SmbServerConfiguration | Select EnableSMB1Protocol
```
### disable
```powershell
Set-SmbServerConfiguration -EnableSMB1Protocol $false
```
### check for service principal names
```powershell
setspn -L <hostname>
```
### Deregister spn
```powershell
setspn -d <serviceClass/Host:Port> <AccountName>
```
### Backup DNS

```powershell
Export-DnsServerZone -Name <zonename> -filename <zonename.dns.bak>
```
- will be stored in C:\Windows\System32\dns

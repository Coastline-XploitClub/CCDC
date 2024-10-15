# csvde 
- way to interact with AD as CSV files
- [https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/cc732101(v=ws.11)](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/cc732101(v=ws.11))
## install rsat ad tools
```powershell
Get-WindowsFeature RSAT-AD-Tools
Install-WindowsFeature RSAT-AD-Tools
csvde -f exportUsers.csv -r "(objectClass=user)"
csvde -f exportGroups.csv -r "(objectClass=group)"
```
# back up dns
```cmd
dnscmd DC1 /zoneexport Zone1.com backup\zone1.com.dns.bak
```
# ad explorer
- sysinternals tool to make a snapshot of a domain for later comparison
[https://learn.microsoft.com/en-us/sysinternals/downloads/adexplorer](https://learn.microsoft.com/en-us/sysinternals/downloads/adexplorer)
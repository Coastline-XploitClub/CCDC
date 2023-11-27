## disable SMBv1 "Eternal Blue"
### check
```powershell
Get-SmbServerConfiguration | Select EnableSMB1Protocol
```
### disable
```powershell
Set-SmbServerConfiguration -EnableSMB1Protocol $false
```

# disable smbv1 on all domain computers (by name, from domain controller as da)
```powershell
invoke-command -ComputerName cpu1,cpu2,etc -ScriptBlock {Set-SMBServerConfiguration -EnableSMB1Protocol $false}
```

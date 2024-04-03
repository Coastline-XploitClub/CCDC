### Convert string from Base64
```powershell
[Text.Encoding]::Utf8.GetString([Convert]::FromBase64String('<base64 encoded string here>'))
```
### Get Events that match an Event ID 
```powershell
Get-WinEvent -FilterHashTable @{LogName='System'; ID='7045'} | fl
```
### Create file hash
```powershell
Get-Filehash -Algorithm MD5 <file>
```
### check scheduled tasks that are not disabled
```powershell
Get-ScheduledTask | ? {$_.Date -ne $null -and $_.State -ne "Disabled"} | sort-object Date | select Date,TaskName,Author,State,TaskPath | ft
```
```cmd
schtasks.exe /query /fo CSV | findstr /V Disabled
```

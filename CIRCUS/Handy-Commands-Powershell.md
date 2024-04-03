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

### Convert string from Base64
```powershell
[Text.Encoding]::Utf8.GetString([Convert]::FromBase64String('<base64 encoded string here>'))
```

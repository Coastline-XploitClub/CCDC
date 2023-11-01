# install windows terminal
- ```
  Invoke-WebRequest -uri https://github.com/microsoft/terminal/releases/download/v1.18.2822.0/Microsoft.WindowsTerminal_1.18.2822.0_8wekyb3d8bbwe.msixbundle -Outfile 'C:\Program Files'
  ```


## DNS hosts file
```Get-Content $env:windir\system32\drivers\etc\hosts```
## Services
- services.msc
- Get-Service
## Winevent viewer
''' Get-EventLog -LogName Security -InstanceID 4765 -EntryType FailureAudit '''
## View Listening Ports
``` Get-NetTCPConnection | select LocalPort, State | Where-Object -Property -eq 'Listening' ```

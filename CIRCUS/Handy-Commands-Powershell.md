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
### script to enumerate all scheduled tasks
```powershell
           
# List all enabled scheduled tasks with creation date and command to be executed, sorted by date and printing all additional information
$tasks = Get-ScheduledTask | Where-Object {$_.Date —ne $null —and $_.State —ne "Disabled" —and $_.Actions.Execute —ne $null} | Sort-Object Date

foreach ($task in $tasks) {
    $taskName = $task.TaskName
    $taskDate = $task.Date
    $taskPath = $task.TaskPath
    $taskAuthor = $task.Author
    $taskCommand = $task.Actions.Execute
    $taskArgs = $task.Actions.Arguments
    $taskRunAs = $task.Principal.UserId

    # Output service information
    Write-Host "Task Name: $taskName"
    Write-Host "Task Author: $taskAuthor"
    Write-Host "Creation Date: $taskDate"
    Write-Host "Task Path: $taskPath"
    Write-Host "Command: $taskCommand $taskArgs"
    Write-Host "Run As: $taskRunAs"
    Write-Host ""
}
```
### enumerate running services with automatic startup
```powershell
Get-Service | Where-Object {$_.Status -eq "Running" -and $_.StartType -eq "Automatic"}
```
### script to get Service information
```powershell
foreach ($service in $services) {
    $serviceName = $service.Name
    $serviceDisplayName = $service.DisplayName
    $serviceStatus = $service.Status
    $serviceWMI = (Get-WmiObject Win32_Service | Where-Object { $_.Name -eq $serviceName })
    $servicePath = $serviceWMI.PathName
    $serviceUser = $serviceWMI.StartName

    Write-Host "Service Name: $serviceName"
    Write-Host "Display Name: $serviceDisplayName"
    Write-Host "Service Status: $serviceStatus"
    Write-Host "Executable Path: $servicePath"
    Write-Host "User Context: $serviceUser"
    Write-Host ""
}
```



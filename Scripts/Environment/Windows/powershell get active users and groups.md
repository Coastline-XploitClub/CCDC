# Powershell Commands

```powershell
Get-LocalUser | Where-object -Property Enabled -eq $True
PS C:\Users\cisne> foreach ($user in $localUsers) {
    Write-Host "User: $($user.Name)"
    Write-Host "Groups:"
    $userGroups = [System.Security.Principal.WindowsIdentity]::GetCurrent().Groups
    foreach ($group in $userGroups) {
        Write-Host "  $($group.Translate([System.Security.Principal.NTAccount]))"
    }
    Write-Host ""
}
```

## cred man
```cmd
rundll32.exe keymgr.dll, KRShowKeyMgr
vaultcmd /list
VaultCmd /listproperties:"VaultName"
VaultCmd /listcreds:"VaultName"
```


## Kerberos
# Kerberos Auditing Group Policy
GPMC / Computer Configuration / Policies / Windows Settings / Advanced Audit Policy Configuration / Audit Policies / Account Logon

# Event ID 4768 
Keyword Audit Success : TGT succesfully requested

# checking for users with preauth disabled
```$nopre=Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true} -Properties DoesNotRequirePreAuth | select SamAccountName, DoesNotRequirePreAuth```

Loop through and change to false

```foreach ($pre in $nopre) { Set-ADAccountControl -Id $pre.SamAccountName -DoesNotRequirePreAuth:$false}```

# check for users with Service Pricipal Names associated

```Get-ADUser -Filter "servicePrincipalName -like '*'" -Properties servicePrincipalname```
## Windows Firewall
# check profile status
- local computer\
  ```Get-NetFirewallProfile | select Name,Enabled```
- remote computer (domain joined, remoting enabled)\
  ```Invoke-Command -ComputerName wkst01 -ScriptBlock { Get-NetFirewallProfile | select Name, Enabled }```
- all ad computers (as Domain admin)\
  ```$adcomps=Get-ADComputer -Filter * | select Name```\
  ```foreach ($name in $adcomps) { Invoke-Command -ComputerName $name.name -ScriptBlock {Get-NetFirewallProfile |select Name, Enabled} }```
# Check profile rules 
- local computer \
``` Get-NetFirewallProfile -Name Private | Get-NetFirewallRule | Where-Object {($_.Enabled -eq 'True') -and ($_.Direction -eq 'Inbound')} | select DisplayName```

- remote computer (domain joined, remoting enabled) \
```Invoke-Command -ComputerName wkst01 -ScriptBlock {Get-NetFirewallProfile -Name Private | Get-NetFirewallRule | Where-Object {($_.Enabled -eq 'True') -and ($_.Direction -eq 'Inbound')} | select DisplayName }```

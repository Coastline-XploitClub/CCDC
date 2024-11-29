# Directory Replication
## find inbound replication partners (other domain controllers or member servers with FSMO roles)
```powershell
Get-ADReplicationPartnersMetadata -Target hostname.domain.name
```
## Check for replication failures
```powershell
Get-ADReplicationFailure -Target hostname.domain.name
```

## test if domain controller is advertising sysvol (for group policy replication)
```powershell
dcdiag /test:sysvolcheck /test:advertising
```
## test replication 
```powershell
repadmin /showrepl
repadmin /replsummary
# manually replicate
repadmin /syncall /APed
```
- remember directory replication is based on DFS so ensure "DFS NamespaceClient" or "DFS Replication" services are running and set to "Automatic"

## restart domain controller services
```powershell
net stop netlogon
net start netlogon
```
## Replication Health script from [Mastering Active Directory](https://github.com/PacktPublishing/Mastering-Active-Directory-Third-Edition/blob/main/Chapter17.ps1)
```powershell
## Active Directory Domain Controller Replication Status##

 $domaincontroller = Read-Host 'What is your Domain Controller?'
 ## Define Objects ##
 $report = New-Object PSObject -Property @{
 ReplicationPartners = $null
 LastReplication = $null
 FailureCount = $null
 FailureType = $null
 FirstFailure = $null
 }

## Replication Partners  Report ##

 $report.ReplicationPartners = (Get-ADReplicationPartnerMetadata -Target $domaincontroller).Partner
 $report.LastReplication = (Get-ADReplicationPartnerMetadata -Target $domaincontroller).LastReplicationSuccess

## Replication Faliures ##

 $report.FailureCount = (Get-ADReplicationFailure -Target $domaincontroller).FailureCount
 $report.FailureType = (Get-ADReplicationFailure -Target $domaincontroller).FailureType
 $report.FirstFailure = (Get-ADReplicationFailure -Target $domaincontroller).FirstFailureTime

## Format Output ##

 $report | select ReplicationPartners,LastReplication,FirstFailure,FailureCount,FailureType | Out-GridView
```
# Group Policy Replication
- ensure that the path \\DomainControllername.domain.name\SYSVOL\Policies is reachable GUIDS for all Group Policies are found there
- if there is a problem with gpupdate /force check and see if GUID for GroupPolicy that is in SYSVOL
## Backup and Restore Group Policy Orphan
### Check existing GUIDS
```powershell
Get-GPO -All | Select-Object DisplayName, Id
```
### Copy the policy
```powershell
Backup-GPO -Guid DCF94B4C-B004-47DD-88AD-3386F4F71875 -Path "C:\GPOBackup"
```
### Remove the offender
```powershell
Remove-GPO -Guid DCF94B4C-B004-47DD-88AD-3386F4F71875
```
### create a new policy
```powershell
New-GPO -Name "Recreated GPO"
# Import the backup to the new policy...The <backup id> is the GUID created when we did hte backup the <target GUID> is the GUID that was giving us problems
Import-GPO -BackupID <backup id> -Path C:\GPOBackup -TargetGUID <target GUID>
```

## stuck? recreate corrupted Default Domain Policy and Default Domain Controllers Policy (will not affect custom Group Policy Objects)
```powershell
dcgpofix /target:both
```


# Practical Windows Security Notes -TCM Security Lab

[ Blue Cape Security Forensic Workstation Setup ](https://bluecapesecurity.com/build-your-forensic-workstation/)

## Windows Server 2019 Installation
1. 100 GB storage
2. 4 GB RAM
3. 4 CPUs

### Install Windows Subsystem for Linux

- on newer servers you may be able to run, will install ubuntu default
```powershell
wsl --install
```
- on server 2019 run 

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
```
download distribution from [ manual distro download microsoft ](https://docs.microsoft.com/en-us/windows/wsl/install-manual#downloading-distributions)

```powershell
Add-AppxPackage <distro file>
```
### other settings
- Set timezone to UTC 
```powershell
Set-Timezone -Id "UTC"
```
- file explorer check "hidden items" and "file extensions"
- disable Microsoft Defender (via Server Manager or GPO)
- Set antivirus exclusion folders
```powershell
Add-MpPreference -ExclusionPath "C:\Windows\Tools"
Add-MpPreference -ExclusionPath "C:\Windows\Cases"
```
## install all tools from blue cape security
- create snapshot
- create target windows VM I chose Windows 10 Enterprise
- optionally create target windows Domain Controller to manage target Group Policy, set hostname, set static IP address then...
  you can find your forest and domain functional levels at [ Install-ADDSForest ](https://learn.microsoft.com/en-us/powershell/module/addsdeployment/install-addsforest?view=windowsserver2022-ps)
```powershell
Install-WindowsFeature AD-Domain-Services
Import-Module ADDSDeployment
Install-ADDSForest `
 -CreateDnsDelegation:$false `
-DatabasePath "C:\Windows\NTDS" `
SysvolPath "C:\Windows\SYSVOL" `
-LogPath "C:\Windows\NTDS" `
 -ForestMode 7 `
-DomainMode 7 `
 -DomainNetbiosName "Target" `
 -DomainName "Target.local" `
-InstallDns:$true `
-NoRebootOnCompletion:$false `
 -Force:$true
```
- Set DSRM password
- Disable Windows Defender using gpedit and pushing local computer policy to domain...disable Windows Defender Antivirus

### Attack Script
- Install Swift on Security Sysmon configuration via the included script
[ pwf ](https://github.com/bluecapesecurity/PWF)
``` powershell
Set-ExecutionPolicy -ExecutitonPolicy Bypass
./InstallSysmon.ps1
.\ART-attack.ps1

```
## Forensic Process
- Collection Examination Analysis Reporting
  
Collection focusing on Memory and Disc, more complex setups may include logs and network traffic.  Never shut down right away, think of isolating the system turn off NetWork Adapters or pause a Virtual Machine
We need to acquire the Memory and create a disc image. Consider order of volatitly. Create a hash to verify data integrity.  
Preserve via snapshot 
- Memory Acquisition
  For virtualbox this can be done with vboxmanage debugvm command.  For Vmware workstation I will be referencing [ https://forum.kaspersky.com/topic/how-to-get-a-memory-dump-of-a-virtual-machine-from-its-hypervisor-36407/ ](https://forum.kaspersky.com/topic/how-to-get-a-memory-dump-of-a-virtual-machine-from-its-hypervisor-36407/)
```powershell
 vmss2core -W8 '.\Clone of Windows 10-netw255-Snapshot2.vmsn' '.\Clone of Windows 10-netw255-Snapshot2.vmem'
# creates memory.dmp file in current directory 
```
- alternative is to capture ram on the live system using a tool like [ Belkasoft RAM Capturer ](https://belkasoft.com/ram-capturer) saves as a mem file
- 
### Disc Acquisition



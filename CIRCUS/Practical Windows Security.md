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
- Set timezone to UTC, all registry entries are in UTC since WINDOWS XP
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
```powershell
# create sha1 hash of memory
certutil -hashfile memory.dump > memory-hash.txt
```
### Disc Acquisition
- if vmdk is split into multiple files can use 
```powershell
vmware-vdiskmanager.exe -r <main_vmdk.vmdk> -t 0 single-vmdk.vmdk
```
- virtualbox can clone medium with vboxmanage clonemedium disk command.  I didn not use virtualbox so I created the disc image directly from vmdk to Encase format using FTK imager
- FTK can also create disk image in dd format, this may come in handy.
### Mount the disk drive
- Mount drive using Arsenal as "write temporary" this allows changes to either be saved to "differencing" file or only exist in RAM.  Does not make permanent changes to the disk.  
### Windows File Artifacts
- look for file artifacts to use for triage (selecting portions of the disc for examination).
```cmd
dir /a
```
more artifacts relating to the NTFS filesystem can be viewed via FTK imager.  To create a triage collection of commonly used items we will use Kape, and the kape triage collection

### exploring the registry
registry keeps track of history of file explorer etc.  Used to make the user experience better.  We can use this to analyze 
- HKEY USERS - user information, symlinked in HKEY CURRENT USER in the live system
- HKEY LOCAL MACHINE, Windows information.  Current Control set is the configuration for windows, of which there may be more than one. To find which one is being used go to HKEY_LOCAL_MACHINE/SYSTEM/SELECT/LASTKNOWNGOOD
- Kape consolidated many of the registry keys in Windows/System32/config for the system hives such as SAM, Security, Software and system
- NTUSER.DAT is linked to HKEY_USERS, HKEY_CURRENT_USER
- usrclass.dat user behavior found in AppData Local MicroSoft Windows
- F:\Windows\System32\config is the location of the registry hive files if we navigate with cmd and do a dir /a we can see the transaction logs
- dirty registry hives have not been written to with the latest changes, so we would need to merge them.
#### RegRipper and Registry Explorer
- Registry Explorer uses predefined bookmarks to give us a better view of the hives
- RegRipper command line tool can specify a plugin to give us succint information based on what we are looking for.
```powershell
rip.exe -l | findstr "plugin"
# search for a plugin by keyword
rip.exe -l -c > file.csv
# export all plugins to a csv file for easy search
```
```powershell
# look for ip address, dns etc
rip -r SYSTEM -p nic2
# what networks was the machine connected to?
rip -r SYSTEM -p networklist
# shutdown time
rip -r SYSTEM -p shutdown
# windows defender
rip -r SOFTWARE -p defender
```
- parse the entire hives
```powershell
# remove the hidden attributes of NTUSER.DAT files
# see attributes
attrib
#remove hidden
attrib -h <FILENAME>
#for loop through directory with rip -a
foreach ($i in gci){rip -a -r $i > $i.txt}
```

### user assist
- applications last opened (in NTUSER.DAT)
```powershell
rip -r .\NTUSER.DAT -p userassist
```
NTUSER\Software\Microsoft\CurrentVersion\Explorer\UserAssist
### recent Docs

- folders last used (NTUSER.DAT)
  ```powershell
   rip -r .\NTUSER.DAT -p recentdocs
```
Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs

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
```powershell
Install-WindowsFeature AD-Domain-Services
Import-Module ADDSDeployment

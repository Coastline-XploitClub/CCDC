Many windows artifacts are due to capabilities that make the Windows User Experience better
- Include desktop layout, browser bookmarks, non default applications
### Registry Hives
1. HKEY_CURRENT_USER
2. HKEY_USERS
3. HKEY_LOCAL_MACHINE
4. HKEY_CLASSES_ROOT
5. HKEY_CURRENT_CONFIG
- HKCU configuration information of currently logged on user.  Control settings, screen colors etc
- HKEY_USERS same but for all users
- HKEY_LOCAL_MACHINE configuration for computer for any user
- HKEY_CLASSES_ROOT sub key of HKEY_LOCAL_MACHINE\Software makes sure programs open correctly from Windows Explorer.
  HKEY_LOCAL_MACHINE\SOFTWARE\CLASSES default settings for local computer
  HKEY_CURRENT_USER\SOFTWARE\CLASSESS defaults for interactive user
- HKEY_CURRENT_CONFIG hardware profile used at startup
### location of Registry on Disk Image
- C:\Windows\System32\Config
1. DEFAULT
2. SAM
3. SECURITY
4. SOFTWARE
5. SYSTEM
- in each user directory there are two more hives NTUSER.DAT and USERCLASS.DAT both hidden files -- use attrib command in cmd... [ attrib docs ]( https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/attrib )
1. NTUSER.DAT C:\Users\User
2. USRCLASS.DAT C:\Users\User\AppData\Local\Microsoft\Windows
3. AMCACHE.HVE C:\Windows\AppCompat\Programs\Amcahce.hve Information on programs recently run, including hashes
![image](https://github.com/Coastline-XploitClub/CCDC/assets/85032657/7aa35000-29f6-4936-8ea0-35417606f982)
![image](https://github.com/Coastline-XploitClub/CCDC/assets/85032657/3ca9d040-6b6e-4b31-940b-a81a6cc360a4)
### Transaction Logs and Backups
- Transaction logs for each hive hold the latest changes to the registry that have not been synced.  The state of the registry with pending transactions is said to be "dirty"
- located in C:\Windows\System32\Config
#### Backups
- Backups are made every ten days and stored in C:\Windows\System32\Config\RegBack good place to look for changes
## Disk Acquisition Tools
- Kape
- Autopsy
- FTK Imager
## Registry viewing tools
- Registry Explorer (Zimmermans tools)
  Takes into consideration transaction logs and can use Bookmarks to condense output
- Registry Viewer (Extero)
- Regripper [ reg ripper github ](https://github.com/keydet89/RegRipper3.0)
  Regripper does not take transaction history into account would have to merge transaction logs if hive was "dirty"

### basic enumeration
- OS details
```powershell
# SOFTWARE hive
SOFTWARE\MICROSOFT\WINDOWS NT\CURRENTVERSION
```
- Control set (startup configuration)
- to find the current control set we look for the control set witht he value "last known good" HKLM\SELECT\LASTKNOWNGOOD here it referred to by number 
- In SYSTEM hive
- CURRENT CONTROL SET is a volatile hive representing the current configuration.  

- Computer Name
```powershell
SYSTEM\CurrentControlSet\Control\ComputerName\Computername
```
- Timezone
```powershell
SYSTEM\CurrentContolSet\Control\TimeZoneInformation
```
- Network Interfaces and past Networks
```powershell
SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces
# each interface is represented by a GUID.
# Past networks are found at
SOFTWARE\Microsoft\Windows NT\Current Version\NetworkList\Signatures\Unmanaged
SOFTWARE\Microsoft\Windows NT\Current Version\NetworkList\Signatures\Managed
```
- Autoruns
```powershell
NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Run

NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\RunOnce

SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce

SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer\Run

SOFTWARE\Microsoft\Windows\CurrentVersion\Run
```
Services found at 
```powershell
SYSTEM\CurrentControlSet\Services
# if service has start key of value 0x02 it will start at boot
```
- User information
```powershell
SAM\DOMAINS\Account\Users
```
### Recent Files
```powershell
NTUSER.DAT\Software\Microsoft\CurrentVersion\Explorer\RecentDocs
```
- sorted by time and file type in Registry Explorer
- Microsoft office files found in NTUSER.DAT\Software\Microsoft\Office\<version>

### ShellBags
changes in layout of windows can store information about last used folders/files
```powershell
NT.Userclass.DAT\Local Settings\Software\Microsoft\Windows\Shell\Bags
USRCLASS.DAT\Local Settings\Software\Microsoft\Windows\Shell\BagMRU

NTUSER.DAT\Software\Microsoft\Windows\Shell\BagMRU

NTUSER.DAT\Software\Microsoft\Windows\Shell\Bags
```
Registry explorer doesn't show much about shellbags but Eric Zimmermans ShellBags explorer does
- Last visited MRUS
  can derive files last used by what the open as or save to dialogs present.
```powershell
NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePIDlMRU

NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRU
```
- Paths typed into Window Explorer address bars
```powershell
NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths

NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\WordWheelQuery
```
### Evidence of Execution
- UserAssist registry keys
- Does not show evidence of command line commands
```powershell
NTUSER.DAT\Software\Microsoft\Windows\Currentversion\Explorer\UserAssist\{GUID}\Count
```
- ShimCache tracks compatibility with applications and OS, therefore keeps a record of applications run
```
SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache\
```
Registry Explorer does work with the ShimCache well, so we can use the AppCompatCacheParser from Eric Zimmerman's Tools
takes input from the SYSTEM hive
```powershell
AppCompatCacheParser.exe --csv <path to save output> -f <path to SYSTEM hive for data parsing> --c <control set to parse>
```
- Try Using EZ view with the csvs that this tool generates (also in Eric Zimmermans tools)
- AmCache is related to ShimCache it hold execution time, path and a SHA1 hash
```powershell
C:\Windows\appcompat\Programs\Amcache.hve

# Information about the last executed programs can be found at the following location in the hive:

Amcache.hve\Root\File\{Volume GUID}\
```
- BAM and DAM (Background Activity Monitor, Desktop Activity Monitor)
- BAM keeps track of backgroud processes
- DAM keeps track of desktop utilization
- ```powershell
  SYSTEM\CurrentControlSet\Services\bam\UserSettings\{SID}

  SYSTEM\CurrentControlSet\Services\dam\UserSettings\{SID}
  ```
  ### External Devices/ USB forensics
  ```powershell
  SYSTEM\CurrentControlSet\Enum\USBSTOR

  SYSTEM\CurrentControlSet\Enum\USB
  # First and last time connected
  SYSTEM\CurrentControlSet\Enum\USBSTOR\Ven_Prod_Version\USBSerial#\Properties\{83da6326-97a6-4088-9453-a19231573b29}\####
  # Usb device volume name
  SOFTWARE\Microsoft\Window Portable Devices\Devices
  ```
  | Value | Information |
  | ----- | ----------- |
  |   0064	| First Connection time |
  |  0066 |	Last Connection time |
  |0067 	| Last removal time |    
  
  

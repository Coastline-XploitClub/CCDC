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

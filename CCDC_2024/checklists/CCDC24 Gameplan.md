# Pre-competition preparation
Ensure the following is configured on your personal computer:
- [ ] Global Protect VPN is working
- [ ] CCDC SSH key is downloaded and copied to the `.ssh` directory (distributed before competition)
    - [ ] Windows: Copy `ccdc_ssh_key` and `ccdc_ssh_key.pub` to `C:\Users\your user/.ssh`
    - [ ] Linux: Copy `ccdc_ssh_key` and `ccdc_ssh_key.pub` to `/home/your user/.ssh`
    - [ ] MacOS: Copy `ccdc_ssh_key` and `ccdc_ssh_key.pub` to `/Users/your user/.ssh`
- [ ] CCDC SSH key is protected
    - [ ] Windows: Right click `ccdc_ssh_key` > Properties > Security > "Advanced" tab > Change the owner to you, disable inheritance and delete all permissions. Then grant yourself "Full control"
    - [ ] Linux/macOS: `chmod 600 /home/your user/.ssh/ccdc_ssh_key`
> ⚠️ **DO NOT** share the `ccdc_ssh_key` to anyone!

> ⚠️ **DO NOT** copy `ccdc_ssh_key` to any other machine! It stays on your personal computer!

Ensure that you know the following:
- [ ] IP address range for the competition environment
- [ ] The designated admin username we will use (`ccdcadmin`)


# Competition start
This is a **rough guide**. If there is anything that you should take the time to do, it's enumeration. Know what services are running on your box and how they work.

## Linux team
1. Wait for the Ansible script to run (a designated team member will be in charge of this)
2. Log into your designated Linux box(es)
3. Perform [enumeration](https://github.com/Coastline-XploitClub/CCDC/blob/main/CCDC_2024/checklists/first-steps.md). **Take notes as you go of important information. Share this info with teammates.**
- Listening ports: `netstat -tulpn`
- Running processes: `ps ef`, can also grep for a PID
- Users with elevated permissions: `/etc/sudoers` and `/etc/sudoers.d`
- Users in sudoers or privileged groups: `/etc/groups`
- Crontabs (under `/etc/` and `/var/spool/cron/crontabs`)
- PAM configurations: `/usr/share/pam/configs`
- SUID/SGID checks: `sudo find / -perm -4000 -type f 2>/dev/null` (SUID), `sudo find / -perm -2000 -type f 2>/dev/null` (SGID)
> ℹ This list only scratches the surface. Investigate running webservers, figure out how hosted services work, what they do, if they are a scored service, etc. **Google and online documentation are key.**
4. Run the [password change script](https://github.com/Coastline-XploitClub/CCDC/blob/main/CCDC_2024/linux/chpass.sh)
5. Move the password .csv file to your personal computer, then remove it from the system or lock down its privileges
6. Create initial [backups](https://github.com/Coastline-XploitClub/CCDC/blob/main/CCDC_2024/checklists/basic-linux-hardening.md#make-compressed-archives-on-local-machine-for-important-filesfolders) if you know what configs are important

## Windows team
1. Identify if your computer is a domain controller.
- If it is, run the [AD password change script](https://github.com/Coastline-XploitClub/CCDC/blob/main/CCDC_2024/windows/Change-ADPasswordsCSV.ps1)
2. **Create OU for Windows Servers we will be managing with Group Policy**
3. Create domain admin accounts for each Windows team member. [script](CCDC_2024/windows/Add-DomainAdmins.ps1)
> ⚠️ REMEMBER TO DELETE THE SCRIPT WHEN DONE

> ⚠️ LOGON AND CHANGE PASSWORD TO SOMETHING YOU WILL REMEMBER
4. Create local administrator accounts for each team member on each domain computer.   [script](CCDC_2024/windows/Add-LocalAdmin.ps1) Script uses ./Add-LocalAdmin.ps1 'OU' with the OU as the one created for domain computers
> ⚠️ REMEMBER TO DELETE THE SCRIPT WHEN DONE

> ⚠️ LOGON AND CHANGE PASSWORD TO SOMETHING YOU WILL REMEMBER, even better if local admin passwords are different for each account on each box
5. Enable Powershell, Logon and Remote Desktop logging via separate group policies for Domain Controller and Domain Computers
- LOGONS: Computer Configuration/Policies/Windows Settings/Security Settings/Advanced Audit/Audit Other Logon/Logoff Events **logging for success is in Security and Terminal Services Operational**
- POWERSHELL Computer Configuration/Policies/Windows Components/ Windows Powershell 
6. Restrict remote desktop/local login for Domain Administrators on **Domain Computers** via Group Policy 
  - Create GP object in Computer Configuration/Policies/Windows Settings/Security Settings/Local Policies/User Rights Assignment/Deny Log on through Remote desktop services and Deny log on locally --> pick Domain Admins group )
7. If not scored, use firewalls to only allow RDP and WinRM only from our IPs (it is in SCOPE)...preferably set group policy
8. Install Sysmon on each machine [link](https://download.sysinternals.com/files/Sysmon.zip) with SWIFT ON SECURITY config [link](https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/refs/heads/master/sysmonconfig-export.xml)
   ```powershell
   ./sysmon.exe -i sysmonconfig-export.xml -accepteula
   ```
9. Run ping castle if possible (needs .NET 4 so we'll see) [link](•	https://github.com/netwrix/pingcastle/releases/download/3.3.0.1/PingCastle_3.3.0.1.zip)
10. Perform enumeration
- [Resource 1](https://github.com/Coastline-XploitClub/CCDC/blob/main/CCDC_2024/roles.md)
- [Resource 2](https://github.com/Coastline-XploitClub/CCDC/blob/main/CCDC_2024/checklists/first-steps.md)
> ℹ️ These lists only scratch the surface. Investigate running webservers, figure out how hosted services work, what they do, if they are a scored service, etc. **Google and online documentation are key.**
11. Create initial [backups](https://github.com/Coastline-XploitClub/CCDC/blob/main/CCDC_2024/windows/active-directory-backups.md), along with important configurations

# Throughout the day
- Continue to make backups as necessary
- Note important changes/progress on whiteboard
- Monitor logs for system and services for red team actions

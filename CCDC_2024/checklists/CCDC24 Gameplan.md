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
- [ ] The designated admin username we will use


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
> ℹ️ This list only scratches the surface. Investigate running webservers, figure out how hosted services work, what they do, if they are a scored service, etc. **Google and online documentation are key.**
4. Run the [password change script](https://github.com/Coastline-XploitClub/CCDC/blob/main/CCDC_2024/linux/chpass.sh)
5. Move the password .csv file to your personal computer, then remove it from the system or lock down its privileges
6. Create initial [backups](https://github.com/Coastline-XploitClub/CCDC/blob/main/CCDC_2024/checklists/basic-linux-hardening.md#make-compressed-archives-on-local-machine-for-important-filesfolders) if you know what configs are important

## Windows team

# Throughout the day
- Continue to make backups as necessary
- Note important changes/progress on whiteboard
# CCDC Checklist

## Machine info

- [] Document both internal and external IPs. (Windows: `ipconfig /all`, Linux: `ifconfig` OR `ip a`)
- [] Record the name of each machine. (Windows: `hostname`, Linux: `hostname`)
- [] Document the operating system. (Windows: `systeminfo`, Linux `cat /etc/os-release` OR `lsb_release -a`)

---

## Users
- [] Save a list of all user accounts, including service accounts. (Windows: `net users`, Linux: `cat /etc/passwd`)
- [] Identify accounts with elevated privileges. (Windows: `net localgroup administrators`, Linux: `grep '^sudo:' /etc/group`)
- [] Change passwords for adminsitrative users. (Windows: `#TODO`, Linux: `sudo passwd`)

---

## Open Ports/Services

- [] Note all open TCP and UDP ports. (Windows: `netstat -an`, Linux: `netstat -tuln`)
- [] Document services running on each port. (Windows: `netstat -anob`, Linux: `netstat -tulpn` OR `ps -ef`)

---

## Backup Status

- [] Check if backups exist and their last update. Create backups of important files, logs, etc. (Windows: `Compress-Archive -Path "C:\path\to\directory" -DestinationPath "C:\path\to\backup.zip"`, Linux `tar -czvf backup.tar.gz /path/to/directory`)

---

## Installed Software

List all software, including versions. (Windows: `wmic product get name,version`, Linux: `dpkg -l`)

---

## Critical Data Locations

Identify where sensitive data is stored.

---

## Scheduled Tasks/Cron Jobs

Review for any unusual or unauthorized tasks. (Windows: `schtasks`, Linux: `crontab -l`)

---

## Firewall Rules

Document current rules and settings. (Varies by firewall software)

---

## Patch Management

Record recent patches and pending updates. (Windows: `wmic qfe list`, Linux: `apt list --upgradable`)

---

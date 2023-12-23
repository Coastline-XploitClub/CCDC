# CCDC Checklist

## Machine IP

Document both internal and external IPs. (Windows: `ipconfig /all`, Linux: `ifconfig` OR` ip a`)

---

## Hostname

Record the name of each machine. (Windows: `hostname`, Linux: `hostname`)

---

## Users

List all user accounts, including service accounts. (Windows: `net users`, Linux: `cat /etc/passwd`)

---

## Administrative Users

Identify accounts with elevated privileges. (Windows: `net localgroup administrators`, Linux: `grep '^sudo:' /etc/group`)

---

## Open Ports

Note all open TCP and UDP ports. (Windows: `netstat -an`, Linux: `netstat -tuln`)

---

## Running Services

Document services running on each port. (Windows: `netstat -anob`, Linux: `netstat -tulpn`)

---

## Installed Software

List all software, including versions. (Windows: `wmic product get name,version`, Linux: `dpkg -l`)

---

## Operating System Details

Include OS type, version, and patch level. (Windows: `systeminfo`, Linux: `lsb_release -a`)

---

## Critical Data Locations

Identify where sensitive data is stored.

---

## Backup Status

Check if backups exist and their last update. Create backups of important files, logs, etc.

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

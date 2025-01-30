# CCDC Checklist Linux Version

## Machine info
Document internal and external IP
```bash
ip a
ifconfig
```

Record the hostname
```bash
hostname
```

Record the operating system information
```bash
lsb_release -a
cat /etc/os-release
```

---

## Users
Save a list of all user accounts
```bash
cat /etc/passwd
getent passwd
```
- Users with `/usr/sbin/nologin` are service accounts
- Users with a shell (ex. `/bin/bash`) are user accounts

Identify administrative groups
- Check `/etc/sudoers`. A line starting with `%` indicates a group. Without it indicates a user.
```bash
cat /etc/sudoers
ls /etc/sudoers.d  # DO THIS AS WELL TO CHECK FOR OTHER SUDOERS FILES
```

Identify accounts with elevated privileges
```bash
grep '^sudo:' /etc/group
```
- Also replace `sudo` with other names of administrative groups if found above to search those as well

Change passwords for administrative users
```bash
passwd <USER>  # if you are root
sudo passwd <USER>  # if you are not root but have sudo privileges
```

---

## Open ports/services
Note open ports and their corresponding processes listening on that port
```bash
netstat -tulpn
```
- You can get more information about a process you find (ex. command used to generate process) by using `ps -ef` and searching for that PID

---

## Interesting data locations
Search for common places for files and 3rd party programs to be stored
```bash
ls /opt
ls /home
ls ~
```

---

## Cron jobs
List scheduled cron jobs
```bash
crontab -l   # List current user crontabs
ls /var/spool/cron/crontabs   # List all user crontabs
ls /etc/cron.d   # System crontabs
ls /etc/crontab  # System crontabs
```

---

# Firewall rules
Document all firewall rules
```bash
iptables -L -v -n
ufw status
```

---

## Backup status
Create backups of important directories and logs
```bash
tar -czvf <BACKUP_NAME>.tar.gz /path/to/directory  # backups a directory
```
- Examples of interesting directories: `/var/log` (logs), crontabs (see "Cron jobs" above), and other files found

Copy backup files to your local machine
```
scp root@<IP>:<path/to/backup> <path/on/your/computer>  # Backs up to your computer. Run on your computer!
```

---

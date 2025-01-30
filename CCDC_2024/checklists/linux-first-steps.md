# CCDC Checklist Linux Version

## Machine info
✅ Record these in our team's competition spreadsheet (if it exists)
### Document internal and external IP
```bash
ip a
ifconfig
```

### Record the hostname
```bash
hostname
```

### Record the operating system information
```bash
lsb_release -a
cat /etc/os-release
```

---

## Users
### Save a list of all user accounts
```bash
cat /etc/passwd
getent passwd
```
- Users with no shell `/usr/sbin/nologin` are usually service accounts
- Users with a shell (ex. `/bin/bash`) are usually user accounts

### Identify administrative groups
- Check `/etc/sudoers`. A line starting with `%` indicates a group. Without it indicates a user.
```bash
cat /etc/sudoers
ls /etc/sudoers.d  # DO THIS AS WELL TO CHECK FOR OTHER SUDOERS FILES
```
- Consider whether or not these users or groups need sudo privileges

### Identify accounts with elevated privileges
```bash
grep '^sudo:' /etc/group
```
- Also replace `sudo` with other names of administrative groups if found above to search those as well

### Change passwords for administrative users
```bash
passwd <USER>  # if you are root
sudo passwd <USER>  # if you are not root but have sudo privileges
```
- ✅ Remember to immediately submit a PCR with the changed passwords on the [scoring engine](https://scoring.wrccdc.org/pcr)!

---

## Open ports/services
### Note open ports and their corresponding processes listening on that port
```bash
netstat -tulpn
```
- You can get more information about a process you find (ex. command used to generate process) by using `ps -ef` and searching for that PID
- You can Google process names if it's something you don't recognize.

⚠️ Compare your findings with the scored services! Consider whether or not to stop unnecessary services or block ports after following this checklist.
- Is the port/service necessary for this machine (being scored)?
- Does the port/service need to be exposed on the network or can it be blocked with a firewall rule (localhost only)?
- Do any other **scored** or critical services on the network rely on this service/port being open?
- ➡️ **If not, action should be taken after this checklist is completed.**

---

## Interesting data locations
### Search for common places for files and 3rd party programs to be stored
```bash
ls /opt
ls /home
ls ~
```

---

## Cron jobs
### List scheduled cron jobs
```bash
crontab -l   # List current user crontabs
ls /var/spool/cron/crontabs   # List all user crontabs
ls /etc/cron.d   # System crontabs
ls /etc/crontab  # System crontabs
```

---

# Firewall rules
### Document all firewall rules (if a firewall is installed)
```bash
iptables -L -v -n
ufw status
```

---

## Additional actions
### Create backups of important directories and logs
```bash
tar -czvf <BACKUP_NAME>.tar.gz /path/to/directory  # backups a directory
```
- Examples of interesting directories: `/var/log` (logs), crontabs (see "Cron jobs" above), and other files found

### Copy backup files to your local machine
```
scp root@<IP>:<path/to/backup> <path/on/your/computer>  # Backs up to your computer. Run on your computer!
```

### Install the audit daemon
```
apt install auditd audispd-plugins curl  # Ubuntu/Debian
yum install audit audit-libs  # CentOS
pacman -S audit  # Arch Linux
apk add audit  # Alpine Linux
dnf install audit  # RHEL-based systems (ex. Rocky Linux)
```
### Configure the audit daemon

```bash
curl -o /etc/audit/audit.rules https://raw.githubusercontent.com/Coastline-XploitClub/CCDC/refs/heads/main/CCDC_2024/linux/Useful%20configurations/audit.rules

# Enable and start the daemon
systemctl enable auditd
systemctl start auditd
systemctl status auditd
```
- For more information on how to view the custom rule alerts, see [this quick guide](https://github.com/Coastline-XploitClub/CCDC/blob/main/CCDC_2024/linux/README.md)

---

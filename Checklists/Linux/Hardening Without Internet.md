# CCDC Linux Hardening (Without Internet) Checklist

## Linux

- Key Tasks:
  -- Take backups of essential files/programs/services/logs
  -- Change default credentials for users and services
  -- Audit firewall rules

## The Following Commands are OPTIONAL and not recommended for Socal Cybercup environment

### Set up ssh PKI authentication and disable password login

Run the following commands on your local kali-linux machine

### Generate rsa keys on host machine

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/<KEY-NAME>
```

### Enter password when prompted, then copy key to remote server ip address

```bash
ssh-copy-id -i ~/.ssh/<KEY-NAME>.pub root@<REMOTE IP ADDRESS>
```

### Test ssh connection. You shouldn't need to enter a password

```bash
ssh -i ~/.ssh/<KEY-NAME> root@<REMOTE IP ADDRESS>
```

## Recommended Checklist for Socal Cybercup

### View authorized keys file for root. Output should only contain our new public key and a key for the "sky_scorebot" user

***If you did not create a public/private keypair, then the "sky_scorebot" user should be the only one in here***

```bash
sudo cat /root/.ssh/authorized_keys
```

### Remove any additional keys

```bash
sudo nano /root/.ssh/authorized_keys
## Comment out additional keys by adding the '#' symbol at the beginning of the line
```

### Change root password

```bash
sudo su root
passwd
```

### Create local admin user

```bash
sudo adduser <USERNAME>
sudo usermod -aG wheel <USERNAME>
sudo usermod -aG sudo <USERNAME>
```

### Login and verify sudo access

```bash
sudo su <USERNAME>
sudo -lu <USERNAME>

```

### Test SSH as our new admin user

```bash
# From local kali-linux vm
ssh <USERNAME>@<TARGET-IP>
# Enter the new password you set and verify connectivity
whoami
```

### Remove root ssh login

```bash
sudo nano /etc/ssh/sshd_config

# Search for "PermitRootLogin" and set to "no"
```

### Restart ssh service to apply changes

```bash
sudo systemctl restart sshd
sudo systemctl restart ssh
```

### AFTER VERIFYING YOU CAN ACCESS THE SYSTEM AS YOUR NEW USER

```bash
# Disable root login shell
sudo nano /etc/passwd
# change /bin/bash to /bin/false for root
```

### Make local backup of important files

```bash
# The following commands will indicate what services are of interest on the system
sudo systemctl | more
sudo systemctl status
sudo systemctl show-unit-files --state=enabled
ps aux | grep -v "$(ps aux | grep -E 'init|systemd|kthreadd|ksoftirqd|root')" # Filter out root services
ps aux | grep -v "$(ps aux | grep -E 'init|systemd|kthreadd|ksoftirqd')" # Don't filter root services

# Identify services running and find the directories that matter (eg. /var/log, /etc/apache/, /var/lib/docker)
## If you have a target process ID (pid), run the following to see files open by this process
sudo lsof -p <PID>

```

### Make backup directory on local machine

```bash
# On your host kali-linux machine
mkdir -p ~/backups/<IPADDRES OF REMOTE MACHINE>/
```

### Scp Option

```bash
# On the target machine
sudo tar -zcvf backup.tar.gz /var/log /path/to/other/directory /another/directory
sudo scp backup.tar.gz <USERNAME>@<LOCAL-IP>:~/backups/<IPADDRESS>/

# If tar isn't available
sudo scp -R /var/log <USERNAME>@<LOCAL-IP>:~/backups/<IPADDRESS>/
```

### Audit users and groups

```bash
# List all users with shell access '/bin/sh, /bin/bash, /bin/tcsh, /bin/zsh, etc.'
awk -F: 'BEGIN{while(getline x<"/etc/shells")shells[x]=1}{if(shells[$NF])print $1}' /etc/passwd

# Files of interest to manually review
sudo nano /etc/passwd
sudo nano /etc/group
sudo nano /etc/shells

# Check that all users have a hash for their password
sudo nano /etc/shadow

# Check which groups have sudo access and lock down to wheel and/or sudo group
sudo nano /etc/sudoers
```

### Lock down files and directories

```bash
which chattr
# Lockdown Files
sudo chattr +i -R /etc/group
# Unlock Files
sudo chattr -i -R /etc/pam.d

```

### Audit processes

```bash
# One of the following
sudo systemctl list-unit-files --state=enabled
sudo service --status-all

# Identify and kill process
ps aux | grep -i <PROCESS NAME>
pgrep <SERVICE NAME>

# Kill service by pid
sudo kill -9 <PID>
```

### Audit Cronjobs

```bash
# Directories of interest
/etc/cron.d
/etc/cron.hourly
/etc/cron.daily
/etc/cron.weekly
/etc/cron.monthly
/var/spool/cron/crontab
```

## One-liner to record crontab state. Appends to a log file in your home directory named "crontab_records.txt"

```bash
echo -e "\n\n$(date)" >> ~/crontab_records.txt; \
for user in $(cut -f1 -d: /etc/passwd); do \
crontab=$(sudo crontab -u $user -l 2>/dev/null); \
if [[ ! -z $crontab ]]; then echo "Crontab for $user:"; \
echo "$crontab"; fi; done; echo "System-wide crontab:"; \
sudo cat /etc/crontab; echo "Cron jobs in /etc/cron.d:"; \
sudo ls /etc/cron.d/; for dir in /etc/cron.hourly /etc/cron.daily \
/etc/cron.weekly /etc/cron.monthly; do echo "Cron jobs in $dir:"; \
sudo ls $dir; done >> ~/crontab_records.txt
```

## Audit and Modify Firewall Rules (IPtables)

### View existing IPtables rules

```bash
sudo iptables -L -v
```

### Backup existing IPTables rules

```bash
sudo iptables-save >> ~/iptables_rules_backup
```

### Remove an existing rule

```bash
# If the rule is in the INPUT chain and it is the 2nd rule
sudo iptables -D INPUT 2
```

### Apply a new IPtables rule

```bash
# Example to allow ssh connections
sudo iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT
```

## Audit and Modify UFW

### Checking UFW Status

```bash
sudo ufw status verbose
```

### Backup existing UFW rules

```bash
sudo ufw status numbered >> ~/ufw_rules_backup
```

### Add a UFW rule

```bash
# Allow ssh example
sudo ufw allow ssh
```

### Remove a UFW rule

```bash
# If 'ufw status numbered' shows '22/tcp' rule as '[ 1] 22/tcp'
sudo ufw delete 1
```

### Enable/Disable UFW

```bash
sudo ufw enable
sudo ufw disable
```

## Windows

## Disable SMB1

```powershell
# Get smb version
Get-SmbServerConfiguration | Format-List EnableSMB1Protocol

# Disable SMB v1
Set-SmbServerConfiguration -EnableSMB1Protocol 0
```

## SMB1 Registry settings

```console
Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters
Double click on “SMB1” in the opened key and enter the value “0” to disable SMB1 in Windows 10. Next, confirm the new value with “OK”:
```

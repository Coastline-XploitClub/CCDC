# CCDC Linux Hardening Checklist

## Linux

- Key Tasks:
  -- Take backups of essential files/programs/services/logs
  -- Change default credentials for users and services
  -- Audit firewall rules

### Set up ssh PKI authentication and disable password login

```bash
which ssh-keygen
```

### If there is no output, perform the following for ubuntu/debian

```bash
sudo apt clean && sudo apt update -y && sudo apt install openssh-client -y
```

### Generate rsa keys

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/<KEY-NAME>
```

### Enter password when prompted, then copy key to remote server ip address

```bash
ssh-copy-id -i ~/.ssh/<KEY-NAME>.pub root@<REMOTE IP ADDRESS>
```

### Test ssh connection

```bash
ssh -i ~/.ssh/<KEY-NAME> root@<REMOTE IP ADDRESS>
```

### View authorized keys file for root. Output should only contain our new public key

```bash
sudo cat /root/.ssh/authorized_keys
```

### Remove any additional keys

```bash
sudo nano /root/.ssh/authorized_keys
```

### Remove ssh password login as option

```bash
sudo nano /etc/ssh/sshd_config

# Search for "password authentication" and set to "no"
```

### Restart ssh service to apply changes

```bash
sudo systemctl restart sshd.service
```

### Verify login still works by exiting and trying ssh connection again

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

### Make local backup of important files

```bash
systemctl | more
systemctl status
```

### Make backup directory on local machine

```bash
mkdir -p ~/backups/<IPADDRES OF REMOTE MACHINE>/
```

### Scp Option

```bash
sudo scp -r /boot <USERNAME>@<LOCAL-IP>:~/backups/<IPADDRESS>/boot
sudo scp -r /var/log <USERNAME>@<LOCAL-IP>:~/backups/<IPADDRESS>/var/log
sudo scp -r <SERVICE CONFIG FILES> <USERNAME>@<LOCAL-IP>:~/backups/<IPADDRESS>/<SERVICE_NAME>
```

### Audit users and groups

```bash
# List all users with shell access '/bin/sh, /bin/bash, /bin/tcsh, /bin/zsh, etc.'
sudo nano /etc/passwd
sudo nano /etc/group
# Check that all users have a hash for their password
sudo nano /etc/shadow
# Check which groups have sudo access and lock down to wheel and/or sudo group
sudo nano /etc/sudoers
```

### Lock down files and directories

```bash
which chattr
# If not installed
sudo apt install chattr
# Lockdown Files
sudo chattr +i /etc/group
sudo chattr -i -R /etc/pam.d
```

### Audit processes

```bash
ps aux | grep -i <PROCESS NAME>
pgrep <SERVICE NAME>
# Kill service by pid
sudo kill <PID>
```

### Audit Cronjobs

```bash
/etc/cron.d
/etc/cron.hourly
/etc/cron.daily
/etc/cron.weekly
/etc/cron.monthly
/var/spool/cron/crontab
```

### Update system

```bash
sudo apt update -y && sudo apt dist-upgrade -y
sudo yum update
sudo pacman -Syyuu
```

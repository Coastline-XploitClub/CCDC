# CCDC MASTER CHECKLIST (Merged + Upgraded)

---

## Phase 0: Pre‑Game Prep 

- [ ] **Team roles confirmation** (Captain, Linux/Kubernetes, Windows/AD, Network, Threat Hunting/Incident Response, Business/Injects). 15‑min cadence.
- [ ] **Scorebot awareness**: list scored services/ports per host; watcher assigned.
- [ ] **Credentials plan**: unique admin creds; change order defined when changing creds.
- [ ] **Comms**: primary + backup (e.g., Discord + on‑prem chat) 
- [ ] **Inject SOP**: scribe template, submission format, approval path.

---

## First 10–15 Minutes 

- [ ] **Change default/weak passwords** (local + service + device + apps). Disable/rename guest.
- [ ] **Create snapshots/backups** before hardening.
- [ ] **Enable host firewalls** (allow only scored ports + management).
- [ ] **Stop/disable obviously non‑scored services** (P2P, games, compilers if safe, telnet, rlogin, rsh, tftp, ftp anonymous, etc.).
- [ ] **Turn on logging/auditing** (Linux journald/auditd; Windows auditpol + PowerShell logging).
- [ ] **Kick out unknown sessions** and **invalidate cached creds** where possible.
- [ ] **Document initial state** (hostname, IPs, services, abnormal findings).

---

## MASTER CHECKLIST – All Systems (Phases 1–10)

### Phase 1: Initial Assessment & Situational Awareness

- [ ] Inventory systems/roles, map network/VLANs, list scored services/ports.
- [ ] Capture running configs (devices), service lists, scheduled tasks/cron, startup items.
- [ ] Identify management access paths (SSH/RDP/console) and restrict by ACL.

### Phase 2: Access Control & Authentication

- [ ] Audit all local/domain users & groups; flag disabled/locked.
- [ ] Remove/disable unauthorized accounts; expire stale accounts.
- [ ] Enforce strong password + lockout policy (local/GPO/PAM).
- [ ] Review sudo/Administrators; follow _least privilege_.
- [ ] Audit SSH keys/authorized_keys, API tokens, service account creds.

### Phase 3: Service & Persistence Auditing

- [ ] Enumerate services; stop/disable unneeded.
- [ ] Review configs for scored services (bind address, TLS, auth, logging).
- [ ] Hunt persistence: cron, systemd timers/units, rc.local, Run/RunOnce, WMI subscriptions, schtasks.

### Phase 4: Network Security

- [ ] Enumerate listening ports; align to scoreboard.
- [ ] Host firewalls: default‑deny inbound; allow only scored + management from jump box.
- [ ] Review routes, ARP cache; look for rogue gateways.
- [ ] Lock down shares (SMB/NFS); disable anonymous access.

### Phase 5: File System & Integrity

- [ ] Sweep for SUID/SGID, world‑writable, hidden dirs/files, recent changes.
- [ ] Webroots: shells/backdoors, dangerous permissions, upload dirs.
- [ ] Deploy file integrity (AIDE/tripwire) if feasible.

### Phase 6: Logging & Monitoring

- [ ] Enable/centralize logs; configure rotation.
- [ ] Monitor auth and service logs in near real‑time.
- [ ] Track configuration changes; ship to SIEM/collector.

### Phase 7: System Hardening

- [ ] Patch within constraints; prioritize remote‑exploitable services.
- [ ] Secure defaults (kernel/sysctl, SELinux/AppArmor, RDP NLA, SMBv1 off).
- [ ] Secure bootloader, BIOS/iLO/iDRAC logins.

### Phase 8: Application Security

- [ ] Web: disable eval/exec, directory listing; set proper perms, sane php.ini.
- [ ] DB: bind localhost if possible, strong creds, least privilege, TLS when possible.
- [ ] Rotate app secrets; remove default creds.

### Phase 9: Backup & Recovery

- [ ] Config/data backups; verify restores on a canary.
- [ ] Secure backup locations; off‑box if possible.

### Phase 10: Continuous Operations

- [ ] Health checks on scored services; restart on failure.
- [ ] IOC watch; block malicious IP ranges; keep a change log.
- [ ] Communicate status; submit incident/inject reports.

---

## Scored‑Service Quick Playbooks (Checklist + key config)

> Fill per host with actual ports/paths.

### SSH (Linux)

- [ ] Bind to management IP only.
- [ ] `PermitRootLogin no`, `PasswordAuthentication no` (if keys), `AllowUsers` whitelist, `MaxAuthTries 3`, `LoginGraceTime 20`.
- [ ] Restart and verify.

### RDP (Windows)

- [ ] Enable **NLA**.
- [ ] Restrict source via Windows Firewall; add jump host rule.
- [ ] Strong local admin, rename default admin if allowed.

### SMB / File Services

- [ ] Disable SMBv1; require signing where feasible.
- [ ] Principle of least privilege on shares; remove Everyone/Anonymous.

### HTTP(S) / Web (Apache/Nginx/IIS)

- [ ] Bind only required IP; redirect HTTP→HTTPS if certs exist.
- [ ] Disable directory listing, dangerous modules; set `Options -Indexes`.
- [ ] PHP: `expose_php=Off`, `disable_functions=exec,system,shell_exec,passthru,popen,proc_open`, `allow_url_fopen=Off`.

### DNS

- [ ] Disable recursion on authoritative servers; restrict zone transfers; TSIG if available.

### DHCP

- [ ] Authorize server (AD), correct scopes; disable rogue DHCP.

### Mail (Postfix/Exchange)

- [ ] Lock down relay (no open relay).
- [ ] Strong creds for SMTP/IMAP/POP; TLS if available.

### Databases (MySQL/Postgres/MSSQL)

- [ ] Bind localhost if possible; strong root/admin; remove test/anonymous; least‑priv users per app.

---

## Windows / Active Directory – Rapid Hardening

### Domain/Local Accounts & Policy

- [ ] Enumerate privileged groups: **Domain Admins**, **Enterprise Admins**, **Schema Admins**, **Administrators**; remove unknowns.
- [ ] Domain password/lockout policy set; disable/rename built‑in Administrator if allowed.
- [ ] Service accounts: rotate passwords; set **“Password never expires”** only if required; limit interactive logon.

### Logging & Audit (minimum effective)

```powershell
# Advanced Audit Policy (success+failure for key categories)
audITpol /set /category:* /success:enable /failure:enable
# If granular time allows, prioritize: Logon/Logoff, Account Logon, Account Management, DS Access, Object Access, Policy Change, Privilege Use.
# PowerShell logging
New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell -Force | Out-Null
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging -Name EnableScriptBlockLogging -Value 1 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription -Name EnableTranscripting -Value 1 -PropertyType DWord -Force | Out-Null
```

### Defender / Hardening

```powershell
# Defender active, signatures fresh
Set-MpPreference -DisableRealtimeMonitoring $false; Update-MpSignature
# Disable SMBv1
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart
# Require NLA for RDP
reg add "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 1 /f
# Disable WDigest credential caching
reg add HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest /v UseLogonCredential /t REG_DWORD /d 0 /f
# LSASS PPL (reboot required)
reg add HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v RunAsPPL /t REG_DWORD /d 1 /f
```

### Persistence & Startup

```powershell
Get-ScheduledTask | where {$_.TaskPath -ne "\\Microsoft\\"}
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Run*
Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run*
Get-WmiObject -Namespace root\subscription -Class __FilterToConsumerBinding
Get-CimInstance Win32_StartupCommand
```

### Networking & Firewall

```powershell
Get-NetTCPConnection -State Listen
# Restrict inbound to scored ports + mgmt from jump host
New-NetFirewallRule -DisplayName "Allow-Score-HTTP" -Direction Inbound -Protocol TCP -LocalPort 80,443 -Action Allow -RemoteAddress <scorebot-ip>,<jumphost-ip>
```

---

## Linux – Rapid Hardening

### Users & Auth

```bash
getent passwd ; getent group
awk -F: '($3==0){print $1}' /etc/passwd
awk -F: '($2=="" ){print $1}' /etc/shadow
chage -l <user>
# Sudoers review
EDITOR=vi visudo -c ; ls -l /etc/sudoers.d ; grep -R "NOPASSWD" /etc/sudoers*
# SSH keys
find / -name authorized_keys -o -name id_rsa -o -name id_ed25519 2>/dev/null
```

### Services & Persistence

```bash
systemctl list-units --type=service --all
systemctl list-unit-files --state=enabled
top -b -n1 | head -30
crontab -l ; ls -la /etc/cron* ; systemctl list-timers --all
# Systemd persistence hunting
find /etc/systemd/system -maxdepth 3 -type f \( -name "*.service" -o -name "*.timer" -o -name "*.path" \) -printf '%p\n'
[ -f /etc/rc.local ] && sed -n '1,200p' /etc/rc.local
```

### Network & Firewall

```bash
ss -tulnpe
ip -br a ; ip r
# Firewall baselines
# UFW example (Debian/Ubuntu)
sudo ufw default deny incoming ; sudo ufw default allow outgoing
sudo ufw allow 22/tcp comment 'SSH from jump'  # adjust source
sudo ufw allow 80,443/tcp comment 'HTTP(S) scored'
sudo ufw enable
# firewalld example (RHEL/Fedora)
firewall-cmd --set-default-zone=public
firewall-cmd --permanent --add-service=http --add-service=https
firewall-cmd --reload
```

### Filesystem & Integrity

```bash
# SUID/SGID, world-writable, hidden, recent
find / -perm -4000 -o -perm -2000 2>/dev/null
find / -type f -perm -002 -o -type d -perm -002 2>/dev/null
find / -name ".*" -type f 2>/dev/null
find / -mmin -30 -type f 2>/dev/null
# Webroot sweep (adjust path)
find /var/www -type f -name "*.php" -exec egrep -H "(shell_exec|system|eval|base64_decode)" {} \;
# AIDE quick init (if allowed)
apt -y install aide || yum -y install aide || dnf -y install aide ; aideinit || true
```

### Logging & Audit

```bash
journalctl -p err..alert -b | tail -200
systemctl enable --now rsyslog auditd || true
# Minimal audit rules (append)
echo -e "-w /etc/passwd -p wa -k acct\n-w /etc/shadow -p wa -k acct\n-w /etc/sudoers -p wa -k priv\n-w /etc/ssh/sshd_config -p wa -k ssh" > /etc/audit/rules.d/critical.rules
augenrules --load || service auditd restart
```

### SSH Hardening Snippet (add to /etc/ssh/sshd_config)

```
Protocol 2
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
PermitEmptyPasswords no
MaxAuthTries 3
LoginGraceTime 20
AllowUsers <ops-user> <captain>
ClientAliveInterval 120
ClientAliveCountMax 2
```

---

## Web Application Triage (Apache/Nginx/IIS)

- [ ] Remove sample apps, default creds.
- [ ] Lock file uploads; separate writeable dir; disable execution in uploads.
- [ ] Rotate app secrets; secure DB creds; environment files (e.g., `.env`) permissions 600.
- [ ] Enable verbose app logging temporarily (ensure disk space) and tail.

**Apache quicks**

```bash
a2dismod status autoindex cgi || true
sed -i 's/^ServerTokens.*/ServerTokens Prod/; s/^ServerSignature.*/ServerSignature Off/' /etc/apache2/conf-available/security.conf || true
```

**Nginx quicks**

```bash
sed -i 's/autoindex on;/autoindex off;/' /etc/nginx/sites-enabled/* || true
nginx -t && systemctl reload nginx
```

---

## Database Triage

**MySQL/MariaDB**

```sql
SELECT user,host,plugin FROM mysql.user; -- remove anonymous, '*' wildcard hosts
SHOW GRANTS FOR 'app'@'localhost'; -- least privilege
```

```bash
# my.cnf
grep -E "^(bind-address|skip-symbolic-links|local-infile)" /etc/mysql/my.cnf /etc/mysql/mariadb.conf.d/* 2>/dev/null
```

**PostgreSQL**

```bash
grep -E "^(listen_addresses|ssl)" /var/lib/pgsql/data/postgresql.conf /etc/postgresql/*/main/postgresql.conf 2>/dev/null
egrep -v '^#' /var/lib/pgsql/data/pg_hba.conf /etc/postgresql/*/main/pg_hba.conf 2>/dev/null
```

**MSSQL (if present)**

- [ ] Strong `sa`, disable SQL Browser if not needed; restrict TCP 1433 inbound.

---

## Network Devices – Cisco IOS Quick Hardening

```
conf t
no ip http server
no ip http secure-server
service password-encryption
ip ssh version 2
login block-for 60 attempts 3 within 60
service timestamps log datetime msec localtime
banner login ^CUnauthorized access prohibited.^C
!
username blue privilege 15 secret <long>
!
aaa new-model
line vty 0 4
 transport input ssh
 exec-timeout 5 0
 logging synchronous
 access-class VTY-ACL in
!
no cdp run  ! (use if safe)
!
logging host <syslog-ip>
copy running-config startup-config
```

- [ ] Set NTP, timezone; enable `spanning-tree portfast bpduguard default` on access ports if safe.

---

## pfSense / BSD Firewall Quick Hardening

- [ ] Change **admin** password; create named admin; backup config (Diagnostics → Backup/Restore).
- [ ] Update packages; **disable UPnP** unless explicitly needed.
- [ ] WAN: default deny inbound; explicit allows for scored services only.
- [ ] Aliases for management & red‑team IPs; quick block rules.
- [ ] Verify NAT/1:1 mappings; review states (`pfctl -ss`); inspect rules (`pfctl -sr`).
- [ ] Enable logging to remote syslog; lock WebGUI to mgmt VLAN/IP.

```bash
pfctl -sa   # all
pfctl -sr   # rules
pfctl -sn   # NAT
clog /var/log/filter.log | tail -100
```

---

## Incident Response – Fast Triage & Containment

### If Compromise Suspected

1. [ ] **Preserve availability** of scored services.
2. [ ] **Isolate** (host FW rules, ACLs) vs pull plug.
3. [ ] **Snapshot** / export volatile info.
4. [ ] **Identify IOC** (process, user, IP, persistence vector).
5. [ ] **Eradicate** (kill proc, remove persistence, rotate creds, patch).
6. [ ] **Recover** (config restore, verify scoring, increase logging).
7. [ ] **Report** to white team per rules.

### Quick Triage Commands

**Linux**

```bash
ss -tpna | grep ESTAB
ps aux --sort=-%cpu | head -20
last -n 20 ; lastb | head
find / -mmin -10 -type f 2>/dev/null
```

**Windows**

```powershell
netstat -abno | findstr LISTEN
Get-EventLog -LogName Security -Newest 100 | select TimeGenerated,EventID,Message
Get-Process | sort CPU -desc | select -First 15
schtasks /query /fo LIST /v | more
```

---

## Documentation & Injects

**Per System Sheet**

- Hostname | IPs | OS | Scored services/ports | Findings | Changes | Current status

**Change Log**

| Time | System | Change | By  |
| ---- | ------ | ------ | --- |

**Incident Report**

- Time | System | IOC/Vector | Impact | Actions | Prevention

**Inject Template**

- Requirements | Data gathered | Actions taken | Evidence | Validation | Submitter

---

## Cadence Checklist (repeat every 15 min)

- [ ] Scoreboard green for all services.
- [ ] New IOCs? Block & note.
- [ ] Pending patches/reboots queued?
- [ ] Inject board checked & assignments updated.
- [ ] Hand‑offs captured in log.

---

## Useful One‑Liners (curated)

**Linux**

```bash
ss -tulnp | awk 'NR>1{print $1,$5,$7}'
find / -perm -4000 -o -perm -2000 -type f 2>/dev/null | xargs ls -la
faillog -a ; lastlog | head
sudo tar -czf /root/quick_backup_$(hostname)_$(date +%F_%H%M).tgz /etc /var/www /home 2>/dev/null
iptables -I INPUT -s <bad-ip>/32 -j DROP
```

**Windows**

```powershell
Disable-LocalUser -Name "guest" -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName "Block Bad IP" -Direction Inbound -RemoteAddress <bad-ip> -Action Block
Stop-Service -Name <svc>; Set-Service -Name <svc> -StartupType Disabled
wevtutil epl Security C:\security_$(hostname)_$(get-date -f yyyyMMdd_HHmm).evtx
```

---

_Use this as a living doc; trim or expand per environment and scoring rules._

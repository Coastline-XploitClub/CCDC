## 192.168.220.22 chowder Server 2012 FTP and Employee Directory 10.100.121.22
- chowder .22 FTP
- chowder .22 HTTP
- chowder .22 SMB
## 192.168.220.80 naruto Windows 10 Bank System 10.100.121.80
- naruto .80 TELNET
## 192.168.220.10 courage Server 2016 FTP,VNC, andSMB 10.100.121.10
- courage .10 DNS
- courage .10 FTP
- courage-vnc .10 HTTP
- courage .10 SMB
## 192.168.220.69 sailormoon Legacy Windows Wordpress 5.2 10.100.121.69
- sailormoon .69 HTTP

``` https://github.com/DigitalRuby/IPBan
┌──(kali㉿kali)-[~/Documents/ccdc23]
└─$ nmap -oA chowder_simple 10.100.121.22 -Pn
Starting Nmap 7.94 ( https://nmap.org ) at 2023-11-04 11:34 EDT
Nmap scan report for 10.100.121.22
Host is up (0.011s latency).
Not shown: 990 filtered tcp ports (no-response)
PORT      STATE SERVICE
21/tcp    open  ftp
22/tcp    open  ssh
135/tcp   open  msrpc
139/tcp   open  netbios-ssn
445/tcp   open  microsoft-ds
3389/tcp  open  ms-wbt-server
49152/tcp open  unknown
49155/tcp open  unknown
49156/tcp open  unknown
49157/tcp open  unknown

Nmap done: 1 IP address (1 host up) scanned in 4.23 seconds
                                                                                                                                         
┌──(kali㉿kali)-[~/Documents/ccdc23]
└─$ nmap -oA naruto_simple 10.100.121.80 -Pn
Starting Nmap 7.94 ( https://nmap.org ) at 2023-11-04 11:34 EDT
Nmap scan report for 10.100.121.80
Host is up (0.011s latency).
Not shown: 993 filtered tcp ports (no-response)
PORT     STATE SERVICE
21/tcp   open  ftp
22/tcp   open  ssh
23/tcp   open  telnet
135/tcp  open  msrpc
139/tcp  open  netbios-ssn
445/tcp  open  microsoft-ds
3389/tcp open  ms-wbt-server

Nmap done: 1 IP address (1 host up) scanned in 12.41 seconds
                                                                                                                                         
┌──(kali㉿kali)-[~/Documents/ccdc23]
└─$ nmap -oA courage_simple 10.100.121.10 -Pn
Starting Nmap 7.94 ( https://nmap.org ) at 2023-11-04 11:35 EDT
Nmap scan report for 10.100.121.10
Host is up (0.013s latency).
Not shown: 985 filtered tcp ports (no-response)
PORT     STATE SERVICE
21/tcp   open  ftp
22/tcp   open  ssh
25/tcp   open  smtp
53/tcp   open  domain
88/tcp   open  kerberos-sec
110/tcp  open  pop3
135/tcp  open  msrpc
139/tcp  open  netbios-ssn
445/tcp  open  microsoft-ds
593/tcp  open  http-rpc-epmap
636/tcp  open  ldapssl
3268/tcp open  globalcatLDAP
3389/tcp open  ms-wbt-server
5800/tcp open  vnc-http
5900/tcp open  vnc

Nmap done: 1 IP address (1 host up) scanned in 9.57 seconds
                                                                                                                                         
┌──(kali㉿kali)-[~/Documents/ccdc23]
└─$ nmap -oA sailormoon_simple  10.100.121.69 -Pn
Starting Nmap 7.94 ( https://nmap.org ) at 2023-11-04 11:36 EDT
Nmap scan report for 10.100.121.69
Host is up (0.021s latency).
Not shown: 994 filtered tcp ports (no-response), 3 filtered tcp ports (host-unreach)
PORT    STATE SERVICE
21/tcp  open  ftp
80/tcp  open  http
443/tcp open  https

Nmap done: 1 IP address (1 host up) scanned in 48.27 seconds
```

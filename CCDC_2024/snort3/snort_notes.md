# command line reference
```bash
snort -c /usr/local/snort/etc/snort/sort.lua -R /usr/local/snort/etc/snort/<rules file> -i <interface> -A alert_fast -s 65535  -k none
```
### change interface to promiscous mode
```bash
ip link set dev eth0 promisc on
```
download default community rules and place in
/usr/local/snort/etc/snort/rules/snort3-community-rules/snort3-community.rules

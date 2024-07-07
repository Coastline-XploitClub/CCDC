# colorado certificate enumeration
## using low privilege account tpatterson:password

```bash
python3 /opt/certi/certi.py list 'stream.stream/tpatterson:password' -n --dc-ip 192.168.50.11 --class ca

Output:
[*] Root CAs

Cert Subject: CN=stream-COLORADO-CA,DC=stream,DC=stream
Cert Serial: 48F108198B53189444DF5C234768097E
Cert Start: 2023-09-24 18:26:40
Cert End: 2028-09-24 18:36:40
Cert Issuer: CN=stream-COLORADO-CA,DC=stream,DC=stream

[*] Authority Information Access

Cert Subject: CN=stream-COLORADO-CA,DC=stream,DC=stream
Cert Serial: 48F108198B53189444DF5C234768097E
Cert Start: 2023-09-24 18:26:40
Cert End: 2028-09-24 18:36:40
Cert Issuer: CN=stream-COLORADO-CA,DC=stream,DC=stream

```
### get tgt
```bash
getTGT.py -dc-ip 192.168.50.11 'stream.stream/tpatterson:password'
# tpatterson.ccache saved to local directory
certi.py req 'stream.stream/tpatterson@colorado.stream.stream' stream-COLORADO-CA -k -n
# requesting the certificicate did not work with this user nor with Administrator, what protects it try on htb
```
# Wazuh Offline Installation
i stored these files on my kali vm under /home/kali/Documents/wazuh-offline/deb and /rpm
## on host with internet access
```bash
curl -sO https://packages.wazuh.com/4.6/wazuh-install.sh
chmod 744 wazuh-install.sh
./wazuh-install.sh -dw <deb|rpm>
```

```bash

curl -sO https://packages.wazuh.com/4.6/config.yml

```
## config.yml
all-in-one deployment, replace "\<indexer-node-ip\>", "<wazuh-manager-ip>", and "\<dashboard-node-ip\>" with 127.0.0.1.
```bash

 sed -i 's/<indexer-node-ip>/127.0.0.1/g' config.yml
 sed -i 's/<wazuh-manager-ip>/127.0.0.1/g' config.yml
 sed -i 's/<dashboard-node-ip>/127.0.0.1/g' config.yml
```
```bash
curl -sO https://packages.wazuh.com/4.6/wazuh-certs-tool.sh
chmod 744 wazuh-certs-tool.sh
./wazuh-certs-tool.sh --all
```
- transfer the offline archive and certificate folder with scp to server host, use scp -r to transfer the certicicate folder
## on server host
- uncompress the archive
```bash
tar xf wazuh-offline.tar.gz
```
- install the indexer
### rpm
```bash
rpm --import ./wazuh-offline/wazuh-files/GPG-KEY-WAZUH
rpm -ivh ./wazuh-offline/wazuh-packages/wazuh-indexer*.rpm
```
### deb
```bash
dpkg -i ./wazuh-offline/wazuh-packages/wazuh-indexer*.deb
```

replace $NODE_NAME with node-1
- make sure the certs tool creates all the required certs and that they are named correctly!!!
```bash

mkdir /etc/wazuh-indexer/certs
mv -n wazuh-certificates/$NODE_NAME.pem /etc/wazuh-indexer/certs/indexer.pem
mv -n wazuh-certificates/$NODE_NAME-key.pem /etc/wazuh-indexer/certs/indexer-key.pem
mv wazuh-certificates/admin-key.pem /etc/wazuh-indexer/certs/
mv wazuh-certificates/admin.pem /etc/wazuh-indexer/certs/
cp wazuh-certificates/root-ca.pem /etc/wazuh-indexer/certs/
chmod 500 /etc/wazuh-indexer/certs
chmod 400 /etc/wazuh-indexer/certs/*
chown -R wazuh-indexer:wazuh-indexer /etc/wazuh-indexer/certs
```

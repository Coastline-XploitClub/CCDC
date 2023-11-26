# Wazuh Offline Installation

-run this command on a computer with internet access
```bash
curl -sO https://packages.wazuh.com/4.6/wazuh-install.sh
chmod 744 wazuh-install.sh
./wazuh-install.sh -dw <deb|rpm>
```
- same with this command 
```bash

curl -sO https://packages.wazuh.com/4.6/config.yml

```
## config.yml
all-in-one deployment, replace "\<indexer-node-ip\>", "<wazuh-manager-ip>", and "\<dashboard-node-ip\>" with 127.0.0.1.

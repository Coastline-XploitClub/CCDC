# Wazuh Offline Installation

- curl command below will be from this repository
- relace deb or rpm based on os
```bash
curl -sO https://github.com/Coastline-XploitClub/CCDC/blob/main/Scripts/Environment/Linux/Wazuh/wazuh-install.sh
chmod 744 wazuh-install.sh
./wazuh-install.sh -dw <deb|rpm>
```
- same with this command config.yml is stored on this repository
```bash

curl -sO https://github.com/Coastline-XploitClub/CCDC/blob/main/Scripts/Environment/Linux/Wazuh/config.yml

```
## config.yml
all-in-one deployment, replace "\<indexer-node-ip\>", "<wazuh-manager-ip>", and "\<dashboard-node-ip\>" with 127.0.0.1.

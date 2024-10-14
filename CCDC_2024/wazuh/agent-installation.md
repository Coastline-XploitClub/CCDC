# debian 
```bash
wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.9.0-1_amd64.deb && sudo WAZUH_MANAGER='<wazuh manager ip' WAZUH_AGENT_NAME='<wazuh agent name>' dpkg -i ./wazuh-agent_4.9.0-1_amd64.deb
```
# red hat
```bash
curl -o wazuh-agent-4.9.0-1.x86_64.rpm https://packages.wazuh.com/4.x/yum/wazuh-agent-4.9.0-1.x86_64.rpm && sudo WAZUH_MANAGER='<wazuh manager ip>' WAZUH_AGENT_NAME='<wazuh agent name>' rpm -ihv wazuh-agent-4.9.0-1.x86_64.rpm
```
# windows
```powershell
Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.9.0-1.msi -OutFile ${env.tmp}\wazuh-agent; msiexec.exe /i ${env.tmp}\wazuh-agent /q WAZUH_MANAGER='<wazuh manager ip>' WAZUH_AGENT_NAME='<wazuh agent name>'
```
# install from sources 
[https://documentation.wazuh.com/current/deployment-options/wazuh-from-sources/wazuh-agent/index.html](https://documentation.wazuh.com/current/deployment-options/wazuh-from-sources/wazuh-agent/index.html)



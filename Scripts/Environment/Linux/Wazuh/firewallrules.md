# Wazuh Server/Indexer: firewall rules
- [ ] ports 9200 and 1514 must be open on wazuh server

## firewalld 
```bash
sudo firewall-cmd --permanent --add-port=9200/tcp
sudo firewall-cmd --permanent --add-port=1514/tcp
sudo systemctl restart firewalld
```

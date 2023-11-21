# ELK Stack Set-Up

Elastic = Database

Kibana = Web Interface for Database

- Fleet Management

- Endpoint Security

- Logging

References:

```console
https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elastic-stack-on-ubuntu-22-04

https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-network.html
```

## Installing Elasticsearch

---

**Import Elasticsearch public GPG key**

```bash
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elastic.gpg
```

**Add Elastic source list to sources.list.d directory**

```bash
echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-8.x.list
```

**Update & Install**

Make note of the generated password when installing.

```bash
sudo apt update && sudo apt install elasticsearch
```

**Configure**

```bash
sudo vim /etc/elasticsearch/elasticsearch.yml
```

**Examples**

```console
network.host: localhost         // Listen on  localhost

network.host: "_en0:ipv4_"      // Listen on interface en0 with ipv4 addresses only

http.port: 9200                 // Listen on port 9200 (default)
```

**Start & Enable**

```bash
sudo systemctl start elasticsearch && sudo systemctl enable elasticsearch
```

**Troubleshooting**

We can test our elasticsearch server with curl. (Make sure to specify https)

```bash
curl -X GET -k https://localhost:9200
```

This will fail as we need to provide authentication. We can reset the password if forgotten.

```bash
curl -X GET -k https://elastic:<password>@localhost:9200
```

**Reset Password**

```bash
/usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic
```

## Installing Kibana

---

**Installation**

```bash
sudo apt install kibana
```

**Create Enrollment Token**

```bash
sudo /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana
```

**Activate w/ Token**

```bash
sudo /usr/share/kibana/bin/kibana-setup
```

**Start & Enable**

```bash
sudo systemctl start kibana && sudo systemctl enable kibana
```

## Configure Nginx

---

**Install**

```bash
sudo apt install nginx
```

**Configure Proxy**

```bash
sudo vim /etc/nginx/sites-enabled/default
```

Add under server location:

```bash
proxy_pass http://127.0.0.1:5601;
```

**Restart & Enable**

```bash
sudo systemctl restart nginx && sudo systemctl enable --now nginx
```

We can now login to the web interface with our original elastic credentials.

## Integrations

---

**Fleet Server**

_**Setup:**_

- Create name for Fleet Server and Agent Policy

- Leave rest as default, save & continue

- Add Elastic Agent to your hosts

- Add Fleet Server

- Fleet Server host: `https://<host-ip>:8220` (Can use domain name if DNS is configured)

- Generate Fleet Server policy

- Run the appropriate commands provided on your Fleet Server. Should see:

  ```console
  Successfully enrolled the Elastic Agent.
  Elastic Agent has been successfully installed.
  ```

- Confirm Fleet Server is connected

- If using a seperate machine for Fleet Server, make sure to copy SSL certs from Elastic Server

  - Elastic certs stored in `/etc/elasticsearch/certs` by default
  - Can replace with legitimate signed certs as well
  - If using a different directory for your certs, you can add these flags to the end of the install commands:

    ```bash
    --fleet-server-es-ca=<path_to_cert> --insecure
    ```

- Continue Enrolling Elastic agent

- Switch tab to Enroll in Fleet

- Create new Agent Policy and follow the install instructions

- Confirm Agent is connected to fleet

**Elastic Defend**

- Add Integration Name & Select Existing Policy w/ enrollments

- Leave rest as default & Continue

- We need to create encryption keys so we can add security rules

  ```bash
  sudo /usr/share/kibana/bin/kibana-encryption-keys generate
  sudo vim /etc/kibana/kibana.yml (Add Keys to bottom of file)
  sudo systemctl restart kibana
  ```

- Navigate to Security > Manage > Rules

- Load Elastic prebuilt rules and timeline templates

- Select All > Enable

**Windows**

- Name & Select Agent Policy

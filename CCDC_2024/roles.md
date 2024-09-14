# Roles for 2024 CCDC Team

## Windows
  - [ ] Identify Domain Controllers and create an administrative user account for the team
  - [ ] Identify existing Domain and Local Admin users
  - [ ] Identify additional Domain and Local users
  - [ ] Identify all groups on the Domain
  - [ ] Identify all file shares on the domain and audit permissions
    - [ ] Identify PII with incorrect permissions 
  - [ ] Audit Domain Group Policy
    - [ ] Audit logging policy
    - [ ] Audit password policy
    - [ ] Audit Kerberos pre auth and enable
  - [ ] Identify Firewall rules and audit
  - [ ] Change all user passwords and document for Ops Team
  - [ ] Identify running services
  - [ ] Identify open ports

## Linux
  - [ ] Identify all Linux Servers and create an sudo user for the team
  - [ ] Identify all administrative (sudo) users
  - [ ] Identify all additional users
  - [ ] Identify all groups, looking for groups with sudo permissions
  - [ ] Identify if domain joined and what software is used
  - [ ] Identify running services
  - [ ] Identify open ports
  - [ ] Identify local firewall rules
  - [ ] Identify remote access and audit if neccessary. CAREFUL TURNING THIS OFF BEFORE YOU KNOW WHAT IS SCORED

## Networking/Firewall
  - [ ] Change default password ASAP
  - [ ] Audit existing firewall rules
    - [ ] Once services are known, implement strict ACL rules
       
## Kubernetes/Docker
  - [ ] Identify kubernetes host machine
  - [ ] Identify services running under kubernetes
  - [ ] Security audit on kubernets cluster and networking

## Business Injects
  - [ ] Track active business injects and document Goal and Due Time for each of these (Use Whiteboard)
  - [ ] Prioritize business injects and assign to appropriate team members
  - [ ] Communicate all change requests to Ops Team on behalf of team
  - [ ] Monitor Discord for customer service requests
  - [ ] Get all injects complete and submitted 10 minutes before due time
  - [ ] Delegate techinical injects to team members and handle administrative injects yourself

## Incident Response / Threat Hunting
  - [ ] Scan environment with vulnerability scanner
  - [ ] Actively monitor environment for suspicious activities
  - [ ] Draft incident responses
    - [ ] Gather evidence and logs

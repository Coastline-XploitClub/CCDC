# default logging

| event id | event | location |
| -----    | ----- | ------   |
| 21       | Session Logon succeeded | Applications and Services Logs\Windows\TerminalServices-LocalSessionManager\Operational |
| 23, 24      | session disconnection, logoff | Applications and Services Logs\Windows\TerminalServices-LocalSessionManager\Operational 

# with audit policy 

[policies.md](policies.md)

| event id | event | location |
| -----    | ----- | ------   |
| 4771      | Audit Failure (will catch RDP failed logins from within the domain USING KERBEROS LOG IS ON DC)| Windows Logs\Security |
| 4625    | Audit Failure (on host user is trying to RDP into, will log failed attempt for OUT OF DOMAIN remote connections (NTLM)) | Windows Logs\Security |

## Kerberos
# Kerberos Auditing Group Policy
GPMC / Computer Configuration / Policies / Windows Settings / Advanced Audit Policy Configuration / Audit Policies / Account Logon

# Event ID 4768 
Keyword Audit Success : TGT succesfully requested

# checking for users with preauth disabled
$nopre=Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true} -Properties DoesNotRequirePreAuth | select SamAccountName, DoesNotRequirePreAuth

Loop through and change to false

foreach ($pre in $nopre) { Set-ADAccountControl -Id $pre.SamAccountName -DoesNotRequirePreAuth:$false}

# Script to get all users and groups from a domain and local machine with admin rights
Import-Module ActiveDirectory

# Prepare output file
$outputFile = "admin.txt"
if (Test-Path $outputFile) {
    Remove-Item $outputFile
}

# Get local admins
$localAdminGroup = Get-LocalGroup -Name "Administrators"
$localAdmins = Get-LocalGroupMember -Group $localAdminGroup
"Local Administrators:" | Out-File $outputFile
"" | Out-File $outputFile -Append
Write-Output "Local Administrators:"
foreach ($admin in $localAdmins) {
    Write-Output "$($admin.Name)"
    $admin.Name | Out-File $outputFile -Append
    Write-Output "$($admin.Name) added to $outputFile"
}

# Get domain admins
$domainAdmins = Get-ADGroupMember -Identity "Domain Admins" -Recursive | Get-ADUser
Write-Output "Domain Administrators:"
"" | Out-File $outputFile -Append
"Domain Administrators:" | Out-File $outputFile -Append
"" | Out-File $outputFile -Append
foreach ($admin in $domainAdmins) {
    Write-Output "$($admin.Name)"
    $admin.Name | Out-File $outputFile -Append
    Write-Output "$($admin.Name) added to $outputFile"
}

# create domain admins for each windows team member...remember to change your password!
$password = ConvertTo-SecureString -AsPlainText -Force '#!C0@stCCDCteam!' 

# Array of names
$Names = @('kyle','ceasar', 'cam', 'marshall')

foreach ($name in $Names) {
    try {
        # Create AD User
        $samacct = "${name}_da"
        New-ADUser -Enabled $true -Name "$samacct" -AccountPassword $password -SamAccountName $samacct -Description "${name}'s DA account" -ErrorAction Stop

        # Add to Domain Admins group
        Add-ADGroupMember -Identity 'Domain Admins' -Members $samacct -ErrorAction Stop

        Write-Output "User ${samacct} created and added to Domain Admins successfully. Log in to DC and CHANGE YOUR PASSWORD NOW!"
    }
    catch {
        Write-Output "Failed to create user ${samacct}: $_"
    }
}

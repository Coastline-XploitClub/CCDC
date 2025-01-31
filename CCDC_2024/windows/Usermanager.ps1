# Banner
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "                  User Management Tool             " -ForegroundColor Green
Write-Host "                  Coastline Xploit Club               " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
# Ensure Checklist directory exists for logging
$logPath = "C:\Checklist"
if (!(Test-Path $logPath)) {
    New-Item -ItemType Directory -Path $logPath -Force | Out-Null
}
$logFile = "$logPath\UserActions.log"
$errorLogFile = "$logPath\ErrorLog.txt"

# Function to log actions
function Log-Action {
    param ([string]$message)
    "$((Get-Date).ToString("yyyy-MM-dd HH:mm:ss")) - $message" | Out-File -Append -FilePath $logFile
}

# Function to generate a strong password
function Generate-StrongPassword {
    return [System.Web.Security.Membership]::GeneratePassword(14, 3)
}

# Function to display security best practices
function Display-SecurityPractices {
    Write-Host "\nSecurity Best Practices:" -ForegroundColor Cyan
    Write-Host "- Use strong passwords with uppercase, lowercase, numbers, and special characters."
    Write-Host "- Enable Multi-Factor Authentication (MFA) when possible."
    Write-Host "- Regularly change passwords and avoid reusing old ones."
    Write-Host "- Disable unused user accounts."
    Write-Host "- Assign the least privilege necessary for user accounts."
}

# Function to display the menu
function Show-Menu {
    Write-Host "===================== User Management & Security Audit ====================="
    Write-Host "1. Add a New User"
    Write-Host "2. Show All Users"
    Write-Host "3. Change Password for a Specific User"
    Write-Host "4. Change Password for All Users"
    Write-Host "5. Enable or Disable a User Account"
    Write-Host "6. Delete a User"
    Write-Host "Q. Quit"
    Write-Host "=============================================================================="
}

# Function to show all users and allow selection for detailed information
function Show-AllUsers {
    do {
        Write-Host "`nList of All Users:" -ForegroundColor Cyan
        $users = Get-LocalUser | Select-Object -Property Name, Enabled, LastLogon, Description
        $i = 1
        $userMap = @{}
        foreach ($user in $users) {
            Write-Host "$i. $($user.Name) (Enabled: $($user.Enabled))"
            $userMap[$i] = $user
            $i++
        }

        $userChoice = Read-Host "`nEnter the number of the user to view details (or 'b' to go back to the main menu)"
        if ($userChoice -match "^\d+$" -and [int]$userChoice -gt 0 -and [int]$userChoice -le $users.Count) {
            $selectedUser = Get-LocalUser -Name $userMap[[int]$userChoice].Name | Select-Object Name, SID, Enabled, LastLogon, PasswordLastSet, PasswordExpires, UserMayChangePassword, AccountExpires, Description
            Write-Host "`nDetailed Information for User: $($selectedUser.Name)" -ForegroundColor Green
            Write-Host "----------------------------------------"
            Write-Host "SID: $($selectedUser.SID)"
            Write-Host "Enabled: $($selectedUser.Enabled)"
            Write-Host "Last Logon: $($selectedUser.LastLogon)"
            Write-Host "Password Last Set: $($selectedUser.PasswordLastSet)"
            Write-Host "Password Expires: $($selectedUser.PasswordExpires)"
            Write-Host "User May Change Password: $($selectedUser.UserMayChangePassword)"
            Write-Host "Account Expires: $($selectedUser.AccountExpires)"
            Write-Host "Description: $($selectedUser.Description)"
            Write-Host "----------------------------------------"

            $nextAction = Read-Host "`nEnter 'l' to return to the user list or 'm' to go back to the main menu"
            if ($nextAction -eq 'm') {
                return
            }
        } elseif ($userChoice -eq 'b') {
            return
        } else {
            Write-Host "Invalid selection. Please enter a valid user number, 'b' to go back, or 'm' for the main menu." -ForegroundColor Red
        }
    } while ($true)
}
# Function to add a new user
function Add-NewUser {
    do {
        $username = Read-Host "Enter the username for the new user"
        $password = Read-Host "Enter the password for the new user" -AsSecureString
        try {
            New-LocalUser -Name $username -Password $password -FullName $username -Description "Added via User Management Script"
            Write-Host "User $username has been added successfully" -ForegroundColor Green
            Log-Action "User added: $username"

            # Ask if the user should be added to any group
            do {
                Write-Host "`nAvailable Groups:" -ForegroundColor Cyan
                $groups = Get-LocalGroup | Select-Object -ExpandProperty Name
                $i = 1
                $groupMap = @{}
                foreach ($group in $groups) {
                    Write-Host "$i. $group"
                    $groupMap[$i] = $group
                    $i++
                }

                $groupChoice = Read-Host "Enter the number of the group to add $username to (or 'n' to skip)"
                if ($groupChoice -match "^\d+$" -and [int]$groupChoice -gt 0 -and [int]$groupChoice -le $groups.Count) {
                    $groupName = $groupMap[[int]$groupChoice]
                    try {
                        Add-LocalGroupMember -Group $groupName -Member $username
                        Write-Host "$username has been added to the ${groupName} group." -ForegroundColor Green
                        Log-Action "User $username added to group: $groupName"
                    } catch {
                        $_ | Out-File -Append -FilePath $errorLogFile
                        Write-Host "Error adding $username to ${groupName}: $($_.Exception.Message)" -ForegroundColor Red
                    }
                } elseif ($groupChoice -eq 'n' -or $groupChoice -eq 'N') {
                    break
                } else {
                    Write-Host "Invalid selection. Please enter a valid group number or 'n' to skip." -ForegroundColor Red
                }
            } while ($true)

        } catch {
            $_ | Out-File -Append -FilePath $errorLogFile
            Write-Host "Error adding user ${username}: $($_.Exception.Message)" -ForegroundColor Red
        }

        $addAnother = Read-Host "`nDo you want to add another user? (y/n)"
    } while ($addAnother -eq 'y' -or $addAnother -eq 'Y')
}

# Function to change password for a specific user
function Change-UserPassword {
    Write-Host "Available users:" -ForegroundColor Cyan
    $users = Get-LocalUser | Select-Object -ExpandProperty Name
    $i = 1
    $userMap = @{}
    foreach ($user in $users) {
        Write-Host "$i. $user"
        $userMap[$i] = $user
        $i++
    }
    
    $userChoice = Read-Host "Enter the number of the user to change password"
    if ($userChoice -match "^\d+$" -and [int]$userChoice -gt 0 -and [int]$userChoice -le $users.Count) {
        $username = $userMap[[int]$userChoice]
        $newPassword = Read-Host "Enter new password for $username" -AsSecureString
        try {
            Set-LocalUser -Name $username -Password $newPassword
            Write-Host "Password for $username has been changed successfully" -ForegroundColor Green
            Log-Action "Password changed for user: $username"
        } catch {
            $_ | Out-File -Append -FilePath $errorLogFile
            Write-Host "Error: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Invalid selection. Please enter a valid user number." -ForegroundColor Red
    }
}

# Function to change password for all users
function Change-AllUserPasswords {
    $newPassword = Read-Host "Enter the new password for all users" -AsSecureString
    $users = Get-LocalUser | Select-Object -ExpandProperty Name
    foreach ($user in $users) {
        try {
            Set-LocalUser -Name $user -Password $newPassword
            Write-Host "Password for $user has been changed successfully" -ForegroundColor Green
            Log-Action "Password changed for user: $user"
        } catch {
            $_ | Out-File -Append -FilePath $errorLogFile
            Write-Host "Error changing password for ${user}: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Function to enable or disable a user account
function Manage-UserStatus {
    Write-Host "Enabled Users:" -ForegroundColor Green
    Get-LocalUser | Where-Object { $_.Enabled -eq $true } | Select-Object Name | Format-Table -AutoSize
    
    Write-Host "Disabled Users:" -ForegroundColor Red
    Get-LocalUser | Where-Object { $_.Enabled -eq $false } | Select-Object Name | Format-Table -AutoSize
    
    $username = Read-Host "Enter the username to enable/disable"
    $user = Get-LocalUser -Name $username -ErrorAction SilentlyContinue
    if ($user) {
        if ($user.Enabled -eq $true) {
            Disable-LocalUser -Name $username
            Write-Host "$username has been disabled." -ForegroundColor Yellow
            Log-Action "User disabled: $username"
        } else {
            Enable-LocalUser -Name $username
            Write-Host "$username has been enabled." -ForegroundColor Green
            Log-Action "User enabled: $username"
        }
    } else {
        Write-Host "User $username does not exist." -ForegroundColor Red
    }
}

# Function to delete a user
function Delete-User {
    Write-Host "Available users:" -ForegroundColor Cyan
    $users = Get-LocalUser | Select-Object -ExpandProperty Name
    $i = 1
    $userMap = @{}
    foreach ($user in $users) {
        Write-Host "$i. $user"
        $userMap[$i] = $user
        $i++
    }
    
    $userChoice = Read-Host "Enter the number of the user to delete"
    if ($userChoice -match "^\d+$" -and [int]$userChoice -gt 0 -and [int]$userChoice -le $users.Count) {
        $username = $userMap[[int]$userChoice]
        try {
            Remove-LocalUser -Name $username -Confirm:$false
            Write-Host "User $username has been deleted successfully" -ForegroundColor Green
            Log-Action "User deleted: $username"
        } catch {
            $_ | Out-File -Append -FilePath $errorLogFile
            Write-Host "Error deleting user ${username}: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "Invalid selection. Please enter a valid user number." -ForegroundColor Red
    }
}

# Main Script Loop
Do {
    Show-Menu
    $Choice = Read-Host "Enter your choice (1-6 or Q)"
    Switch ($Choice) {
        "1" { Add-NewUser }
        "2" { Show-AllUsers }
        "3" { Change-UserPassword }
        "4" { Change-AllUserPasswords }
        "5" { Manage-UserStatus }
        "6" { Delete-User }
        "Q" { Write-Host "\nExiting... Stay safe!" -ForegroundColor Green; Exit }
        Default { Write-Host "\nInvalid option! Please choose between 1-6 or Q." -ForegroundColor Red }
    }
} While ($Choice -ne "Q")
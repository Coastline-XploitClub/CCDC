# $ADusers = Get-ADUser -Filter * | Where-Object {$_.SamAccountName -ne "Administrator"} 
# $passlength= 10
# $chars = 'abcdefghijklmnopqrstuvwxyz'.ToCharArray()
# $specialChars = '!@#$%^&*()_+-={}|[]\;'.ToCharArray()
# $upperCaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
# $numbers = '0123456789'.ToCharArray()

# $userObjects = @()
# foreach ($user in $ADusers){
#     # Add a random special character, uppercase character, and number to the password
#     $randompass = -join (($specialChars | Get-Random -Count 1), ($upperCaseChars | Get-Random -Count 1), ($numbers | Get-Random -Count 1))
    
#     # Add random characters from the $chars array to the password until it reaches the $passlength
#     $randompass += -join ($chars.ToCharArray() | Get-Random -Count ($passlength - 3))

#     # Shuffle the password
#     $randompass = -join ($randompass.ToCharArray() | Get-Random -Count $randompass.Length)

#     $userObject = New-Object PSObject -Property @{
#         SamAccountName = $user.SamAccountName
#         Password = "$randompass"
# }
#     Set-ADAccountPassword -Reset -Identity $user.SamAccountName -NewPassword (ConvertTo-SecureString $randompass -AsPlainText -Force)
    
#     $userObjects += $userObject

#     }


# $userObjects | Export-Csv .\adusers.csv -NoTypeInformation


$ADusers = Get-ADUser -Filter * | Where-Object {$_.SamAccountName -ne "Administrator"} 
$passlength= 10
$chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()_+-={}|[]\;'.ToCharArray()

$userObjects = @()
foreach ($user in $ADusers){
    $randompass = -join ($chars | Get-Random -Count $passlength)
    $userObject = New-Object PSObject -Property @{
        SamAccountName = $user.SamAccountName
        Password = "$randompass"
}
    Set-ADAccountPassword -Reset -Identity $user.SamAccountName -NewPassword (ConvertTo-SecureString $randompass -AsPlainText -Force)
    
    $userObjects += $userObject

    }


$userObjects | Export-Csv .\adusers.csv -NoTypeInformation

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

function change_admin_pw{
    param([string]$domcomputer)
    $matchloop =$true
    Do{
    Write-Host -NoNewline -ForegroundColor Green "[?] "
    $pw1=Read-Host -AsSecureString -Prompt "Enter new password for $($domcomputer):"
    Write-Host -NoNewline -ForegroundColor Green "[?] "
    $pw2= Read-Host -AsSecureString -Prompt "Enter password again:"
    $plainText1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pw1))
    $plainText2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pw2))
    if ($plainText1 -ceq $plainText2){
        
        Invoke-Command -ComputerName $domcomputer -ScriptBlock {Set-LocalUser -Name "Administrator" -Password $using:pw1 -PasswordNeverExpires $true}
        Write-Host -NoNewline -ForegroundColor Green "[-] "
        
        $matchloop=$false     
     
        
             
         
        
    }
    else{
        Write-Host -NoNewline -ForegroundColor Red "[!] "
        Write-Host "they do not match, try again"
        
    }
    }While($matchloop -eq $true)



}

function disable_local_admin{
    param([string]$domcomputer)
    Write-Host -NoNewline -ForegroundColor Green "[?] "
    $disable_choice=Read-Host -Prompt "Disable local Administrator on $($domcomputer)(y/n)?"
    if ($disable_choice.ToLower() -eq 'y'){
        
        Invoke-Command -Computername $domcomputer -ScriptBlock { Disable-LocalUser -Name "Administrator" }
    }
    else{
        Write-Host -NoNewline -ForegroundColor Red "[!] "
        Write-Host "did not disable Local Administrator on $($domcomputer)"
    }
}
function enable_local_admin{
    param([string]$domcomputer)
        Write-Host -NoNewline -ForegroundColor Green "[?] "
        $disable_choice=Read-Host -Prompt "Enable local Administrator on $($domcomputer)(y/n)?"
    if ($disable_choice.ToLower() -eq 'y'){
        
        Invoke-Command -Computername $domcomputer -ScriptBlock { Enable-LocalUser -Name "Administrator" }
        Write-Host -NoNewline -ForegroundColor Green "[-] "
        Write-Host "Administrator on $($domcomputer) Enabled please change password"
        change_admin_pw -domcomputer $domcomputer
    }
    else{
        Write-Host -NoNewline -ForegroundColor Red "[!] "
        Write-Host "did not enable Local Administrator on $($domcomputer)"
    }
    }

function set_local_admin{
    param([string]$domcomputer,$enabled
    )
    
    if ($enabled -eq $true){
    $loop=$true
    DO{
    Write-Host -NoNewline -ForegroundColor Green "[-] "
    Write-Host "Local Administrator on $($domcomputer) is enabled"
    Write-Host -NoNewline -ForegroundColor Green "[?] "
    $pw_choice = Read-Host -Prompt "Change $($domcomputer) Administrator password(y/n)?"
    if ($pw_choice.ToLower() -eq 'y'){
        
        change_admin_pw -domcomputer $domcomputer
        disable_local_admin -domcomputer $domcomputer
        $loop=$false
        
    }
    else{
        Write-Host -NoNewline -ForegroundColor Red "[!] "
        write-host "$($domcomputer) Administrator password unchanged"
        disable_local_admin -domcomputer $domcomputer
        $loop=$false
    }
     }while ($loop -eq $true)
     
    }
    # if local admin is not enabled 
    else {
        
        enable_local_admin -domcomputer $domcomputer
    }

}
   
#script to enumerate local Administrators on domain joined computers
#will give the option to change password or disable account Requires ActiveDirectory module and administrator privileges
$domcpus= Get-ADComputer -Filter * | select name
foreach ($cpu in $domcpus){
    $enabled = Invoke-Command -ComputerName $cpu.name -ScriptBlock {Get-LocalUser -Name "Administrator" | select enabled }
    set_local_admin -domcomputer $cpu.name -enabled $enabled.Enabled

    
}
#final result 
foreach ($cpu in $domcpus){
    $isenabled = Invoke-Command -ComputerName $cpu.name -ScriptBlock { (Get-LocalUser -Name "Administrator").Enabled }
    $lastset = Invoke-Command -ComputerName $cpu.name -ScriptBlock { (net user "Administrator")[8]}
    Write-Host -NoNewline -ForegroundColor Green "[-] "
    Write-Host "Administrator Enabled set to $($isenabled) on $($cpu.name)"
    Write-Host -NoNewline -ForegroundColor Green "[-] "
    Write-Host "Administrator $($lastset)" 
}

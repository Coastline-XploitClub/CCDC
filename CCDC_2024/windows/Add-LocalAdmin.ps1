# script to add local administrators on each windows box, requires WINRM access from DC, Domain Admin login, AND MOST IMPORTANLY an OU created with servers you want to add local admins to

$Names = @('kyle','cesar', 'cam', 'marshall')

# check for ou argument
if ($args.Count -ne 1){
    Write-host "Usage is ./Add-LocalAdmin.ps1 <'organizational unit for computers'>"
    exit 1
}
else {
    $ou=$args[0]
    }

# get distinguished name for domain for searchbase
try{
$dist=Get-ADDomain | select -ExpandProperty DistinguishedName -ErrorAction SilentlyContinue
}catch{
$dist=$null
}
if (!$dist){
Write-Host "Something is wrong with the Get-ADDomain Command...exiting"
exit 1
}

# filter out only the ou set in command line argument
$searchbase = "OU=$ou,$dist"
Write-Host "Searching $searchbase..."
try {
    $computers = Get-ADComputer -SearchBase $searchbase -Filter * -ErrorAction SilentlyContinue
    }catch {
        $computers =$null
    }
if ($computers) {
    Write-Host "Computers Found:"
    $computers | select -ExpandProperty Name | fl
}
else {
    Write-Host "No Computers Found! Check your OU!"
    exit 1
    }

Write-Host ""

foreach ($computer in $computers){
    foreach ($name in $Names){
        $newUsername = "${name}_test_admin"
        
        # Create the new user
        Invoke-Command -ComputerName $computer.name -ScriptBlock {
            param([string]$inputVar)
            $result = net user /add /Y $inputVar "#!C0@stCCDCteam!" 
            if ($LASTEXITCODE -eq 0) {
                Write-Output "User $inputVar created successfully."
            } else {
                Write-Output "Failed to create user $inputVar. Error: $result"
            }
        } -ArgumentList $newUsername
        
        # Add the new user to the Administrators group
        Invoke-Command -ComputerName $computer.name -ScriptBlock {
            param([string]$inputVar)
            $result = net localgroup Administrators /add $inputVar
            if ($LASTEXITCODE -eq 0) {
                Write-Output "Successfully added $inputVar to Administrators group."
            } else {
                Write-Output "Failed to add $inputVar to Administrators group. Error: $result"
            }
        } -ArgumentList $newUsername
    }
}
$Names = @('kyle','ceasar', 'cam', 'marshall')

# check for ou argument
if ($args.Count -ne 1){
    Write-host "Usage is ./Add-LocalAdmin.ps1 <'organizational unit for computers'>"
    exit 1
}
else {
    $ou=$args[0]
    }

# get distinguished name for domain for searchbase
try{
$dist=Get-ADDomain | select -ExpandProperty DistinguishedName -ErrorAction SilentlyContinue
}catch{
$dist=$null
}
if (!$dist){
Write-Host "Something is wrong with the Get-ADDomain Command...exiting"
exit 1
}

# filter out only the ou set in command line argument
$searchbase = "OU=$ou,$dist"
Write-Host "Searching $searchbase..."
try {
    $computers = Get-ADComputer -SearchBase $searchbase -Filter * -ErrorAction SilentlyContinue
    }catch {
        $computers =$null
    }
if ($computers) {
    Write-Host "Computers Found:"
    $computers | select -ExpandProperty Name | fl
}
else {
    Write-Host "No Computers Found! Check your OU!"
    exit 1
    }

Write-Host ""

foreach ($computer in $computers){
    foreach ($name in $Names){
        $newUsername = "${name}_test_admin"
        
        # Create the new user
        Invoke-Command -ComputerName $computer.name -ScriptBlock {
            param([string]$inputVar)
            $result = net user /add /Y $inputVar "#!C0@stCCDCteam!" 
            if ($LASTEXITCODE -eq 0) {
                Write-Output "User $inputVar created successfully."
            } else {
                Write-Output "Failed to create user $inputVar. Error: $result"
            }
        } -ArgumentList $newUsername
        
        # Add the new user to the Administrators group
        Invoke-Command -ComputerName $computer.name -ScriptBlock {
            param([string]$inputVar)
            $result = net localgroup Administrators /add $inputVar
            if ($LASTEXITCODE -eq 0) {
                Write-Output "Successfully added $inputVar to Administrators group."
            } else {
                Write-Output "Failed to add $inputVar to Administrators group. Error: $result"
            }
        } -ArgumentList $newUsername
    }
}

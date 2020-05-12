$srvUser = "NA\Bhu103950-a"
$password = Get-Content $PSScriptRoot\Password.txt | ConvertTo-SecureString -Key (Get-Content $PSScriptRoot\aes.key)
$credential = New-Object System.Management.Automation.PsCredential($srvUser,$password)

$remoteServer = "KACI-PWVENG-10"

$sess = New-PSSession -Credential $credential -ComputerName $remoteServer
#Enter-PSSession $sess
$samUser = (Get-ADUser -Filter "Name -like 'jamison*, bruce*'").samaccountname

Invoke-Command -Session $sess -ScriptBlock {
    $prc = Get-Process -Name 'notepad'
    if($prc.Name[0] -like 'notepad') {
        Stop-Process -name 'notepad'
        if($?) {
            Write-Host "SUccess"
        }
        else {
            Write-Host "fail"
        }

    }
}


#Exit-PSSession
Remove-PSSession $sess
$srvUser = "NA\Bhu103950-a"
$password = Get-Content $PSScriptRoot\Password.txt | ConvertTo-SecureString -Key (Get-Content $PSScriptRoot\aes.key)
$credential = New-Object System.Management.Automation.PsCredential($srvUser,$password)

$userList = Import-Csv -Path "UserList.csv"
$serverList = Import-Csv -Path "serverList.csv"

foreach ($remoteServer in $serverList){
    $remoteSession = New-PSSession -Credential $credential -ComputerName $remoteServer.Name

    foreach($user in $userList){
        $userSamAccountName = (get-ADUser -Filter "name -like '($user.lastname)*, ($user.firstname)*'").samaccountname
        Invoke-Command -Session $remoteSession -ScriptBlock {
            $localadmingroup = Get-LocalGroupMember -Group "Administrators"
            foreach($localuser in $localadmingroup) {
                if($localuser.Name -match $userSamAccountName) {
                    
                    Remove-LocalGroupMember -Group "Administrators" -Member $localuser.Name
                }
            }
        }
    }
}

<# $remoteServer = "KACI-PWVENG-10"

$sess = New-PSSession -Credential $credential -ComputerName $remoteServer

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
} #>


Remove-PSSession $sess
$srvuser = "NA\pat102920-a"
$password = ConvertTo-SecureString -String "Welcome@2211" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PsCredential($srvUser,$password)

<# $srvuser = "svc_local"
$password = Get-Content $PSScriptRoot\password.txt | ConvertTo-SecureString -Key (Get-Content $PSScriptRoot\aes.key)
$credential = New-Object System.Management.Automation.PSCredential($srvuser,$password)

#>

$userList = Import-Csv -Path "$PSScriptRoot\Userlist.csv"
$serverList = Import-Csv -Path "$PSScriptRoot\Serverlist.csv"

foreach($remoteserver in $serverList)
{
    $remoteSession = New-PSSession -Credential $credential -ComputerName $remoteServer.Name
    foreach($user in $userList)
    {
        $userSam = (Get-ADUser -Filter "name -like '$($user.Lastname)*, $($user.firstname)*'").samaccountname
        Invoke-Command -Session $remoteSession -ScriptBlock {

            $localAdminGroup = Get-LocalGroupMember -Group "Administrators"
            $userSamName = $Using:userSam
            foreach($localAdminUser in $localAdminGroup.Name)
            {
                if(${localAdminUser} -match $userSamName)
                {
                    #$localAdminUser
                    #Remove-LocalGroupMember -Group "Administrators" -Member $localAdminUser
                    Remove-LocalGroupMember -Group "Administrators" -Member $localAdminUser
                    #(Get-LocalGroupMember -Group "Administrators" -Member $localAdminUser).Name
                }

            }
        }    
    }   
    Remove-PSSession $remoteSession
}

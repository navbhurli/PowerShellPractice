<#
##==================================================
## Created by: Naveen Bhurli
## Created Date: 12-May-2020
## Organisation: Stefanini
##==================================================
#>
##==================================================
## Log Creation & Appending
##==================================================

If( !(Test-Path -Path "${env:windir}\logs\RemoveLocalAdminUsers.log"))
{
    New-Item -Path "${env:windir}\logs" -Name "RemoveLocalAdminUsers.log" -ItemType File -Force -ErrorAction SilentlyContinue | Out-Null
}

Function Input-Log($x)
{
    $time = (Get-Date).ToString()
    $data = $time + ": " + $x
    Add-Content -Path "${env:windir}\logs\RemoveLocalAdminUsers.log" -Value $data -ErrorAction SilentlyContinue
}



## Declaring variable for credentials
$srvuser = "NA\bhu103950-a"
$password = ConvertTo-SecureString -String "!H@8P@ssw0rd" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PsCredential($srvUser,$password)

<#  
## Domain admin creds
$srvuser = "svc_local"
$password = Get-Content $PSScriptRoot\password.txt | ConvertTo-SecureString -Key (Get-Content $PSScriptRoot\aes.key)
$credential = New-Object System.Management.Automation.PSCredential($srvuser,$password)
#>

#test to check if syncing to correct repo in github

## csv files containing users that needs to be removed
$userList = Import-Csv -Path "$PSScriptRoot\Userlist.csv"
## csv files containing servers from which the user needs to be removed
$serverList = Import-Csv -Path "$PSScriptRoot\Serverlist.csv"

foreach($remoteserver in $serverList)
{
    #$rmsrvName = $remoteserver.Name
    Input-Log "Scanning '$($remoteserver.Name)'"
    #remote session to the server/machine
    try 
    {
        $remoteSession = New-PSSession -Credential $credential -ComputerName $remoteServer.Name
        foreach($user in $userList)
        {
            Input-Log "Checking if '$($user.lastname), $($user.firstname)' exists and removing it"
            # fetching UserSamAccountName from provided user's first and last name from AD
            $userSam = (Get-ADUser -Filter "name -like '$($user.Lastname)*, $($user.firstname)*'").samaccountname
            # Remoting to that server and executing the script (further important actions)
            Invoke-Command -Session $remoteSession -ScriptBlock {
                
                # fecthing all the users from local administrators group
                $localAdminGroup = Get-LocalGroupMember -Group "Administrators"
                # using the variable from outside the scriptblock
                $userSamName = $Using:userSam

                # iterating through all the members and comparing the samaccountname
                foreach($localAdminUser in $localAdminGroup.Name)
                {
                    # if any user exusts then go ahead with removing it from the local admin group
                    if(${localAdminUser} -match $userSamName)
                    {
                        #Perform the required function i.e., Remove-LocalGroupMember
                        Get-LocalGroupMember -Group "Administrators" -Member $localAdminUser
                    }

                }


            }   
        }
    }
    catch 
    {
        Input-Log "The server may not be available this moment and hence, it couldn't remove users from it"
        
    }
        
    # removing the PSSession
    Remove-PSSession $remoteSession
}

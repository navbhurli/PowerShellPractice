[CmdletBinding()]
param (
    [Parameter(ParameterSetName='user')]
    [switch]
    $user,
    [Parameter(ParameterSetName='machine')]
    [switch]
    $machine
)


If( !(Test-Path -Path "${env:userprofile}\PST-log\${env:username}_pstcopy.log" ))
{
    New-Item -Path "${env:userprofile}\PST-log" -Name "${env:username}_pstcopy.log" -ItemType File -Force -ErrorAction SilentlyContinue | Out-Null
}

function Create-BackupFolder
{
    If (!(Test-Path -Path $copyPath -PathType Container))
    {
        New-Item -ItemType Directory -Path $copyPath -Force -ErrorAction SilentlyContinue
        Input-Log "Folder created"
    }    
}

Function Input-Log($x)
{
    $time = (Get-Date).ToString()
    $data = $time + ": " + $x
    Add-Content -Path "${env:userprofile}\PST-log\${env:username}_pstcopy.log" -Value $data -ErrorAction SilentlyContinue
}

## Variable declartion
$notReplicated = "$env:USERPROFILE\Not-Replicated\PST"

#Executing according to the input - if machine is selected, it will start searching all the physical drives
if($machine)
{
    Input-Log "********************Starting to filter physical drives and scan PST files from entire drives********************"
    Create-BackupFolder
    #scanning and filtering only physical drives and not any shared location or mapped drives
    $physicalDrive = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" | Select-Object -Property DeviceID
    #variable declaration for use in duplicate entries
    $num = 10
    foreach($drives in $physicalDrive.DeviceID)
    {
        $files = Get-ChildItem -Path "$($drives)\" -Recurse -Filter *.pst -Force -ErrorAction SilentlyContinue | Where-Object {$_.FullName -notmatch 'Not-Replicated|OneDrive|Recycle'}   
        $existPST = Get-ChildItem -Path $notReplicated -Recurse -Filter *.pst -Force
        foreach($newfile in $files)
        {
            if($existPST)
            {
                foreach($existFile in $existPST)
                {
                    if ($existFile.Name -eq $newfile.Name)
                    {
                        Move-Item -Path $newfile.FullName -Destination "$($notReplicated+$newfile.BaseName+'_'+$num+$newfile.extension)"
                        $num += 1      
                    }
                    else
                    {
                        Move-Item -Path $newfile.FullName -Destination $notReplicated -Force
                    }
                }
            }
            else 
            {
                Copy-Item -Path $newfile.FullName -Destination $notReplicated -Force         
            }
        }
    }
}


#Executing according to the input - is user is selected, it will start searching only userprofile
if ($user)
{
    Create-BackupFolder
    $PST = Get-ChildItem -Path "$env:USERPROFILE" -Recurse -Filter *.pst -Force -ErrorAction SilentlyContinue | Where-Object {$_.FullName -notmatch 'Not-Replicated|Recycle|OneDrive'}
    $existPST = Get-ChildItem -Path $notReplicated -Recurse -Filter *.pst -Force
    $num = 10
    foreach($newfile in $PST)
    {
        if($existPST)
        {
            foreach($existFile in $existPST)
            {
                if ($existFile.Name -eq $newfile.Name)
                {
                    Move-Item -Path $newfile.FullName -Destination "$($notReplicated+$newfile.BaseName+'_'+$num+$newfile.extension)"
                    $num += 1      
                }
                else
                {
                    Move-Item -Path $newfile.FullName -Destination $notReplicated -Force
                }
            }
        }
        else 
        {
            Copy-Item -Path $newfile.FullName -Destination $notReplicated -Force         
        }
    }
}
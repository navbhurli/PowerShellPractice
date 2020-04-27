[CmdletBinding()]
param (
    [Parameter(ParameterSetName='user')]
    [switch]
    $user,
    [Parameter(ParameterSetName='machine')]
    [switch]
    $machine
)

## Variable declartion
$notReplicated = "$env:USERPROFILE\Not-Replicated\PST\"

If( !(Test-Path -Path "${env:userprofile}\PST-log\${env:username}_pstcopy.log" ))
{
    New-Item -Path "${env:userprofile}\PST-log" -Name "${env:username}_pstcopy.log" -ItemType File -Force -ErrorAction SilentlyContinue | Out-Null
}

Function Input-Log($x)
{
    $time = (Get-Date).ToString()
    $data = $time + ": " + $x
    Add-Content -Path "${env:userprofile}\PST-log\${env:username}_pstcopy.log" -Value $data -ErrorAction SilentlyContinue
}

function Create-BackupFolder()
{
    If (!(Test-Path -Path $notReplicated -PathType Container))
    {
        New-Item -ItemType Directory -Path $notReplicated -Force -ErrorAction SilentlyContinue
        Input-Log "Folder created"
    }    
}





#Executing according to the input - if machine is selected, it will start searching all the physical drives
if($machine)
{
    Input-Log "********************Starting to filter physical drives and scan PST files from entire drives********************"
    Create-BackupFolder
    #scanning and filtering only physical drives and not any shared location or mapped drives
    $physicalDrive = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" | Select-Object -Property DeviceID
    #variable declaration for use in duplicate entries
    
    foreach($drives in $physicalDrive.DeviceID)
    {
        $files = Get-ChildItem -Path "$($drives)\" -Recurse -Filter *.pst -Force -ErrorAction SilentlyContinue | Where-Object {$_.FullName -notmatch 'Not-Replicated|OneDrive|Recycle'}   
        $existPST = Get-ChildItem -Path $notReplicated -Recurse -Filter *.pst -Force
        foreach($newfile in $files)
        {
            #$num = 10
            if($existPST)
            {
                foreach($existFile in $existPST)
                {
                    if ($existFile.Name -eq $newfile.Name)
                    {
                        Copy-Item -Path $newfile.FullName -Destination "$($notReplicated+$newfile.BaseName+'_'+(((Get-Date).Minute).ToString()+((Get-Date).Second).ToString())+$newfile.extension)"
                        #$num += 1
                    }
                    else
                    {
                        Copy-Item -Path $newfile.FullName -Destination $notReplicated -Force
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
    #$num = 10
    foreach($newfile in $PST)
    {
        if($existPST)
        {
            foreach($existFile in $existPST)
            {
                if ($existFile.Name -eq $newfile.Name)
                {
                    Copy-Item -Path $newfile.FullName -Destination "$($notReplicated+$newfile.BaseName+'_'+(((Get-Date).Minute).ToString()+((Get-Date).Second).ToString())+$newfile.extension)"
                    #$num += 1      
                }
                else
                {
                    Copy-Item -Path $newfile.FullName -Destination $notReplicated -Force
                }
            }
        }
        else 
        {
            Copy-Item -Path $newfile.FullName -Destination $notReplicated -Force         
        }
    }
}
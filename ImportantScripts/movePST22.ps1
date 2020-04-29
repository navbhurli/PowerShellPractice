<#
##==============================================
## Created by: Naveen Bhurli
## Created Date: 29-April-2020
## Organisation: Stefanini
##==============================================
#>


##========================================================================
## This script searches for .pst files from all the physical drives or ...
## userprofile (depending on the input) and moves them to a single location
##========================================================================


[CmdletBinding()]
param (
    [Parameter(ParameterSetName='user')]
    [switch]
    $user, ## This input parameter when used, searches only under userprofile
    [Parameter(ParameterSetName='machine')]
    [switch]
    $machine ## This input parameter when used, searches all physical drives
)

## Variable declartion
$notReplicated = "$env:USERPROFILE\Not-Replicated\PST\"

<#
.SYNOPSIS
Function to generate a log entry whenever needed

.PARAMETER x
Parameter x is the input string that would be written to the logs

.EXAMPLE
Add-Log "This sentence will be written to the log file"

#>
Function Add-Log($x)
{
    $time = (Get-Date).ToString()
    $data = $time + ": " + $x
    Add-Content -Path "${env:userprofile}\PST-log\${env:username}_pstcopy.log" -Value $data -ErrorAction SilentlyContinue
}


## Creating a folder and a log file to record details of the execution
If( !(Test-Path -Path "${env:userprofile}\PST-log\${env:username}_pstcopy.log" ))
{
    #Add-Log "Creating log folder and file"
    New-Item -Path "${env:userprofile}\PST-log" -Name "${env:username}_pstcopy.log" -ItemType File -Force -ErrorAction SilentlyContinue | Out-Null
    if($?)
    {
        Add-Log "Log folder and file created successfully"
    }
    else 
    {
        Add-Log "Failed to create Log folder and file"       
    }
}

<#
.SYNOPSIS
Creating the destination folder
#>
function Set-BackupFolder()
{
    Add-Log "Checking if Backup folder exists"
    If (!(Test-Path -Path $notReplicated -PathType Container))
    {
        Add-Log "Backup folder does not exist, creating one now..."
        New-Item -ItemType Directory -Path $notReplicated -Force -ErrorAction SilentlyContinue
        if($?)
        {
            Add-Log "Backup folder created successfully"
        }
        else 
        {
            Add-Log "Failed to create Backup folder"
        }
    }    
}

<#
.SYNOPSIS
Searches recursively for .pst files depending on input paramter passed to the script

.DESCRIPTION
Depending on the input parameter, this function searches for .pst files and moves them to a single location, "$env:USERPROFILE\Not-Replicated\PST\"

If there are duplicate files already present in the destination location, those files would be renamed and moved.
Note: Renaming format is fileName_MinutesSeconds.

.PARAMETER files
Parameter "files" will be the array of locations of .pst files

#>
Function Move-Files($files)
{
    foreach($newfile in $files)
    {
        if(Test-Path -Path "$($notReplicated+$newfile.name)")
        {
            Copy-Item -Path $newfile.FullName -Destination "$($notReplicated+$newfile.BaseName+'_'+(((Get-Date).Minute).ToString()+((Get-Date).Second).ToString())+$newfile.extension)"
            if($?)
            {
                Add-Log "Successfully moved $($newfile.fullname) to $notReplicated after renaming"
            }
            else
            {
                Add-Log "Failed to move $newfile from $($newfile.fullname) "
            }   
            Start-Sleep -Seconds 3            
        }
        else
        {
            Copy-Item -Path $newfile.FullName -Destination $notReplicated -Force
            if($?)
            {
                Add-Log "Successfully moved $($newfile.fullname) to $notReplicated "
            }
            else
            {
                Add-Log "Failed to move $newfile from $($newfile.fullname) "
            }
            Start-Sleep -Seconds 3
        }
    }
}

##Main execution starts here....

#Executing according to the input - if machine is selected, it will start searching all the physical drives
if($machine)
{
    Add-Log "Script Execution started"
    Add-Log "Starting to filter physical drives and scan PST files from entire drives"
    Set-BackupFolder
    #scanning and filtering only physical drives and not any shared location or mapped drives
    Add-Log "Scanning for Physical Drives" 
    $physicalDrive = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" | Select-Object -Property DeviceID
    
    foreach($drives in $physicalDrive.DeviceID)
    {  
        #fetching .pst files from each of those drives recursively excluding few locations such as Recycle bin, OneDrive, Destination location and few others
        $files = Get-ChildItem -Path "$($drives)\" -Recurse -Filter *.pst -Force -ErrorAction SilentlyContinue | Where-Object {$_.FullName -notmatch 'Not-Replicated|OneDrive|Recycle'}   
        Move-Files($files)
    }
    Add-Log "Script execution ended`n"
}


#Executing according to the input - is user is selected, it will start searching only userprofile
if ($user)
{
    Add-Log "Script execution started" 
    Set-BackupFolder
    #fetching .pst files recursively from %userprofile% excluding few locations such as Recycle bin, OneDrive, Destination location and few others
    $files = Get-ChildItem -Path "$env:USERPROFILE" -Recurse -Filter *.pst -Force -ErrorAction SilentlyContinue | Where-Object {$_.FullName -notmatch 'Not-Replicated|Recycle|OneDrive'}
    Move-Files($files)
    Add-Log "Script execution ended`n"
}
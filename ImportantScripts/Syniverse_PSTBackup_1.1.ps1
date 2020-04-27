<#
##==================================================
## Created by: Naveen Bhurli
## Created Date: 04-Feb-2020
## Modified on: 24-April-2020
## Organisation: Stefanini
##==================================================
#>
##==================================================
## Log Creation & Appending
##==================================================

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

##==================================================
## Script to backup user's pst from userprofile
##==================================================

Input-Log "********Start of Installation*********"

## Creating a folder to copy all the pst's under User's Profile

## Global variables

$copyPath = "$env:USERPROFILE\Not-Replicated\PST"


If (!(Test-Path -Path $copyPath -PathType Container))
{
    New-Item -ItemType Directory -Path $copyPath -Force -ErrorAction SilentlyContinue
    Input-Log "Folder created"
}


## Iterating through all the physical drives and fetching pst info
$drives = Get-CimInstance -ClassName win32_logicaldisk -Filter "drivetype=3" | Select-Object -Property DeviceID

foreach($drive in $drives)
{
   $driveID = $drive.DeviceID
   $PST = Get-ChildItem -Path "$($driveID)\" -Recurse -Filter *.pst -Force -ErrorAction SilentlyContinue | Where-Object {$_.FullName -notlike "*\Not-Replicated\*"}
   $PST.FullName

}


$num = 1

foreach($childPST in $PST.fullname)
{
    ## Copying the PST's to the folder created before
    if((Get-ChildItem -Path $copyPath -Filter *.pst).Name -eq $childPST.Name)
    {
        Move-Item -Path $childPST -Destination "$copyPath\$($childPST.basename+$num+$childPST.extension)" -Force -ErrorAction SilentlyContinue
        If($?)
        {
            Input-Log "$childPST successfully moved to $copyPath"
        }
        else
        {
            Input-Log "Failed to move $childPST"
        }
        $num += 1
    }
    Move-Item -Path $childPST -Destination $copyPath -Force -ErrorAction SilentlyContinue    
    If($?)
    {
        Input-Log "$childPST successfully moved to $copyPath"
    }
    else
    {
        Input-Log "Failed to copy $childPST"
    }

}

Input-Log "********End of Installation***********`r`n"
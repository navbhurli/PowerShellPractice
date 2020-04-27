<#
##==================================================
## Created by: Naveen Bhurli
## Created Date: 04-Feb-2020
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


## Iterating through user's profile for pst's 

$PST = Get-ChildItem -Path "$env:USERPROFILE" -Recurse -Filter *.pst -Force -ErrorAction SilentlyContinue | where {$_.FullName -notlike "*\Not-Replicated\*"}
  
foreach($childPST in $PST.fullname)
{
    ## Copying the PST's to the folder created before
    Copy-Item -Path $childPST -Destination $copyPath -Force -ErrorAction SilentlyContinue
    If($?)
    {
        Input-Log "$childPST successfully copied to $copyPath"
    }
    else
    {
        Input-Log "Failed to copy $childPST"
    }

}

Input-Log "********End of Installation***********`r`n"
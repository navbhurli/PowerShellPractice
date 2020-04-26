$physicalDrive = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" | Select-Object -Property DeviceID

$notReplicated = "$env:USERPROFILE\Downloads\Not-Replicated"

foreach($drives in $physicalDrive.DeviceID)
{
    $files = Get-ChildItem -Path "$($drives)\" -Recurse -Filter *.pst -Force -ErrorAction SilentlyContinue | Where-Object {$_.FullName -notmatch 'Not-Replicated|OneDrive|Recycle'}   
    $files.FullName
    Copy-Item -Path $files.FullName -Destination $notReplicated -Force
    <# $existPST = Get-ChildItem -Path $notReplicated 
    foreach($somFile in $existPST)
    {
        if ($somFile.Name -eq $files.Name)
        {
           Write-Host $somFile.Name         
        }
        else
        {
            Copy-Item -Path $files.FullName -Destination $notReplicated -Force
        }

    } #>
    
}


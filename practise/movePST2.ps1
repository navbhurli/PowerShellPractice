$physicalDrive = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" | Select-Object -Property DeviceID

$notReplicated = "$env:USERPROFILE\Downloads\Not-Replicated\"
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
                    Copy-Item -Path $newfile.FullName -Destination "$($notReplicated+$newfile.BaseName+'_'+$num+$newfile.extension)"
                    $num += 1      
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
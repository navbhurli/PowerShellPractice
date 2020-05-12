$localgroup = (Get-LocalGroupMember -Group administrators)

#$localgroup.GetType()

foreach ($member in $localgroup)
{
    if($member.ToString() -match "test")
    {
        Remove-LocalGroupMember -Group administrators -Member $member
        if($?)
        {
            Write-Host "Success"
        }
        
    }
    
}
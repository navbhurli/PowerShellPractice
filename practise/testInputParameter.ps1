<# Param(
    [Parameter(ParameterSetName='user')]
    [switch]$user,
    [Parameter(ParameterSetName='machine')]
    [switch]$machine
) #>
[CmdletBinding()]
param (
    [switch]
    $user,
    [switch]
    $machine
)

if ($user) {
    Write-Host "user level"
    exit    
}
if($machine){
    Write-Host "Machine level"
    exit
}
Write-Host "Nothing selected"
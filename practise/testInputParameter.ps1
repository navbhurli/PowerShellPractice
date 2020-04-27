Param(
    [Parameter(ParameterSetName='user')]
    [switch]$user,
    [Parameter(ParameterSetName='machine')]
    [switch]$machine
)
try {
    if ($user) {
        Write-Host "user level"
        exit    
    }
    if($machine){
        Write-Host "Machine level"
        exit
    }
}
catch {
    Write-Host "Something went wrong"
}
finally {
    Write-Host "nothing selected"
}


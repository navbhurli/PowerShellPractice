<# $key = New-Object Byte[] 32
[Security.cryptography.RNGCryptoServiceProvider]::Create().GetBytes($key)
$key | Out-File C:\Naveen\Packaging\2020\BV\aes.key

(Get-Credential).Password | ConvertFrom-SecureString -Key (Get-Content C:\Naveen\Packaging\2020\BV\aes.key) | Set-Content C:\Naveen\Packaging\2020\BV\Password.txt
 #>

$srvUser = "NA\Bhu103950-a"
$password = Get-Content $PSScriptRoot\Password.txt | ConvertTo-SecureString -Key (Get-Content $PSScriptRoot\aes.key)
$credential = New-Object System.Management.Automation.PsCredential($srvUser,$password)

$remoteServer = "KACI-PWVENG-10"

$sess = New-PSSession -Credential $credential -ComputerName $remoteServer
Enter-PSSession $sess
<Run commands in remote session>
Exit-PSSession
Remove-PSSession $sess
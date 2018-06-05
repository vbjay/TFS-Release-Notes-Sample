$PSScriptRoot
$pth= $PSScriptRoot
$keys=[System.IO.Path]::Combine($pth,"Keys.ps1")
Import-Module $keys -Scope Local

$csp=Get-ReleaseNotesCSP

$rsa=Create-RSAManagedObject -csp $csp
$token = Read-Host -Prompt "Please enter your TFS Personal Access Token"
Clear-Host 
$tokenFile=$([System.IO.Path]::Combine($env:USERPROFILE,"Sample-Token.crypt"))
Encrypt-String -rsa $rsa -unencryptedString $token > $tokenFile


$rsa.Dispose()
$rsa=$null
Write-Host "Token stored at $tokenFile"

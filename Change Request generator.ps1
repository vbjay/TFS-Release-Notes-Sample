$PSScriptRoot
$pth= $PSScriptRoot
$zip=$([System.IO.Path]::Combine($pth, "TFS-Release-Notes\TFS Release Notes\bin\Debug\release\attached files.zip"))

$tokenFile=$([System.IO.Path]::Combine($env:USERPROFILE,"Sample-Token.crypt"))
$keys=[System.IO.Path]::Combine($pth,"Keys.ps1")
$manageToken=[System.IO.Path]::Combine($pth,"Manage-TFSToken.ps1")
Import-Module $keys -Verbose -Scope Local

$csp =Get-ReleaseNotesCSP
$rsa=Create-RSAManagedObject -csp $csp
if (-NOT (test-path $tokenfile))
{
& $manageToken
}

$encToken=get-content -Path $tokenFile

$token=Decrypt-String -rsa $rsa -encryptedString $encToken

Set-Location $([System.IO.Path]::Combine($pth, "TFS-Release-Notes\TFS Release Notes\bin\Debug"))



Import-Module '.\TFS Release Notes.psd1' -Verbose
#$cred = New-Object Microsoft.VisualStudio.Services.Common.VssBasicCredential('','yourPAT')
#$tfs=get-tfs -ServerURL https://xxx.visualstudio.com/DefaultCollection -Credentials $cred
$tfs=get-tfs -ServerURL https://Your_VSTS_Here.visualstudio.com/DefaultCollection -VSTSToken $token
$token=''
$tfs
 $tfs.ProjectCollection.HasAuthenticated
 $folderExists=test-path .\release
 if($folderExists -eq $False)
 {
	 mkdir release
 }
 else
 {
 Remove-Item -path .\release\ -Recurse
  mkdir release
 }

 $workitemInput=Read-Host 'Enter comma seperated list of workitem IDs'
 $workitems=$workitemInput -split ","

#generate changelog
Get-WorkItemChangesets -TFSCollection $tfs -WorkItemIDs $workitems -GetSubWorkItems |Sort-Object -Property CreationDate |Select-Object @{N='Date';E={$_.CreationDate}},@{N='ID';E={$_.ChangesetId}},@{N='Author';E={$_.CommitterDisplayName}},@{N='Description';E={$_.Comment}} |Format-List >.\release\changelog.txt

#generate list of files touched by workitems
Get-WorkItemFiles -TFSCollection $tfs -WorkItemIDs $workitems -GetSubWorkItems |Select-Object -Property ServerPath |Format-List >".\release\modified files.txt"

#get a list of files attached and generate a zip of those files
Get-WorkItemAttachments -TFSCollection $tfs -WorkItemIDs $workitems -GetSubWorkItems -ZipPath $zip

#open release folder
Invoke-Item  .\release
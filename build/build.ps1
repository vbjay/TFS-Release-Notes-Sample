$sourceNugetExe = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
#$sourceNugetExe = "https://dist.nuget.org/win-x86-commandline/v4.7.0/nuget.exe"

$pth=Split-Path -parent $PSScriptRoot


$targetNugetExe = $([System.IO.Path]::Combine($pth, 'build\nuget.exe'))
$proj=$([System.IO.Path]::Combine($pth, 'TFS-Release-Notes\TFS Release Notes\TFS Release Notes.vbproj'))
$slnDir=$([System.IO.Path]::Combine($pth, 'TFS-Release-Notes'))
$dbg=[System.IO.Path]::Combine($pth, "TFS-Release-Notes\TFS Release Notes\bin\Debug")
Remove-Item -path $dbg -Recurse

Invoke-WebRequest $sourceNugetExe -OutFile $targetNugetExe 
Set-Alias nuget $targetNugetExe -Scope Script -Verbose

nuget restore $proj "-SolutionDirectory" $slnDir

Import-Module -Name $([System.IO.Path]::Combine($pth, 'build\Invoke-MsBuild.psm1'))
$buildResult = Invoke-MsBuild -Path $proj 

if ($buildResult.BuildSucceeded -eq $true)
{
    Write-Output ("Build completed successfully in {0:N1} seconds." -f $buildResult.BuildDuration.TotalSeconds)
    $dest=$([System.IO.Path]::Combine($pth, 'build\output'))
    
    $folderExists=test-path $dest
    if($folderExists -eq $False)
    {
	     mkdir $dest
    }
    else
    {
        Remove-Item -path $dest -Recurse
        mkdir $dest
    }
    Copy-Item $($pth +"\*.ps1") $dest
       
    Copy-Item  $dbg $($dest +'\TFS-Release-Notes') -Exclude '.\release' -Recurse
    $gen=$dest +'\Change Request generator.ps1'
    (Get-Content $gen) |
    Foreach-Object {$_ -replace 'TFS Release Notes\\bin\\Debug',''}  | 
    Out-File $gen
    Invoke-Item $dest
}
elseif ($buildResult.BuildSucceeded -eq $false)
{
	Write-Output ("Build failed after {0:N1} seconds. Check the build log file '$($buildResult.BuildLogFilePath)' for errors." -f $buildResult.BuildDuration.TotalSeconds)
}
elseif ($buildResult.BuildSucceeded -eq $null)
{
	Write-Output "Unsure if build passed or failed: $($buildResult.Message)"
}
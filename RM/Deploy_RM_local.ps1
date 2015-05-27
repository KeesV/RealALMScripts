param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ApplicationPath,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $PSConfigurationPath,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $PSScriptPath
    )

#Validate parameters
if(!(Test-Path -Path $ApplicationPath))
{
    Write-Error ("Application path was not found [{0}]!
    " -f $ApplicationPath)
    exit 1
}

$PSConfigurationPathFull = Join-Path $ApplicationPath $PSConfigurationPath;
if(!(Test-Path -Path $PSConfigurationPathFull))
{
    Write-Error ("Configuration script was not found [{0}]!" -f $PSConfigurationPathFull)
    exit 1
}

$PSScriptPathFull = Join-Path $ApplicationPath $PSScriptPath
if(!(Test-Path -Path $PSScriptPathFull))
{
    Write-Error ("DSC script was not found [{0}]!" -f $PSScriptPathFull)
    exit 1
}

#make sure our WinRM configuration is correct
winrm quickconfig -quiet

#Execute the configuration script
. $PSConfigurationPathFull

#Execute the DSC configuration to generate a .mof file
. $PSScriptPathFull

#Find generated MOF files for this machine
$mofFiles = Get-ChildItem -Filter "$env:ComputerName.mof" -Recurse
Write-Verbose ("Found {0} configurations" -f $mofFiles.Count)

#execute them one by one
foreach($mofFile in $mofFiles)
{
    Write-Verbose ("Starting configuration {0}"-f $mofFile.FullName)
    Start-DscConfiguration -Path $mofFile.DirectoryName -Verbose -Wait
}

#clean up mof files
Write-Verbose "Cleaning up generated MOF files"
foreach($mofFile in $mofFiles)
{
    Remove-Item $mofFile.DirectoryName -Recurse -Force
}
Write-Verbose "Done."
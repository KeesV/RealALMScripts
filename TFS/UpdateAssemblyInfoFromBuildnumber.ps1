# Script to set the AssemblyVersion and AssemblyFileVersion in AssemblyInfo.cs files
# This can be used from a TFS build definition to keep build numer and Assembly versioning in sync
# This script was downloaded from http://www.4tecture.ch/blog/assembly-versioning-during-build-with-powershell

Param(    
	[int]$digitsSetInAssemblyVersion = 4
) 

function Set-AssemblyVersionNumbers([string]$buildNumber, [string]$pathToSearch, [int]$numberOfDigitsToSetInAssemlbyVersion = 2)
{
	[string]$searchFilter = "AssemblyInfo.*"
	[regex]$pattern = "\d+\.\d+\.\d+\.\d+"

	if ($buildNumber -match $pattern -ne $true) 
	{    
		Write-Host "Could not extract a version from [$buildNumber] using pattern [$pattern]"
	} 
	else 
	{
		$extractedBuildNumber = $Matches[0]    
		Write-Host "Using version $extractedBuildNumber"     

		$buildNumberTokens = $extractedBuildNumber.Split('.')
		$assemblyVersionThirdDigit = if($numberOfDigitsToSetInAssemlbyVersion -gt 2){ $buildNumberTokens[2]} else {"0"}
		$assemblyVersionForthDigit = if($numberOfDigitsToSetInAssemlbyVersion -gt 3){ $buildNumberTokens[3]} else {"0"}

		$buildNumberAssemblyVersion = [string]::Format("{0}.{1}.{2}.{3}",$buildNumberTokens[0],$buildNumberTokens[1], $assemblyVersionThirdDigit, $assemblyVersionForthDigit)
		$buildNumberAssemblyFileVersion = [string]::Format("{0}.{1}.{2}.{3}",$buildNumberTokens[0],$buildNumberTokens[1],$buildNumberTokens[2], $buildNumberTokens[3])
		[regex]$patternAssemblyVersion = "(AssemblyVersion\("")(\d+\.\d+\.\d+\.\d+)(""\))"
		$replacePatternAssemblyVersion = "`${1}$($buildNumberAssemblyVersion)`$3"
		[regex]$patternAssemblyFileVersion = "(AssemblyFileVersion\("")(\d+\.\d+\.\d+\.\d+)(""\))"
		$replacePatternAssemblyFileVersion = "`${1}$($buildNumberAssemblyFileVersion)`$3"

		gci -Path $pathToSearch -Filter $searchFilter -Recurse | %{        
			Write-Host "  -> Changing $($_.FullName)"                 
			# remove the read-only bit on the file        
			sp $_.FullName IsReadOnly $false         
			# run the regex replace        
			(gc $_.FullName) | % { $_ -replace $patternAssemblyVersion, $replacePatternAssemblyVersion } | sc $_.FullName    
			(gc $_.FullName) | % { $_ -replace $patternAssemblyFileVersion, $replacePatternAssemblyFileVersion } | sc $_.FullName
		}     
		Write-Host "Done!"
	}
}

Set-AssemblyVersionNumbers $env:TF_BUILD_BUILDNUMBER $env:TF_BUILD_SOURCESDIRECTORY $digitsSetInAssemblyVersion
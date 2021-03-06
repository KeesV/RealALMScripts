﻿#This script sets a specific field to a specified value for all work items in a specific project

Function LoadTfsAssemblies() {
    Add-Type –AssemblyName "Microsoft.TeamFoundation.Client, Version=12.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
    Add-Type -AssemblyName "Microsoft.TeamFoundation.WorkItemTracking.Client, Version=12.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
    
}

##### SETTINGS
#The TFS Team Project Collection to connect to
$tfsUri = "http://tfsserver:8080/tfs/DefaultCollection"

#The TFS Team Project from which to select the work items
$tfsProject = "Test Project"

#The work item type of the work items to update
$wiType = "Test Case"

#The reference name of the field to update
$wiFieldRefName = "Microsoft.VSTS.Common.Priority"

#The value to set the field to
$wiFieldNewValue = "1"
##### END SETTINGS

LoadTfsAssemblies
$tfs = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($tfsUri)
$tfs.EnsureAuthenticated()
if($tfs.HasAuthenticated)
{
    Write-Output "Successfully authenticated to TFS server [$tfsUri]"
    $workItemStore = $tfs.GetService([Microsoft.TeamFoundation.WorkItemTracking.Client.WorkItemStore])
    $query = "SELECT [System.Id], [System.Title] FROM WorkItems WHERE [System.TeamProject] = '{0}'  AND  [System.WorkItemType] = '{1}'" -f $tfsProject, $wiType
    Write-Output("Using query [$query]")

    $workItems = $workItemStore.Query($query)
	Write-Output("Going to update [{0}] work items" -f $workItems.Count)
	$successCount = 0
	$failureCount = 0
    ForEach($wi in $workItems) {
        Write-Output("Updating work item [{0}]" -f $wi.Title)
        
        try {
            $wi.Open()
            $wi.Fields[$wiFieldRefName].Value = $wiFieldNewValue
            Write-Output("Set field [{0}] to [{1}]" -f $wiFieldRefName, $wiFieldNewValue)
            $validationMessages = $wi.Validate()
        
            if($wi.IsValid() -eq $true)
            {
                $wi.Save()
                Write-Output("Successfully updated work item [{0}]" -f $wi.Title)
				$successCount++
            } else {
                Write-Error("Work item is not valid!")
                ForEach($validationMessage in $validationMessages)
                {
                    Write-Error("Error: {0}" -f $validationMessage)
                }
				$failureCount++
            }
        } catch  {
            Write-Error("Couldn't set field [{0}] to [{1}] for work item [{2}]" -f $wiFieldRefName,$wiFieldNewValue,$wi.Title)
            Write-Error $_
			$failureCount++
        }
    }
	
	Write-Output("Finished!")
	Write-Output("Successfully updated: {0}" -f $successCount)
	Write-Output("Failed to update: {0}" -f $failureCount)
	
} else {
    Write-Error("Couldn't authenticate to TFS server [$tfsUri]")
}
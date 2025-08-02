Function Invoke-NerdioMEWorkspaceAssign {
  <#
  .SYNOPSIS
  Assigns a workspace to a user in Nerdio Manager for Enterprise.
  .DESCRIPTION
  This function assigns a specified workspace to a user in Nerdio Manager for Enterprise.
  .PARAMETER WorkspaceName
  Specifies the name of the workspace to assign.
  .PARAMETER SubscriptionId
  Specifies the ID of the subscription where the workspace is located.
  .PARAMETER ResourceGroupName
  Specifies the name of the resource group where the workspace is located.
  .EXAMPLE
  Invoke-NerdioMEWorkspaceAssign -WorkspaceName "MyWorkspace" -SubscriptionId "MySubscriptionId" -ResourceGroupName "MyResourceGroupName"
  #>
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $true)]
    [string]$WorkspaceName,
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName

  )
  begin {
    Write-Verbose "Assigning workspace to user in Nerdio Manager for Enterprise..."
    Get-TokenValidity
  }
  Process {
    $body = @{
      workspaceName = $WorkspaceName
      subscriptionId = $SubscriptionId
      resourceGroupName = $ResourceGroupName
    } | ConvertTo-Json -Depth 10

    try {
      $response = Invoke-RestMethod -Method Post `
        -Uri "$script:NMEBaseurl/api/arm/workspace/assign" `
        -Headers $script:NMEAuthheader `
        -Body $body `
        -ContentType "application/json"
      Write-Verbose "Workspace assigned successfully."

    }
    catch {
      Throw "Failed to assign workspace: $_"
    }
  }
  end {
    Write-Verbose "Workspace assignment process completed."
    return $response
  }
}
Function Remove-NerdioMELinkedResourceGroup {
  <#
  .SYNOPSIS
  Removes a linked resource group in Nerdio Manager for Enterprise.
  .DESCRIPTION
  This function removes a linked resource group associated with the Nerdio Manager for Enterprise.
  .PARAMETER SubscriptionId
  Specifies the ID of the subscription where the linked resource group is located.
  .PARAMETER ResourceGroupName
  Specifies the name of the resource group to be removed.
  .EXAMPLE
  Remove-NerdioMELinkedResourceGroup -SubscriptionId "MySubscriptionId" -ResourceGroupName "MyResourceGroupName"
  Removes the specified linked resource group in the given subscription.
  .NOTES
  #>

  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName
  )

  begin {
    Write-Verbose "Removing linked resource group in Nerdio Manager for Enterprise..."
    Get-TokenValidity
  }

  Process {
    try {
      $Response = Invoke-RestMethod -Method Delete `
        -Uri "$script:NMEBaseurl/api/$Script:NMEApiVersion/resourcegroup/$($SubscriptionId)/$($ResourceGroupName)/linked" `
        -Headers $Script:NMEAuthheader
      Write-Verbose "Linked resource group removed successfully."
    }
    catch {
      Throw "Failed to remove linked resource group: $_"
    }
  }
}
Function New-NerdioMELinkedResourceGroup {
  <#
  .SYNOPSIS
  Creates a new linked resource group in Nerdio Manager for Enterprise.
  .DESCRIPTION
  This function creates a new linked resource group associated with the Nerdio Manager for Enterprise.
  .PARAMETER SubscriptionId
  Specifies the ID of the subscription where the linked resource group will be created.
  .PARAMETER ResourceGroupName
  Specifies the name of the resource group where the linked resource group will be created.
  .EXAMPLE
  New-NerdioMELinkedResourceGroup -SubscriptionId "MySubscriptionId" -ResourceGroupName "MyResourceGroupName"
  Creates a new linked resource group in the specified subscription and resource group.
  .NOTES
  #>

  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $false)]
    [bool]$IsDefault = $false
  )

  begin {
    Write-Verbose "Creating new linked resource group in Nerdio Manager for Enterprise..."
    Get-TokenValidity
  }

  Process {

    $body = @{
      isDefault = $IsDefault
    } | ConvertTo-Json

    try {
      $response = Invoke-RestMethod -Method Post `
        -Uri "$script:NMEBaseurl/api/$Script:NMEApiVersion/resourcegroup/$($SubscriptionId)/$($ResourceGroupName)/linked" `
        -Headers $Script:NMEAuthheader `
        -Body $body `
        -ContentType "application/json"
    }
    catch {
      Throw "Failed to link resource group: $_"
    }

  }
  End {
    write-Verbose "Linked resource group created successfully."
    Return $response.job
  }
}
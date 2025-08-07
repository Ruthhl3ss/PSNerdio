Function New-NerdioMELinkedNetwork {
  <#
  .SYNOPSIS
  Creates a new linked Network in Nerdio Manager for Enterprise.
  .DESCRIPTION
  This function creates a new linked Network associated with the Nerdio Manager for Enterprise.
  .PARAMETER SubscriptionId
  Specifies the ID of the subscription where the linked Network will be created.
  .PARAMETER ResourceGroupName
  Specifies the name of the resource group where the linked Network will be created.
  .EXAMPLE
  New-NerdioMELinkedNetwork -SubscriptionId "MySubscriptionId" -ResourceGroupName "MyResourceGroupName" `
    -VNetname "MyVNet" -SubnetName "MySubnet" -IsDefault $true
  Creates a new linked Network in the specified subscription and resource group with the specified virtual network and subnet name. The IsDefault parameter indicates whether this linked Network should be set as the default.
  .NOTES
  #>

  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$VNetname,
    [Parameter(Mandatory = $true)]
    [string]$SubnetName,
    [Parameter(Mandatory = $false)]
    [bool]$IsDefault = $false
  )

  begin {
    Write-Verbose "Creating new linked Network in Nerdio Manager for Enterprise..."
    Get-TokenValidity
  }

  Process {

    $body = @{
      Networkname       = $VNetname
      subnetName        = $SubnetName
      subscriptionId    = $SubscriptionId
      resourceGroupName = $ResourceGroupName
      isDefault         = $IsDefault
    } | ConvertTo-Json

    Write-Verbose "Request body for linked Network creation: $body"

    try {
      $response = Invoke-RestMethod -Method Post `
        -Uri "$script:NMEBaseurl/api/$Script:NMEApiVersion/networks" `
        -Headers $Script:NMEAuthheader `
        -Body $body `
        -ContentType "application/json"
    }
    catch {
      Throw "Failed to link network: $_"
    }

  }
  End {
    write-Verbose "Linked network created successfully."
    Return $response.job
  }
}
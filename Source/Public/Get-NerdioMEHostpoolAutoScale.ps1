function Get-NerdioMEHostpoolAutoScale {
  <#
  .SYNOPSIS
    Retrieves the auto-scaling settings of a specific Nerdio Managed Environment (NME) host pool.
  .DESCRIPTION
    The Get-NerdioMEHostpoolAutoScale cmdlet fetches information about the auto-scaling settings of a specified host pool within a Nerdio Managed Environment (NME).
    It requires the host pool name, resource group name, and subscription ID as parameters.
  .PARAMETER Name
    The name of the host pool to retrieve.
  .PARAMETER ResourceGroupName
    The name of the resource group where the host pool is located.
  .PARAMETER SubscriptionId
    The subscription ID associated with the Nerdio Managed Environment.
  .EXAMPLES
    Get-NerdioMEHostpoolAutoScale -Name "MyHostPool" -ResourceGroupName "MyResourceGroup" -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    Retrieves the auto-scaling settings of the host pool named "MyHostPool" in the specified resource group and subscription.
  .NOTES
    Author: Niels Kok
    Date: September 2025
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, HelpMessage = "Enter the name of the host pool.")][string]$Name,
    [Parameter(Mandatory = $true, HelpMessage = "Enter the resource group name.")][string]$ResourceGroupName,
    [Parameter(Mandatory = $true, HelpMessage = "Enter the subscription ID.")][string]$SubscriptionId
  )
  begin {
    Write-Verbose "Starting Get-NerdioMEHostpool for host pool: $Name in resource group: $ResourceGroupName under subscription: $SubscriptionId"
    Get-TokenValidity
  }
  process {

    $uri = "$script:NMEBaseurl/api/$Script:NMEApiVersion/arm/hostpool/$subscriptionId/$ResourceGroupName/$Name/auto-scale"
    Write-Verbose "Constructed URI: $uri"

    try {
      $Hostpool = Invoke-RestMethod -Method GET -Uri $uri -Headers $script:NMEAuthheader
      Write-Verbose "Successfully retrieved host pool details."

    }
    catch {
      Write-Error "Error retrieving host pool: $_"
    }
  }
  end {

    return $Hostpool

  }
}
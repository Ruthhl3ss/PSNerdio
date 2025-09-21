function Remove-NerdioMEHostpool {
  <#
  .SYNOPSIS
    Removes a specific Nerdio Managed Environment (NME) host pool.
  .DESCRIPTION
    The Remove-NerdioMEHostpool cmdlet removes a specified host pool within a Nerdio Managed Environment (NME).
    It requires the host pool name, resource group name, and subscription ID as parameters.
  .PARAMETER Name
    The name of the host pool to remove.
  .PARAMETER ResourceGroupName
    The name of the resource group where the host pool is located.
  .PARAMETER SubscriptionId
    The subscription ID associated with the Nerdio Managed Environment.
  .EXAMPLES
    Remove-NerdioMEHostpool -Name "MyHostPool" -ResourceGroupName "MyResourceGroup" -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    Removes the host pool named "MyHostPool" in the specified resource group and subscription.
  .NOTES
    Author: Niels Kok
    Date: August 2025
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, HelpMessage = "Enter the name of the host pool.")][string]$Name,
    [Parameter(Mandatory = $true, HelpMessage = "Enter the resource group name.")][string]$ResourceGroupName,
    [Parameter(Mandatory = $true, HelpMessage = "Enter the subscription ID.")][string]$SubscriptionId
  )
  begin {
    Write-Verbose "Starting Remove-NerdioMEHostpool for host pool: $Name in resource group: $ResourceGroupName under subscription: $SubscriptionId"
    Get-TokenValidity
  }
  process {

    $uri = "$script:NMEBaseurl/api/$Script:NMEApiVersion/arm/hostpool/$subscriptionId/$ResourceGroupName/$Name"
    Write-Verbose "Constructed URI: $uri"

    try {
      $Hostpool = Invoke-RestMethod -Method Delete -Uri $uri -Headers $script:NMEAuthheader
      Write-Verbose "Successfully removed host pool."

    }
    catch {
      Write-Error "Error removing host pool: $_"
    }
  }
  end {

    return $Hostpool

  }
}
function Invoke-NerdioMEHostpoolAutoScaleConvert {
  <#
    .SYNOPSIS
    Converts the auto-scaling settings of a specified host pool to a different format or structure.

    .DESCRIPTION
    The Invoke-NerdioMEHostpoolAutoScaleConvert cmdlet converts a static hostpool to a dynamic scaling hostpool within a Nerdio Managed Environment (NME).

    .PARAMETER Name
    The name of the host pool whose auto-scaling settings you want to convert.

    .PARAMETER ResourceGroupName
    The name of the resource group that contains the host pool.

    .PARAMETER SubscriptionId
    The subscription ID associated with the host pool.

    .EXAMPLE
    PS C:\> Invoke-NerdioMEHostpoolAutoScaleConvert -Name "MyHostPool" -ResourceGroupName "MyResourceGroup" -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    Converts the auto-scaling settings of the host pool named "MyHostPool" in the specified resource group and subscription.

    .NOTES
    Author: Niels Kok
    Date: September 2025
    #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, HelpMessage = "Enter the name of the host pool.")]
    [string]$Name,
    [Parameter(Mandatory = $true, HelpMessage = "Enter the resource group name.")]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true, HelpMessage = "Enter the subscription ID.")]
    [string]$SubscriptionId
  )
  begin {
    Write-Verbose "Starting Invoke-NerdioMEHostpoolAutoScaleConvert for host pool: $Name in resource group: $ResourceGroupName under subscription: $SubscriptionId"
    Get-TokenValidity
  }
  process {

    $uri = "$script:NMEBaseurl/api/$Script:NMEApiVersion/arm/hostpool/$subscriptionId/$ResourceGroupName/$Name/auto-scale"

    write-Verbose "Constructed URI: $uri"

    try {
      $HostpoolAutoScale = Invoke-RestMethod -Method Post -Uri $uri -Headers $script:NMEAuthheader -ContentType "application/json"
      Write-Verbose "Successfully converted hostpool to dynamic scaling."
    }

    catch {
      Write-Error "Error retrieving or converting host pool auto scale settings: $_"
    }

  }
  end {

    return $HostpoolAutoScale

  }

}
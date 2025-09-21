function Set-NerdioMEHostpoolAutoScale {
  <#
  .SYNOPSIS
    Assign an Auto Scale Profile to a Hostpool in Nerdio Manager for Enterprise.
  .DESCRIPTION
    The Set-NerdioMEHostpoolAutoScale cmdlet allows you to assign an existing auto scale profile to a specified hostpool within Nerdio Manager for Enterprise (NME).
    It requires the hostpool name, resource group name, subscription ID, and the auto scale profile name as parameters.
  .PARAMETER HostpoolName
    The name of the hostpool to which the auto scale profile will be assigned.
  .PARAMETER ResourceGroupName
    The name of the resource group where the hostpool is located.
  .PARAMETER SubscriptionId
    The ID of the subscription containing the hostpool.
  .PARAMETER AutoScaleProfileName
    The name of the auto scale profile to assign to the hostpool.
  .EXAMPLES
    Set-NerdioMEHostpoolAutoScale -HostpoolName "MyHostpool" -ResourceGroupName "MyResourceGroup" -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" -AutoScaleProfileName "MyAutoScaleProfile"
    Assigns the auto scale profile named "MyAutoScaleProfile" to the hostpool "MyHostpool" in the specified resource group and subscription.
  .NOTES
    Author: Niels Kok
    Date: September 2025
  #>

  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, HelpMessage = "Specify the name of the Hostpool to configure Auto Scale.")]
    [string]$HostpoolName,
    [Parameter(Mandatory = $true, HelpMessage = "Specify the name of the Resource Group.")]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true, HelpMessage = "Specify the id of the Subscription.")]
    [string]$SubscriptionId,
    [Parameter(Mandatory = $true, HelpMessage = "Specify the name of the Auto Scale Profile.")]
    [string]$AutoScaleProfileName
  )

  begin {
    Write-Verbose "Starting Set-NerdioMEHostpoolAutoScale"
    Get-TokenValidity

    $AutoScaleProfile = Get-NerdioMEAutoScaleProfile -Name $AutoScaleProfileName
    if (-not $AutoScaleProfile) {
      Throw "Auto Scale Profile '$AutoScaleProfileName' not found. Please create it first."
    }
    else {
      Write-Verbose "Auto Scale Profile '$AutoScaleProfileName' found."
    }

  }
  process {

    $uri = "$script:NMEBaseurl/api/$Script:NMEApiVersion/auto-scale-profile/$($AutoScaleProfile.id)/assignments"

    $body = [pscustomobject]@{
      hostPoolId = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.DesktopVirtualization/hostPools/$HostpoolName"
      Type       = "Primary"
      schedule   = $null
    } | ConvertTo-Json -Depth 10

    try {
      Invoke-RestMethod -Method Post -Uri $uri -Headers $script:NMEAuthheader -Body $body -ContentType "application/json"
      Write-Verbose "Successfully assigned Auto Scale Profile '$AutoScaleProfileName' to Hostpool '$HostpoolName'."
    }
    catch {
      Throw "Error assigning Auto Scale Profile to Hostpool: $_"
    }

  }
  End {
    Write-Verbose "Completed Set-NerdioMEHostpoolAutoScale"
  }

}
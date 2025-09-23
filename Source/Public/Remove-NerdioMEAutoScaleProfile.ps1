Function Remove-NerdioMEAutoScaleProfile {
  <#
  .SYNOPSIS
    Removes a specified Nerdio Managed Environment (NME) auto scale profile.
  .DESCRIPTION
    The Remove-NerdioMEAutoScaleProfile cmdlet deletes a specified auto scale profile from a Nerdio Managed Environment (NME).
    It requires the name of the auto scale profile to be removed as a parameter.
  .PARAMETER Name
    The name of the auto scale profile to remove.
  .EXAMPLES
    Remove-NerdioMEAutoScaleProfile -Name "MyAutoScaleProfile"
    Deletes the auto scale profile named "MyAutoScaleProfile".
  .NOTES
    Author: Niels Kok
    Date: September 2025
  #>
  [CmdletBinding()]
  param (
      [Parameter(Mandatory = $true, HelpMessage = "Specify the name of the Auto Scale Profile to remove.")]
      [string]$Name
  )
  begin {
    Write-Verbose "Starting Remove-NerdioMEAutoScaleProfile"
    Get-TokenValidity

    $AutoScaleProfile = Get-NerdioMEAutoScaleProfile -Name $Name
    if (-not $AutoScaleProfile) {
      Throw "Auto Scale Profile '$Name' not found. Please check the name and try again."
    }
    else {
      Write-Verbose "Auto Scale Profile '$Name' found with ID: $($AutoScaleProfile.id)"
    }

    $uri = "$script:NMEBaseurl/api/$Script:NMEApiVersion/auto-scale-profile/$($AutoScaleProfile.id)"
  }
  process {

    Write-Verbose "Removing Auto Scale Profile '$Name' using API call to: $uri"

    try {
      Invoke-RestMethod -Method Delete -Uri $uri -Headers $script:NMEAuthheader
      Write-Verbose "Successfully removed Auto Scale Profile '$Name'."
    }
    catch {
      Throw "Error removing Auto Scale Profile: $_"
    }
  }

  End {

  }
}
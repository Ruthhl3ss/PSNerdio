function Get-NerdioMEAutoScaleProfile {
  <#
  .SYNOPSIS
    Retrieves details of a specific Nerdio Managed Environment (NME) auto scale profile.
  .DESCRIPTION
    The Get-NerdioMEAutoScaleProfile cmdlet fetches information about a specified auto scale profile within a Nerdio Managed Environment (NME).
    It requires the auto scale profile name as a parameter.
  .PARAMETER Name
    The name of the auto scale profile to retrieve.
  .EXAMPLES
    Get-NerdioMEAutoScaleProfile -Name "MyAutoScaleProfile"
    Retrieves details of the auto scale profile named "MyAutoScaleProfile".
  .NOTES
    .NOTES
    Author: Niels Kok
    Date: September 2025
  #>
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $false)]
    [string]$Name
  )

  begin {
    Write-Verbose "Retrieving Auto Scale Profiles for Nerdio Manager for Enterprise..."
    Get-TokenValidity
  }

  Process {

    try {
      $response = Invoke-RestMethod -Method Get `
        -Uri "$script:NMEBaseurl/api/$Script:NMEApiVersion/auto-scale-profile" `
        -Headers $script:NMEAuthheader
    }
    catch {
      Throw "Failed to retrieve auto scale profiles: $_"
    }

    If ($Name) {
      Write-Verbose "Name parameter specified: $Name"
      $autoScaleProfile = $response | Where-Object { $_.name -eq $Name }
      return $autoScaleProfile
    }
    else {
      Write-Verbose "No Name parameter specified, returning all auto scale profiles."
      return $response
    }

  }
}
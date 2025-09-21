function Get-NerdioMEADConfig {
  <#
  .SYNOPSIS
    Retrieves the Active Directory configuration for Nerdio Managed Environment (NME).
  .DESCRIPTION
    The Get-NerdioMEADConfig cmdlet fetches information about the Active Directory configuration of the Nerdio Managed Environment (NME).
    It does not require any parameters.
  .EXAMPLES
    Get-NerdioMEADConfig
    Retrieves the Active Directory configuration for the Nerdio Managed Environment.
  .NOTES
    .NOTES
    Author: Niels Kok
    Date: September 2025
  #>
  [CmdletBinding()]
  param ()
  begin {
    Write-Verbose "Starting Get-NerdioMEADConfig"
    Get-TokenValidity
  }
  process {

    $uri = "$script:NMEBaseurl/api/$Script:NMEApiVersion/ad/config"
    Write-Verbose "Constructed URI: $uri"

    try {
      $ADConfig = Invoke-RestMethod -Method GET -Uri $uri -Headers $script:NMEAuthheader
      Write-Verbose "Successfully retrieved AD configuration details."

    }
    catch {
      Write-Error "Error retrieving AD configuration: $_"
    }
  }
  end {

    return $ADConfig

  }
}
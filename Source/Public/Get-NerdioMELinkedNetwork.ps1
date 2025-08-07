Function Get-NerdioMELinkedNetwork {
  <#
  .SYNOPSIS
  Retrieves the linked Network for Nerdio Manager for Enterprise.
  .DESCRIPTION
  This function retrieves the linked Network associated with the Nerdio Manager for Enterprise.
  .PARAMETER Name
  Specifies the name of the subnet of the linked Network to retrieve. If not specified, all linked Networks will be returned.
  .EXAMPLE
  Get-NerdioMELinkedNetwork
  Retrieves the linked Network for Nerdio Manager for Enterprise.

  Get-NerdioMELinkedNetwork -Name "subnet-name"
  Retrieves the linked Network for Nerdio Manager for Enterprise with the specified subnet name.
  .NOTES
  #>

  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $false)]
    [string]$Name
  )

  begin {
    Write-Verbose "Retrieving linked Networks for Nerdio Manager for Enterprise..."
    Get-TokenValidity
  }

  Process {


    try {
      $response = Invoke-RestMethod -Method Get `
        -Uri "$script:NMEBaseurl/api/$Script:NMEApiVersion/networks" `
        -Headers $script:NMEAuthheader
    }
    catch {
      Throw "Failed to retrieve linked network: $_"
    }

    If ($Name) {
      Write-Verbose "Name parameter specified: $Name"
      $linkedNetwork = $response | Where-Object { $_.subnet -eq $Name }
      return $linkedNetwork
    }
    else {
      Write-Verbose "No Name parameter specified, returning all linked networks."
      return $response
    }

  }
}
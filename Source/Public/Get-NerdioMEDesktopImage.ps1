Function Get-NerdioMEDesktopImage {
  <#
    .SYNOPSIS
    Retrieves the desktop images for a specified Nerdio Manager for Enterprise.

    .DESCRIPTION
    This function fetches the desktop images associated with a given Nerdio Manager for Enterprise.

    .EXAMPLE
    Get-NerdioMEDesktopImage

    Retrieves the desktop image for the specified tenant.
    #>

  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $false)]
    [string]$Name
  )

  begin {

    Write-Verbose "Checking token validity for Nerdio Manager for Enterprise..."
    Get-TokenValidity
  }

  Process {
    Write-Verbose "Retrieving Desktop Image details for Nerdio Manager for Enterprise..."
    try {
      $response = Invoke-RestMethod -Method Get `
        -Uri "$script:NMEBaseurl/api/$Script:NMEApiVersion/desktop-image" `
        -Headers @{ "Authorization" = "Bearer $script:NMEAuthtoken" }
    }
    catch {
      Throw "Failed to retrieve desktop image details: $_"
    }

    If ($Name) {
      Write-Verbose "Name parameter specified: $Name"
      $desktopImage = $response | Where-Object { $_.name -eq $Name }
      return $desktopImage
    }
    else {
      Write-Verbose "No Name parameter specified, returning all desktop images."
      return $response
    }
  }
}
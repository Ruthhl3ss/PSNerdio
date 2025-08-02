Function Get-NerdioMELinkedResourceGroup {
  <#
  .SYNOPSIS
  Retrieves the linked resource group for Nerdio Manager for Enterprise.
  .DESCRIPTION
  This function retrieves the linked resource group associated with the Nerdio Manager for Enterprise.
  .PARAMETER Name
  Specifies the name of the linked resource group to retrieve. If not specified, all linked resource groups will be returned.
  .EXAMPLE
  Get-NerdioMELinkedResourceGroup
  Retrieves the linked resource group for Nerdio Manager for Enterprise.
  .NOTES
  #>

  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $false)]
    [string]$Name
  )

  begin {
    Write-Verbose "Retrieving linked resource group for Nerdio Manager for Enterprise..."
    Get-TokenValidity
  }

  Process {


    try {
      $response = Invoke-RestMethod -Method Get `
        -Uri "$script:NMEBaseurl/api/$Script:NMEApiVersion/resourcegroup" `
        -Headers @{ "Authorization" = "Bearer $script:NMEAuthtoken" }
    }
    catch {
      Throw "Failed to retrieve linked resource group: $_"
    }

    If ($Name) {
      Write-Verbose "Name parameter specified: $Name"
      $linkedResourceGroup = $response | Where-Object { $_.name -eq $Name }
      return $linkedResourceGroup
    }
    else {
      Write-Verbose "No Name parameter specified, returning all linked resource groups."
      return $response
    }

  }
}
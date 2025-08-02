Function Get-NerdioMEWorkspace {
  <#
  .SYNOPSIS
  Retrieves the workspace details for Nerdio Manager for Enterprise.
  .DESCRIPTION
  This function retrieves the workspace details associated with the Nerdio Manager for Enterprise.
  .PARAMETER Name
  Specifies the name of the workspace to retrieve. If not specified, all workspaces will be returned.
  .EXAMPLE
  Get-NerdioMEWorkspace
  Retrieves all workspaces for Nerdio Manager for Enterprise.
  .NOTES
  #>

  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $false)]
    [string]$Name
  )

  begin {
    Write-Verbose "Retrieving workspace details for Nerdio Manager for Enterprise..."
    Get-TokenValidity
  }

  Process {
    try {
      $response = Invoke-RestMethod -Method Get `
        -Uri "$script:NMEBaseurl/api/$Script:NMEApiVersion/workspace" `
        -Headers @{ "Authorization" = "Bearer $script:NMEAuthtoken" }
    }
    catch {
      Throw "Failed to retrieve workspace details: $_"
    }

    If ($Name) {
      Write-Verbose "Name parameter specified: $Name"
      $workspace = $response | Where-Object { $_.name -eq $Name }
      return $workspace
    }
    else {
      Write-Verbose "No Name parameter specified, returning all workspaces."
      return $response
    }
  }
}
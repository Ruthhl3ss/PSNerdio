Function Get-NerdioMEScriptedAction {
  <#
  .SYNOPSIS
  Retrieves a scripted action for Nerdio Manager for Enterprise.
  .DESCRIPTION
  This function retrieves the scripted action associated with the Nerdio Manager for Enterprise.
  .PARAMETER Name
  Specifies the name of the scripted action to retrieve. If not specified, all scripted actions will be returned.
  .EXAMPLE
  Get-NerdioMEScriptedAction -Name "TestModule"
  Retrieves a scripted action for Nerdio Manager for Enterprise.
  .NOTES
  #>

  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $false)]
    [string]$Name
  )

  begin {
    Write-Verbose "Retrieving scripted action for Nerdio Manager for Enterprise..."
    Get-TokenValidity
  }

  Process {


    try {
      $response = Invoke-RestMethod -Method Get `
        -Uri "$script:NMEBaseurl/api/$Script:NMEApiVersion/scripted-actions" `
        -Headers $script:NMEAuthheader
    }
    catch {
      Throw "Failed to retrieve scripted actions: $_"
    }

    If ($Name) {
      Write-Verbose "Name parameter specified: $Name"
      $scriptedAction = $response | Where-Object { $_.name -eq $Name }
      return $scriptedAction
    }
    else {
      Write-Verbose "No Name parameter specified, returning all scripted actions."
      return $response
    }

  }
}
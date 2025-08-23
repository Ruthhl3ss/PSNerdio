Function Invoke-NerdioMEScriptedActionUpdate {
  <#
  .SYNOPSIS
  Updates a scripted action for Nerdio Manager for Enterprise.
  .DESCRIPTION
  This function updates the specified scripted action associated with the Nerdio Manager for Enterprise.
  .PARAMETER Id
  Specifies the ID of the scripted action to update.
  .PARAMETER Name
  Specifies the new name of the scripted action.
  .PARAMETER Description
  Specifies the new description of the scripted action.
  .PARAMETER ScriptContent
  Specifies the new script content of the scripted action.
  .PARAMETER ExecutionTimeOut
  Specifies the new execution timeout of the scripted action.
  .EXAMPLE
  Invoke-NerdioMEScriptedActionUpdate -Id "48" -Name "Optimize Microsoft Edge for AVD" -Description "Optimizes Microsoft Edge settings for Azure Virtual Desktop." -ScriptPath "C:\Scripts\OptimizeEdge.ps1"
  Updates a scripted action for Nerdio Manager for Enterprise.
  .NOTES
  #>

  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $false)]
    [string]$Description = $null,

    [Parameter(Mandatory = $false)]
    [string]$ScriptPath = $null,

    [Parameter(Mandatory = $false)]
    [string]$ExecutionTimeOut = $null
  )

  begin {
    Write-Verbose "Updating scripted action for Nerdio Manager for Enterprise..."
    Get-TokenValidity

    $scriptedaction = Get-NerdioMEScriptedAction | Where-Object name -EQ $Name

    If ($ScriptPath) {
      Write-Verbose "Script path: $ScriptPath"

      Write-Verbose "Reading script content from file..."

      $Script = Get-Content -Path $ScriptPath -Raw
    }

  }

  Process {
    # Create a hashtable to hold the updated properties

    $Body = [PSCustomObject]@{
      jobPayload = [PSCustomObject]@{
        name                 = $Name
        script               = $Script
        executionMode        = $null
        executionEnvironment = $null
        executionTimeout     = $null
        tags                 = $null
        description          = $Description
      }
    }

    $body = $Body | ConvertTo-Json

    Write-Verbose "Updating Scripted action with ID $($scriptedaction.id) with body $body"

    $uri = "$script:NMEBaseurl/api/$script:NMEApiVersion/scripted-actions/$($scriptedaction.id)"

    Write-Verbose "Sending PATCH request to $uri"

    try {
      $response = Invoke-RestMethod -Uri $uri -Method Patch -Body $body -Headers $script:NMEAuthheader -ContentType "application/json"
    }
    catch {
      Throw "Couldn't update Nerdio Manager for Enterprise scripted action with ID $($scriptedaction.id). Error $_"
    }

  }
  End {
    return $response
  }
}
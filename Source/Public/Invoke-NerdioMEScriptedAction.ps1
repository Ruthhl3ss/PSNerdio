Function Invoke-NerdioMEScriptedAction {
  <#
    .SYNOPSIS
    Invokes a scripted action for Nerdio Manager for Enterprise.
    .DESCRIPTION
    This function invokes a scripted action associated with the Nerdio Manager for Enterprise. This cmdlet can only invoke Azure Automation runbooks.
    .PARAMETER Name
    Specifies the name of the scripted action to invoke.
    .EXAMPLE
    Invoke-NerdioMEScriptedAction -Name "TestModule"
    Invokes the specified scripted action for Nerdio Manager for Enterprise.
    .NOTES
  #>

  [CmdletBinding()]
  param (
      [Parameter(Mandatory = $true)]
      [string]$Name,
      [Parameter(Mandatory = $true)]
      [string]$SubscriptionId,
      [Parameter(Mandatory = $false)]
      [System.Object]$Parameters
  )

  begin {

    Get-TokenValidity

    $scriptedaction = Get-NerdioMEScriptedAction | Where-Object name -EQ $Name

    If ($scriptedaction.executionEnvironment -ne "AzureAutomation") {
      Throw "Scripted action '$Name' is not an Azure Automation runbook. Only Azure Automation runbooks can be invoked. To run a custom scripted action on an image, use the 'Invoke-NerdioMEDesktopImageScriptedAction' cmdlet."
    }
    else {
      Write-Verbose "Scripted action '$Name' found."
    }

  }

  Process {

    $body = @{
      subscriptionId = $SubscriptionId
      adConfigId = $null
      minutesToWait = 30
      paramsBindings = $null
    }

    if ($Parameters) {
      $body.paramsBindings = $Parameters
    }

    $body = $body | ConvertTo-Json -Depth 10

    Write-Verbose "Invoking scripted action '$Name' with body: $body"

    $uri = "$script:NMEBaseurl/api/$script:NMEApiVersion/scripted-actions/$($scriptedaction.id)/execution"

    Write-Verbose "Invoking scripted action '$Name' with ID $($scriptedaction.id) using URI: $uri"

    try {
      $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $script:NMEAuthheader -Body $body -ContentType "application/json"
      Write-Verbose "Scripted action '$Name' invoked successfully."
    }
    catch {
      Throw "Couldn't invoke Nerdio Manager for Enterprise scripted action with ID $($scriptedaction.id). Error $_"
    }


  }
  End {
    return $response
  }
}
Function Invoke-NerdioMEDesktopImageScriptedAction {
  <#
    .SYNOPSIS
    Invokes a scripted action for Nerdio Manager for Enterprise Desktop Images.
    .DESCRIPTION
    This function invokes a scripted action associated with the Nerdio Manager for Enterprise Desktop Images.
    .PARAMETER Name
    Specifies the name of the scripted action to invoke.
    .EXAMPLE
    Invoke-NerdioMEDesktopImageScriptedAction -Name "TestModule"
    Invokes the specified scripted action for Nerdio Manager for Enterprise Desktop Images.
    .NOTES
  #>

  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]$DesktopImageName,
    [Parameter(Mandatory = $true)]
    [string]$ScriptedActionName,
    [Parameter(Mandatory = $false)]
    [System.Object]$Parameters
  )

  begin {

    Get-TokenValidity

    $scriptedaction = Get-NerdioMEScriptedAction -Name $ScriptedActionName

    If ($scriptedaction.executionEnvironment -ne "CustomScript") {
      Throw "Scripted action '$ScriptedActionName' is not a CustomScript. Only CustomScripts can be invoked. To run a Azure Automation Scripted action, use the 'Invoke-NerdioMEScriptedAction' cmdlet."
    }
    else {
      Write-Verbose "Scripted action '$ScriptedActionName' found."
    }

    $desktopimage = Get-NerdioMEDesktopImage -Name $DesktopImageName

    if ($null -eq $desktopimage) {
      Throw "Desktop image '$DesktopImageName' not found."
    }
    else {
      Write-Verbose "Desktop image '$DesktopImageName' found. Setting variables."
      $SubscriptionId = $desktopimage.id -split "/" | Select-Object -Index 2
      $ResourceGroupName = $desktopimage.id -split "/" | Select-Object -Index 4
      $ImageName = $desktopimage.id -split "/" | Select-Object -Index 8
    }
  }

  Process {

    $body = @{
      scriptedActions = @(
        @{
          type   = "Action"
          id     = $scriptedaction.id
        }
      )
      restartVm = $false
    }

    if ($Parameters) {
      $body.scriptedActions.params = $Parameters
    }

    $body = $body | ConvertTo-Json -Depth 10

    Write-Verbose "Invoking scripted action '$ScriptedActionName' with body: $body"

    $uri = "$script:NMEBaseurl/api/$script:NMEApiVersion/desktop-image/$SubscriptionId/$ResourceGroupName/$ImageName/script"

    Write-Verbose "Invoking scripted action '$ScriptedActionName' with ID $($scriptedaction.id) using URI: $uri"

    try {
      $response = Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json" -Headers $script:NMEAuthheader
    }
    catch {
      throw "Unable to invoke scripted action '$ScriptedActionName': $_"
    }

  }

  End {

    return $Response

  }

}
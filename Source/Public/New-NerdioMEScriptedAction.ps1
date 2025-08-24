Function New-NerdioMEScriptedAction {
  <#
    .SYNOPSIS
    Creates a new scripted action for Nerdio Manager for Enterprise.
    .DESCRIPTION
    This function creates a new scripted action associated with the Nerdio Manager for Enterprise.
    .PARAMETER Name
    Specifies the name of the scripted action to create.
    .PARAMETER Description
    Specifies the description of the scripted action.
    .PARAMETER ScriptPath
    Specifies the path to the script file.
    .PARAMETER ExecutionMode
    Specifies the execution mode for the scripted action. Combined is a custom script extension and Individual is an Azure Automation runbook.
    .PARAMETER Tags
    Specifies the tags for the scripted action.
    .PARAMETER ExecutionTimeOut
    Specifies the execution timeout for the scripted action.
    .EXAMPLE
    New-NerdioMEScriptedAction -Name "TestModule" -ScriptPath "C:\Temp\Test.ps1"
    Creates a new scripted action for Nerdio Manager for Enterprise.
    .NOTES
    #>

  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $true, HelpMessage = "Enter the name of the scripted action.")]
    [string]$Name,

    [Parameter(Mandatory = $false, HelpMessage = "Enter a description for the scripted action.")]
    [string]$Description,

    [Parameter(Mandatory = $true, HelpMessage = "Enter the path to the script file.")]
    [string]$ScriptPath,

    [Parameter(Mandatory = $false, HelpMessage = "Select the execution mode. Combined is a custom script extension and Individual is an Azure Automation runbook.")]
    [ValidateSet("Combined", "Individual")]
    [string]$ExecutionMode = "Combined",

    [Parameter(Mandatory = $false, HelpMessage = "Enter tags for the scripted action.")]
    [string]$Tags,

    [Parameter(Mandatory = $false, HelpMessage = "Enter the execution timeout for the scripted action.")]
    [Int64]$ExecutionTimeOut = 0

  )

  begin {
    Write-Verbose "Creating new scripted action for Nerdio Manager for Enterprise..."
    Get-TokenValidity

    Write-Verbose "Script path: $ScriptPath"

    Write-Verbose "Reading script content from file..."

    $Script = Get-Content -Path $ScriptPath -Raw

    switch ($ExecutionMode) {
      "Combined" {
        Write-Verbose "Execution mode set to Combined."
        $ExecutionEnvironment = "CustomScript"
      }
      "Individual" {
        Write-Verbose "Execution mode set to Individual."
        $ExecutionEnvironment = "AzureAutomation"
      }
    }
  }

  Process {
    $body = @{
      name                 = $Name
      script               = $Script
      Executionmode        = $ExecutionMode
      Executionenvironment = $ExecutionEnvironment
      Executiontimeout     = $ExecutionTimeOut
    }

    If ($Tags) {
      $body.Tags = $Tags -split ","
    }

    Write-Verbose "Body content: $($body | ConvertTo-Json -Depth 10)"

    Write-Verbose "Sending request to create scripted action..."

    try {
      $response = Invoke-RestMethod -Method Post `
        -Uri "$script:NMEBaseurl/api/$Script:NMEApiVersion/scripted-actions" `
        -Headers $script:NMEAuthheader `
        -Body ($body | ConvertTo-Json) `
        -ContentType "application/json"
    }
    catch {
      Throw "Failed to create scripted action: $_"
    }

    return $response
  }

  end {
    Write-Verbose "Scripted action '$Name' created successfully."
  }
}
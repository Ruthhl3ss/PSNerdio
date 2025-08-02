Function New-NerdioMEWorkspace {
  <#
  .SYNOPSIS
  Creates a new workspace in Nerdio Manager for Enterprise.
  .DESCRIPTION
  This function creates a new workspace associated with the Nerdio Manager for Enterprise.
  .PARAMETER SubscriptionId
  Specifies the ID of the subscription where the workspace will be created.
  .PARAMETER ResourceGroupName
  Specifies the name of the resource group where the workspace will be created.
  .PARAMETER Name
  Specifies the name of the workspace to be created.
  .PARAMETER Location
  Specifies the Azure region where the workspace will be created.
  .PARAMETER FriendlyName
  Specifies a friendly name for the workspace.
  .PARAMETER Description
  Specifies a description for the workspace.
  .PARAMETER Tags
  Specifies tags to be associated with the workspace in the form of a hashtable.
  .EXAMPLE
  New-NerdioMEWorkspace -SubscriptionId "dd5a4399-3766-4520-9659-b6a98bf6ba8a" `
    -ResourceGroupName "rg-infra-avd-dev-vdpool" `
    -Name "TestWorkspace" `
    -Location "West Europe" `
    -FriendlyName "Test Workspace" `
    -Description "This is a test workspace for Nerdio Manager for Enterprise." `
    -Tags @{ Environment = "Test"; Owner = "Nerdio" }
  Creates a new workspace with the specified name in the given resource group.
  .NOTES
  #>

  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$Location,
    [Parameter(Mandatory = $false)]
    [string]$FriendlyName,
    [Parameter(Mandatory = $false)]
    [string]$Description,
    [Parameter(Mandatory = $false)]
    [hashtable]$Tags = @{}
  )

  begin {
    Write-Verbose "Creating new workspace in Nerdio Manager for Enterprise..."
    Get-TokenValidity
  }

  Process {
    $body = @{
      id = @{
        subscriptionId = $SubscriptionId
        resourceGroup = $ResourceGroupName
        name = $Name
      }
      location = $Location
    }

    if ($FriendlyName) {
      $body.friendlyName = $FriendlyName
    }
    if ($Description) {
      $body.description = $Description
    }
    if ($Tags) {
      $body.tags = $Tags
    }

    $body = $body | ConvertTo-Json -Depth 10

    try {
      $response = Invoke-RestMethod -Method Post `
        -Uri "$script:NMEBaseurl/api/$Script:NMEApiVersion/workspace" `
        -Headers $Script:NMEAuthheader `
        -Body $body `
        -ContentType "application/json"
      Write-Verbose "Workspace created successfully."
      return $response
    }
    catch {
      Throw "Failed to create workspace: $_"
    }
  }
}
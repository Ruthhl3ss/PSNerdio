Function New-NerdioMEHostpool {
  <#
  .SYNOPSIS
    Creates a new Nerdio Managed Environment (NME) host pool.
  .DESCRIPTION
    The New-NerdioMEHostpool cmdlet creates a new host pool within a Nerdio Managed Environment (NME).
    It requires the host pool name, resource group name, subscription ID, workspace details, and other optional parameters to define the host pool's configuration.
  .PARAMETER Name
    The name of the host pool to be created.
  .PARAMETER Description
    A description for the host pool.
  .PARAMETER ResourceGroupName
    The name of the resource group where the host pool will be created.
  .PARAMETER SubscriptionId
    The subscription ID associated with the Nerdio Managed Environment.
  .PARAMETER tags
    Tags to be applied to the host pool. This is an object that contains key-value pairs for tagging the host pool in Azure.
  .PARAMETER WorkspaceSubscriptionId
    The subscription ID where the workspace is located.
  .PARAMETER WorkspaceResourceGroupName
    The resource group name where the workspace is located.
  .PARAMETER WorkspaceName
    The name of the workspace where the host pool will be assigned.
  .PARAMETER Location
    The Azure region where the host pool will be created (e.g., "West Europe").
  .PARAMETER HostpoolType
    The type of host pool to create. Valid values are "Pooled" or "Personal". Default is "Pooled".
  .PARAMETER SingleUser
    Specifies whether the host pool is for single user or multi-user. Default is false (multi-user).
  .PARAMETER Desktop
    Specifies whether the host pool is for Desktops or Remote Apps. Default is true (Desktops).
  .PARAMETER AssignmentType
    Specifies the assignment type for personal host pools. Valid values are "Automatic" or "Direct". Default is "Automatic".
  .PARAMETER ApplicationGroupName
    The name of the application group where the host pool will be assigned.
  .EXAMPLE
    New-NerdioMEHostpool -Name "MyHostPool" -ResourceGroupName "MyResourceGroup" -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" `
      -WorkspaceSubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" -WorkspaceResourceGroupName "MyWorkspaceRG" -WorkspaceName "MyWorkspace" `
      -Location "West Europe" -HostpoolType "Pooled" -SingleUser $false -Desktop $true -ApplicationGroupName "MyAppGroup" `
      -Description "This is a test host pool." -tags @{ Environment = "Test"; Owner = "Nerdio" }
    Creates a new host pool named "MyHostPool" in the specified resource group and subscription, associated with the given workspace and application group. The host pool is configured as a pooled desktop host pool for multi-user access.
  .NOTES
    Author: Niels Kok
    Date: September 2025
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, HelpMessage = "Enter the name of the host pool.")]
    [string]$Name,

    [Parameter(Mandatory = $false, HelpMessage = "Enter the name of the host pool.")]
    [string]$Description = "Nerdio Managed Hostpool created by PSNerdio Module",

    [Parameter(Mandatory = $true, HelpMessage = "Enter the resource group name.")]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true, HelpMessage = "Enter the subscription ID where the host pool will be created.")]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $false, HelpMessage = "Tags to be applied to the desktop image. This is an object that contains key-value pairs for tagging the desktop image in Azure.")]
    [System.Object]$tags,

    [Parameter(Mandatory = $true, HelpMessage = "Enter the subscription ID where the workspace is located.")]
    [string]$WorkspaceSubscriptionId,

    [Parameter(Mandatory = $true, HelpMessage = "Enter the resource group name where the workspace is located.")]
    [string]$WorkspaceResourceGroupName,

    [Parameter(Mandatory = $true, HelpMessage = "Enter the name of the workspace where the host pool will be assigned.")]
    [string]$WorkspaceName,

    [Parameter(Mandatory = $true, HelpMessage = "Enter the Azure region where the host pool will be created (e.g., 'West Europe').")]
    [ValidateSet("Pooled", "Personal")]
    [string]$HostpoolType = "Pooled",

    [Parameter(Mandatory = $false, HelpMessage = "Specifies whether the host pool is for single user or multi-user. Default is false (multi-user).")]
    [bool]$SingleUser = $false,

    [Parameter(Mandatory = $false, HelpMessage = "Specifies whether the host pool is for Desktops or Remote Apps. Default is true (Desktops).")]
    [bool]$Desktop = $true,

    [Parameter(Mandatory = $false, HelpMessage = "Specifies the assignment type for personal host pools. Default is 'Automatic'.")]
    [string]$AssignmentType = "Automatic",


    [Parameter(Mandatory = $true, HelpMessage = "Enter the name of the application group where the host pool will be assigned.")]
    [string]$ApplicationGroupName

  )
  begin {
    Write-Verbose "Starting New-NerdioMEHostpool for host pool: $Name in resource group: $ResourceGroupName under subscription: $SubscriptionId at location: $Location"
    Get-TokenValidity
  }
  process {

    $uri = "$script:NMEBaseurl/api/$Script:NMEApiVersion/arm/hostpool/$subscriptionId/$ResourceGroupName/$Name"
    Write-Verbose "Constructed URI: $uri"

    $body = [PSCustomObject]@{
      workspaceId     = [PSCustomObject]@{
        subscriptionId = $WorkspaceSubscriptionId
        resourceGroup  = $WorkspaceResourceGroupName
        name           = $WorkspaceName
      }
      pooledParams    = @{}
      description     = $Description
      tags            = $tags
      activeDirectory = [PSCustomObject]@{
        adProfileId = 1
      }
      appGroupName    = $ApplicationGroupName
    }

    If ($HostpoolType -eq "Pooled") {
      $Body.pooledParams = [PSCustomObject]@{
        isDesktop    = $Desktop
        isSingleUser = $SingleUser
      }

    }
    ElseIf ($HostpoolType -eq "Personal") {
      $Body.personalParams = [PSCustomObject]@{
        assignmentType = $AssignmentType
      }
    }

    $jsonBody = $body | ConvertTo-Json -Depth 10
    Write-Verbose "Request Body: $jsonBody"

    try {
      $Hostpool = Invoke-RestMethod -Method POST -Uri $uri -Headers $script:NMEAuthheader -Body $jsonBody -ContentType "application/json"
      Write-Verbose "Successfully created host pool."
    }
    catch {
      Write-Error "Error creating host pool: $_"
    }

  }
  end {
    return $Hostpool
  }
}
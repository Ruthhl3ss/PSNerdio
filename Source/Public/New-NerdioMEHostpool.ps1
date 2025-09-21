Function New-NerdioMEHostpool {
  <#
  .SYNOPSIS
    Creates a new Nerdio Managed Environment (NME) host pool.
  .NOTES
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
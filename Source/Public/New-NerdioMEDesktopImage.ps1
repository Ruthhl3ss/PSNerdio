function New-NerdioMEDesktopImage {
  <#
  .SYNOPSIS
    Creates a new desktop image in Nerdio Manager for Enterprise.
  .DESCRIPTION
    This function creates a new desktop image associated with the Nerdio Manager for Enterprise.
  .PARAMETER Name
    The name of the desktop image to be created. This is a string that will be used to identify the desktop image in Nerdio Manager for Enterprise.
  .PARAMETER Description
    The description of the desktop image. This is a string that provides additional information about the desktop image.
  .PARAMETER ImageType
    The type of the desktop image to be created. This is a string that represents the type of desktop image, such as 'AzureComputeGallery' or 'Classic'.
  .PARAMETER ImageIdResourceGroupName
    The name of the resource group where the desktop image will be created. This is a string that represents the name of the resource group in Azure.
  .PARAMETER SubscriptionId
    Subscription Id for the managed resource group where the desktop image will be created. This is a string that represents the subscription ID in Azure.
  .PARAMETER SourceImageId
    The source image to be used for the desktop image. This is a string that represents the source image ID from the Azure Marketplace. Defaults to a Windows 11 24h2 image if not specified.
  .PARAMETER VmSize
    The size of the VM to be used for the desktop image. Defaults to Standard_D4s_v5 if not specified.
  .PARAMETER StorageType
    The type of storage to be used for the desktop image. Defaults to Premium_LRS if not specified.
  .PARAMETER DiskPerformanceTier
    The performance tier of the disk to be used for the desktop image. Defaults to P10 if not specified.
  .PARAMETER DiskSize
    The size of the disk to be used for the desktop image in GB. Defaults to 128 if not specified.
  .PARAMETER VNetResourceId
    The resourceid of the network that is linked to Nerdio. This is a string that represents the full resource id of the network in Azure.
  .PARAMETER SubnetName
    The name of the subnet that is linked to Nerdio
  .PARAMETER TimeZone
    The time zone to be set for the desktop image. Defaults to W. Europe Standard Time if not specified.
  .PARAMETER tags
    Tags to be applied to the desktop image. This is an object that contains key-value pairs for tagging the desktop image in Azure.
  .PARAMETER AdminUserName
    The name of the admin user to be created for the desktop image. Defaults to PSNerdioAdmin if not specified.
  .PARAMETER AdminPassword
    The password for the admin user to be created for the desktop image. Defaults to a secure password if not specified.
  .PARAMETER DisableAccount
    Indicates whether the admin account should be disabled. Defaults to false if not specified.
  .PARAMETER TimeZoneRedirection
    Indicates whether to enable time zone redirection for the desktop image. Defaults to true if not specified.
  .PARAMETER UninstallFSLogix
    Indicates whether to uninstall FSLogix for the desktop image. Defaults to true if not specified.
  .PARAMETER SkipRemoveProfiles
    Indicates whether to skip the removal of user profiles during the creation of the desktop image. Defaults to false if not specified.
  .PARAMETER NoImageObjectRequired
    Indicates whether to build a managed image for the desktop image. Defaults to false if not specified.
  .PARAMETER EnableAppvClientService
    Indicates whether to enable the AppV services for the desktop image. Defaults to false if not specified.
  .PARAMETER FailurePolicyRestart
    The failure policy for the desktop image creation. Defaults to restarting the job if not specified.
  .PARAMETER FailurePolicyCleanup
    Indicates whether to clean up resources in case of a failure during the creation of the desktop image. Defaults to true if not specified.
  .PARAMETER AzureComputeGalleryResourceId
    The name of the Azure Compute Gallery to be used for the desktop image.
  .PARAMETER TargetRegions
    The regions where the desktop image will be created. This is an array of strings that represent the Azure regions where the desktop image will be available. Defaults to West Europe and North Europe if not specified.
  .PARAMETER ReplicaCount
    The number of replicas to be created for the desktop image. Defaults to 5 if not specified.
  .PARAMETER HibernationSupported
    Indicates whether hibernation is supported for the desktop image. Defaults to false if not specified.
  .PARAMETER ScriptedActions
    The scripted action object containing name, id and other properties.
  .EXAMPLE
  New-NerdioMEDesktopImage -Name "TestModule" -ImageIdResourceGroupName "rg-infra-avd-dev-gal" `
    -ImageType "AzureComputeGallery" -SubscriptionId "dd5a4399-3766-4520-9659-b6a98bf6ba8a" `
    -VNetResourceId "/subscriptions/dd5a4399-3766-4520-9659-b6a98bf6ba8a/resourceGroups/rg-infra-common-network/providers/Microsoft.Network/virtualNetworks/infra-avd-vnet" `
    -AdminPassword $Password `
    -SubnetName "snet-avd-mgmt" `
    -AzureComputeGalleryResourceId "/subscriptions/dd5a4399-3766-4520-9659-b6a98bf6ba8a/resourceGroups/rg-infra-avd-dev-gal/providers/Microsoft.Compute/galleries/infra_avd_dev_gal" `
    -Verbose
  .NOTES
    Author: Niels Kok
    Date: August 2025
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, HelpMessage = "The name of the desktop image to be created. This is a string that will be used to identify the desktop image in Nerdio Manager for Enterprise.")]
    [string]$Name,

    [Parameter(Mandatory = $false, HelpMessage = "The description of the desktop image. This is a string that provides additional information about the desktop image.")]
    [string]$Description = "Nerdio Manager for Enterprise Desktop Image created by PSNerdio",

    [Parameter(Mandatory = $true, HelpMessage = "The type of the desktop image to be created. This is a string that represents the type of desktop image, such as 'AzureComputeGallery' or 'Classic'.")]
    [ValidateSet("ManagedImage", "AzureComputeGallery", "ConfidentialVMWithGalleryImage")]
    [string]$ImageType,

    [Parameter(Mandatory = $true, HelpMessage = "The name of the resource group where the desktop image will be created. This is a string that represents the name of the resource group in Azure.")]
    [string]$ImageIdResourceGroupName,

    [Parameter(Mandatory = $true, HelpMessage = "Subscription Id for the managed resource group where the desktop image will be created. This is a string that represents the subscription ID in Azure.")]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $false, HelpMessage = "The source image to be used for the desktop image. This is a string that represents the source image ID from the Azure Marketplace. Defaults to a Windows 11 24h2 image if not specified.")]
    [string]$SourceImageId = "MicrosoftWindowsDesktop/windows-11/win11-24h2-avd/latest",

    [Parameter(Mandatory = $false, HelpMessage = "The size of the VM to be used for the desktop image. Defaults to Standard_D4s_v5 if not specified.")]
    [string]$VmSize = "Standard_D4s_v5",

    [Parameter(Mandatory = $false, HelpMessage = "The type of storage to be used for the desktop image. Defaults to Premium_LRS if not specified.")]
    [string]$StorageType = "Premium_LRS",

    [Parameter(Mandatory = $false, HelpMessage = "The performance tier of the disk to be used for the desktop image. Defaults to P10 if not specified.")]
    [string]$DiskPerformanceTier = "P10",

    [Parameter(Mandatory = $false, HelpMessage = "The size of the disk to be used for the desktop image in GB. Defaults to 128 if not specified.")]
    [Int64]$DiskSize = 128,

    [Parameter(Mandatory = $true, HelpMessage = "The resourceid of the network that is linked to Nerdio. This is a string that represents the full resource id of the network in Azure.")]
    [string]$VNetResourceId,

    [Parameter(Mandatory = $true, HelpMessage = "The name of the subnet that is linked to Nerdio")]
    [string]$SubnetName,

    [Parameter(Mandatory = $false, HelpMessage = "The time zone to be set for the desktop image. Defaults to W. Europe Standard Time if not specified.")]
    [string]$TimeZone = "W. Europe Standard Time",

    [Parameter(Mandatory = $false, HelpMessage = "Tags to be applied to the desktop image. This is an object that contains key-value pairs for tagging the desktop image in Azure.")]
    [System.Object]$tags,

    [Parameter(Mandatory = $false, HelpMessage = "The name of the admin user to be created for the desktop image. Defaults to PSNerdioAdmin if not specified.")]
    [string]$AdminUserName = "PSNerdioAdmin",

    [Parameter(Mandatory = $true, HelpMessage = "The password for the admin user to be created for the desktop image. Defaults to a secure password if not specified.")]
    [SecureString]$AdminPassword,

    [Parameter(Mandatory = $false, HelpMessage = "Indicates whether the admin account should be disabled. Defaults to false if not specified.")]
    [bool]$DisableAccount = $false,

    [Parameter(Mandatory = $false, HelpMessage = "Indicates whether to enable time zone redirection for the desktop image. Defaults to true if not specified.")]
    [bool]$TimeZoneRedirection = $true,

    [Parameter(Mandatory = $false, HelpMessage = "Indicates whether to uninstall FSLogix for the desktop image. Defaults to true if not specified.")]
    [bool]$UninstallFSLogix = $true,

    [Parameter(Mandatory = $false, HelpMessage = "Indicates whether to skip the removal of user profiles during the creation of the desktop image. Defaults to false if not specified.")]
    [bool]$SkipRemoveProfiles = $false,

    [Parameter(Mandatory = $false, HelpMessage = "Indicates whether to build a managed image for the desktop image. Defaults to false if not specified.")]
    [bool]$NoImageObjectRequired = $false,

    [Parameter(Mandatory = $false, HelpMessage = "Indicates whether to enable the AppV services for the desktop image. Defaults to false if not specified.")]
    [bool]$EnableAppvClientService = $false,

    [Parameter(Mandatory = $false, HelpMessage = "The failure policy for the desktop image creation. Defaults to restarting the job if not specified.")]
    [bool]$FailurePolicyRestart = $true,

    [Parameter(Mandatory = $false, HelpMessage = "Indicates whether to clean up resources in case of a failure during the creation of the desktop image. Defaults to true if not specified.")]
    [bool]$FailurePolicyCleanup = $true,

    #Region Parameters for Azure Compute Gallery Image
    [Parameter(Mandatory = $false, HelpMessage = "The name of the Azure Compute Gallery to be used for the desktop image.")]
    [string]$AzureComputeGalleryResourceId,

    [Parameter(Mandatory = $false, HelpMessage = "The regions where the desktop image will be created. This is an array of strings that represent the Azure regions where the desktop image will be available. Defaults to West Europe and North Europe if not specified.")]
    [string[]]$TargetRegions = @("West Europe", "North Europe"),

    [Parameter(Mandatory = $false, HelpMessage = "The number of replicas to be created for the desktop image. Defaults to 5 if not specified.")]
    [Int64]$ReplicaCount = 5,

    [Parameter(Mandatory = $false, HelpMessage = "Indicates whether hibernation is supported for the desktop image. Defaults to false if not specified.")]
    [bool]$HibernationSupported = $false,
    #End of Region Parameters for Azure Compute Gallery Image

    [Parameter(Mandatory = $false, HelpMessage = "The scripted action object containing name, id and other properties.")]
    [System.Object[]]$ScriptedActions
  )

  begin {
    Write-Verbose "Checking token validity for Nerdio Manager for Enterprise..."
    Get-TokenValidity

  }

  Process {
    Write-Verbose "Creating new Desktop Image in Nerdio Manager for Enterprise..."

    #Base body for the request
    $Body = [PSCustomObject]@{
      jobPayload    = [PSCustomObject]@{
        imageId                   = [PSCustomObject]@{
          subscriptionId = $SubscriptionId
          resourceGroup  = $ImageIdResourceGroupName
          name           = $Name
        }
        sourceImageId             = $SourceImageId
        vmSize                    = $VmSize
        storageType               = $StorageType
        diskSize                  = $DiskSize
        diskPerformanceTier       = $DiskPerformanceTier
        networkId                 = $VNetResourceId
        subnet                    = $SubnetName
        localAdminCredentials     = [PSCustomObject]@{
          userName       = $AdminUserName
          password       = ($AdminPassword | ConvertFrom-SecureString -AsPlainText)
          disableAccount = $DisableAccount
        }
        description               = $Description
        noImageObjectRequired     = $NoImageObjectRequired
        enableTimezoneRedirection = $TimeZoneRedirection
        vmTimezone                = $TimeZone
        skipRemoveProfiles        = $SkipRemoveProfiles
        uninstallFSLogix          = $UninstallFSLogix
        securityProfile           = @{}
        galleryImage              = @{}
        tags                      = $tags
        installCertificates       = $false
        enableAppvClientService   = $EnableAppvClientService
        scriptedActions           = @()
      }
      failurePolicy = [PSCustomObject]@{
        restart = $FailurePolicyRestart
        cleanup = $FailurePolicyCleanup
      }

    }

    switch ($ImageType) {
      "ManagedImage" {
        Write-Verbose "Creating a Managed Image type desktop image."
        $Body.jobPayload.securityProfile = [PSCustomObject]@{
          securityType      = "None"
          secureBootEnabled = $false
          vTpmEnabled       = $false
        }
        $Body.jobPayload.galleryImage = $null
      }
      "AzureComputeGallery" {
        Write-Verbose "Creating an Azure Compute Gallery type desktop image."
        $Body.jobPayload.securityProfile = [PSCustomObject]@{
          securityType      = "TrustedLaunch"
          secureBootEnabled = $true
          vTpmEnabled       = $true
        }
        $Body.jobPayload.galleryImage = [PSCustomObject]@{
          galleryId            = $AzureComputeGalleryResourceId
          targetRegions        = $TargetRegions
          setInactive          = $false
          replicaCount         = $ReplicaCount
          hibernationSupported = $false
          ImageSecurityType    = "TrustedLaunch"
          osState              = "Generalized"
        }
      }
      "ConfidentialVMWithGalleryImage" {
        Write-Verbose "Creating a Confidential VM with Gallery Image type desktop image."
        $Body.jobPayload.securityProfile = [PSCustomObject]@{
          securityType      = "Confidential"
          secureBootEnabled = $true
          vTpmEnabled       = $true
        }
        $Body.jobPayload.galleryImage = [PSCustomObject]@{
          galleryId            = $AzureComputeGalleryResourceId
          targetRegions        = $TargetRegions
          setInactive          = $false
          replicaCount         = $ReplicaCount
          hibernationSupported = $false
          ImageSecurityType    = "Confidential"
          osState              = "Generalized"
        }
      }
    }

    If ($ScriptedActions) {
      foreach ($Action in $ScriptedActions) {
        If ($Action.params) {

          Write-Verbose "Scripted action parameters provided for: $($Action.name)"

          $Body.jobPayload.ScriptedActions += [PSCustomObject]@{
            name   = $Action.name
            id     = $Action.id
            params = $Action.params
          }
        }
        else {
          Write-Verbose "Scripted action provided: $($Action.name)"
          # Add the scripted action to the body
          $Body.jobPayload.ScriptedActions += [PSCustomObject]@{
            name = $Action.name
            id   = $Action.id
          }
        }
      }
    }
    else {
      Write-Verbose "No scripted action provided, skipping."
      $Body.jobPayload.scriptedActions = $null
    }

    #parameters that are based on the image type created. This is also based in on the parameters passed to the function

    $Body = $body | ConvertTo-Json -Depth 10
    Write-Verbose "Creating new desktop image with the following parameters: $($body)"

    try {
      $response = Invoke-RestMethod -Method Post `
        -Uri "$script:NMEBaseurl/api/$script:NMEApiVersion/desktop-image/create-from-library" `
        -Headers @{ "Authorization" = "Bearer $script:NMEAuthtoken" } `
        -Body $body `
        -ContentType "application/json"
    }
    catch {
      Throw "Failed to create new desktop image: $_"
    }

    return $response
  }
}
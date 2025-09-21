Function New-NerdioMEDefaultAutoScaleProfile {
  <#
  .SYNOPSIS
    Creates a new auto scale profile in Nerdio Manager for Enterprise (NME).
  .DESCRIPTION
    The New-NerdioMEAutoScaleProfile cmdlet allows you to create a new auto scale profile within Nerdio Manager for Enterprise (NME).
  .PARAMETER Name
    The name of the auto scale profile to create.
  .PARAMETER Description
    A description for the auto scale profile.
  .PARAMETER MaxSessionsPerHost
    The maximum number of sessions allowed per host. Default is 10.
  .PARAMETER LoadBalancing
    The load balancing method. Default is DepthFirst.
  .PARAMETER StartVMOnConnect
    Indicates whether VMs should start on user connect. Default is false.
  .PARAMETER ActiveHostType
    The type of active host. Default is Running.
  .PARAMETER HostPoolCapacity
    The capacity of the host pool. Default is 10.
  .PARAMETER MinActiveHostsCount
    The minimum number of active hosts. Default is 2.
  .PARAMETER BurstCapacity
    The burst capacity. Default is 2.
  .PARAMETER TriggerType
    The type of trigger for scaling. Default is CPUUsage. Other options are RAMUsage.
  .PARAMETER ScaleOutAverageTimeRangeInMinutes
    The average time range in minutes for scaling out. Default is 5 minutes.
  .PARAMETER ScaleOutHostChangeCount
    The number of hosts to change when scaling out. Default is 1.
  .PARAMETER ScaleOutValue
    The CPU or RAM usage percentage to trigger scaling out. Default is 65 percent.
  .PARAMETER ScaleInAverageTimeRangeInMinutes
    The average time range in minutes for scaling in. Default is 15 minutes.
  .PARAMETER ScaleInHostChangeCount
    The number of hosts to change when scaling in. Default is 1.
  .PARAMETER ScaleInValue
    The CPU or RAM usage percentage to trigger scaling in. Default is 40 percent.
  .PARAMETER ScaleInRestrictionEnabled
    Indicates whether scale in restriction during working hours (9 AM - 4 PM) is enabled. Default is false.
  .PARAMETER ScaleInAggressiveness
    The aggressiveness of scale in. Default is Low. Options are Low, Medium, High.
  .PARAMETER MinutesBeforeRemove
    The number of minutes before sending a remove message. Default is 10 minutes.
  .PARAMETER ScaleInMessage
    The message to display when scaling in.
  .PARAMETER AutoHealEnabled
    Indicates whether auto healing is enabled. Default is false.
  .EXAMPLES
  .NOTES
    Author: Niels Kok
    Date: September 2025
  #>

  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $true, HelpMessage = "Specify the name of the Auto Scale Profile.")]
    [string]$Name,
    [Parameter(Mandatory = $false, HelpMessage = "Write a description for the Auto Scale Profile.")]
    [string]$Description = "Auto Scale Profile created via PSNerdio",
    #AVD Properties parameters
    [Parameter(Mandatory = $false, HelpMessage = "Enter the maximum sessions per host. Default is 10.")]
    [Int64]$MaxSessionsPerHost = 10,
    [Parameter(Mandatory = $false, HelpMessage = "Enter the load balancing method. Default is DepthFirst.")]
    [string]$LoadBalancing = "DepthFirst",
    [Parameter(Mandatory = $false, HelpMessage = "Define if VMs should start on user connect. Default is false.")]
    [bool]$StartVMOnConnect = $false,
    #Size parameters
    [Parameter(Mandatory = $false, HelpMessage = "Enter the active host type.")]
    [string]$ActiveHostType = "Running",
    [Parameter(Mandatory = $false, HelpMessage = "Enter the host pool capacity.")]
    [Int64]$HostPoolCapacity = 10,
    [Parameter(Mandatory = $false, HelpMessage = "Enter the minimum active hosts count.")]
    [Int64]$MinActiveHostsCount = 2,
    [Parameter(Mandatory = $false, HelpMessage = "Enter the burst capacity.")]
    [Int64]$BurstCapacity = 2,
    #Trigger parameters
    [Parameter(Mandatory = $false, HelpMessage = "Enter the trigger type. Default is CPUUsage. Other options are RAMUsage (for now)")]
    [ValidateSet("CPUUsage", "RAMUsage")]
    [string]$TriggerType = "CPUUsage",
    [Parameter(Mandatory = $false, HelpMessage = "Enter the scale out average time range in minutes. Default is 5 minutes.")]
    [Int64]$ScaleOutAverageTimeRangeInMinutes = 5,
    [Parameter(Mandatory = $false, HelpMessage = "Enter the scale out host change count. Default is 1.")]
    [Int64]$ScaleOutHostChangeCount = 1,
    [Parameter(Mandatory = $false, HelpMessage = "Enter the scale out average time range in minutes. Default is 65 percent.")]
    [Int64]$ScaleOutValue = 65,
    [Parameter(Mandatory = $false, HelpMessage = "Enter the scale in average time range in minutes. Default is 5 minutes.")]
    [Int64]$ScaleInAverageTimeRangeInMinutes = 15,
    [Parameter(Mandatory = $false, HelpMessage = "Enter the scale in host change count. Default is 1.")]
    [Int64]$ScaleInHostChangeCount = 1,
    [Parameter(Mandatory = $false, HelpMessage = "Enter the scale in average time range in minutes. Default is 65 percent.")]
    [Int64]$ScaleInValue = 40,
    #Scale In Policy parameters
    [Parameter(Mandatory = $false, HelpMessage = "Enabled scale in restriction during working hours (9 AM - 4 PM). Default is false.")]
    [bool]$ScaleInRestrictionEnabled = $false,
    [Parameter(Mandatory = $false, HelpMessage = "Set the scale In aggressiveness. Default is Low.")]
    [ValidateSet("Low", "Medium", "High")]
    [string]$ScaleInAggressiveness = "Low",
    [Parameter(Mandatory = $false, HelpMessage = "Enter the minutes before remove message. Default is 10 minutes.")]
    [Int64]$MinutesBeforeRemove = 10,
    [Parameter(Mandatory = $false, HelpMessage = "Sets the scale In message.")]
    [string]$ScaleInMessage = 'Sorry for the interruption. We are doing some maintenance and need you to log out. We will be terminating your session in 10 minutes if you haven''t logged out by then.',
    #Auto Heal parameters
    [Parameter(Mandatory = $false, HelpMessage = "Enabled auto healing. Default is false.")]
    [bool]$AutoHealEnabled = $false

  )

  begin {
    Write-Verbose "Creating a new Auto Scale Profile in Nerdio Manager for Enterprise..."
    Get-TokenValidity

    $ScriptedAction = Get-NerdioMEScriptedAction -Name "Update AVD Agent"
  }

  process {

    $body = [pscustomobject]@{
      userDriven   = $null
      mode         = 'Default'
      name         = $Name
      description  = $Description
      default      = @{
        avdProperties    = @{
          maxSessionsPerHost = $MaxSessionsPerHost
          loadBalancing      = $LoadBalancing
          startVmOnConnect   = $StartVMOnConnect
        }
        size             = @{
          activeHostType      = $ActiveHostType
          hostPoolCapacity    = $HostPoolCapacity
          minActiveHostsCount = $MinActiveHostsCount
          burstCapacity       = $BurstCapacity
        }
        triggers         = @(
          @{
            triggerType        = $TriggerType
            averageSessions    = $null
            availableSessions  = $null
            cpu                = @{
              scaleOut = @{
                averageTimeRangeInMinutes = $ScaleOutAverageTimeRangeInMinutes
                hostChangeCount           = $ScaleOutHostChangeCount
                value                     = $ScaleOutValue
              }
              scaleIn  = @{
                averageTimeRangeInMinutes = $ScaleInAverageTimeRangeInMinutes
                hostChangeCount           = $ScaleInHostChangeCount
                value                     = $ScaleInValue
              }
            }
            ram                = $null
            userDriven         = $null
            personalAutoGrow   = $null
            personalAutoShrink = $null
          }
        )
        scaleInPolicy    = @{
          restriction    = @{
            enable         = $false
            timeRange      = $null
            putToDrainMode = $false
          }
          aggressiveness = $ScaleInAggressiveness
          messaging      = @{
            minutesBeforeRemove = $MinutesBeforeRemove
            message             = $ScaleInMessage
          }
        }
        rollingDrainMode = @{
          isEnabled = $false
        }
        preStage         = @{
          enable = $false
        }
        autoHeal         = @{
          enable = $false
        }
      }
      workingHours = $null
    }

    If ($TriggerType -eq "RAMUsage") {
      $body.default.triggers[0].cpu = $null
      $body.default.triggers[0].ram = @{
        scaleOut = @{
          averageTimeRangeInMinutes = $ScaleOutAverageTimeRangeInMinutes
          hostChangeCount           = $ScaleOutHostChangeCount
          value                     = $ScaleOutValue
        }
        scaleIn  = @{
          averageTimeRangeInMinutes = $ScaleInAverageTimeRangeInMinutes
          hostChangeCount           = $ScaleInHostChangeCount
          value                     = $ScaleInValue
        }
      }
    }

    if ($ScaleInRestrictionEnabled -eq $true) {
      $body.default.scaleInPolicy.restriction.enable = $true
      $body.default.scaleInPolicy.restriction.timeRange = @{
        startHour   = 9
        startMinute = 0
        endHour     = 16
        endMinute   = 0
      }
      $body.default.scaleInPolicy.restriction.putToDrainMode = $true
    }

    if ($AutoHealEnabled -eq $true) {
      $body.default.autoHeal = @{
        enable  = $true
        config  = $null
        configs = @(
          @{
            wvdStatuses                  = @('NoHeartbeat', 'UpgradeFailed', 'NeedsAssistance')
            sessionCriteria              = 'WithoutSessions'
            staleHeartbeatMinutes        = 30
            waitMinutesBeforeFirstAction = 5
            waitMinutes                  = 5
            actions                      = @(
              @{ type = 'RestartVm' }
              @{ type = 'ScriptedAction'; scriptedActionId = $($ScriptedAction.Id) }
              @{ type = 'RestartVm' }
            )
          }
        )
      }
    }

    $body = $body | ConvertTo-Json -Depth 10

    Write-Verbose "Request Body: $body"

    try {
      $response = Invoke-RestMethod -Method Post `
        -Uri "$script:NMEBaseurl/api/$Script:NMEApiVersion/auto-scale-profile" `
        -Headers $script:NMEAuthheader `
        -Body $body `
        -ContentType "application/json"
      Write-Verbose "Auto Scale Profile '$Name' created successfully."

    }
    Catch {
      Throw "Failed to create Auto Scale Profile: $_"
    }
  }
  End {
    return $response
  }
}
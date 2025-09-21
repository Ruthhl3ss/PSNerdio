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
  .EXAMPLES
  .NOTES
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
    [Parameter(Mandatory = $false, HelpMessage = "Write a description for the Auto Scale Profile.")]
    [bool]$StartVMOnConnect = $false,
    #Size parameters
    [Parameter(Mandatory = $false, HelpMessage = "Enter the active host type.")]
    [string]$ActiveHostType = "Running",
    [Parameter(Mandatory = $false, HelpMessage = "Enter the host pool capacity.")]
    [Int64]$HostPoolCapacity = 10,
    [Parameter(Mandatory = $false, HelpMessage = "Enter the minimum active hosts count.")]
    [Int64]$MinActiveHostsCount = 2,
    [Parameter(Mandatory = $false, HelpMessage = "Enter the burst capacity.")]
    [Int64]$BurstCapacity = 2
  )

  begin {
    Write-Verbose "Creating a new Auto Scale Profile in Nerdio Manager for Enterprise..."
    Get-TokenValidity
  }

  process {

    $body = [pscustomobject]@{
      userDriven  = $null
      mode        = 'Default'
      name        = $Name
      description = $Description
      default     = @{
        avdProperties = @{
          maxSessionsPerHost = $MaxSessionsPerHost
          loadBalancing      = $LoadBalancing
          startVmOnConnect   = $StartVMOnConnect
        }
        size = @{
          activeHostType      = $ActiveHostType
          hostPoolCapacity    = $HostPoolCapacity
          minActiveHostsCount = $MinActiveHostsCount
          burstCapacity       = $BurstCapacity
        }
        triggers = @(
          @{
            triggerType       = 'CPUUsage'
            averageSessions   = $null
            availableSessions = $null
            cpu = @{
              scaleOut = @{
                averageTimeRangeInMinutes = 5
                hostChangeCount           = 1
                value                     = 65
              }
              scaleIn = @{
                averageTimeRangeInMinutes = 15
                hostChangeCount           = 1
                value                     = 40
              }
            }
            ram                = $null
            userDriven         = $null
            personalAutoGrow   = $null
            personalAutoShrink = $null
          }
        )
        scaleInPolicy = @{
          restriction = @{
            enable         = $false
            timeRange      = $null
            putToDrainMode = $false
          }
          aggressiveness = 'Low'
          messaging = @{
            minutesBeforeRemove = 10
            message             = 'Sorry for the interruption. We are doing some maintenance and need you to log out. We will be terminating your session in 10 minutes if you haven''t logged out by then.'
          }
        }
        rollingDrainMode = @{
          isEnabled = $true
          windows   = @(
            @{
              name                  = 'Window 1'
              startTime             = '12:00:00'
              percent               = 50
              loadBalancing         = 'DepthFirst'
              scaleInAggressiveness = 'High'
            }
          )
        }
        preStage = @{
          enable = $true
          config = @{
            days = @(1)
            startWork = @{
              duration = 600
              hour     = 8
              minutes  = 0
            }
            hostsToBeReady          = 10
            preStageDiskType        = $true
            preStageUnassigned      = $false
            preStageUnassignedHosts = $false
          }
          isMultipleConfigsMode   = $false
          configs                 = $null
          intelligentPrestageMode = $null
        }
        autoHeal = @{
          enable = $true
          config = $null
          configs = @(
            @{
              wvdStatuses                  = @('FSLogixNotHealthy')
              sessionCriteria              = 'WithoutSessions'
              staleHeartbeatMinutes        = 30
              waitMinutesBeforeFirstAction = 5
              waitMinutes                  = 5
              actions = @(
                @{ type = 'RestartVm' }
                @{ type = 'ScriptedAction'; scriptedActionId = 1 }
                @{ type = 'RestartVm' }
              )
            }
          )
        }
      }
      workingHours = $null
    }

    $body = $body | ConvertTo-Json -Depth 10

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
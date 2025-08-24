Function New-NerdioMeDesktopImageSchedule {
  <#
  .SYNOPSIS
  Creates a new schedule for a Nerdio Managed Desktop image.

  .DESCRIPTION
  This function creates a new schedule for a specified Nerdio Managed Desktop image.

  .PARAMETER DesktopImageName
  The name of the desktop image for which the schedule is being created.

  .PARAMETER ScriptedActions
  An array of scripted actions to be executed as part of the schedule.

  .PARAMETER ScheduleName
  The name of the schedule being created.

  .PARAMETER ScheduleDescription
  A description of the schedule being created.

  .PARAMETER ScheduleTime
  The time at which the schedule will be executed. Default is 24 hours from now.

  .PARAMETER ScheduleRecurrenceType
  The recurrence type for the schedule (e.g., Daily, Weekly). Default is Weekly.

  .PARAMETER ScheduleTimeZone
  The time zone in which the schedule will be executed. Default is "W. Europe Standard Time".

  .PARAMETER startHour
  The hour at which the schedule will start. Default is 8 AM.

  .PARAMETER startMinute
  The minute at which the schedule will start. Default is 30 minutes past the hour.

  .PARAMETER dayOfWeekNumber
  The day of the week number for the schedule (1 = Sunday, 2 = Monday, etc.). Default is null.

  .PARAMETER dayOfWeek
  The day of the week for the schedule (1 = Sunday, 2 = Monday, etc.). Default is 1 (Sunday).

  .PARAMETER offsetInDays
  The offset in days for the schedule. Default is null.

  .EXAMPLE
  New-NerdioMeDesktopImageSchedule -DesktopImageName "MyDesktopImage" -ScheduleName "Weekly Update" -Verbose
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]$DesktopImageName,

    [Parameter(Mandatory = $false)]
    [System.Object[]]$ScriptedActions,

    [Parameter(Mandatory = $true)]
    [string]$ScheduleName,

    [Parameter(Mandatory = $false)]
    [string]$ScheduleDescription,

    [Parameter(Mandatory = $false)]
    [string]$ScheduleTime = (Get-Date).AddHours(24).ToString("yyyy-MM-ddTHH:mm:ssZ"),  # Default to current time in HH:mm format

    [Parameter(Mandatory = $false)]
    [string]$ScheduleRecurrenceType = "Weekly",

    [Parameter(Mandatory = $false)]
    [string]$ScheduleTimeZone = "W. Europe Standard Time",

    [Parameter(Mandatory = $false)]
    [int]$startHour = 8,

    [Parameter(Mandatory = $false)]
    [int]$startMinute = 30,

    [Parameter(Mandatory = $false)]
    [int]$dayOfWeekNumber = $null,

    [Parameter(Mandatory = $false)]
    [int]$dayOfWeek = 1,

    [Parameter(Mandatory = $false)]
    [int]$offsetInDays = $null

  )

  begin {
    Get-TokenValidity

    $desktopimage = Get-NerdioMEDesktopImage -Name $DesktopImageName

    $SubscriptionId = $desktopimage.id -split "/" | Select-Object -Index 2
    $ResourceGroupName = $desktopimage.id -split "/" | Select-Object -Index 4
    $ImageName = $desktopimage.id -split "/" | Select-Object -Index 8

    IF ($null -eq $ScriptedActions) {
      Write-Verbose "No scripted actions provided, using default."
      $ScriptedActions = @(
        @{
          type = "Action"
          id   = 53
        }
      )
    }
  }

  process {

    $body = [PSCustomObject]@{
      schedule = @{
        startDate              = $ScheduleTime
        startHour              = $startHour
        startMinutes           = $startMinute
        timeZoneId             = $ScheduleTimeZone
        scheduleRecurrenceType = $ScheduleRecurrenceType
        dayOfWeekNumber        = $dayOfWeekNumber
        dayOfWeek              = $dayOfWeek
        offsetInDays           = $offsetInDays
        name                   = $ScheduleName
        description            = $ScheduleDescription
      }
      Config   = @{
        restartVm       = $false
        scriptedActions = @()
      }
    }
    $body.Config.scriptedActions += $ScriptedActions

    $body = $body | ConvertTo-Json -Depth 10

    Write-Verbose "body: $body"

    $uri = "$script:NMEBaseurl/api/$script:NMEApiVersion/desktop-image/$SubscriptionId/$ResourceGroupName/$ImageName/script/schedule-v2"

    Write-Verbose "uri: $uri"

    try {
      $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $script:NMEAuthheader -Body $body -ContentType "application/json"
    }
    catch {
      Throw "Failed to retrieve desktop image schedule: $_"
    }

  }

  end {
    $response
  }

}
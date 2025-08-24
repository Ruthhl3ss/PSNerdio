function Get-NerdioMEDesktopImageSchedule {
  <#
  .SYNOPSIS
  Retrieves the schedule for a Nerdio ME desktop image.

  .PARAMETER Name
  The name of the desktop image to retrieve the schedule for.

  .EXAMPLE
  Get-NerdioMEDesktopImageSchedule -Name "MyDesktopImage"
  #>
  [CmdletBinding()]
  param (
    [Parameter()]
    [string]$Name
  )

  begin {
    Get-TokenValidity

    $desktopimage = Get-NerdioMEDesktopImage -Name $Name

    $SubscriptionId = $desktopimage.id -split "/" | Select-Object -Index 2
    $ResourceGroupName = $desktopimage.id -split "/" | Select-Object -Index 4
    $ImageName = $desktopimage.id -split "/" | Select-Object -Index 8
  }

  process {

    $uri = "$script:NMEBaseurl/api/$script:NMEApiVersion/desktop-image/$SubscriptionId/$ResourceGroupName/$ImageName/schedule"

    Write-Verbose "uri: $uri"

    try {
      $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $script:NMEAuthheader
    }
    catch {
      Throw "Failed to retrieve desktop image schedule: $_"
    }

  }

  end {
    $response
  }

}
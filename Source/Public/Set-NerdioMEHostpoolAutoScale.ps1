function Set-NerdioMEHostpoolAutoScale {

  [CmdletBinding()]
  param (
      [Parameter()]
      [string]$HostpoolName
  )

  begin {
    Write-Verbose "Starting Set-NerdioMEHostpoolAutoScale"
    Get-TokenValidity
  }
  process {

  }
  End {
        Write-Verbose "Completed Set-NerdioMEHostpoolAutoScale"
  }

}
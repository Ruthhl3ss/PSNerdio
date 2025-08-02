#Function to check if the user is connected to Nerdio Manager for Enterprise
function Get-TokenValidity {

  if ($null -eq $script:NMEAuthtoken) {
    Throw "No token found. Please authenticate first using the Connect-NerdioME command"
  }
  else {
    Write-Verbose "Token found. Checking validity..."

    $date = [System.DateTime]::UtcNow
    If ($date -gt $script:NMEAuthtime.AddMinutes(58)) {
      Throw "Token expired. Please authenticate again using the Connect-NerdioNME command"
      $script:NMEAuthtime = $null
      $script:NMEAuthtoken = $null
      $script:NMEAuthheader = $null
    }
    else {
      Write-Verbose "Token is still valid."
    }
  }
}

Function Test-NerdioConnection {
  Get-TokenValidity
  if ($script:NMEAuthtoken) {
    Write-Verbose "Nerdio Manager for Enterprise is connected."
  }

  Write-Verbose "Testing connection to Nerdio Manager for Enterprise API..."
  # Ensure the base URL is set
  Write-Verbose "Base URL: $script:NMEBaseurl"

  # Make the API request
  $response = Invoke-RestMethod -Method Get `
    -Uri "$script:NMEBaseurl/api/v1/test" `
    -Headers @{ "Authorization" = "Bearer $script:NMEAuthtoken" }
  if ($response) {
    Write-Verbose "Connection to Nerdio Manager for Enterprise is successful."
  }
  else {
    Write-Error "Failed to connect to Nerdio Manager for Enterprise."
  }
}
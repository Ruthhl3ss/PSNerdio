Function Connect-NerdioME {
  <#
  .SYNOPSIS
  Connects to the Nerdio Manager for Enterprise API.
  .DESCRIPTION
  This function authenticates to the Nerdio Manager for Enterprise API using client credentials and retrieves an access token.
  .PARAMETER TenantId
  The ID of the tenant to connect to.
  .PARAMETER ClientId
  The client ID of the application registered in Azure AD.
  .PARAMETER ClientSecret
  The client secret of the application registered in Azure AD.
  .PARAMETER Scope
  The scope for the access token, typically in the format "api://<application-id>/.default".
  .EXAMPLE
  Connect-NerdioME -TenantId "your-tenant-id" -ClientId "your-client-id" -ClientSecret "your-client-secret" -Scope "api://your-application-id/.default"
  Connects to the Nerdio Manager for Enterprise API using the specified tenant ID, client ID, client secret, and scope.
  .NOTES
  #>

  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $true)]
    [string]$TenantId,

    [Parameter(Mandatory = $true)]
    [string]$ClientId,

    [Parameter(Mandatory = $true)]
    [string]$ClientSecret,

    [Parameter(Mandatory = $true)]
    [string]$Scope,

    [Parameter(Mandatory = $true)]
    [string]$Baseurl
  )

  begin {
    Write-Verbose "Connecting to Nerdio Manager for Enterprise..."
  }

  Process {
    try {

      Write-Verbose "Authenticating to Nerdio Manager for Enterprise API..."

      $tokenResponse = Invoke-RestMethod -Method Post `
        -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" `
        -Headers @{ "Content-Type" = "application/x-www-form-urlencoded" } `
        -Body @{
          grant_type    = "client_credentials"
          client_id     = $ClientId
          scope         = $Scope
          client_secret = $ClientSecret
      }

      $script:NMEAuthtoken = $($tokenResponse.access_token)
      $script:NMEBaseurl = $Baseurl
      $script:NMEAuthtime = [System.DateTime]::UtcNow
      $script:NMEAuthheader = @{
        "Authorization" = "Bearer $($tokenResponse.access_token)"
      }

      Write-Verbose "Successfully connected to Nerdio Manager for Enterprise."
    }
    catch {
      Throw "Failed to connect to Nerdio Manager for Enterprise: $_"
    }
  }

  End {

    # Check if the connection was successful
    Test-NerdioConnection

  }
}

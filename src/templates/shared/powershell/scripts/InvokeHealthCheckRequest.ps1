function Test-HealthCheck {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$BaseUrl,

        [Parameter()]
        [int]$MaxTries = 10,

        [Parameter()]
        [int]$RetryDelaySeconds = 5,

        [Parameter()]
        [string]$HealthCheckPath = "health"
    )

    function Invoke-HealthCheckRequest {
        param (
            [string]$Url,
            [int]$MaxTries,
            [int]$RetryDelaySeconds
        )

        $Tries = 0

        while ($Tries -lt $MaxTries) {
            $Tries++
            Start-Sleep -Seconds $RetryDelaySeconds
            Write-Host "Sending request to $Url ($Tries of $MaxTries attempts) ..." -NoNewline

            try {
                $Response = Invoke-WebRequest -Uri $Url -UseBasicParsing
                $StatusCode = $Response.StatusCode
                Write-Host "API responded with HTTP status $StatusCode" -ForegroundColor Green

                if ($StatusCode -eq 200) {
                    Write-Host "Health check passed!" -ForegroundColor Green
                    return $true
                }
            }
            catch {
                Write-Host "Error: $_" -ForegroundColor Red
            }
        }

        Write-Host "Health check failed after $MaxTries attempts." -ForegroundColor Red
        return $false
    }

    try {
        $Url = Join-Path -Path $BaseUrl -ChildPath $HealthCheckPath
        Write-Host "Attempting to retrieve response from health check endpoint at $Url."

        $HealthCheckResult = Invoke-HealthCheckRequest -Url $Url -MaxTries $MaxTries -RetryDelaySeconds $RetryDelaySeconds

        if (-not $HealthCheckResult) {
            throw "Health check failed. Please investigate the issue."
        }
    }
    catch {
        Write-Host "An error occurred: $_" -ForegroundColor Red
        throw
    }
}
<#
.SYNOPSIS
Logs the values of specified environment variables.
.DESCRIPTION
This function logs the values of a collection of environment variables.
For each variable, it checks if it's set.
If the variable is set but its value is empty, the script will log that it's empty.
If the variable is not set at all, the script will log that it's not set.
If the variable is set and has a value, the script will log the value.
.PARAMETER VariableName
Name of the environment variable whose value is to be logged.
.EXAMPLE
Write-EnvironmentVariable -VariableName "AGENT_BUILDDIRECTORY"
Output might be:
AGENT_BUILDDIRECTORY: C:\Agent\_work\1
.NOTES
Designed for use to quickly log the values of common environment variables available in Azure DevOps pipelines.
#>
function Write-EnvironmentVariable {
    param(
        [Parameter(Mandatory = $true)]
        [string]$VariableName
    )

    # Check if the environment variable exists.
    if (Test-Path "env:$VariableName") {
        # Retrieve the value of the environment variable.
        $VariableValue = Get-Content "env:$VariableName"
        
        if ([string]::IsNullOrEmpty($VariableValue)) {
            Write-Host "${VariableName} is set but empty."
        }
        else {
            Write-Host "${VariableName}: $VariableValue"
        }
    }
    else {
        Write-Host "${VariableName} is not set."
    }
}
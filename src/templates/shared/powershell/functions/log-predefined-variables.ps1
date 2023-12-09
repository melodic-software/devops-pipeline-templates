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
LogVariable -VariableName "AGENT_BUILDDIRECTORY"
Output might be:
AGENT_BUILDDIRECTORY: C:\Agent\_work\1
.NOTES
Designed for use to quickly log the values of common environment variables available in Azure DevOps pipelines.
#>
function LogVariable {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VariableName
    )

    # Check if the environment variable exists
    if (Test-Path "env:$VariableName") {
        # Retrieve the value of the environment variable
        $VariableValue = Get-Content "env:$VariableName"
        
        if ([string]::IsNullOrEmpty($VariableValue)) {
            Write-Host "${VariableName} is set but empty."
        } else {
            Write-Host "${VariableName}: $VariableValue"
        }
    } else {
        Write-Host "${VariableName} is not set."
    }
}

# Define the collection of variable names
$VariableNames = @(
    "AGENT_BUILDDIRECTORY",
    "AGENT_HOMEDIRECTORY",
    "AGENT_ID",
    "AGENT_JOBNAME",
    "AGENT_JOBSTATUS",
    "AGENT_MACHINENAME",
    "AGENT_NAME",
    "AGENT_OS",
    "AGENT_OSARCHITECTURE",
    "AGENT_TEMPDIRECTORY",
    "AGENT_TOOLSDIRECTORY",
    "AGENT_WORKFOLDER",
    "BUILD_ARTIFACTSTAGINGDIRECTORY",
    "BUILD_BUILDID",
    "BUILD_BUILDNUMBER",
    "BUILD_BUILDURI",
    "BUILD_BINARIESDIRECTORY",
    "BUILD_DEFINITIONNAME",
    "BUILD_DEFINITIONVERSION",
    "BUILD_QUEUEDBY",
    "BUILD_QUEUEDBYID",
    "BUILD_REASON",
    "BUILD_REPOSITORY_CLEAN",
    "BUILD_REPOSITORY_LOCALPATH",
    "BUILD_REPOSITORY_ID",
    "BUILD_REPOSITORY_NAME",
    "BUILD_REPOSITORY_PROVIDER",
    "BUILD_REPOSITORY_URI",
    "BUILD_REQUESTEDFOR",
    "BUILD_REQUESTEDFOREMAIL",
    "BUILD_REQUESTEDFORID",
    "BUILD_SOURCEBRANCH",
    "BUILD_SOURCEBRANCHNAME",
    "BUILD_SOURCESDIRECTORY",
    "BUILD_SOURCEVERSION",
    "BUILD_SOURCEVERSIONMESSAGE",
    "BUILD_STAGINGDIRECTORY",
    "COMMON_TESTRESULTSDIRECTORY",
    "PIPELINE_WORKSPACE",
    "SYSTEM_ARTIFACTSDIRECTORY",
    "SYSTEM_COLLECTIONID",
    "SYSTEM_DEFAULTWORKINGDIRECTORY",
    "SYSTEM_DEFINITIONID",
    "SYSTEM_HOSTTYPE",
    "SYSTEM_JOBATTEMPT",
    "SYSTEM_JOBDISPLAYNAME",
    "SYSTEM_JOBID",
    "SYSTEM_JOBNAME",
    "SYSTEM_PHASEATTEMPT",
    "SYSTEM_PHASEDISPLAYNAME",
    "SYSTEM_PHASENAME",
    "SYSTEM_PLANID",
    "SYSTEM_PULLREQUEST_ISFORK",
    "SYSTEM_PULLREQUEST_PULLREQUESTID",
    "SYSTEM_PULLREQUEST_PULLREQUESTNUMBER",
    "SYSTEM_PULLREQUEST_SOURCEBRANCH",
    "SYSTEM_PULLREQUEST_SOURCECOMMITID",
    "SYSTEM_PULLREQUEST_SOURCEREPOSITORYURI",
    "SYSTEM_PULLREQUEST_TARGETBRANCH",
    "SYSTEM_STAGEATTEMPT",
    "SYSTEM_STAGEDISPLAYNAME",
    "SYSTEM_STAGENAME",
    "SYSTEM_TEAMFOUNDATIONCOLLECTIONURI",
    "SYSTEM_TEAMPROJECT",
    "SYSTEM_TEAMPROJECTID",
    "SYSTEM_TIMELINEID",
    "TF_BUILD"
)

try {
    foreach ($VariableName in $VariableNames) {
        LogVariable -VariableName $VariableName
    }
} catch {
    Write-Error "An error occurred while processing the variable '${VariableName}': $_"
    # Optionally, further error handling can be added here, like logging to a file.
}
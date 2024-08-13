<#
.SYNOPSIS
Logs the values of a predefined set of environment variables.

.DESCRIPTION
The `Write-PredefinedEnvironmentVariables` function logs the values of a predefined list of environment variables.
For each variable, it checks if it's set, and logs the appropriate message:
- If the variable is set but its value is empty, it logs that it's empty.
- If the variable is not set, it logs that it's not set.
- If the variable is set and has a value, it logs the value.
This function is useful for quickly logging the values of common environment variables available in Azure DevOps pipelines or other CI/CD environments.

.PARAMETER VariableNames
An array of environment variable names to be logged. If not provided, a default set of common environment variables will be used.

.EXAMPLE
Write-PredefinedEnvironmentVariables
Logs the values of the default set of environment variables.

.EXAMPLE
$CustomVariables = @("CUSTOM_VAR1", "CUSTOM_VAR2")
Write-PredefinedEnvironmentVariables -VariableNames $CustomVariables
Logs the values of the specified custom environment variables.

.NOTES
- This function uses the `Write-EnvironmentVariable` function to log each variable's value.
- The `Write-EnvironmentVariable` function is sourced automatically from the same directory.
#>
function Write-PredefinedEnvironmentVariables {
    param (
        [Parameter(Mandatory = $false)]
        [string[]]$VariableNames = @(
            # Agent Variables
            "AGENT_BUILDDIRECTORY",
            "AGENT_CONTAINERMAPPING",
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
            "AGENT_VERSION",
            "AGENT_WORKFOLDER",
            "AGENT_DISABLELOGPLUGIN_TESTFILEPUBLISHER",

            # Build Variables
            "BUILD_CLEAN" # Deprecated
            "BUILD_ARTIFACTSTAGINGDIRECTORY",
            "BUILD_BINARIESDIRECTORY",
            "BUILD_BUILDID",
            "BUILD_BUILDNUMBER",
            "BUILD_BUILDNUMBERFORMAT",
            "BUILD_BUILDURI",
            "BUILD_CONTAINERID",
            "Build.CronSchedule.DisplayName", # TRANSLATE THIS
            "BUILD_DEFINITIONNAME",
            "BUILD_DEFINITIONVERSION",
            "BUILD_QUEUEDBY",
            "BUILD_QUEUEDBYID",
            "BUILD_REASON",
            "BUILD_REPOSITORY_CLEAN",
            "BUILD_REPOSITORY_GIT_LFS_SUPPORT",
            "BUILD_REPOSITORY_GIT_SUBMODULECHECKOUT",
            "BUILD_REPOSITORY_ID",
            "BUILD_REPOSITORY_LOCALPATH",
            "BUILD_REPOSITORY_NAME",
            "BUILD_REPOSITORY_PROVIDER",
            "BUILD_REPOSITORY_URI",
            "Build.Repository.Tfvc.Workspace", # TRANSLATE THIS
            "Build.Repository.Uri", # TRANSLATE THIS
            "BUILD_REQUESTEDFOR",
            "BUILD_REQUESTEDFOREMAIL",
            "BUILD_REQUESTEDFORID",
            "BUILD_SOURCEBRANCH",
            "BUILD_SOURCEBRANCHNAME",
            "BUILD_SOURCESDIRECTORY",
            "BUILD_SOURCEVERSION",
            "BUILD_SOURCEVERSIONAUTHOR",
            "BUILD_SOURCEVERSIONMESSAGE",
            "BUILD_STAGINGDIRECTORY",
            "Build.Repository.Git.SubmoduleCheckout" # TRANSLATE THIS
            "Build.SourceTfvcShelveset" # TRANSLATE THIS
            "BUILD_TRIGGEREDBYBUILDID",
            "BUILD_TRIGGEREDBYDEFINITIONID",
            "BUILD_TRIGGEREDBYDEFINITIONNAME",
            "BUILD_TRIGGEREDBYID",
            "Build.TriggeredBy.BuildNumber", # TRANSLATE THIS AND ENSURE OTHERS ARE ACCURATE
            "Build.TriggeredBy.ProjectID", # TRANSLATE THIS

            # Common Variables
            "COMMON_TESTRESULTSDIRECTORY",
            "PIPELINE_WORKSPACE",
            "TF_BUILD",

            # Release Variables
            "RELEASE_ARTIFACTS_ASPNETCORE_SNAPSHOT_NAME",
            "RELEASE_ARTIFACTS_ASPNETCORE_VERSION",
            "RELEASE_DEPLOYMENT_REQUESTEDFOR",
            "RELEASE_DEPLOYMENT_REQUESTEDFOREMAIL",
            "RELEASE_ENVIRONMENTID",
            "RELEASE_ENVIRONMENTNAME",
            "RELEASE_ENVIRONMENTURI",
            "RELEASE_RELEASEDESCRIPTION",
            "RELEASE_RELEASEID",
            "RELEASE_RELEASENAME",
            "RELEASE_RELEASEWEBURL",
            "RELEASE_REQUESTEDFORID",
            "RELEASE_REQUESTEDFORMAIL",
            "RELEASE_REQUESTEDFORNAME",
            "RELEASE_REQUESTEDFORUNIQUEUSERID",
            "RELEASE_RELEASEURI",
            "RELEASE_PRIMARYARTIFACT_ALIAS",
            "RELEASE_PRIMARYARTIFACT_BUILDID",
            "RELEASE_PRIMARYARTIFACT_DEFINITIONID",
            "RELEASE_PRIMARYARTIFACT_DEFINITIONNAME",
            "RELEASE_PRIMARYARTIFACT_SOURCEBRANCH",
            "RELEASE_PRIMARYARTIFACT_SOURCEBRANCHNAME",
            "RELEASE_PRIMARYARTIFACT_SOURCEVERSION",

            # System Variables
            "SYSTEM_ACCESSTOKEN",
            "SYSTEM_ARTIFACTSDIRECTORY",
            "SYSTEM_COLLECTIONID",
            "SYSTEM_COLLECTIONURI",
            "SYSTEM_CULTURE",
            "SYSTEM_DEBUG",
            "SYSTEM_DEFAULTWORKINGDIRECTORY",
            "SYSTEM_DEFINITIONID",
            "SYSTEM_DEFINITIONNAME",
            "SYSTEM_ENABLEPROCESSDUMP",
            "SYSTEM_HOSTTYPE",
            "SYSTEM_JOBATTEMPT",
            "SYSTEM_JOBDISPLAYNAME",
            "SYSTEM_JOBID",
            "SYSTEM_JOBIDENTITY",
            "SYSTEM_JOBNAME",
            "SYSTEM_OIDCREQUESTURI",
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
            "System.PullRequest.targetBranchName", # TRANSLATE THIS
            "SYSTEM_STAGEATTEMPT",
            "SYSTEM_STAGEDISPLAYNAME",
            "SYSTEM_STAGENAME",
            "SYSTEM_TASKDEFINITIONSURI",
            "SYSTEM_TEAMFOUNDATIONCOLLECTIONURI",
            "SYSTEM_TEAMPROJECT",
            "SYSTEM_TEAMPROJECTID",
            "SYSTEM_TIMELINEID",
            "SYSTEM_WORKFOLDER",

            # Repository Variables (additional)
            "BUILD_REPOSITORY_CLEAN",
            "BUILD_REPOSITORY_GIT_SUBMODULECHECKOUT",
            "BUILD_REPOSITORY_GIT_LFS_SUPPORT",
            "BUILD_REPOSITORY_NAME",
            "BUILD_REPOSITORY_PROVIDER",
            "BUILD_REPOSITORY_URI",
            "BUILD_REPOSITORY_LOCALPATH",
            "BUILD_REPOSITORY_ID",
            "BUILD_SOURCESDIRECTORY",

            "PIPELINE_WORKSPACE",

            "ENVIRONMENT_NAME",
            "ENVIRONMENT_ID",
            "ENVIRONMENT_RESOURCENAME",
            "ENVIRONMENT_RESOURCEID",
            "STRATEGY_NAME",
            "STRATEGY_CYCLENAME",

            "CHECKS.STAGEATTEMPT"
        )
    )

    # Dot-source the Write-EnvironmentVariable function from the same directory.
    . "$PSScriptRoot\WriteEnvironmentVariable.ps1"

    try {
        foreach ($VariableName in $VariableNames) {
            Write-EnvironmentVariable -VariableName $VariableName
        }
    }
    catch {
        Write-Error "An error occurred while processing the variable '${VariableName}': $_"
        # Optionally, further error handling can be added here, like logging to a file.
    }
}
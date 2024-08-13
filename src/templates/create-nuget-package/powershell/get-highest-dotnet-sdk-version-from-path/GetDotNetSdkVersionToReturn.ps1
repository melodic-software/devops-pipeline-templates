<#
.SYNOPSIS
Decides the version to return based on the SDK version and current highest version.
.DESCRIPTION
Compares the SDK version and current highest version, returning the one that is greater. If no valid SDK version is found in the project file, the function returns $null.
.PARAMETER SdkVersion
The .NET SDK version from a specific project file.
.PARAMETER CurrentHighestVersion
The current highest .NET SDK version found so far.
#>
function Get-DotNetSdkVersionToReturn {
    param (
        [Version]$SdkVersion,
        [Version]$CurrentHighestVersion
    )

    if (-not $SdkVersion) {
        Write-Warning "No valid SDK version found in project file."
        return $null
    }

    if (Test-NewDotNetSdkVersionIsHigher -CurrentVersion $CurrentHighestVersion -NewVersion $SdkVersion) {
        Write-Debug "Version updated: $SdkVersion"
        return $SdkVersion
    }

    Write-Debug "Current version ($CurrentHighestVersion) is higher or equal to the found version ($SdkVersion). No update necessary."
    return $CurrentHighestVersion
}
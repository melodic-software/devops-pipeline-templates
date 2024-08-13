<#
.SYNOPSIS
Checks if a new SDK version is higher than the current version.
.DESCRIPTION
Evaluates whether the new version is higher than the current version, returning a boolean.
.PARAMETER CurrentVersion
The current .NET SDK version.
.PARAMETER NewVersion
The new .NET SDK version to compare against.
#>
function Test-NewDotNetSdkVersionIsHigher {
    param (
        [Version]$CurrentVersion,
        [Version]$NewVersion
    )

    return ($CurrentVersion -eq $null) -or ($NewVersion -gt $CurrentVersion)
}
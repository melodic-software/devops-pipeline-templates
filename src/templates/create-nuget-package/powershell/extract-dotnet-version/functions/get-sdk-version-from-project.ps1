<#
.SYNOPSIS
Determines the SDK version from a project file and compares it with the current highest version.
.DESCRIPTION
This function retrieves the SDK version from a project's content and returns the higher version between it and the current highest version. If there's an error reading the project file, it returns $null.
.PARAMETER ProjectFilePath
The path to the .csproj file.
.PARAMETER CurrentHighestVersion
The current highest .NET SDK version found so far.
#>
function Get-SDKVersionFromProject {
    param (
        [ValidateScript({ Test-Path $_ })]
        [string]$ProjectFilePath,
        [Version]$CurrentHighestVersion
    )

    try {
        Write-Debug "Reading content of: $ProjectFilePath"
        [string]$ProjectContent = Get-Content -Path $ProjectFilePath -Raw
        [Version]$SdkVersion = Get-ProjectSdkVersion -ProjectContent $ProjectContent -FallbackDotNetVersion $CurrentHighestVersion
        return DetermineVersionToReturn -SdkVersion $SdkVersion -CurrentHighestVersion $CurrentHighestVersion
    }
    catch {
        Write-Warning "Error processing project file: $($_.Exception.Message)"
        return $null
    }
}

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
function DetermineVersionToReturn {
    param (
        [Version]$SdkVersion,
        [Version]$CurrentHighestVersion
    )

    if (-not $SdkVersion) {
        Write-Warning "No valid SDK version found in project file."
        return $null
    }

    if (IsNewVersionHigher -CurrentVersion $CurrentHighestVersion -NewVersion $SdkVersion) {
        Write-Debug "Version updated: $SdkVersion"
        return $SdkVersion
    }

    Write-Debug "Current version ($CurrentHighestVersion) is higher or equal to the found version ($SdkVersion). No update necessary."
    return $CurrentHighestVersion
}

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
function IsNewVersionHigher {
    param (
        [Version]$CurrentVersion,
        [Version]$NewVersion
    )

    return ($CurrentVersion -eq $null) -or ($NewVersion -gt $CurrentVersion)
}
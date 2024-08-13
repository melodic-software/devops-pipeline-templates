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
function Get-DotNetSdkVersionFromProject {
    param (
        [ValidateScript({ Test-Path $_ })]
        [string]$ProjectFilePath,
        [Version]$CurrentHighestVersion
    )

    try {
        Write-Debug "Reading content of: $ProjectFilePath"
        [string]$ProjectContent = Get-Content -Path $ProjectFilePath -Raw
        [Version]$SdkVersion = Get-DotNetSdkVersionFromProjectContent -ProjectContent $ProjectContent -FallbackDotNetVersion $CurrentHighestVersion
        return Get-DotNetSdkVersionToReturn -SdkVersion $SdkVersion -CurrentHighestVersion $CurrentHighestVersion
    }
    catch {
        Write-Warning "Error processing project file: $($_.Exception.Message)"
        return $null
    }
}
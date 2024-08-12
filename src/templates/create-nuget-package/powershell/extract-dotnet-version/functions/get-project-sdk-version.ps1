<#
.SYNOPSIS
Extracts the SDK version from a project's content.
.DESCRIPTION
This function analyzes the project file content to determine the .NET SDK version used.
If the content doesn't specify the SDK version, the function returns a default version defined in `FallbackDotNetVersion`.
.PARAMETER ProjectContent
The string content of the project file.
.PARAMETER FallbackDotNetVersion
The default .NET version to use if the project content does not specify the SDK version.
.EXAMPLE
$Project = Get-Content -Path "C:\path\to\project.csproj"
$SdkVersion = Get-ProjectSdkVersion -ProjectContent $Project -FallbackDotNetVersion "8.x"
.NOTES
This function utilizes `ConvertTo-SystemVersion` for version string processing.
#>
function Get-ProjectSdkVersion {
    param (
        [ValidateNotNullOrEmpty()]
        [string]$ProjectContent,
        [string]$FallbackDotNetVersion
    )

    # Determine if the project is a .NET Standard project.
    $IsDotNetStandardProject = Test-DotNetStandardProject -ProjectContent $ProjectContent

    if ($IsDotNetStandardProject) {
        Write-Debug "Project is a .NET Standard project."
        
        if ($FallbackDotNetVersion) {
            return Convert-VersionString -VersionString $FallbackDotNetVersion
        }
        
        return $null
    }

    # Attempt to extract the SDK version from the project file.
    $ParsedSdkVersionString = ParseProjectFile -ProjectContent $ProjectContent

    if (-not $ParsedSdkVersionString) {
        Write-Debug "SDK version not found in project file. Using fallback version: $FallbackDotNetVersion."
        return Convert-VersionString -VersionString $FallbackDotNetVersion
    }

    Write-Debug "Parsed SDK version from project file: $ParsedSdkVersionString."

    # Convert the parsed SDK version into a System.Version object.
    $CurrentVersion = if ($ParsedSdkVersionString -Match "^\d+\.\d+$") {
        New-Object System.Version $ParsedSdkVersionString
    } else {
        ConvertTo-SystemVersion -VersionString $ParsedSdkVersionString
    }

    Write-Debug "Converted current SDK version to System.Version object: $CurrentVersion."
    return $CurrentVersion
}

function Convert-VersionString {
    param (
        [string]$VersionString
    )

    # Validate and convert the version string to a System.Version object, if possible.
    if (-not [string]::IsNullOrEmpty($VersionString)) {
        $ConvertedVersion = ConvertTo-SystemVersion -VersionString $VersionString
        Write-Debug "Converted version string to System.Version object: $ConvertedVersion."
        return $ConvertedVersion
    }

    return $null
}
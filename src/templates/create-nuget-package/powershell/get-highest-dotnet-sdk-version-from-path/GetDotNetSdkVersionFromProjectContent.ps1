<#
.SYNOPSIS
Extracts the SDK version from a project file's content.
.DESCRIPTION
The function retrieves the SDK version from the content of a .csproj file, focusing on the TargetFramework(s) value to identify patterns indicative of .NET versions (e.g., 'net5.0', 'net8.0').
.PARAMETER ProjectContent
A string representing the content of a .csproj file.
.EXAMPLE
$Project = Get-Content -Path "C:\path\to\project.csproj"
$DotNetSdkVersion = Get-DotNetSdkVersionFromProjectContent -ProjectContent $Project
Returns the SDK version (like "8.x") if found; otherwise, it returns `$null`.
.NOTES
- The function returns the major version with a ".x" suffix, indicating any minor version (like "8.x").
- It returns `$null` if no SDK version pattern matches or if an error occurs.
#>
function Get-DotNetSdkVersionFromProjectContent {
    param (
        [ValidateNotNullOrEmpty()]
        [string]$ProjectContent
    )

    try {
        # This regex pattern searches within the <TargetFramework> or <TargetFrameworks> tags in the .csproj file.
        # It captures the full framework identifier like 'net5.0' or 'net8.0'.
        $Pattern = '<TargetFramework(?:s)?>((?:net|netcoreapp)\d+\.\d+)'
        $Match = [regex]::Match($ProjectContent, $Pattern)

        # If no match is found, the function logs a debug message and returns null.
        if (-not $Match.Success) {
            Write-Debug "SDK version not detected in the 'netX.X' or 'netcoreappX.X' format."
            return $null
        }

        # Logging the entire matched value for diagnostic purposes.
        $SdkIdentifier = $Match.Groups[1].Value
        Write-Debug "Complete Matched SDK Identifier: $SdkIdentifier"

        # Retrieving the version number (e.g., "5.0") from the regex match.
        $SdkVersionRaw = $SdkIdentifier -replace '^(net|netcoreapp)', ''
        Write-Debug "Extracted Raw SDK Version: $SdkVersionRaw"

        # Parsing the major version from the full version number.
        $VersionParts = $SdkVersionRaw.Split('.')
        $MajorVersion = $VersionParts[0]
        $SdkVersionFormatted = "$MajorVersion.x"
        
        Write-Debug "Parsed Major SDK Version: $MajorVersion"
        Write-Debug "Formatted SDK Version: $SdkVersionFormatted"

        # Returning the formatted version, indicating the major version and any minor version (e.g., "8.x").
        return $SdkVersionFormatted
    } catch {
        # In case of an unexpected error during processing, the function logs a warning and returns null.
        Write-Warning "An error occurred while parsing the project file: $($_.Exception.Message)"
        return $null
    }
}
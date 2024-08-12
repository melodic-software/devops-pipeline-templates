<#
.SYNOPSIS
Determines the highest .NET SDK version from an array of project file paths.
.DESCRIPTION
Scans the provided project file paths, extracts the SDK version from each, and then identifies the highest version among them. If no version is detected, it uses the provided fallback .NET version.
.PARAMETER ProjectFiles
An array containing paths of the `.csproj` files to be analyzed.
.PARAMETER FallbackDotNetVersion
Fallback .NET version to utilize if no SDK version is detected in the project files.
.EXAMPLE
$projects = Get-ChildItem -Path "C:\path\to\projects" -Filter "*.csproj"
Get-HighestSdkVersion -ProjectFiles $projects.FullName -FallbackDotNetVersion "8.x"
.NOTES
This function relies on `Get-ProjectSdkVersion` and related helper functions to compute the highest SDK version.
#>
function Get-HighestSdkVersion {
    param (
        [Parameter(Mandatory=$true)]
        [array]$ProjectFiles,
        [string]$FallbackDotNetVersion
    )

    Write-Debug "Total project files: $($ProjectFiles.Count)"

    $HighestDotNetVersion = $null
    $FrameworkProjectFound = $false

    foreach ($ProjectFile in $ProjectFiles) {
        # Adding logging for better tracking and debugging.
        Write-Debug "Processing project file: $ProjectFile"

        # Get the content of the project file only once to improve performance.
        $ProjectContent = Get-Content -Path $ProjectFile -Raw
        $IsFrameworkProject = Test-DotNetFrameworkProject -ProjectContent $ProjectContent

        if ($IsFrameworkProject) {
            Write-Debug "Project is a .NET Framework project."
            $FrameworkProjectFound = $true
            continue
        }

        # Attempt to get the highest version from the project file.
        $HighestDotNetVersion = Get-SDKVersionFromProject -ProjectFilePath $ProjectFile -CurrentHighestVersion $HighestDotNetVersion
    }
    
    # Handling different scenarios for more accurate feedback and results.
    if ($null -eq $HighestDotNetVersion -and $FrameworkProjectFound) {
        Write-Host "Only .NET Framework projects were found. No .NET SDK versions detected."
        return $null
    }

    if ($null -eq $HighestDotNetVersion) {
        Write-Host "No valid .NET SDK versions found in project files. Using fallback version: $FallbackDotNetVersion"
        return ConvertTo-SystemVersion -VersionString $FallbackDotNetVersion
    }

    Write-Debug "Highest .NET SDK version found: $HighestDotNetVersion"
    return $HighestDotNetVersion
}
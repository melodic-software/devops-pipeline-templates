<#
.SYNOPSIS
Determines and sets the NuGet package ID based on the .csproj file or provided parameters.
.DESCRIPTION
This function attempts to extract the `PackageId` from the specified .csproj file within the source directory.
If a `PackageId` is found, it uses that as the NuGet package ID. If no `PackageId` is specified or the .csproj file cannot be found,
it defaults to using the provided project name as the package ID. Optionally, a package prefix can be added to the package ID.
The function sets the determined `NugetPackageId` as a pipeline variable for use in subsequent tasks.
.PARAMETER SourceDirectory
The root directory to search for the .csproj file.
.PARAMETER ProjectName
The name of the project, used as a fallback for the package ID if no `PackageId` is found in the .csproj file.
.PARAMETER PackagePrefix
An optional prefix to prepend to the package ID.
.EXAMPLE
$NugetPackageId = Set-NuGetPackageId -SourceDirectory "src" -ProjectName "MyProject" -PackagePrefix "MyCompany"
This command searches for the MyProject.csproj file in the src directory, extracts the PackageId, 
prepends the MyCompany prefix if necessary, and sets the NugetPackageId for subsequent tasks.
#>
function Set-NuGetPackageId {
    param(
        [string]$SourceDirectory,
        [string]$ProjectName,
        [string]$PackagePrefix
    )

    # Debugging logs
    Write-Host "SourceDirectory: $SourceDirectory"
    Write-Host "ProjectName: $ProjectName"
    Write-Host "PackagePrefix: $PackagePrefix"

    # Initialize the variable for the final package ID
    $NugetPackageId = $ProjectName

    # Attempt to extract the PackageId from the .csproj
    $CsProjPaths = Get-ChildItem -Path $SourceDirectory -Recurse -Filter "$ProjectName.csproj"

    # Debugging logs
    Write-Host "Searching in directory: $SourceDirectory"
    Write-Host "Looking for project file: $ProjectName.csproj"

    if ($CsProjPaths.Count -gt 0) {
        Write-Host "Found $($CsProjPaths.Count) matching .csproj files."
        $CsProjPath = $CsProjPaths[0].FullName
        Write-Host "Using .csproj file at: $CsProjPath"

        try {
            $ProjectXml = [xml](Get-Content -Path $CsProjPath)
            
            # Log the XML structure to understand its content
            Write-Host "Project XML structure: $($ProjectXml.OuterXml)"
            
            # Iterate through all PropertyGroup elements to find the PackageId
            $PropertyGroups = $ProjectXml.Project.PropertyGroup
            $PackageIdFound = $false
            
            foreach ($PropertyGroup in $PropertyGroups) {
                if ($PropertyGroup.PackageId) {
                    $ExtractedPackageId = $PropertyGroup.PackageId
                    if (-not [string]::IsNullOrWhiteSpace($ExtractedPackageId)) {
                        $NugetPackageId = $ExtractedPackageId.Trim()  # Trim any leading or trailing whitespace
                        Write-Host "Extracted PackageId from .csproj: '$NugetPackageId'"
                        $PackageIdFound = $true
                        break
                    }
                }
            }

            if (-not $PackageIdFound) {
                Write-Host "No PackageId specified in .csproj or it's an empty value. Using ProjectName as fallback."
                $NugetPackageId = $ProjectName
            }
            
        } catch {
            Write-Host "Warning: An error occurred while attempting to extract PackageId from .csproj. Using ProjectName as fallback."
            Write-Host "Error details: $_"
        }
    } else {
        Write-Host "Couldn't locate .csproj file for project $ProjectName. Using ProjectName as fallback."
    }

    # Adjust package name with prefix
    try {
        Write-Host "PackageId before adjustment: '$NugetPackageId'"
        if (-not [string]::IsNullOrEmpty($PackagePrefix)) {
            Write-Host "PackagePrefix: '$PackagePrefix'"
            if ($NugetPackageId -and -not $NugetPackageId.ToLower().StartsWith($PackagePrefix.ToLower())) {
                Write-Host "Adjusting PackageId with provided prefix: $PackagePrefix"
                $NugetPackageId = "$PackagePrefix.$NugetPackageId"
            } else {
                Write-Host "PackageId already contains the prefix or is null. No adjustment needed."
            }
        }
    } catch {
        Write-Host "Warning: Issue occurred while adjusting with prefix. Keeping the extracted/fallback package ID."
        Write-Host "Error details: $_"
    }

    # Logging the project name and package ID for clarity and debugging
    Write-Host "Final Project Name: $ProjectName"
    Write-Host "Final NuGet Package ID: '$NugetPackageId'"

    # Set the NugetPackageId in the pipeline variable for use in subsequent tasks
    try {
        Write-Host "Setting the NugetPackageId variable for subsequent tasks."
        Write-Host "##vso[task.setvariable variable=NugetPackageId]$NugetPackageId"
    } catch {
        Write-Error "Error: Failed to set the NugetPackageId variable for subsequent tasks."
        Write-Error "Error details: $_"
        exit 1
    }

    return $NugetPackageId
}

# Example usage of the function
#$NugetPackageId = Set-NuGetPackageId -SourceDirectory $SourceDirectory -ProjectName $ProjectName -PackagePrefix $PackagePrefix
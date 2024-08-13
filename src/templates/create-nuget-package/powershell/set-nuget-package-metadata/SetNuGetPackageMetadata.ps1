<#
.SYNOPSIS
Extracts and sets NuGet package metadata from the .nuspec or AssemblyInfo.cs files.
.DESCRIPTION
This function attempts to extract NuGet package metadata such as ID, Title, and Description from the specified .nuspec file. 
If the .nuspec file is not found or certain metadata is missing, it falls back to attempting extraction from the AssemblyInfo.cs file.
If neither source provides the metadata, the function uses fallback values based on the project name.
The extracted values are set as pipeline variables for use in subsequent tasks.
.PARAMETER SourceDirectory
The root directory to search for the .nuspec and AssemblyInfo.cs files.
.PARAMETER ProjectName
The name of the project, used as a fallback for the package ID and title if not found in the .nuspec or AssemblyInfo.cs files.
.EXAMPLE
Set-NuGetPackageMetadata -SourceDirectory "src" -ProjectName "MyProject"
This command searches for the MyProject.nuspec file in the src directory and extracts the metadata.
If the .nuspec file is not found, it searches for AssemblyInfo.cs in the src directory and extracts metadata from there.
#>
function Set-NuGetPackageMetadata {
    param(
        [string]$SourceDirectory,
        [string]$ProjectName
    )

    # Initialize with fallback values
    $NugetPackageId = $ProjectName
    $NugetPackageTitle = $ProjectName
    $NugetPackageDescription = ""

    # Attempt to get the values from the .nuspec file
    $NuspecPath = Get-ChildItem -Path $SourceDirectory -Recurse -Filter "$ProjectName.nuspec" | Select-Object -First 1

    if ($NuspecPath) {
        Write-Host "Found .nuspec file at $($NuspecPath.FullName). Attempting to extract metadata..."
        [xml]$NuspecContent = Get-Content -Path $NuspecPath.FullName

        $NugetPackageId = $NuspecContent.package.metadata.id -as [string]
        $NugetPackageTitle = $NuspecContent.package.metadata.title -as [string]
        
        if ($NugetPackageId -eq $null) {
            $NugetPackageId = $ProjectName
        }
        else {
            Write-Host "Extracted NuGet Package ID from .nuspec: $NugetPackageId"
        }

        if ($NugetPackageTitle -eq $null) {
            $NugetPackageTitle = $ProjectName
        }
        else {
            Write-Host "Extracted NuGet Package Title from .nuspec: $NugetPackageTitle"
        }
        
        $NugetPackageDescription = $NuspecContent.package.metadata.description -as [string]
        if ($NugetPackageDescription -eq $null) {
            $NugetPackageDescription = ""
        }
        else {
            Write-Host "Extracted NuGet Package Description from .nuspec: $NugetPackageDescription"
        }
    }
    else {
        Write-Host ".nuspec file not found for project $ProjectName. Falling back to defaults and AssemblyInfo.cs extraction (if available)."
    }

    # If values not found in .nuspec, attempt to get them from AssemblyInfo.cs
    if (-not $NugetPackageTitle -or -not $NugetPackageDescription) {
        $AssemblyInfoPath = Get-ChildItem -Path $SourceDirectory -Recurse -Filter "AssemblyInfo.cs" | Where-Object { $_.FullName -like "*\src\$ProjectName\Properties\*" } | Select-Object -First 1 
        
        if ($AssemblyInfoPath) {
            Write-Host "Found AssemblyInfo.cs at $($AssemblyInfoPath.FullName). Attempting to extract metadata..."
            $AssemblyInfoContent = Get-Content -Path $AssemblyInfoPath.FullName -Raw

            # Extract assembly title and description
            $TitleRegex = [regex]'AssemblyTitle\("([^"]+)"\)'
            $DescriptionRegex = [regex]'AssemblyDescription\("([^"]+)"\)'
            
            if (-not $NugetPackageTitle) {
                $AssemblyTitleMatch = $TitleRegex.Match($AssemblyInfoContent)
                if ($AssemblyTitleMatch.Success) {
                    $NugetPackageTitle = $AssemblyTitleMatch.Groups[1].Value
                    Write-Host "Extracted NuGet Package Title from AssemblyInfo.cs: $NugetPackageTitle"
                }
            }
            if (-not $NugetPackageDescription) {
                $AssemblyDescriptionMatch = $DescriptionRegex.Match($AssemblyInfoContent)
                if ($AssemblyDescriptionMatch.Success) {
                    $NugetPackageDescription = $AssemblyDescriptionMatch.Groups[1].Value
                    Write-Host "Extracted NuGet Package Description from AssemblyInfo.cs: $NugetPackageDescription"
                }
            }
        }
        else {
            Write-Host "AssemblyInfo.cs not found for project $ProjectName. Using default values."
        }
    }

    if ($NugetPackageId -eq $null) {
        $NugetPackageId = $ProjectName
    }

    # Logging the extracted/decided values
    Write-Host "NuGet Package Title: $NugetPackageTitle"
    Write-Host "NuGet Package Description: $NugetPackageDescription"

    # Set the NugetPackageTitle and NugetPackageDescription in the pipeline variable for use in subsequent tasks
    Write-Host "##vso[task.setvariable variable=NuGetPackageId;]$NugetPackageId"
    Write-Host "##vso[task.setvariable variable=NugetPackageTitle;]$NugetPackageTitle"
    Write-Host "##vso[task.setvariable variable=NugetPackageDescription;]$NugetPackageDescription"

    # Return the extracted values for further processing or testing
    return @{
        NuGetPackageId          = $NugetPackageId
        NuGetPackageTitle       = $NugetPackageTitle
        NuGetPackageDescription = $NugetPackageDescription
    }
}

# Example usage of the function
#$NuGetMetadata = Set-NuGetPackageMetadata -SourceDirectory $SourceDirectory -ProjectName $ProjectName
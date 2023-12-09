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
        $ExtractedPackageId = $ProjectXml.Project.PropertyGroup.PackageId
        if (-not [string]::IsNullOrWhiteSpace($ExtractedPackageId)) {
            $NugetPackageId = $ExtractedPackageId
            Write-Host "Extracted PackageId from .csproj: $NugetPackageId"
        } else {
            Write-Host "No PackageId specified in .csproj or it's an empty value. Using ProjectName as fallback."
            $NugetPackageId = $ProjectName
        }
    } catch {
        Write-Host "Warning: An error occurred while attempting to extract PackageId from .csproj. Using ProjectName as fallback."
    }
} else {
    Write-Host "Couldn't locate .csproj file for project $ProjectName. Using ProjectName as fallback."
}

# Adjust package name with prefix
try {
    if (-not [string]::IsNullOrEmpty($PackagePrefix)) {
        if (-not $NugetPackageId.StartsWith($PackagePrefix)) {
            Write-Host "Adjusting PackageId with provided prefix: $PackagePrefix"
            $NugetPackageId = "$PackagePrefix.$NugetPackageId"
        } else {
            Write-Host "PackageId already contains the prefix. No adjustment needed."
        }
    }
} catch {
    Write-Host "Warning: Issue occurred while adjusting with prefix. Keeping the extracted/fallback package ID."
}

# Logging the project name and package ID for clarity and debugging
Write-Host "Final Project Name: $ProjectName"
Write-Host "Final NuGet Package ID: $NugetPackageId"

# Set the NugetPackageId in the pipeline variable for use in subsequent tasks
try {
    Write-Host "Setting the NugetPackageId variable for subsequent tasks."
    Write-Host "##vso[task.setvariable variable=NugetPackageId]$NugetPackageId"
} catch {
    Write-Error "Error: Failed to set the NugetPackageId variable for subsequent tasks."
    exit 1
}
<#
.SYNOPSIS
Fetches the highest .NET SDK version based on the provided project path.
.DESCRIPTION
Parses the specified project path to identify and extract the highest .NET SDK version.
If any issues arise during this process, the script falls back to the `FallbackDotNetVersion` specified.
.PARAMETER ProjectPath
The path that might be directly associated with a `.csproj` file, include wildcards, or point to a directory.
.PARAMETER FallbackDotNetVersion
A default .NET version employed if no SDK version is extracted from the project files or in the event of an exception.
.PARAMETER SharedTemplateDirectory
A directory that contains shared PowerShell script templates.
.PARAMETER Warnings
A switch to toggle warning logs.
.PARAMETER Info
A switch to toggle informational logs.
.PARAMETER Verbose
A switch to toggle verbose logs.
.PARAMETER Debug
A switch to toggle debug logs.
.EXAMPLE
.\extract-dotnet-version.ps1 -ProjectPath "C:/path/to/projects" -FallbackDotNetVersion "8.x"
.NOTES
The script employs various helper functions to validate inputs, resolve paths, and ascertain the highest SDK version.
It then displays and returns the highest SDK version discovered or the fallback version if necessary.
#>
param (
    [ValidateNotNullOrEmpty()]
    [string]$ProjectPath,
    [ValidateNotNullOrEmpty()]
    [string]$FallbackDotNetVersion,
    [ValidateNotNullOrEmpty()]
    [string]$SharedTemplateDirectory,
    [switch]$Warnings = $false,
    [switch]$Info = $false,
    [switch]$Verbose = $false,
    [switch]$Debug = $false
)

# Set log level preferences
$WarningPreference = if ($Warnings) { 'Continue' } else { 'SilentlyContinue' }
$InformationPreference = if ($Info) { 'Continue' } else { 'SilentlyContinue' }
$VerbosePreference = if ($Verbose) { 'Continue' } else { 'SilentlyContinue' }
$DebugPreference = if ($Debug) { 'Continue' } else { 'SilentlyContinue' }

# Import the configuration
$Config = Import-PowerShellDataFile -Path (Join-Path $PSScriptRoot "config.psd1")

# Set default value for FallbackDotNetVersion if not provided or empty
if (-not $FallbackDotNetVersion) {
    $FallbackDotNetVersion = $Config.FallbackDotNetVersion
}

# Import necessary scripts
. (Join-Path -Path $SharedTemplateDirectory -ChildPath "powershell/functions/TestDotNetFrameworkProject.ps1")
. (Join-Path -Path $SharedTemplateDirectory -ChildPath "powershell/functions/is-dotnet-standard-project.ps1")
. (Join-Path -Path $SharedTemplateDirectory -ChildPath "powershell/functions/resolve-project-path.ps1")
. (Join-Path -Path $PSScriptRoot -ChildPath "functions/convert-to-system-version.ps1")
. (Join-Path -Path $PSScriptRoot -ChildPath "functions/convert-version-x-to-zero.ps1")
. (Join-Path -Path $PSScriptRoot -ChildPath "functions/find-project-files.ps1")
. (Join-Path -Path $PSScriptRoot -ChildPath "functions/get-highest-sdk-version.ps1")
. (Join-Path -Path $PSScriptRoot -ChildPath "functions/get-project-sdk-version.ps1")
. (Join-Path -Path $PSScriptRoot -ChildPath "functions/get-sdk-version-from-project.ps1")
. (Join-Path -Path $PSScriptRoot -ChildPath "functions/parse-project-file.ps1")

# Validate inputs before proceeding
if ($FallbackDotNetVersion -notmatch "^\d+\.x$") {
    throw "Fallback .NET version '$FallbackDotNetVersion' does not match the expected format (X.x)."
}

try {
    $ResolvedPath = Resolve-ProjectPath -Path $ProjectPath

    Write-Debug "Resolved path: $ResolvedPath"

    # Initialize $ProjectFiles as an array
    $ProjectFiles = @()
    if ($ResolvedPath.EndsWith(".csproj")) {
        $ProjectFiles += $ResolvedPath
    } else {
        $ProjectFiles += Find-ProjectFiles -Path $ResolvedPath
    }

    if ($ProjectFiles.Count -eq 0) {
        Write-Warning "No .csproj files found in the specified path."
    }

    [System.Version]$HighestVersion = Get-HighestSdkVersion -ProjectFiles $ProjectFiles -FallbackDotNetVersion $FallbackDotNetVersion
} catch {
    Write-Warning "Failed to parse the .NET SDK version from the .csproj file(s). Falling back to default version: $FallbackDotNetVersion."
    Write-Warning "Error details: $($_.Exception.Message)"
    $HighestVersion = $FallbackDotNetVersion
}

# If we did not find any .NET SDK versions OR only found .NET Framework projects, return null.
if (-not $HighestVersion) {
    Write-Debug "No .NET SDK version found or only .NET Framework projects discovered."
    return $null
}

# The result can't be a version object; we need to provide the major version with a wildcard for minor and patch.
# Use the fallback as needed.

$MajorVersionString = if ($HighestVersion) {
    Write-Debug "Highest SDK version: $HighestVersion"
    "$($HighestVersion.Major).x"  # Constructing the string based on the highest version found.
} else {
    Write-Warning "SDK Version not found. Using fallback value: $FallbackDotNetVersion"
    $FallbackDotNetVersion  # Using the fallback version since no SDK version was found.
}

Write-Information "SDK Version: $MajorVersionString"  # Display the SDK version being used.
Write-Output $MajorVersionString  # Return the value so it can be captured from the script output.
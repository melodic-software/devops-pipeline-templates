<#
.SYNOPSIS
Updates or removes the release notes of a project based on the provided parameters.
.DESCRIPTION
Analyzes the provided project file path and modifies its release notes section based on the `ReleaseNotes` parameter.
If the `ReleaseNotes` parameter is empty or "N/A", the script removes the `PackageReleaseNotes` node.
If a valid `ReleaseNotes` value is provided, the node is either updated or added.
.PARAMETER ReleaseNotes
Release note content to be set. If blank or "N/A", the `PackageReleaseNotes` node will be removed.
.PARAMETER ProjectPath
Absolute or relative path to the target .csproj file to be processed.
.EXAMPLE
.\update-release-notes.ps1 -ReleaseNotes "Bug fixes and improvements" -ProjectPath "C:/path/to/project.csproj"
.NOTES
This script leverages helper functions like `Resolve-ProjectPath`, `RemovePackageReleaseNotes`, `UpdatePackageReleaseNotes`, and `AddPackageReleaseNotes` to perform its operations.
#>
param (
    [string]$ReleaseNotes,
    [string]$ProjectPath,
    [string]$SharedTemplateDirectory
)

# Dot-source the functions using Join-Path
. (Join-Path -Path $SharedTemplateDirectory -ChildPath "powershell/functions/resolve-project-path.ps1")
. (Join-Path -Path $PSScriptRoot -ChildPath "functions/remove-package-release-notes.ps1")
. (Join-Path -Path $PSScriptRoot -ChildPath "functions/update-package-release-notes.ps1")
. (Join-Path -Path $PSScriptRoot -ChildPath "functions/add-package-release-notes.ps1")

$ResolvedProjectPath = Resolve-ProjectPath -Path $ProjectPath

Write-Host "Resolved project path: $ResolvedProjectPath"

# Check if the project file exists
if (-not (Test-Path $ResolvedProjectPath)) {
    Write-Error "Project file at $ResolvedProjectPath not found!"
    exit 1
}

$Xml = [xml](Get-Content $ResolvedProjectPath)

# If ReleaseNotes is either blank or "N/A", remove the node
if (-not $ReleaseNotes -or $ReleaseNotes -eq "N/A") {
    RemovePackageReleaseNotes $Xml
}
# If there's a valid ReleaseNotes value, add or update the node
elseif ($ReleaseNotes) {
    UpdatePackageReleaseNotes $Xml $ReleaseNotes
}

$Xml.Save($ResolvedProjectPath)
<#
.SYNOPSIS
    Updates or removes the release notes of a project based on the provided parameters.
.DESCRIPTION
    Analyzes the provided project file path and modifies its release notes section based on the `ReleaseNotes` parameter.
    If the `ReleaseNotes` parameter is empty or "N/A", the function removes the `PackageReleaseNotes` node.
    If a valid `ReleaseNotes` value is provided, the node is either updated or added.
.PARAMETER ReleaseNotes
    Release note content to be set. If blank or "N/A", the `PackageReleaseNotes` node will be removed.
.PARAMETER ProjectPath
    Absolute or relative path to the target .csproj file to be processed.
.PARAMETER SharedTemplateDirectory
    Path to the directory containing shared PowerShell function templates.
.EXAMPLE
    Update-ReleaseNotes -ReleaseNotes "Bug fixes and improvements" -ProjectPath "C:/path/to/project.csproj" -SharedTemplateDirectory "C:/path/to/templates"
.NOTES
    This function leverages helper functions like `Find-ProjectPath`, `Remove-ReleaseNotesFromCsproj`, `Update-ReleaseNotesInCsproj`, and `Add-ReleaseNotesToCsproj` to perform its operations.
#>
function Update-ReleaseNotes {
    param (
        [string]$ReleaseNotes,
        [string]$ProjectPath,
        [string]$SharedTemplateDirectory
    )

    # Dot-source the functions using Join-Path
    . (Join-Path -Path $SharedTemplateDirectory -ChildPath "powershell/functions/FindProjectPath.ps1")
    . (Join-Path -Path $PSScriptRoot -ChildPath "Remove-ReleaseNotesFromCsproj.ps1")
    . (Join-Path -Path $PSScriptRoot -ChildPath "Update-ReleaseNotesInCsproj.ps1")
    . (Join-Path -Path $PSScriptRoot -ChildPath "Add-ReleaseNotesToCsproj.ps1")

    $ResolvedProjectPath = Find-ProjectPath -Path $ProjectPath

    Write-Host "Resolved project path: $ResolvedProjectPath"

    # Check if the project file exists
    if (-not (Test-Path $ResolvedProjectPath)) {
        Write-Error "Project file at $ResolvedProjectPath not found!"
        exit 1
    }

    $Xml = [xml](Get-Content $ResolvedProjectPath)

    # If ReleaseNotes is either blank or "N/A", remove the node
    if (-not $ReleaseNotes -or $ReleaseNotes -eq "N/A") {
        Remove-ReleaseNotesFromCsproj -XmlDocument $Xml
    }
    # If there's a valid ReleaseNotes value, add or update the node
    elseif ($ReleaseNotes) {
        Update-ReleaseNotesInCsproj -XmlDocument $Xml -Notes $ReleaseNotes
    }

    $Xml.Save($ResolvedProjectPath)
}
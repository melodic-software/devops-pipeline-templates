<#
.SYNOPSIS
Configures the versioning behavior based on the provided Git branch and GitVersion configuration.
.DESCRIPTION
This script is designed to dynamically update the templated GitVersion configuration.
It ensures the necessary dependencies are present, sets the appropriate pre-release tags based on the branch, and appends any repository-specific ignore SHA configurations.
.PARAMETER SourceBranch
Specifies the name of the Git branch for which the versioning needs to be configured.
.PARAMETER GitVersionConfigPath
Path to the GitVersion configuration file that governs versioning rules.
.PARAMETER WorkingDirectory
Specifies the working directory where temporary files or modules might be stored or referenced.
.EXAMPLE
.\configure-git-version.ps1 -SourceBranch "feature/new-feature" -GitVersionConfigPath "C:\path\to\gitversion.yml" -WorkingDirectory "C:\workspace"
Configures versioning for the "feature/new-feature" branch based on rules defined in the provided GitVersion configuration file.
.NOTES
This script relies on helper scripts to load necessary modules, set the pre-release tag, and append ignore SHA configuration, respectively.
Always ensure the required helper scripts are present in the relative "functions" directory for smooth operations.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$SourceBranch,
    [Parameter(Mandatory=$true)]
    [string]$GitVersionConfigPath,
    [Parameter(Mandatory=$true)]
    [string]$WorkingDirectory
)

# Import required helper functions
$RequiredScripts = @(
    "download-yaml-module.ps1",
    "ensure-yaml-module.ps1",
    "set-pre-release-tag.ps1"
    "append-ignore-sha-config.ps1"
)

foreach ($Script in $RequiredScripts) {
    $ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath "functions/$Script"
    
    if (-not (Test-Path -Path $ScriptPath)) {
        Write-Error "Required script '$Script' is missing from the 'functions' directory. Please ensure it exists and try again."
        return
    }
    
    . $ScriptPath
}

# Ensure the 'powershell-yaml' module is available for use
EnsureYamlModule -WorkingDirectory $WorkingDirectory

# Process the GitVersion configuration based on the source branch
Set-PreReleaseTag -BranchName $SourceBranch -ConfigPath $GitVersionConfigPath

# Append ignore SHA configuration if available
AppendIgnoreShaConfig -ConfigDirectory $WorkingDirectory -GitVersionConfigPath $GitVersionConfigPath

# Log the GitConfig.yml file
try {
    # Load the YAML file and parse it
    # This requires the YAML PowerShell module
    $YamlContent = Get-Content -Path $GitVersionConfigPath -Raw
    $ParsedYaml = ConvertFrom-Yaml -Yaml $YamlContent

    # Convert the object back to a YAML string with indentation
    # TODO: ensure YAML is formatted EXACTLY as is (no reordering)
    $IndentedYaml = ConvertTo-Yaml -Data $ParsedYaml
    Write-Host "Content of GitVersion.yml:"
    Write-Host $IndentedYaml
} catch {
    Write-Error "Failed to read and parse GitVersion.yml file at '$GitVersionConfigPath'. Error: $_"
}
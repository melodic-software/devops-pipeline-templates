<#
.SYNOPSIS
Updates the pre-release tag in the GitVersion configuration based on the specified Git branch.
.DESCRIPTION
The `Set-PreReleaseTag` function adjusts the GitVersion configuration to set the appropriate pre-release tag based on the branch name.
For both feature and hotfix branches, it extracts the respective branch's name and uses it as the pre-release tag.
.PARAMETER BranchName
The name of the Git branch for which the pre-release tag needs to be configured.
.PARAMETER ConfigPath
Path to the GitVersion configuration file that governs versioning rules.
.EXAMPLE
Set-PreReleaseTag -BranchName "refs/heads/feature/new-feature" -ConfigPath "C:\path\to\gitversion.yml"
Updates the GitVersion configuration file to set the pre-release tag as "new-feature" based on the provided feature branch.
.EXAMPLE
Set-PreReleaseTag -BranchName "refs/heads/hotfix/urgent-fix" -ConfigPath "C:\path\to\gitversion.yml"
Updates the GitVersion configuration file to set the pre-release tag as "urgent-fix" based on the provided hotfix branch.
.NOTES
This function targets feature and hotfix branches, deriving the pre-release tag from the branch's name.
Always ensure to back up your configuration or use source control before applying modifications with this function.
#>
function Set-PreReleaseTag {
    param(
        [Parameter(Mandatory=$true)]
        [string] $BranchName,
        [Parameter(Mandatory=$true)]
        [string] $ConfigPath
    )

    # Ensure the GitVersion config file exists
    if (-not (Test-Path $ConfigPath)) {
        Write-Error "The GitVersion configuration file '$ConfigPath' does not exist."
        return
    }

    # Load the GitVersion configuration
    try {
        $Config = (Get-Content -Path $ConfigPath -Raw) | ConvertFrom-Yaml
    } catch {
        Write-Error "Failed to load the GitVersion configuration from '$ConfigPath'. Error: $($_.Exception.Message)"
        return
    }

    # Determine the branch type and extract the name
    switch ($BranchName) {
        { $_ -match '^refs/heads/features?/' } {  # Matches both 'feature/' and 'features/'
            $BranchTagName = ($_ -split '/')[-1]  # Extract the leaf name
            $Config.branches.feature.tag = $BranchTagName
            Write-Host "Feature branch detected. Setting the pre-release tag to: $BranchTagName"
        }
        { $_ -match '^refs/heads/hotfix(es)?/' } {  # Matches both 'hotfix/' and 'hotfixes/'
            $BranchTagName = ($_ -split '/')[-1]  # Extract the leaf name
            $Config.branches.hotfix.tag = $BranchTagName
            Write-Host "Hotfix branch detected. Setting the pre-release tag to: $BranchTagName"
        }
        default {
            Write-Host "GitVersion.yml does not need modification for branch: $BranchName. No changes were made."
            return
        }
    }

    # Save the updated configuration
    try {
        $Config | ConvertTo-Yaml | Set-Content -Path $ConfigPath
        Write-Host "GitVersion configuration updated successfully."
    } catch {
        Write-Error "Failed to save the updated GitVersion configuration. Error: $($_.Exception.Message)"
    }
}
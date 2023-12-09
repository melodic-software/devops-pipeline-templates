<#
.SYNOPSIS
Appends repository-specific ignore SHA configurations to the templated GitVersion configuration file.
.DESCRIPTION
The `AppendIgnoreShaConfig` function enhances the GitVersion configuration by appending ignore SHA settings from a `GitVersionIgnoreSHA.yml` file found within the specified directory or its subdirectories.
This allows for dynamic customization of the GitVersion configuration based on repository-specific needs, particularly for ignoring certain SHAs during version calculation.
.PARAMETER ConfigDirectory
The directory to search for the `GitVersionIgnoreSHA.yml` file.
This search is recursive and includes all subdirectories.
.PARAMETER GitVersionConfigPath
The full path to the `GitVersion.yml` file that is used for versioning.
.EXAMPLE
AppendIgnoreShaConfig -ConfigDirectory "C:\MyRepository" -GitVersionConfigPath "C:\MyRepository\GitVersion.yml"
This example searches for a `GitVersionIgnoreSHA.yml` file within `C:\MyRepository` and its subdirectories.
If found, it appends the ignore SHA configuration from this file to the `GitVersion.yml` file at `C:\MyRepository\GitVersion.yml`.
.NOTES
- The function performs a recursive search in the specified `ConfigDirectory` for a file named `GitVersionIgnoreSHA.yml`.
- If multiple `GitVersionIgnoreSHA.yml` files are found, preference is given to a file located under a `src` directory, excluding any whose parent directory name contains 'template' (case-insensitive).
- If a suitable `GitVersionIgnoreSHA.yml` file is found, its contents are appended to the `GitVersion.yml` file specified by `GitVersionConfigPath`.
- The function assumes that the contents of `GitVersionIgnoreSHA.yml` are correctly formatted for GitVersion.
- If no suitable `GitVersionIgnoreSHA.yml` file is found, no changes are made to `GitVersion.yml`, and the function exits without error.
- This function is typically used in build scripts or CI/CD pipelines to dynamically adjust the GitVersion configuration on a per-repository basis.
#>
function AppendIgnoreShaConfig {
    param(
        [Parameter(Mandatory=$true)]
        [string] $ConfigDirectory,
        [Parameter(Mandatory=$true)]
        [string] $GitVersionConfigPath
    )

    Write-Host "Searching for GitVersionIgnoreSHA.yml files in $ConfigDirectory..."

    # Search for all instances of GitVersionIgnoreSHA.yml file recursively within the ConfigDirectory
    $IgnoreShaConfigFiles = Get-ChildItem -Path $ConfigDirectory -Filter "GitVersionIgnoreSHA.yml" -Recurse -File

    Write-Host "$($IgnoreShaConfigFiles.Count) GitVersionIgnoreSHA.yml file(s) found."

    try {
        # Apply additional filtering only if more than one file is found
        if ($IgnoreShaConfigFiles.Count -gt 1) {
            Write-Host "Multiple GitVersionIgnoreSHA.yml files found. Applying additional filtering criteria..."
            $IgnoreShaConfigFiles = $IgnoreShaConfigFiles | Where-Object {
                $_.DirectoryName -match '\\src\\' -and
                -not ($_.DirectoryName -split '\\src\\')[0] -match 'template'
            }
            Write-Host "Filtering completed. Number of files after filtering: $($IgnoreShaConfigFiles.Count)"
        }
    } catch {
        Write-Host "Error occurred during filtering. Using the first GitVersionIgnoreSHA.yml file found. Error: $($_.Exception.Message)"
    }

    # Select the first file from the filtered or unfiltered list
    $IgnoreShaConfigPath = $IgnoreShaConfigFiles | Select-Object -First 1

    if ($IgnoreShaConfigPath) {
        $IgnoreShaConfigFullPath = $IgnoreShaConfigPath.FullName
        Write-Host "Using GitVersionIgnoreSHA.yml file located at: $IgnoreShaConfigFullPath"
        Write-Host "Appending ignore SHA configuration to $GitVersionConfigPath..."

        try {
            # Append the content as plain text
            $ContentToAppend = Get-Content $IgnoreShaConfigFullPath -Raw
            Add-Content -Value "`n$ContentToAppend" -Path $GitVersionConfigPath
            Write-Host "Ignore SHA configuration appended successfully."
        } catch {
            Write-Error "Failed to append ignore SHA configuration. Error: $($_.Exception.Message)"
        }
    } else {
        Write-Host "No suitable ignore SHA configuration file found. No changes made to GitVersion.yml."
    }
}
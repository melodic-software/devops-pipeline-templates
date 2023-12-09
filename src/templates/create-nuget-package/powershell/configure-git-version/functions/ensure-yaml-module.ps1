<#
.SYNOPSIS
Ensures the 'powershell-yaml' module is available in the current PowerShell session.
.DESCRIPTION
This function checks if the 'powershell-yaml' module is already installed in the session.
If it isn't found, the function attempts to install it from the PowerShell Gallery.
Should the installation fail, it then tries to manually download and extract the module from a provided URL.
.PARAMETER WorkingDirectory
The directory where the module will be downloaded and extracted, if necessary.
This should ideally be set to a directory that has adequate permissions.
.EXAMPLE
EnsureYamlModule -WorkingDirectory "(Build.SourcesDirectory)"
.NOTES
For the manual download and extraction to work, the function relies on the `DownloadYamlModule` function.
Make sure it's available and loaded in the current session.
#>
function EnsureYamlModule {
    param(
        [Parameter(Mandatory=$true)]
        [string] $WorkingDirectory
    )

    # Validate WorkingDirectory
    if (-not (Test-Path $WorkingDirectory)) {
        throw "Provided WorkingDirectory '$WorkingDirectory' does not exist. Exiting function."
    }

    # Import the configuration
    $Config = Import-PowerShellDataFile -Path (Join-Path $PSScriptRoot "..\config.psd1")

    # Check if 'powershell-yaml' is already available
    $Module = Get-Module -ListAvailable -Name 'powershell-yaml'

    if ($Module) {
        Write-Host "The 'powershell-yaml' module is already available."
        return
    }

    Write-Host "The required module 'powershell-yaml' is not installed. Attempting to install..."

    try {
        # Try using Install-PSResource from PowerShellGet 3.0, if available
        if (Get-Command -Name 'Install-PSResource' -ErrorAction SilentlyContinue) {
            Install-PSResource -Name 'powershell-yaml' -Scope CurrentUser -Force
            Write-Host "'powershell-yaml' module installed successfully using Install-PSResource."
        } else {
            # If Install-PSResource is not available, fall back to Install-Module
            Install-Module -Name 'powershell-yaml' -Scope CurrentUser -Confirm:$false -Force -SkipPublisherCheck -AllowClobber
            Write-Host "'powershell-yaml' module installed successfully from the PowerShell Gallery."
        }
    } catch {
        Write-Warning "An error occurred while attempting to install the 'powershell-yaml' module. Error: $($_.Exception.Message)"
        Write-Host "Attempting to download and load the 'powershell-yaml' module manually..."
        
        # Check if the nested function 'DownloadYamlModule' is available
        if (Get-Command -Name 'DownloadYamlModule' -ErrorAction SilentlyContinue) {
            DownloadYamlModule -YamlModuleUrl $Config.YamlModuleUrl -RetryCount 3 -RetryInterval 10 -WorkingDirectory $WorkingDirectory
        } else {
            Write-Error "DownloadYamlModule function not available. Cannot proceed with manual download."
        }
    }
}
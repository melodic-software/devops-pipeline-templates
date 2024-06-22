$RequiredPesterVersion = '5.5.0'

function Install-Pester {
    param (
        [Version]$Version
    )
    Write-Host "Installing Pester version $Version..."
    Install-Module -Name Pester -RequiredVersion $Version -Force -Scope CurrentUser -SkipPublisherCheck
}

try {
    # Ensure the latest list of installed modules is available
    Write-Host "Refreshing available modules..."
    $null = Get-Module -ListAvailable -Refresh

    # Check if the required Pester version is available
    $PesterModule = Get-Module -ListAvailable -Name Pester | Where-Object { $_.Version -ge [version]$RequiredPesterVersion }

    if (-not $PesterModule) {
        Write-Host "Required Pester version not found. Installing..."
        Install-Pester -Version $RequiredPesterVersion
    } else {
        Write-Host "Pester version $RequiredPesterVersion or higher is already installed."
    }

    # Import Pester module
    if ($PesterModule) {
        $ModulePath = $PesterModule.ModuleBase
        Write-Host "Importing Pester from $ModulePath..."
        Import-Module -Name Pester -RequiredVersion $RequiredPesterVersion -ErrorAction Stop -Verbose
    } else {
        Write-Host "Attempting to import Pester without specifying a path."
        Import-Module -Name Pester -RequiredVersion $RequiredPesterVersion -ErrorAction Stop -Verbose
    }

    # Re-check if the correct version is installed
    $InstalledPester = Get-Module -Name Pester | Where-Object { $_.Version -ge [version]$RequiredPesterVersion }
    if (-not $InstalledPester) {
        Write-Error "Failed to install or load required Pester version $RequiredPesterVersion."
        exit 1
    }
    else {
        Write-Host "Pester installation/update successful."
    }
} catch {
    Write-Error "An error occurred: $_"
    exit 1
} finally {
    # Check for interactive host and non-Azure DevOps environment
    if ($Host.UI.RawUI -and (Test-Path Env:\AGENT_ID) -eq $false) {
        Write-Host "Press any key to continue ..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}
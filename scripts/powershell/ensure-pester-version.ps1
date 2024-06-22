$RequiredPesterVersion = '5.5.0'

function Install-Pester {
    param (
        [Version]$Version
    )
    Write-Host "Installing Pester version $Version..."
    Install-Module -Name Pester -RequiredVersion $Version -Force -Scope CurrentUser -SkipPublisherCheck
}

try {
    # Check if the required Pester version is available
    $PesterModule = Get-Module -ListAvailable -Name Pester | Where-Object { $_.Version -ge [version]$RequiredPesterVersion }

    if (-not $PesterModule) {
        Install-Pester -Version $RequiredPesterVersion
    }
    else {
        Write-Host "Pester version $RequiredPesterVersion or higher is already installed."
    }

    # Import Pester module
    Import-Module -Name Pester -RequiredVersion $RequiredPesterVersion -ErrorAction Stop

    # Re-check if the correct version is installed
    $InstalledPester = Get-Module -Name Pester | Where-Object { $_.Version -ge [version]$RequiredPesterVersion }
    if (-not $InstalledPester) {
        Write-Error "Failed to install required Pester version $RequiredPesterVersion"
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
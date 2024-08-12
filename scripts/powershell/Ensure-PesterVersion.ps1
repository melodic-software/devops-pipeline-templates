$RequiredPesterVersion = '5.5.0'

function Install-Pester {
    param (
        [Version]$Version
    )
    Write-Host "Installing Pester version $Version..."
    Install-Module -Name Pester -RequiredVersion $Version -Force -Scope CurrentUser -SkipPublisherCheck
}

try {
    # Refreshing the list of installed modules.
    Write-Host "Refreshing available modules..."
    $null = Get-Module -ListAvailable -Refresh

    # Check the highest version of Pester available
    $PesterModule = Get-Module -ListAvailable -Name Pester | 
                    Where-Object { $_.Version -ge [version]$RequiredPesterVersion } |
                    Sort-Object Version -Descending |
                    Select-Object -First 1

    if (-not $PesterModule) {
        Write-Host "Required Pester version not found. Installing version $RequiredPesterVersion..."
        Install-Pester -Version $RequiredPesterVersion
    } else {
        Write-Host "Using Pester version $($PesterModule.Version)."
    }

    # Import the Pester module
    $ModulePath = Join-Path $PesterModule.ModuleBase "Pester.psd1"
    Write-Host "Importing Pester from $ModulePath..."
    Import-Module -Name $ModulePath -ErrorAction Stop

    # Re-check the imported version.
    $InstalledPester = Get-Module -Name Pester
    if (-not $InstalledPester) {
        Write-Error "Failed to load Pester."
        exit 1
    } else {
        Write-Host "Successfully loaded Pester version $($InstalledPester.Version)."
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
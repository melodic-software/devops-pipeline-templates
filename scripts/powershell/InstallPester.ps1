$RequiredPesterVersion = '5.x'

function Install-Pester {
    param (
        [Version]$Version
    )
    Write-Host "Installing Pester version $Version..."
    try {
        Install-Module -Name Pester -RequiredVersion $Version -Force -Scope CurrentUser -SkipPublisherCheck
        Write-Host "Pester version $Version installed successfully."
    } catch {
        Write-Error "Failed to install Pester version $Version. Error: $_"
        exit 1
    }
}

try {
    Write-Host "Refreshing available modules..."
    $null = Get-Module -ListAvailable -Refresh

    Write-Host "Checking for installed versions of Pester..."
    $PesterModule = Get-Module -ListAvailable -Name Pester | 
                    Where-Object { $_.Version -eq [version]$RequiredPesterVersion } |
                    Sort-Object Version -Descending |
                    Select-Object -First 1

    if (-not $PesterModule) {
        Write-Host "Required Pester version $RequiredPesterVersion not found. Installing..."
        Install-Pester -Version $RequiredPesterVersion
        $PesterModule = Get-Module -ListAvailable -Name Pester | 
                        Where-Object { $_.Version -eq [version]$RequiredPesterVersion } |
                        Sort-Object Version -Descending |
                        Select-Object -First 1
    }

    if (-not $PesterModule) {
        Write-Error "Pester module installation failed or version $RequiredPesterVersion not found."
        exit 1
    } else {
        Write-Host "Using Pester version $($PesterModule.Version)."
    }

    $ModulePath = Join-Path $PesterModule.ModuleBase "Pester.psd1"
    Write-Host "Importing Pester from $ModulePath..."
    try {
        Import-Module -Name $ModulePath -ErrorAction Stop
        Write-Host "Successfully imported Pester."
    } catch {
        Write-Error "Failed to import Pester from $ModulePath. Error: $_"
        exit 1
    }

    $InstalledPester = Get-Module -Name Pester
    if (-not $InstalledPester) {
        Write-Error "Failed to load Pester after installation."
        exit 1
    } else {
        Write-Host "Successfully loaded Pester version $($InstalledPester.Version)."
    }
} catch {
    Write-Error "An unexpected error occurred: $_"
    exit 1
} finally {
    if ($Host.UI.RawUI -and (Test-Path Env:\AGENT_ID) -eq $false) {
        Write-Host "Press any key to continue ..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}
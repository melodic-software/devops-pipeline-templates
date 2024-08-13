# Initialize variable to track the number of failed tests
$TotalFailedTests = 0

# Suppress all non-critical streams for this session
$VerbosePreference = 'SilentlyContinue'
$DebugPreference = 'SilentlyContinue'
$InformationPreference = 'SilentlyContinue'
$WarningPreference = 'SilentlyContinue'
$ErrorActionPreference = 'SilentlyContinue'

# Run Pester tests for each test file
Get-ChildItem -Path "$PSScriptRoot" -Recurse -Filter "*.tests.ps1" | ForEach-Object {
    # Run tests with Pester-specific output, suppressing all other streams in this script's scope
    $TestResult = Invoke-Pester -Path $_.FullName -PassThru -Output Minimal
    $TotalFailedTests += $TestResult.FailedCount
}

# Output total failed tests count, conditionally based on environment
Write-Host "Total failed tests: $TotalFailedTests"

# Check for interactive host and non-Azure DevOps environment
if ($Host.UI.RawUI -and (Test-Path Env:\AGENT_ID) -eq $false) {
    Write-Host "Press any key to continue ..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Check if there were any failed tests
if ($TotalFailedTests -gt 0) {
    exit 1
}

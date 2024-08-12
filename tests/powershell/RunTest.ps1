& "$PSScriptRoot/create-nuget-package/set-nuget-package-id/SetNugetPackageId.Tests.ps1" -ErrorAction SilentlyContinue

# Check if the current host is interactive and if the script is not running in Azure DevOps
if ($Host.UI.RawUI -and (Test-Path Env:\AGENT_ID) -eq $false) {
    Write-Host "Press any key to continue ..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
& "$PSScriptRoot/create-nuget-package/configure-git-version/configure-git-version.tests.ps1" -ErrorAction SilentlyContinue

# Check if the current host is interactive and if the script is not running in Azure DevOps
if ($Host.UI.RawUI -and (Test-Path Env:\AGENT_ID) -eq $false) {
    Write-Host "Press any key to continue ..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
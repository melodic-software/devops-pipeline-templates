Describe "EnsureYamlModule Tests" {
    BeforeAll {
        . "$PSScriptRoot/../../../../../src/templates/create-nuget-package/powershell/configure-git-version/functions/ensure-yaml-module.ps1"

        # Define a dummy function for DownloadYamlModule
        
        function Install-PSResource { }
        function DownloadYamlModule { }

        # Mocks
        # Ensure Install-PSResource is not found to test Install-Module path
        Mock Get-Command { return $null } -ParameterFilter { $Name -eq 'Install-PSResource' }
        # Force both Install-PSResource and Install-Module to fail
        Mock Install-PSResource { throw "Installation failed" }
        Mock Install-Module { throw "Installation failed" }
        Mock DownloadYamlModule { }
        Mock Get-Module { return $null } -ParameterFilter { $Name -eq 'powershell-yaml' }
        Mock Test-Path { return $true }
        Mock Import-PowerShellDataFile { return @{ YamlModuleUrl = "http://example.com/module.zip" } }
    }

    It "Detects existing 'powershell-yaml' module" {
        Mock Get-Module { return @{ Name = 'powershell-yaml' } } -ParameterFilter { $Name -eq 'powershell-yaml' }

        EnsureYamlModule -WorkingDirectory "C:\SomeDirectory"
        Should -Invoke -CommandName Get-Module -Exactly -Times 1
    }

    It "Installs the 'powershell-yaml' module if Install-PSResource is not present" {
        EnsureYamlModule -WorkingDirectory "C:\SomeDirectory"
        Should -Invoke -CommandName Install-Module -Exactly -Times 1
    }

    It "Attempts manual download if installation fails" {
        EnsureYamlModule -WorkingDirectory "C:\SomeDirectory"
        Should -Invoke -CommandName DownloadYamlModule -Exactly -Times 1
    }

    It "Throws error if working directory is invalid" {
        Mock Test-Path { return $false }
        { 
            EnsureYamlModule -WorkingDirectory "InvalidDirectory" 
        } | Should -Throw -ExpectedMessage "Provided WorkingDirectory 'InvalidDirectory' does not exist. Exiting function."
    }

    It "Throws error if DownloadYamlModule function is unavailable" {
        Mock Get-Command { return $null } -ParameterFilter { $Name -eq 'DownloadYamlModule' }
        $Error.Clear()
        & { EnsureYamlModule -WorkingDirectory "C:\SomeDirectory" }
        $Error[0].Exception.Message | Should -Contain "DownloadYamlModule function not available. Cannot proceed with manual download."
    }
}
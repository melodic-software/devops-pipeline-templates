Describe "DownloadYamlModule Function Tests" {

    BeforeAll {
        . "$PSScriptRoot/../../../../../src/templates/create-nuget-package/powershell/configure-git-version/functions/download-yaml-module.ps1"
    }

    Context "Successful download and extraction on the first attempt" {
        It "Downloads, extracts, and loads the module without retries" {
            Mock Invoke-WebRequest {} -ParameterFilter { $Uri -eq 'https://example.com/powershell-yaml.zip' }
            Mock Expand-Archive {} -ParameterFilter { $Path -like "*.zip" }
            Mock Get-ChildItem { 
                return [PSCustomObject]@{ FullName = Join-Path -Path $TestDrive -ChildPath "powershell-yaml\powershell-yaml.psd1" } 
            } -ParameterFilter { $Filter -eq "*.psd1" }
            Mock Import-Module {} -ParameterFilter { $Name -like "*powershell-yaml.psd1" }
    
            DownloadYamlModule -YamlModuleUrl 'https://example.com/powershell-yaml.zip' -RetryCount 3 -RetryInterval 2 -WorkingDirectory "$TestDrive"
    
            Assert-MockCalled -CommandName Invoke-WebRequest -Exactly 1
            Assert-MockCalled -CommandName Expand-Archive -Exactly 1
            Assert-MockCalled -CommandName Get-ChildItem -Exactly 1
            Assert-MockCalled -CommandName Import-Module -Exactly 1
        }
    }

    Context "Failure in module extraction" {
        It "Retries downloading when module extraction fails" {
            Mock Invoke-WebRequest {} -ParameterFilter { $Uri -eq 'https://example.com/powershell-yaml.zip' }
            Mock Expand-Archive { throw "Extraction failed" } -ParameterFilter { $Path -like "*.zip" }
            Mock Get-ChildItem { 
                return [PSCustomObject]@{ FullName = Join-Path -Path $TestDrive -ChildPath "powershell-yaml\powershell-yaml.psd1" } 
            } -ParameterFilter { $Filter -eq "*.psd1" }
            Mock Import-Module {} -ParameterFilter { $Name -like "*powershell-yaml.psd1" }
    
            { 
                DownloadYamlModule -YamlModuleUrl 'https://example.com/powershell-yaml.zip' -RetryCount 3 -RetryInterval 2 -WorkingDirectory "$TestDrive"
            } | Should -Throw "All retry attempts failed."
    
            Assert-MockCalled -CommandName Invoke-WebRequest -Times 3
            Assert-MockCalled -CommandName Expand-Archive -Times 3
            Assert-MockCalled -CommandName Import-Module -Times 0
        }
    }

    Context "Failure in module loading" {
        It "Retries downloading when module loading fails" {
            Mock Invoke-WebRequest {} -ParameterFilter { $Uri -eq 'https://example.com/powershell-yaml.zip' }
            Mock Expand-Archive {} -ParameterFilter { $Path -like "*.zip" }
            Mock Get-ChildItem { 
                return [PSCustomObject]@{ FullName = Join-Path -Path $TestDrive -ChildPath "powershell-yaml\powershell-yaml.psd1" } 
            } -ParameterFilter { $Filter -eq "*.psd1" }
            Mock Import-Module { throw "Loading failed" } -ParameterFilter { $Name -like "*powershell-yaml.psd1" }
    
            { 
                DownloadYamlModule -YamlModuleUrl 'https://example.com/powershell-yaml.zip' -RetryCount 3 -RetryInterval 2 -WorkingDirectory "$TestDrive" 
            } | Should -Throw "All retry attempts failed."
    
            Assert-MockCalled -CommandName Invoke-WebRequest -Times 3
            Assert-MockCalled -CommandName Expand-Archive -Times 3
            Assert-MockCalled -CommandName Get-ChildItem -Times 3
            Assert-MockCalled -CommandName Import-Module -Times 3
        }
    }    

    Context "Invalid URL provided" {
        It "Fails all attempts with an invalid URL" {
            Mock Invoke-WebRequest { throw "Invalid URL" } -ParameterFilter { $Uri -like 'NOT-A-REAL-URL' }

            { 
                DownloadYamlModule -YamlModuleUrl 'NOT-A-REAL-URL' -RetryCount 3 -RetryInterval 2 -WorkingDirectory "$TestDrive" 
            } | Should -Throw "The provided URL is not a valid absolute URI: NOT-A-REAL-URL"

            Assert-MockCalled -CommandName Invoke-WebRequest -Times 0
        }
    }

    Context "Exceeding Retry Count" {
        It "Stops after the specified number of retries" {
            Mock Invoke-WebRequest { throw "Download failed" } -ParameterFilter { $Uri -like 'https://example.com/powershell-yaml.zip' }

            { 
                DownloadYamlModule -YamlModuleUrl 'https://example.com/powershell-yaml.zip' -RetryCount 2 -RetryInterval 2 -WorkingDirectory "$TestDrive" 
            } | Should -Throw "All retry attempts failed."

            Assert-MockCalled -CommandName Invoke-WebRequest -Times 2
        }
    }

    Context "Retry Interval Effectiveness" {
        It "Waits the specified interval between retries" {
            Mock Invoke-WebRequest { throw "Download failed" }
            Mock Start-Sleep { Write-Host "Mocked Start-Sleep called" }
    
            { 
                DownloadYamlModule -YamlModuleUrl 'https://example.com/powershell-yaml.zip' -RetryCount 2 -RetryInterval 2 -WorkingDirectory "$TestDrive" 
            } | Should -Throw "All retry attempts failed."
    
            Assert-MockCalled -CommandName Start-Sleep -Times 1
        }
    }
}
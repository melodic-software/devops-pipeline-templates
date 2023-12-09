Describe "AppendIgnoreShaConfig Function Tests" {

    BeforeAll {
        . "$PSScriptRoot/../../../../../src/templates/create-nuget-package/powershell/configure-git-version/functions/append-ignore-sha-config.ps1"
    }

    Mock Get-ChildItem { 
        return @(
            [System.IO.FileInfo]"$TestDrive/src/GitVersionIgnoreSHA.yml",
            [System.IO.FileInfo]"$TestDrive/template/src/GitVersionIgnoreSHA.yml"
        )
    } -ParameterFilter { $Path -like "*GitVersionIgnoreSHA.yml" }

    Mock Get-Content { "ignore-sha-config" } -ParameterFilter { $Path -like "*src/GitVersionIgnoreSHA.yml" }

    Context "When GitVersionIgnoreSHA.yml files are found" {
        It "Appends content from the first GitVersionIgnoreSHA.yml file" {
            Mock Get-ChildItem { return [System.IO.FileInfo]"$TestDrive/src/GitVersionIgnoreSHA.yml" }
            Mock Get-Content { "ignore-sha-config" }
            Mock Add-Content {}
        
            AppendIgnoreShaConfig -ConfigDirectory "$TestDrive" -GitVersionConfigPath "$TestDrive/GitVersion.yml"
        
            Assert-MockCalled -CommandName Add-Content -Exactly 1
        }
    }

    Context "When no suitable GitVersionIgnoreSHA.yml files are found" {
        It "Does not append any content to GitVersion.yml" {
            Mock Get-ChildItem { @() }
            Mock Add-Content {}

            AppendIgnoreShaConfig -ConfigDirectory "$TestDrive" -GitVersionConfigPath "$TestDrive/GitVersion.yml"

            Assert-MockCalled -CommandName Add-Content -Times 0
        }
    }
}

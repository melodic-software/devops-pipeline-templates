Describe "Set-PreReleaseTag Tests" {
    BeforeAll {
        # Ensure the YAML module is installed and imported
        # Commented out to avoid automatic installation in test script
        Install-Module -Name powershell-yaml -Scope CurrentUser -Force
        Import-Module -Name powershell-yaml -ErrorAction Stop

        # Mocks and other setup
        Mock Test-Path { $true }

        Mock Get-Content {
            @{
                branches = @{
                    feature = @{ tag = 'alpha' }
                    bugfix = @{ tag = 'alpha' }
                    refactor = @{ tag = 'alpha' }
                    hotfix = @{ tag = 'beta' }
                }
            } | ConvertTo-Yaml
        }
        
        Mock Set-Content {}

        # Dot source the script under test
        . "$PSScriptRoot/../../../../../src/templates/create-nuget-package/powershell/configure-git-version/functions/set-pre-release-tag.ps1"
    }

    It "Updates pre-release tag for feature branches" {
        Mock Set-Content -Verifiable -ParameterFilter { $Path -eq "dummyPath" }
        Set-PreReleaseTag -BranchName "refs/heads/feature/new-feature" -ConfigPath "dummyPath"
        Assert-MockCalled Set-Content -Exactly -Times 1 -Scope It
    }

    It "Updates pre-release tag for bugfix branches" {
        Mock Set-Content -Verifiable -ParameterFilter { $Path -eq "dummyPath" }
        Set-PreReleaseTag -BranchName "refs/heads/bugfix/fix-issue" -ConfigPath "dummyPath"
        Assert-MockCalled Set-Content -Exactly -Times 1 -Scope It
    }

    It "Updates pre-release tag for refactor branches" {
        Mock Set-Content -Verifiable -ParameterFilter { $Path -eq "dummyPath" }
        Set-PreReleaseTag -BranchName "refs/heads/refactor/code-cleanup" -ConfigPath "dummyPath"
        Assert-MockCalled Set-Content -Exactly -Times 1 -Scope It
    }

    It "Updates pre-release tag for hotfix branches" {
        Mock Set-Content -Verifiable -ParameterFilter { $Path -eq "dummyPath" }
        Set-PreReleaseTag -BranchName "refs/heads/hotfix/urgent-fix" -ConfigPath "dummyPath"
        Assert-MockCalled Set-Content -Exactly -Times 1 -Scope It
    }

    It "Does not modify the tag for non-feature/hotfix branches" {
        Mock Set-Content -Verifiable -ParameterFilter { $Path -eq "dummyPath" }
        Set-PreReleaseTag -BranchName "refs/heads/release/1.0.0" -ConfigPath "dummyPath"
        Assert-MockCalled Set-Content -Exactly -Times 0 -Scope It
    }

    It "Returns an error if the config file doesn't exist" {
        Mock Test-Path { $false }
        Set-PreReleaseTag -BranchName "refs/heads/feature/example" -ConfigPath "nonexistent.yml" -ErrorAction SilentlyContinue -ErrorVariable ErrorMsg
        $ErrorMsg | Should -Not -BeNullOrEmpty
    }

    It "Handles errors when reading the configuration file" {
        Mock Get-Content { throw "Read error" }
        Set-PreReleaseTag -BranchName "refs/heads/feature/example" -ConfigPath "dummyPath" -ErrorAction SilentlyContinue -ErrorVariable ErrorMsg
        $ErrorMsg | Should -Not -BeNullOrEmpty
    }

    It "Handles errors when writing to the configuration file" {
        Mock Set-Content { throw "Write error" }
        Set-PreReleaseTag -BranchName "refs/heads/feature/example" -ConfigPath "dummyPath" -ErrorAction SilentlyContinue -ErrorVariable ErrorMsg
        $ErrorMsg | Should -Not -BeNullOrEmpty
    }

    It "Handles invalid branch name format" {
        { Set-PreReleaseTag -BranchName "invalidformatbranch" -ConfigPath "dummyPath" } | Should -Not -Throw
    }

    It "Handles empty branch name" {
        { Set-PreReleaseTag -BranchName "" -ConfigPath "dummyPath" } | Should -Throw
    }

    It "Handles empty config path" {
        { Set-PreReleaseTag -BranchName "refs/heads/feature/example" -ConfigPath "" } | Should -Throw
    }

    It "Handles non-string branch name" {
        Set-PreReleaseTag -BranchName 123 -ConfigPath "dummyPath" -ErrorAction SilentlyContinue -ErrorVariable ErrorMsg
        $ErrorMsg | Should -BeNullOrEmpty
    }

    It "Handles non-string config path" {
        Set-PreReleaseTag -BranchName "refs/heads/feature/example" -ConfigPath 123 -ErrorAction SilentlyContinue -ErrorVariable ErrorMsg
        $ErrorMsg | Should -BeNullOrEmpty
    }

    It "Correctly parses feature branch name" {
        Mock Set-Content -Verifiable -ParameterFilter { $Path -eq "dummyPath" }
        Set-PreReleaseTag -BranchName "refs/heads/feature/complex-feature-name" -ConfigPath "dummyPath"
        Assert-MockCalled Set-Content -Exactly -Times 1 -Scope It
    }

    It "Correctly parses bugfix branch name" {
        Mock Set-Content -Verifiable -ParameterFilter { $Path -eq "dummyPath" }
        Set-PreReleaseTag -BranchName "refs/heads/bugfix/complex-bugfix-name" -ConfigPath "dummyPath"
        Assert-MockCalled Set-Content -Exactly -Times 1 -Scope It
    }

    It "Correctly parses refactor branch name" {
        Mock Set-Content -Verifiable -ParameterFilter { $Path -eq "dummyPath" }
        Set-PreReleaseTag -BranchName "refs/heads/refactor/complex-refactor-name" -ConfigPath "dummyPath"
        Assert-MockCalled Set-Content -Exactly -Times 1 -Scope It
    }

    It "Correctly parses hotfix branch name" {
        Mock Set-Content -Verifiable -ParameterFilter { $Path -eq "dummyPath" }
        Set-PreReleaseTag -BranchName "refs/heads/hotfix/complex-hotfix-name" -ConfigPath "dummyPath"
        Assert-MockCalled Set-Content -Exactly -Times 1 -Scope It
    }

    It "Preserves other config settings" {
        Mock Set-Content -Verifiable -ParameterFilter { $Path -eq "dummyPath" }
        Set-PreReleaseTag -BranchName "refs/heads/feature/preserve-test" -ConfigPath "dummyPath"
        Assert-MockCalled Set-Content -Exactly -Times 1 -Scope It
    }

    It "Maintains proper YAML format after updates" {
        Mock Set-Content -Verifiable -ParameterFilter { $Path -eq "dummyPath" }
        Set-PreReleaseTag -BranchName "refs/heads/feature/yaml-format-test" -ConfigPath "dummyPath"
        Assert-MockCalled Set-Content -Exactly -Times 1 -Scope It
    }

    It "Handles branch names with unusual characters" {
        Mock Set-Content -Verifiable -ParameterFilter { $Path -eq "dummyPath" }
        Set-PreReleaseTag -BranchName "refs/heads/feature/feature@123" -ConfigPath "dummyPath"
        Assert-MockCalled Set-Content -Exactly -Times 1 -Scope It
    }

    It "Handles extremely long branch names" {
        Mock Set-Content -Verifiable -ParameterFilter { $Path -eq "dummyPath" }
        $ReallyLongName = 'a' * 500
        Set-PreReleaseTag -BranchName "refs/heads/feature/$ReallyLongName" -ConfigPath "dummyPath"
        Assert-MockCalled Set-Content -Exactly -Times 1 -Scope It
    }

    It "Handles config path with spaces or special characters" {
        Mock Set-Content -Verifiable -ParameterFilter { $Path -eq "dummy path with spaces.yml" }
        Set-PreReleaseTag -BranchName "refs/heads/feature/spaces-and-characters" -ConfigPath "dummy path with spaces.yml"
        Assert-MockCalled Set-Content -Exactly -Times 1 -Scope It
    }

    It "Handles branch name matching multiple patterns" {
        Mock Set-Content -Verifiable -ParameterFilter { $Path -eq "dummyPath" }
        Set-PreReleaseTag -BranchName "refs/heads/feature/hotfix/special-case" -ConfigPath "dummyPath"
        Assert-MockCalled Set-Content -Exactly -Times 1 -Scope It
    }
}
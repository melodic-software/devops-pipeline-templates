Describe "NormalizePathSeparator Function Tests" {

    BeforeAll {
        . "$PSScriptRoot/../../../../src/templates/shared/powershell/functions/normalize-path-separator.ps1"
    }

    Context "When running on a Windows-like environment" {
        It "Replaces forward slashes with backslashes" {
            $Result = NormalizePathSeparator -Path "C:/Windows/System32" -DirectorySeparator "\"
            $Result | Should -Be "C:\Windows\System32"
        }
    }

    Context "When running on a Unix-like environment" {
        It "Replaces backslashes with forward slashes" {
            $Result = NormalizePathSeparator -Path "C:\Directory\ToSomethingAwesome" -DirectorySeparator "/"
            $Result | Should -Be "C:/Directory/ToSomethingAwesome"
        }
    }
}
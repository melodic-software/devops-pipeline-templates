Describe "LogVariable Function Tests" {

    BeforeAll {
        . "$PSScriptRoot/../../../../src/templates/shared/powershell/functions/log-predefined-variables.ps1"
    }

    Context "Environment variable is set and has a value" {
        It "Logs the value of the environment variable" {
            Mock Test-Path { $true }
            Mock Get-Content { "Value" }

            LogVariable -VariableName "TEST_VAR" -InformationVariable InfoVar
            $InfoVar[0].MessageData.ToString().Trim() | Should -Match "TEST_VAR: Value"
        }
    }

    Context "Environment variable is set but empty" {
        It "Logs that the environment variable is set but empty" {
            Mock Test-Path { $true }
            Mock Get-Content { "" }

            LogVariable -VariableName "TEST_VAR" -InformationVariable InfoVar
            $InfoVar[0].MessageData.ToString().Trim() | Should -Match "TEST_VAR is set but empty."
        }
    }

    Context "Environment variable is not set" {
        It "Logs that the environment variable is not set" {
            Mock Test-Path { $false }

            LogVariable -VariableName "TEST_VAR" -InformationVariable InfoVar
            $InfoVar[0].MessageData.ToString().Trim() | Should -Match "TEST_VAR is not set."
        }
    }
}

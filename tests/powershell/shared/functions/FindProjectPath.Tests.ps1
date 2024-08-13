Describe "Find-ProjectPath Function Tests" {

    BeforeAll {
        . "$PSScriptRoot/../../../../src/templates/shared/powershell/functions/FindProjectPath.ps1"
    }

    Context "When a specific .csproj file is given" {
        It "Returns the full path of the .csproj file" {
            Mock Get-ChildItem { [PSCustomObject]@{ FullName = "C:/demo-package/Enterprise.Demo.csproj" } }

            $Result = Find-ProjectPath -Path "demo-package/Enterprise.Demo.csproj"
            $Result | Should -Be "C:/demo-package/Enterprise.Demo.csproj"
        }
    }

    Context "When a wildcard pattern for .csproj files is given" {
        It "Returns the base directory containing .csproj files" {
            Mock Get-ChildItem { [PSCustomObject]@{ FullName = "C:/demo-package/AnyProject.csproj" } }

            $Result = Find-ProjectPath -Path "demo-package/*.csproj"
            $Result | Should -Be "demo-package"
        }
    }

    Context "When a directory path is given" {
        It "Returns the normalized input path" {
            $Result = Find-ProjectPath -Path "demo-package/"
            $Result | Should -Be "demo-package/"
        }
    }

    Context "When a specific .csproj file within nested directories is given" {
        It "Returns the full path of the .csproj file" {
            Mock Get-ChildItem { [PSCustomObject]@{ FullName = "C:/demo-package/subdir/Enterprise.Demo.csproj" } }

            $Result = Find-ProjectPath -Path "demo-package/**/Enterprise.Demo.csproj"
            $Result | Should -Be "C:/demo-package/subdir/Enterprise.Demo.csproj"
        }
    }

    Context "When a non-existent .csproj file is given" {
        It "Throws an exception" {
            Mock Get-ChildItem { $null }

            { Find-ProjectPath -Path "demo-package/NonExistent.csproj" } | Should -Throw
        }
    }
}
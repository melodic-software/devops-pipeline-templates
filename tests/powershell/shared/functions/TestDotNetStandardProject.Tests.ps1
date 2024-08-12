Describe "Test-DotNetStandardProject Tests" {
    
    BeforeAll {
        . "$PSScriptRoot/../../../../src/templates/shared/powershell/functions/TestDotNetStandardProject.ps1"
    }

    Context "When content is not a .csproj file" {
        It "Returns false" {
            $NonCsprojContent = '<NotAProject></NotAProject>'
            $Result = Test-DotNetStandardProject -ProjectContent $NonCsprojContent
            $Result | Should -Be $false
        }
    }

    Context "When content is a .NET Standard project" {
        It "Returns true for single target framework" {

            $ValidDotNetStandardContent = @"
<Project>
    <PropertyGroup>
        <TargetFramework>netstandard2.0</TargetFramework>
    </PropertyGroup>
</Project>
"@

            $Result = Test-DotNetStandardProject -ProjectContent $ValidDotNetStandardContent
            $Result | Should -Be $true
        }
        It "Returns true for multiple target frameworks" {

            $ValidDotNetStandardMultiTargetContent = @"
<Project>
    <PropertyGroup>
        <TargetFrameworks>netstandard2.0;netcoreapp3.1</TargetFrameworks>
    </PropertyGroup>
</Project>
"@

            $Result = Test-DotNetStandardProject -ProjectContent $ValidDotNetStandardMultiTargetContent
            $Result | Should -Be $true
        }
    }

    Context "When content is not a .NET Standard project" {
        It "Returns false for single target framework" {

            $ValidNonDotNetStandardContent = @"
<Project>
    <PropertyGroup>
        <TargetFramework>netcoreapp3.1</TargetFramework>
    </PropertyGroup>
</Project>
"@
            $Result = Test-DotNetStandardProject -ProjectContent $ValidNonDotNetStandardContent
            $Result | Should -Be $false
        }
        It "Returns false for multiple target frameworks" {

            $ValidNonDotNetStandardMultiTargetContent = @"
<Project>
    <PropertyGroup>
        <TargetFrameworks>netcoreapp3.1;net8.0</TargetFrameworks>
    </PropertyGroup>
</Project>
"@

            $Result = Test-DotNetStandardProject -ProjectContent $ValidNonDotNetStandardMultiTargetContent
            $Result | Should -Be $false
        }
    }

    Context "When XML parsing fails" {
        It "Returns true based on regex matching" {
            $InvalidXmlContent = 'Invalid XML <Project><TargetFramework>netstandard2.0</TargetFramework></Project>'
            $Result = Test-DotNetStandardProject -ProjectContent $InvalidXmlContent
            $Result | Should -Be $true
        }
    }
}

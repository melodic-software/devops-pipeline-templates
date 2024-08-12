Describe "Test-DotNetFrameworkProject Tests" {
    
    BeforeAll {
        . "$PSScriptRoot/../../../../src/templates/shared/powershell/functions/TestDotNetFrameworkProject.ps1"
    }

    Context "When content does not contain a Project tag" {
        It "Returns false" {
            $NonProjectContent = '<NotAProject></NotAProject>'
            $Result = Test-DotNetFrameworkProject -ProjectContent $NonProjectContent
            $Result | Should -Be $false
        }
    }

    Context "When content is a .NET Framework project" {
        It "Returns true" {

            $DotNetFrameworkProjectContent = @"
<Project>
    <PropertyGroup>
        <TargetFrameworkVersion>v4.7.2</TargetFrameworkVersion>
    </PropertyGroup>
</Project>
"@
            $Result = Test-DotNetFrameworkProject -ProjectContent $DotNetFrameworkProjectContent
            $Result | Should -Be $true
        }
    }

    Context "When content is an SDK-style project" {
        It "Returns false" {
            $SdkStyleProjectContent = '<Project Sdk="Microsoft.NET.Sdk"></Project>'
            $Result = Test-DotNetFrameworkProject -ProjectContent $SdkStyleProjectContent
            $Result | Should -Be $false
        }
    }

    Context "When XML parsing fails and content is a .NET Framework project by regex" {
        It "Returns true" {
            $InvalidXmlDotNetFrameworkContent = 'Invalid XML <Project><TargetFrameworkVersion>v4.5</TargetFrameworkVersion></Project>'
            $Result = Test-DotNetFrameworkProject -ProjectContent $InvalidXmlDotNetFrameworkContent
            $Result | Should -Be $true
        }
    }

    Context "When XML parsing fails and content is not a .NET Framework project by regex" {
        It "Returns false" {
            $InvalidXmlSdkStyleContent = 'Invalid XML <Project Sdk="Microsoft.NET.Sdk"></Project>'
            $Result = Test-DotNetFrameworkProject -ProjectContent $InvalidXmlSdkStyleContent
            $Result | Should -Be $false
        }
    }

    Context "When content has no TargetFrameworkVersion tag" {
        It "Returns false" {
            $NoTargetFrameworkVersionContent = @"
<Project>
    <PropertyGroup>
        <OutputType>Exe</OutputType>
    </PropertyGroup>
</Project>
"@
            $Result = Test-DotNetFrameworkProject -ProjectContent $NoTargetFrameworkVersionContent
            $Result | Should -Be $false
        }
    }
}
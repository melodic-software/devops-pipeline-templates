Describe "IsDotNetFrameworkProject Tests" {
    
    BeforeAll {
        . "$PSScriptRoot/../../../../src/templates/shared/powershell/functions/is-dotnet-framework-project.ps1"
    }

    Context "When content does not contain a Project tag" {
        It "Returns false" {
            $NonProjectContent = '<NotAProject></NotAProject>'
            $Result = IsDotNetFrameworkProject -ProjectContent $NonProjectContent
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
            $Result = IsDotNetFrameworkProject -ProjectContent $DotNetFrameworkProjectContent
            $Result | Should -Be $true
        }
    }

    Context "When content is an SDK-style project" {
        It "Returns false" {
            $SdkStyleProjectContent = '<Project Sdk="Microsoft.NET.Sdk"></Project>'
            $Result = IsDotNetFrameworkProject -ProjectContent $SdkStyleProjectContent
            $Result | Should -Be $false
        }
    }

    Context "When XML parsing fails and content is a .NET Framework project by regex" {
        It "Returns true" {
            $InvalidXmlDotNetFrameworkContent = 'Invalid XML <Project><TargetFrameworkVersion>v4.5</TargetFrameworkVersion></Project>'
            $Result = IsDotNetFrameworkProject -ProjectContent $InvalidXmlDotNetFrameworkContent
            $Result | Should -Be $true
        }
    }

    Context "When XML parsing fails and content is not a .NET Framework project by regex" {
        It "Returns false" {
            $InvalidXmlSdkStyleContent = 'Invalid XML <Project Sdk="Microsoft.NET.Sdk"></Project>'
            $Result = IsDotNetFrameworkProject -ProjectContent $InvalidXmlSdkStyleContent
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
            $Result = IsDotNetFrameworkProject -ProjectContent $NoTargetFrameworkVersionContent
            $Result | Should -Be $false
        }
    }
}
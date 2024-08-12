Describe "NuGet Package ID Extraction and Processing Tests" {

    BeforeAll {
        . "$PSScriptRoot/../../../../src/templates/create-nuget-package/powershell/set-nuget-package-id/SetNuGetPackageId.ps1"
        
        $CsprojWithoutPackageId = @'
<Project>
    <PropertyGroup>
    </PropertyGroup>
</Project>
'@
    }

    Context "PackageId Does Not Exist In .CSPROJ" {
        It "Correctly adds the provided prefix" {
            Mock Get-ChildItem { return @([IO.FileInfo]::new("TestProject.csproj")) }
            Mock Get-Content { return $CsprojWithoutPackageId }

            $NugetPackageId = Set-NuGetPackageId -SourceDirectory "src" -ProjectName "TestProject" -PackagePrefix "Company"

            $NugetPackageId | Should -Be "Company.TestProject"
        }

        It "Does not duplicate prefix" {
            Mock Get-ChildItem { return @([IO.FileInfo]::new("TestProject.csproj")) }
            Mock Get-Content { return $CsprojWithoutPackageId }

            $NugetPackageId = Set-NuGetPackageId -SourceDirectory "src" -ProjectName "Company.TestProject" -PackagePrefix "Company"

            $NugetPackageId | Should -Be "Company.TestProject"
        }
    }

    Context "When PackageId Exists In .CSPROJ" {
        It "Correctly adds the provided prefix" {
            $CsprojWithPackageId = @'
<Project>
    <PropertyGroup>
        <PackageId>TestPackageId</PackageId>
    </PropertyGroup>
</Project>
'@

            Mock Get-ChildItem { return @([IO.FileInfo]::new("TestProject.csproj")) }
            Mock Get-Content { return $CsprojWithPackageId }

            $NugetPackageId = Set-NuGetPackageId -SourceDirectory "src" -ProjectName "TestProject" -PackagePrefix "Company"

            $NugetPackageId | Should -Be "Company.TestPackageId"
        }

        It "Does not duplicate prefix" {
            $CsprojWithPrefixedPackageId = @'
<Project>
    <PropertyGroup>
        <PackageId>Company.TestPackageId</PackageId>
    </PropertyGroup>
</Project>
'@

            Mock Get-ChildItem { return @([IO.FileInfo]::new("TestProject.csproj")) }
            Mock Get-Content { return $CsprojWithPrefixedPackageId }

            $NugetPackageId = Set-NuGetPackageId -SourceDirectory "src" -ProjectName "TestProject" -PackagePrefix "Company"

            $NugetPackageId | Should -Be "Company.TestPackageId"
        }
    }
}